package com.foodscan.backend.controller;

import com.foodscan.backend.dto.FoodSearchItemDto;
import com.foodscan.backend.dto.NutritionResponse;
import com.foodscan.backend.service.FoodCatalogService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/foods")
public class FoodController {

    private final FoodCatalogService foodCatalogService;

    public FoodController(FoodCatalogService foodCatalogService) {
        this.foodCatalogService = foodCatalogService;
    }

    @GetMapping("/search")
    public ResponseEntity<List<FoodSearchItemDto>> search(
            @RequestParam(required = false, defaultValue = "") String q,
            @RequestParam(required = false, defaultValue = "20") int limit
    ) {
        return ResponseEntity.ok(foodCatalogService.search(q, limit));
    }

    @GetMapping("/nutrition")
    public ResponseEntity<NutritionResponse> nutrition(
            @RequestParam String name,
            @RequestParam(defaultValue = "100") int portionGrams
    ) {
        return ResponseEntity.ok(foodCatalogService.nutritionFor(name, portionGrams));
    }
}
