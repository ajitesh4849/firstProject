package com.foodscan.backend.controller;

import com.foodscan.backend.dto.ConfirmScanRequest;
import com.foodscan.backend.dto.FoodCandidateDto;
import com.foodscan.backend.dto.NutritionRequest;
import com.foodscan.backend.dto.NutritionResponse;
import com.foodscan.backend.dto.ScanResponse;
import com.foodscan.backend.service.ScanService;
import jakarta.validation.Valid;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

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

    @GetMapping("/match")
    public ResponseEntity<List<FoodCandidateDto>> match(
            @RequestParam String q,
            @RequestParam(defaultValue = "8") int limit
    ) {
        return ResponseEntity.ok(scanService.catalogMatch(q, limit));
    }

    @PostMapping("/{scanId}/confirm")
    public ResponseEntity<ScanResponse> confirm(
            @PathVariable String scanId,
            @Valid @RequestBody ConfirmScanRequest request
    ) {
        return ResponseEntity.ok(scanService.confirmScan(scanId, request));
    }

    @PostMapping("/{scanId}/nutrition")
    public ResponseEntity<NutritionResponse> nutrition(
            @PathVariable String scanId,
            @Valid @RequestBody NutritionRequest request
    ) {
        return ResponseEntity.ok(scanService.nutritionFor(scanId, request));
    }
}
