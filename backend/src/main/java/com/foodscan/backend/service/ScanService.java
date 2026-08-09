package com.foodscan.backend.service;

import com.foodscan.backend.client.AiServiceClient;
import com.foodscan.backend.dto.AiPredictResponse;
import com.foodscan.backend.dto.FoodDto;
import com.foodscan.backend.dto.NutritionRequest;
import com.foodscan.backend.dto.NutritionResponse;
import com.foodscan.backend.dto.ScanResponse;
import com.foodscan.backend.exception.BadRequestException;
import com.foodscan.backend.exception.NotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class ScanService {

    private final AiServiceClient aiServiceClient;
    private final Map<String, String> scans = new ConcurrentHashMap<>();

    public ScanService(AiServiceClient aiServiceClient) {
        this.aiServiceClient = aiServiceClient;
    }

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

        String scanId = "scan-" + UUID.randomUUID();
        scans.put(scanId, prediction.foodName());

        return new ScanResponse(
                scanId,
                new FoodDto(prediction.foodName(), prediction.confidence())
        );
    }

    public NutritionResponse nutritionFor(String scanId, NutritionRequest request) {
        String foodName = scans.get(scanId);
        if (foodName == null) {
            throw new NotFoundException("Scan not found: " + scanId);
        }

        double factor = request.portionGrams() / 100.0;
        return new NutritionResponse(
                foodName,
                request.portionGrams(),
                (int) Math.round(190 * factor),
                round1(7 * factor),
                round1(6 * factor),
                round1(15 * factor),
                true
        );
    }

    private static double round1(double value) {
        return Math.round(value * 10.0) / 10.0;
    }
}
