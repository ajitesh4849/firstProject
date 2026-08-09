package com.foodscan.backend.client;

import com.foodscan.backend.dto.AiPredictResponse;
import com.foodscan.backend.exception.BadRequestException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestClientResponseException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@Component
public class AiServiceClient {

    private final RestTemplate restTemplate;
    private final String predictUrl;

    public AiServiceClient(@Value("${foodscan.ai.base-url}") String baseUrl) {
        this.restTemplate = new RestTemplate();
        this.predictUrl = baseUrl.endsWith("/") ? baseUrl + "predict" : baseUrl + "/predict";
    }

    public AiPredictResponse predict(MultipartFile image) {
        try {
            byte[] bytes = image.getBytes();
            String filename = image.getOriginalFilename() == null ? "food.jpg" : image.getOriginalFilename();

            ByteArrayResource resource = new ByteArrayResource(bytes) {
                @Override
                public String getFilename() {
                    return filename;
                }
            };

            MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
            body.add("image", resource);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.MULTIPART_FORM_DATA);

            ResponseEntity<AiPredictResponse> response = restTemplate.postForEntity(
                    predictUrl,
                    new HttpEntity<>(body, headers),
                    AiPredictResponse.class
            );

            AiPredictResponse prediction = response.getBody();
            if (prediction == null || prediction.foodName() == null || prediction.foodName().isBlank()) {
                throw new BadRequestException("AI service returned an empty prediction");
            }
            return prediction;
        } catch (RestClientResponseException ex) {
            throw new BadRequestException("AI service rejected image: " + ex.getResponseBodyAsString());
        } catch (BadRequestException ex) {
            throw ex;
        } catch (IOException | RuntimeException ex) {
            throw new BadRequestException("AI service unavailable: " + ex.getMessage());
        }
    }
}
