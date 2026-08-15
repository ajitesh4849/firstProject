package com.foodscan.backend.service;

import com.foodscan.backend.awareness.IngredientAwarenessService;
import com.foodscan.backend.client.AiServiceClient;
import com.foodscan.backend.dto.AiPredictResponse;
import com.foodscan.backend.dto.ScanResponse;
import com.foodscan.backend.entity.FoodScan;
import com.foodscan.backend.nutrition.NutritionEstimator;
import com.foodscan.backend.repository.FoodScanRepository;
import com.foodscan.backend.security.CurrentUserService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mock.web.MockMultipartFile;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ScanServiceTest {

    @Mock
    private AiServiceClient aiServiceClient;

    @Mock
    private FoodScanRepository foodScanRepository;

    @Mock
    private CurrentUserService currentUserService;

    private ScanService scanService;

    @BeforeEach
    void setUp() {
        scanService = new ScanService(
                aiServiceClient,
                foodScanRepository,
                currentUserService,
                new NutritionEstimator(),
                new IngredientAwarenessService()
        );
    }

    @Test
    void createScanUsesAiPrediction() {
        when(currentUserService.requireUserId()).thenReturn(UUID.randomUUID());
        when(aiServiceClient.predict(any())).thenReturn(new AiPredictResponse("Masala Dosa", 0.91));
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
        assertNotNull(response.food().awareness());
        assertNotNull(response.food().awareness().category());
    }
}
