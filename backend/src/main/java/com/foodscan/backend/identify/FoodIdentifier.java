package com.foodscan.backend.identify;

import org.springframework.web.multipart.MultipartFile;

import java.util.List;

/**
 * Pluggable meal identification. Phase 1 = catalog text match; later = vision AI.
 */
public interface FoodIdentifier {

    String mode();

    /**
     * @param image meal photo (may be unused by catalog mode)
     * @param hint  user-typed query; required for meaningful catalog matches
     */
    List<FoodCandidate> identify(MultipartFile image, String hint);

    record FoodCandidate(String foodName, double confidence, String category) {
    }
}
