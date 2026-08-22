package com.foodscan.backend.service;

import com.foodscan.backend.awareness.IngredientAwarenessService;
import com.foodscan.backend.client.AiServiceClient;
import com.foodscan.backend.dto.AiPredictResponse;
import com.foodscan.backend.dto.FoodDto;
import com.foodscan.backend.dto.FoodIntelligenceDto;
import com.foodscan.backend.dto.NutritionRequest;
import com.foodscan.backend.dto.NutritionResponse;
import com.foodscan.backend.dto.ScanResponse;
import com.foodscan.backend.entity.FoodScan;
import com.foodscan.backend.entity.UserAccount;
import com.foodscan.backend.exception.BadRequestException;
import com.foodscan.backend.exception.NotFoundException;
import com.foodscan.backend.intelligence.FoodIntelligenceService;
import com.foodscan.backend.nutrition.MacroProfile;
import com.foodscan.backend.nutrition.NutritionEstimator;
import com.foodscan.backend.repository.FoodScanRepository;
import com.foodscan.backend.repository.UserAccountRepository;
import com.foodscan.backend.security.CurrentUserService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.UUID;

@Service
public class ScanService {

    private final AiServiceClient aiServiceClient;
    private final FoodScanRepository foodScanRepository;
    private final CurrentUserService currentUserService;
    private final UserAccountRepository userAccountRepository;
    private final NutritionEstimator nutritionEstimator;
    private final IngredientAwarenessService ingredientAwarenessService;
    private final FoodIntelligenceService foodIntelligenceService;

    public ScanService(
            AiServiceClient aiServiceClient,
            FoodScanRepository foodScanRepository,
            CurrentUserService currentUserService,
            UserAccountRepository userAccountRepository,
            NutritionEstimator nutritionEstimator,
            IngredientAwarenessService ingredientAwarenessService,
            FoodIntelligenceService foodIntelligenceService
    ) {
        this.aiServiceClient = aiServiceClient;
        this.foodScanRepository = foodScanRepository;
        this.currentUserService = currentUserService;
        this.userAccountRepository = userAccountRepository;
        this.nutritionEstimator = nutritionEstimator;
        this.ingredientAwarenessService = ingredientAwarenessService;
        this.foodIntelligenceService = foodIntelligenceService;
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

        AiPredictResponse prediction = aiServiceClient.predict(image);
        if (prediction == null || prediction.foodName() == null || prediction.foodName().isBlank()) {
            throw new BadRequestException("AI service returned an empty prediction");
        }

        UUID userId = currentUserService.requireUserId();
        FoodScan scan = new FoodScan();
        scan.setUserId(userId);
        scan.setFoodName(prediction.foodName());
        scan.setConfidence(prediction.confidence());
        foodScanRepository.save(scan);

        return new ScanResponse(
                scan.getId(),
                new FoodDto(
                        scan.getFoodName(),
                        scan.getConfidence(),
                        ingredientAwarenessService.forFoodName(scan.getFoodName())
                )
        );
    }

    @Transactional(readOnly = true)
    public NutritionResponse nutritionFor(String scanId, NutritionRequest request) {
        UUID userId = currentUserService.requireUserId();
        FoodScan scan = foodScanRepository.findByIdAndUserId(scanId, userId)
                .orElseThrow(() -> new NotFoundException("Scan not found: " + scanId));

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

    private static double round1(double value) {
        return Math.round(value * 10.0) / 10.0;
    }
}
