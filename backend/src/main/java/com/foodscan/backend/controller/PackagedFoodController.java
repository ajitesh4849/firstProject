package com.foodscan.backend.controller;

import com.foodscan.backend.dto.PackagedFoodResponse;
import com.foodscan.backend.service.PackagedFoodService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/packaged")
public class PackagedFoodController {

    private final PackagedFoodService packagedFoodService;

    public PackagedFoodController(PackagedFoodService packagedFoodService) {
        this.packagedFoodService = packagedFoodService;
    }

    @GetMapping("/barcode/{barcode}")
    public ResponseEntity<PackagedFoodResponse> byBarcode(@PathVariable String barcode) {
        return ResponseEntity.ok(packagedFoodService.analyzeBarcode(barcode));
    }
}
