package com.foodscan.backend.service;

import com.foodscan.backend.awareness.IngredientAwarenessService;
import com.foodscan.backend.dto.ConfirmScanRequest;
import com.foodscan.backend.dto.FoodCandidateDto;
import com.foodscan.backend.dto.FoodDto;
import com.foodscan.backend.dto.FoodIntelligenceDto;
import com.foodscan.backend.dto.NutritionRequest;
import com.foodscan.backend.dto.NutritionResponse;
import com.foodscan.backend.dto.ScanResponse;
import com.foodscan.backend.entity.FoodScan;
import com.foodscan.backend.entity.UserAccount;
import com.foodscan.backend.exception.BadRequestException;
import com.foodscan.backend.exception.NotFoundException;
import com.foodscan.backend.identify.FoodIdentifier;
import com.foodscan.backend.intelligence.FoodIntelligenceService;
import com.foodscan.backend.nutrition.FoodNutritionCache;
import com.foodscan.backend.nutrition.MacroProfile;
import com.foodscan.backend.nutrition.NutritionEstimator;
import com.foodscan.backend.repository.FoodScanRepository;
import com.foodscan.backend.repository.UserAccountRepository;
import com.foodscan.backend.security.CurrentUserService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.UUID;

@Service
public class ScanService {

    private static final String PENDING_NAME = "Unidentified";

    private final FoodIdentifier foodIdentifier;
    private final FoodScanRepository foodScanRepository;
    private final CurrentUserService currentUserService;
    private final UserAccountRepository userAccountRepository;
    private final NutritionEstimator nutritionEstimator;
    private final IngredientAwarenessService ingredientAwarenessService;
    private final FoodIntelligenceService foodIntelligenceService;
    private final FoodNutritionCache foodNutritionCache;

    public ScanService(
            FoodIdentifier foodIdentifier,
            FoodScanRepository foodScanRepository,
            CurrentUserService currentUserService,
            UserAccountRepository userAccountRepository,
            NutritionEstimator nutritionEstimator,
            IngredientAwarenessService ingredientAwarenessService,
            FoodIntelligenceService foodIntelligenceService,
            FoodNutritionCache foodNutritionCache
    ) {
        this.foodIdentifier = foodIdentifier;
        this.foodScanRepository = foodScanRepository;
        this.currentUserService = currentUserService;
        this.userAccountRepository = userAccountRepository;
        this.nutritionEstimator = nutritionEstimator;
        this.ingredientAwarenessService = ingredientAwarenessService;
        this.foodIntelligenceService = foodIntelligenceService;
        this.foodNutritionCache = foodNutritionCache;
    }

    @Transactional
    public ScanResponse createScan(MultipartFile image) {
        if (image == null || image.isEmpty()) {
            throw new BadRequestException("Image file is required");
        }

        String contentType = image.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new BadRequestException("Uploaded file must be an image");
        }

        UUID userId = currentUserService.requireUserId();
        String mode = foodIdentifier.mode();

        // Catalog mode: photo is accepted for the session; user must type to match the DB.
        if ("catalog".equalsIgnoreCase(mode)) {
            FoodScan scan = new FoodScan();
            scan.setUserId(userId);
            scan.setFoodName(PENDING_NAME);
            scan.setConfidence(0.0);
            foodScanRepository.save(scan);
            return new ScanResponse(scan.getId(), null, List.of(), mode, true);
        }

        List<FoodIdentifier.FoodCandidate> identified = foodIdentifier.identify(image, null);
        List<FoodCandidateDto> candidates = toDtos(identified);

        FoodScan scan = new FoodScan();
        scan.setUserId(userId);
        boolean needsPick = candidates.isEmpty()
                || candidates.size() > 1
                || candidates.getFirst().confidence() < 0.85;
        if (candidates.isEmpty()) {
            scan.setFoodName(PENDING_NAME);
            scan.setConfidence(0.0);
        } else {
            scan.setFoodName(candidates.getFirst().foodName());
            scan.setConfidence(candidates.getFirst().confidence());
        }
        foodScanRepository.save(scan);

