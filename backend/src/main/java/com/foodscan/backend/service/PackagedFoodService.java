package com.foodscan.backend.service;

import com.foodscan.backend.client.AiServiceClient;
import com.foodscan.backend.dto.AiLabelReadResponse;
import com.foodscan.backend.dto.PackagedFoodResponse;
import com.foodscan.backend.exception.BadRequestException;
import com.foodscan.backend.exception.NotFoundException;
import com.foodscan.backend.packaged.OpenFoodFactsClient;
import com.foodscan.backend.packaged.OpenFoodFactsProduct;
import com.foodscan.backend.packaged.PackagedFoodRiskAnalyzer;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class PackagedFoodService {

    private static final String LABEL_DISCLAIMER =
            "Based on an ingredients-label photo read by AI, then rule checks — "
                    + "not a lab test or medical advice. OCR may misread text.";

    private final OpenFoodFactsClient openFoodFactsClient;
    private final PackagedFoodRiskAnalyzer riskAnalyzer;
    private final AiServiceClient aiServiceClient;

    public PackagedFoodService(
            OpenFoodFactsClient openFoodFactsClient,
            PackagedFoodRiskAnalyzer riskAnalyzer,
            AiServiceClient aiServiceClient
    ) {
        this.openFoodFactsClient = openFoodFactsClient;
        this.riskAnalyzer = riskAnalyzer;
        this.aiServiceClient = aiServiceClient;
    }

    public PackagedFoodResponse analyzeBarcode(String barcode) {
        String cleaned = barcode == null ? "" : barcode.trim().replaceAll("\\s+", "");
        if (!cleaned.matches("\\d{8,14}")) {
            throw new BadRequestException("Enter a valid barcode (8–14 digits)");
        }

        OpenFoodFactsProduct product = openFoodFactsClient.fetchByBarcode(cleaned);
        if (!product.found()) {
            throw new NotFoundException("Product not found for barcode " + cleaned);
        }

        return toResponse(product, PackagedFoodRiskAnalyzer.DISCLAIMER);
    }

    public PackagedFoodResponse analyzeLabelPhoto(MultipartFile image, String barcodeHint) {
        if (image == null || image.isEmpty()) {
            throw new BadRequestException("Upload a clear photo of the ingredients label");
        }

        AiLabelReadResponse label = aiServiceClient.readLabel(image);
        String barcode = barcodeHint == null ? "" : barcodeHint.trim().replaceAll("\\D", "");
        if (!barcode.matches("\\d{8,14}")) {
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

        return toResponse(product, LABEL_DISCLAIMER);
    }

    private PackagedFoodResponse toResponse(OpenFoodFactsProduct product, String disclaimer) {
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
                true
        );
    }

    private static String blankTo(String value, String fallback) {
        return value == null || value.isBlank() ? fallback : value.trim();
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
