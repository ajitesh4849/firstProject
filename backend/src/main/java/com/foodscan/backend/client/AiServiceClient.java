package com.foodscan.backend.client;

import com.foodscan.backend.dto.AiLabelReadResponse;
import com.foodscan.backend.dto.AiPredictResponse;
import com.foodscan.backend.exception.BadRequestException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.RestClientResponseException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@Component
public class AiServiceClient {

    private final RestTemplate restTemplate;
    private final String predictUrl;
    private final String readLabelUrl;

    public AiServiceClient(
            @Value("${foodscan.ai.base-url}") String baseUrl,
            @Value("${foodscan.ai.connect-timeout-ms:5000}") int connectTimeoutMs,
            @Value("${foodscan.ai.read-timeout-ms:35000}") int readTimeoutMs
    ) {
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(connectTimeoutMs);
        factory.setReadTimeout(readTimeoutMs);
        this.restTemplate = new RestTemplate(factory);
        String root = baseUrl.endsWith("/") ? baseUrl.substring(0, baseUrl.length() - 1) : baseUrl;
        this.predictUrl = root + "/predict";
        this.readLabelUrl = root + "/read-label";
    }

    public AiPredictResponse predict(MultipartFile image) {
        AiPredictResponse prediction = postImage(
                image,
                predictUrl,
                AiPredictResponse.class,
                "AI service returned an empty prediction"
        );
        if (prediction.foodName() == null || prediction.foodName().isBlank()) {
            throw new BadRequestException("AI service returned an empty prediction");
        }
        return prediction;
    }

    public AiLabelReadResponse readLabel(MultipartFile image) {
        AiLabelReadResponse result = postImage(
                image,
                readLabelUrl,
                AiLabelReadResponse.class,
                "AI service returned empty label data"
        );
        if (result.ingredientsText() == null || result.ingredientsText().isBlank()) {
            throw new BadRequestException(
                    "Could not read ingredients from this photo. Try a clearer close-up of the label."
            );
        }
        return result;
    }

    private <T> T postImage(
            MultipartFile image,
            String url,
            Class<T> responseType,
            String emptyMessage
    ) {
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

            ResponseEntity<T> response = restTemplate.postForEntity(
                    url,
                    new HttpEntity<>(body, headers),
                    responseType
            );

            T prediction = response.getBody();
            if (prediction == null) {
                throw new BadRequestException(emptyMessage);
            }
            return prediction;
        } catch (RestClientResponseException ex) {
            throw new BadRequestException("AI service rejected image: " + ex.getResponseBodyAsString());
        } catch (BadRequestException ex) {
            throw ex;
        } catch (ResourceAccessException ex) {
            throw new BadRequestException(
                    "Food analysis timed out or AI service is unreachable. Try a clearer, closer photo."
            );
        } catch (IOException | RuntimeException ex) {
            throw new BadRequestException("AI service unavailable: " + ex.getMessage());
        }
    }
}