        FoodDto food = PENDING_NAME.equals(scan.getFoodName())
                ? null
                : toFoodDto(scan.getFoodName(), scan.getConfidence());
        return new ScanResponse(scan.getId(), food, candidates, mode, needsPick || food == null);
    }

    @Transactional(readOnly = true)
    public List<FoodCandidateDto> matchCandidates(String query, int limit) {
        return toDtos(foodIdentifier.identify(null, query).stream()
                .limit(Math.max(1, Math.min(limit, 20)))
                .toList());
    }

    /** Catalog-only ranked match (always available for the pick UI). */
    @Transactional(readOnly = true)
    public List<FoodCandidateDto> catalogMatch(String query, int limit) {
        return foodNutritionCache.rankMatch(query, limit).stream()
                .map(r -> new FoodCandidateDto(r.name(), r.score(), r.category()))
                .toList();
    }

    @Transactional
    public ScanResponse confirmScan(String scanId, ConfirmScanRequest request) {
        UUID userId = currentUserService.requireUserId();
        FoodScan scan = foodScanRepository.findByIdAndUserId(scanId, userId)
                .orElseThrow(() -> new NotFoundException("Scan not found: " + scanId));

        String foodName = request.foodName().trim();
        if (foodName.isBlank() || PENDING_NAME.equalsIgnoreCase(foodName)) {
            throw new BadRequestException("Pick a food from the catalog");
        }
        if (foodNutritionCache.find(foodName).isEmpty()) {
            throw new BadRequestException("Unknown food. Pick a catalog match or search again.");
        }

        double confidence = request.confidence() == null
                ? foodNutritionCache.rankMatch(foodName, 1).stream()
                .findFirst()
                .map(FoodNutritionCache.RankedMatch::score)
                .orElse(1.0)
                : clamp01(request.confidence());

        scan.setFoodName(foodName);
        scan.setConfidence(confidence);
        foodScanRepository.save(scan);

        FoodDto food = toFoodDto(foodName, confidence);
        return new ScanResponse(
                scan.getId(),
                food,
                List.of(new FoodCandidateDto(foodName, confidence,
                        foodNutritionCache.findEntry(foodName)
                                .map(FoodNutritionCache.FoodCatalogEntry::category)
                                .orElse("GENERAL"))),
                foodIdentifier.mode(),
                false
        );
    }

    @Transactional(readOnly = true)
    public NutritionResponse nutritionFor(String scanId, NutritionRequest request) {
        UUID userId = currentUserService.requireUserId();
        FoodScan scan = foodScanRepository.findByIdAndUserId(scanId, userId)
                .orElseThrow(() -> new NotFoundException("Scan not found: " + scanId));

        if (PENDING_NAME.equalsIgnoreCase(scan.getFoodName())) {
            throw new BadRequestException("Confirm the dish before estimating nutrition");
        }

        MacroProfile profile = nutritionEstimator.estimateFor(scan.getFoodName());
        double factor = request.portionGrams() / 100.0;

        int calories = (int) Math.round(profile.caloriesPer100g() * factor);
        double protein = round1(profile.proteinPer100g() * factor);
        double carbs = round1(profile.carbsPer100g() * factor);
        double fat = round1(profile.fatPer100g() * factor);
        double fibre = round1(profile.fibrePer100g() * factor);
        double sugar = round1(profile.sugarPer100g() * factor);
        double sodium = round1(profile.sodiumMgPer100g() * factor);

        String goal = userAccountRepository.findById(userId)
                .map(UserAccount::getGoal)
                .orElse("LOSE_WEIGHT");

        FoodIntelligenceDto intelligence = foodIntelligenceService.forMeal(
                scan.getFoodName(),
                calories,
                protein,
                carbs,
                fat,
                fibre,
                sugar,
                sodium,
                request.portionGrams(),
                goal
        );

        return new NutritionResponse(
                scan.getFoodName(),
                request.portionGrams(),
                calories,
                protein,
                carbs,
                fat,
                fibre,
                sugar,
                sodium,
                true,
                intelligence
        );
    }

    private FoodDto toFoodDto(String foodName, double confidence) {
        return new FoodDto(
                foodName,
                confidence,
                ingredientAwarenessService.forFoodName(foodName)
        );
    }

    private static List<FoodCandidateDto> toDtos(List<FoodIdentifier.FoodCandidate> identified) {
        return identified.stream()
                .map(c -> new FoodCandidateDto(c.foodName(), c.confidence(), c.category()))
                .toList();
    }

    private static double clamp01(double value) {
        return Math.max(0, Math.min(1, value));
    }

    private static double round1(double value) {
        return Math.round(value * 10.0) / 10.0;
    }
}
