package com.foodscan.backend.client;

import com.foodscan.backend.dto.AiPredictResponse;
import com.foodscan.backend.exception.BadRequestException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.MediaType;
import org.springframework.http.client.MultipartBodyBuilder;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestClientResponseException;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@Component
public class AiServiceClient {

    private final RestClient restClient;

    public AiServiceClient(
            RestClient.Builder restClientBuilder,
            @Value("${foodscan.ai.base-url}") String baseUrl
    ) {
        this.restClient = restClientBuilder.baseUrl(baseUrl).build();
    }

    public AiPredictResponse predict(MultipartFile image) {
        try {
            byte[] bytes = image.getBytes();
            String filename = image.getOriginalFilename() == null ? "food.jpg" : image.getOriginalFilename();
            String contentType = image.getContentType() == null ? MediaType.IMAGE_JPEG_VALUE : image.getContentType();

            ByteArrayResource resource = new ByteArrayResource(bytes) {
                @Override
                public String getFilename() {
                    return filename;
                }
            };

            MultipartBodyBuilder bodyBuilder = new MultipartBodyBuilder();
            bodyBuilder.part("image", resource).contentType(MediaType.parseMediaType(contentType));

            return restClient.post()
                    .uri("/predict")
                    .contentType(MediaType.MULTIPART_FORM_DATA)
                    .body(bodyBuilder.build())
                    .retrieve()
                    .body(AiPredictResponse.class);
        } catch (RestClientResponseException ex) {
            throw new BadRequestException("AI service rejected image: " + ex.getResponseBodyAsString());
        } catch (RestClientException | IOException ex) {
            throw new BadRequestException("AI service unavailable: " + ex.getMessage());
        }
    }
}
