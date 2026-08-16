package com.foodscan.backend.service;

import com.foodscan.backend.dto.PackagedFoodResponse;
import com.foodscan.backend.exception.BadRequestException;
import com.foodscan.backend.exception.NotFoundException;
import com.foodscan.backend.packaged.OpenFoodFactsClient;
import com.foodscan.backend.packaged.OpenFoodFactsProduct;
import com.foodscan.backend.packaged.PackagedFoodRiskAnalyzer;
import org.springframework.stereotype.Service;

@Service
public class PackagedFoodService {

    private final OpenFoodFactsClient openFoodFactsClient;
    private final PackagedFoodRiskAnalyzer riskAnalyzer;

    public PackagedFoodService(
            OpenFoodFactsClient openFoodFactsClient,
            PackagedFoodRiskAnalyzer riskAnalyzer
    ) {
        this.openFoodFactsClient = openFoodFactsClient;
        this.riskAnalyzer = riskAnalyzer;
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
                analysis.disclaimer(),
                true
        );
    }
}
