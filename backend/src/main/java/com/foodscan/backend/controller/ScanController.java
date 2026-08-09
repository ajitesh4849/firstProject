package com.foodscan.backend.controller;

import com.foodscan.backend.dto.NutritionRequest;
import com.foodscan.backend.dto.NutritionResponse;
import com.foodscan.backend.dto.ScanResponse;
import com.foodscan.backend.service.ScanService;
import jakarta.validation.Valid;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/v1/scans")
public class ScanController {

    private final ScanService scanService;

    public ScanController(ScanService scanService) {
        this.scanService = scanService;
    }

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ScanResponse> createScan(@RequestPart("image") MultipartFile image) {
        return ResponseEntity.ok(scanService.createScan(image));
    }

    @PostMapping("/{scanId}/nutrition")
    public ResponseEntity<NutritionResponse> nutrition(
            @PathVariable String scanId,
            @Valid @RequestBody NutritionRequest request
    ) {
        return ResponseEntity.ok(scanService.nutritionFor(scanId, request));
    }
}
