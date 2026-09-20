package com.foodscan.backend.service;

import com.foodscan.backend.awareness.IngredientAwarenessService;
import com.foodscan.backend.dto.ScanResponse;
import com.foodscan.backend.entity.FoodScan;
import com.foodscan.backend.identify.FoodIdentifier;
import com.foodscan.backend.intelligence.FoodIntelligenceService;
import com.foodscan.backend.nutrition.FoodNutritionCache;
import com.foodscan.backend.nutrition.NutritionEstimator;
import com.foodscan.backend.repository.FoodScanRepository;
import com.foodscan.backend.repository.UserAccountRepository;
import com.foodscan.backend.security.CurrentUserService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mock.web.MockMultipartFile;

import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ScanServiceTest {

    @Mock
    private FoodIdentifier foodIdentifier;

    @Mock
    private FoodScanRepository foodScanRepository;

    @Mock
    private CurrentUserService currentUserService;

    @Mock
    private UserAccountRepository userAccountRepository;

    @Mock
    private NutritionEstimator nutritionEstimator;

    @Mock
    private FoodNutritionCache foodNutritionCache;

    private ScanService scanService;

    @BeforeEach
    void setUp() {
        scanService = new ScanService(
                foodIdentifier,
                foodScanRepository,
                currentUserService,
                userAccountRepository,
                nutritionEstimator,
                new IngredientAwarenessService(),
                new FoodIntelligenceService(),
                foodNutritionCache
        );
    }

    @Test
    void createScanCatalogModeNeedsUserPick() {
        when(foodIdentifier.mode()).thenReturn("catalog");
        when(currentUserService.requireUserId()).thenReturn(UUID.randomUUID());
        when(foodScanRepository.save(any())).thenAnswer(invocation -> {
            FoodScan scan = invocation.getArgument(0);
            if (scan.getId() == null) {
                scan.setId("scan-test");
            }
            return scan;
        });

        MockMultipartFile image = new MockMultipartFile(
                "image",
                "meal.jpg",
                "image/jpeg",
                "fake-bytes".getBytes()
        );

        ScanResponse response = scanService.createScan(image);
        assertNotNull(response.scanId());
        assertTrue(response.needsUserPick());
        assertEquals("catalog", response.identifierMode());
        assertEquals(List.of(), response.candidates());
    }

    @Test
    void createScanAiModeReturnsCandidate() {
        when(foodIdentifier.mode()).thenReturn("ai");
        when(foodIdentifier.identify(any(), any())).thenReturn(List.of(
                new FoodIdentifier.FoodCandidate("Masala Dosa", 0.91, "SOUTH_INDIAN")
        ));
        when(currentUserService.requireUserId()).thenReturn(UUID.randomUUID());
        when(foodScanRepository.save(any())).thenAnswer(invocation -> {
            FoodScan scan = invocation.getArgument(0);
            if (scan.getId() == null) {
                scan.setId("scan-test");
            }
            return scan;
        });

        MockMultipartFile image = new MockMultipartFile(
                "image",
                "dosa.jpg",
                "image/jpeg",
                "fake-bytes".getBytes()
        );

        ScanResponse response = scanService.createScan(image);
        assertNotNull(response.scanId());
        assertEquals("Masala Dosa", response.food().name());
        assertEquals(0.91, response.food().confidence());
        assertEquals(1, response.candidates().size());
    }
}
