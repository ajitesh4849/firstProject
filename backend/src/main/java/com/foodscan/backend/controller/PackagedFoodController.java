package com.foodscan.backend.controller;

import com.foodscan.backend.dto.PackagedFoodResponse;
import com.foodscan.backend.dto.SavePackagedSeedRequest;
import com.foodscan.backend.service.PackagedFoodService;
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

    /**
     * Fallback when barcode is missing from catalog + Open Food Facts:
     * user photographs the ingredients panel; AI reads text; same rule engine scores risks.
     */
    @PostMapping(value = "/label", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<PackagedFoodResponse> byLabelPhoto(
            @RequestPart("image") MultipartFile image,
            @RequestParam(value = "barcode", required = false) String barcode
    ) {
        return ResponseEntity.ok(packagedFoodService.analyzeLabelPhoto(image, barcode));
    }

    /**
     * Save a user-contributed product into the local India/catalog seed table
     * so the next barcode scan hits Postgres instead of failing.
     */
    @PostMapping("/catalog")
    public ResponseEntity<PackagedFoodResponse> saveToCatalog(
            @Valid @RequestBody SavePackagedSeedRequest request
    ) {
        return ResponseEntity.ok(packagedFoodService.saveToCatalog(request));
    }
}
