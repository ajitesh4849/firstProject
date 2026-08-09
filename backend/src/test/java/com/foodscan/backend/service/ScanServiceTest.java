package com.foodscan.backend.service;

import com.foodscan.backend.client.AiServiceClient;
import com.foodscan.backend.dto.AiPredictResponse;
import com.foodscan.backend.dto.ScanResponse;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mock.web.MockMultipartFile;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ScanServiceTest {

    @Mock
    private AiServiceClient aiServiceClient;

    @InjectMocks
    private ScanService scanService;

    @Test
    void createScanUsesAiPrediction() {
        when(aiServiceClient.predict(any())).thenReturn(
                new AiPredictResponse("Masala Dosa", 0.91)
        );

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
    }
}
