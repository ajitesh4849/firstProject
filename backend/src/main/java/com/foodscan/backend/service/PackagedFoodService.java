package com.foodscan.backend.service;

import com.foodscan.backend.client.AiServiceClient;
import com.foodscan.backend.dto.AiLabelReadResponse;
import com.foodscan.backend.dto.PackagedFoodResponse;
import com.foodscan.backend.dto.SavePackagedSeedRequest;
import com.foodscan.backend.entity.PackagedProductSeed;
import com.foodscan.backend.exception.BadRequestException;
import com.foodscan.backend.exception.NotFoundException;
import com.foodscan.backend.packaged.OpenFoodFactsClient;
import com.foodscan.backend.packaged.OpenFoodFactsProduct;
import com.foodscan.backend.packaged.PackagedFoodRiskAnalyzer;
import com.foodscan.backend.repository.PackagedProductSeedRepository;
import com.foodscan.backend.security.CurrentUserService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.UUID;

@Service
public class PackagedFoodService {

    public static final String SOURCE_SEED = "SEED";
    public static final String SOURCE_OFF = "OPEN_FOOD_FACTS";
    public static final String SOURCE_LABEL = "LABEL_PHOTO";

    private static final String SEED_DISCLAIMER =
            "Based on FoodScan’s local product catalog + ingredient rules — "
                    + "not a lab test or medical advice.";

    private static final String LABEL_DISCLAIMER =
            "Based on an ingredients-label photo read by AI, then rule checks — "
                    + "not a lab test or medical advice. OCR may misread text. "
                    + "You can save this product so the next barcode scan finds it faster.";

    private final OpenFoodFactsClient openFoodFactsClient;
    private final PackagedFoodRiskAnalyzer riskAnalyzer;
    private final AiServiceClient aiServiceClient;
    private final PackagedProductSeedRepository seedRepository;
    private final CurrentUserService currentUserService;

    public PackagedFoodService(
            OpenFoodFactsClient openFoodFactsClient,
            PackagedFoodRiskAnalyzer riskAnalyzer,
            AiServiceClient aiServiceClient,
            PackagedProductSeedRepository seedRepository,
            CurrentUserService currentUserService
    ) {
        this.openFoodFactsClient = openFoodFactsClient;
        this.riskAnalyzer = riskAnalyzer;
        this.aiServiceClient = aiServiceClient;
        this.seedRepository = seedRepository;
        this.currentUserService = currentUserService;
    }

    public PackagedFoodResponse analyzeBarcode(String barcode) {
        String cleaned = cleanBarcode(barcode);
        if (!isValidBarcode(cleaned)) {
            throw new BadRequestException("Enter a valid barcode (8–14 digits)");
        }

        // 1) Local seed (fast indexed Postgres lookup — does not slow the app)
        OpenFoodFactsProduct fromSeed = seedRepository.findByBarcode(cleaned)
                .map(this::toProduct)
                .orElse(null);
        if (fromSeed != null) {
            return toResponse(fromSeed, SEED_DISCLAIMER, SOURCE_SEED, false);
        }

        // 2) Open Food Facts (network)
        OpenFoodFactsProduct product = openFoodFactsClient.fetchByBarcode(cleaned);
        if (!product.found()) {
            throw new NotFoundException("Product not found for barcode " + cleaned);
        }

        return toResponse(product, PackagedFoodRiskAnalyzer.DISCLAIMER, SOURCE_OFF, false);
    }

    public PackagedFoodResponse analyzeLabelPhoto(MultipartFile image, String barcodeHint) {
        if (image == null || image.isEmpty()) {
            throw new BadRequestException("Upload a clear photo of the ingredients label");
        }

        AiLabelReadResponse label = aiServiceClient.readLabel(image);
        String barcode = cleanBarcode(barcodeHint);
        boolean canSave = isValidBarcode(barcode);
        if (!canSave) {
            barcode = "label-photo";
        }

        OpenFoodFactsProduct product = new OpenFoodFactsProduct(
                barcode,
                blankTo(label.productName(), "Unknown product"),
                blankToNull(label.brand()),
                null,
                label.ingredientsText().trim(),
                "",
                null,
                null,
                null,
                true
        );

        return toResponse(product, LABEL_DISCLAIMER, SOURCE_LABEL, canSave);
    }

    @Transactional
    public PackagedFoodResponse saveToCatalog(SavePackagedSeedRequest request) {
        String barcode = cleanBarcode(request.barcode());
        if (!isValidBarcode(barcode)) {
            throw new BadRequestException("Enter a valid barcode (8–14 digits)");
        }
        String ingredients = blankTo(request.ingredientsText(), "");
        if (ingredients.isBlank()) {
            throw new BadRequestException("Ingredients text is required to save the product");
        }

        UUID userId = currentUserService.requireUserId();
        PackagedProductSeed seed = seedRepository.findByBarcode(barcode).orElseGet(PackagedProductSeed::new);
        seed.setBarcode(barcode);
        seed.setProductName(blankTo(request.productName(), "Unknown product"));
        seed.setBrand(blankToNull(request.brand()));
        seed.setQuantity(blankToNull(request.quantity()));
        seed.setIngredientsText(ingredients.trim());
        seed.setSugarPer100g(request.sugarPer100g());
        seed.setSaltPer100g(request.saltPer100g());
        seed.setEnergyKcalPer100g(request.energyKcalPer100g());
        seed.setCreatedByUserId(userId);
        seed.setSource("USER");
        seedRepository.save(seed);

        return toResponse(toProduct(seed), SEED_DISCLAIMER, SOURCE_SEED, false);
    }

    private OpenFoodFactsProduct toProduct(PackagedProductSeed seed) {
        return new OpenFoodFactsProduct(
                seed.getBarcode(),
                seed.getProductName(),
                seed.getBrand(),
                seed.getQuantity(),
                seed.getIngredientsText(),
                seed.getCategories() == null ? "" : seed.getCategories(),
                seed.getSugarPer100g(),
                seed.getSaltPer100g(),
                seed.getEnergyKcalPer100g(),
                true
        );
    }

    private PackagedFoodResponse toResponse(
            OpenFoodFactsProduct product,
            String disclaimer,
            String source,
            boolean canSaveToCatalog
    ) {
        PackagedFoodRiskAnalyzer.AnalysisResult analysis = riskAnalyzer.analyze(product);
        return new PackagedFoodResponse(
                product.barcode(),
                product.productName(),
                product.brand(),
                product.quantity(),
                product.ingredientsText(),
                product.sugarPer100g(),
                product.saltPer100g(),
                product.energyKcalPer100g(),
                analysis.score(),
                analysis.flags().size(),
                analysis.flags(),
                analysis.healthierSwaps(),
                disclaimer,
                true,
                source,
                canSaveToCatalog
        );
    }

    private static String cleanBarcode(String barcode) {
        return barcode == null ? "" : barcode.trim().replaceAll("\\D", "");
    }

    private static boolean isValidBarcode(String barcode) {
        return barcode != null && barcode.matches("\\d{8,14}");
    }

    private static String blankTo(String value, String fallback) {
        return value == null || value.isBlank() ? fallback : value.trim();
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
