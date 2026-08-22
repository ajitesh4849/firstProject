package com.foodscan.backend.packaged;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

import java.util.Map;

/**
 * Fetches packaged product data from Open Food Facts (no AI).
 * OFF requires a descriptive User-Agent; anonymous clients are often blocked.
 */
@Component
public class OpenFoodFactsClient {

    private static final Logger log = LoggerFactory.getLogger(OpenFoodFactsClient.class);

    private final RestClient restClient;

    public OpenFoodFactsClient(
            @Value("${foodscan.openfoodfacts.base-url:https://world.openfoodfacts.org}") String baseUrl,
            @Value("${foodscan.openfoodfacts.user-agent:FoodScan/1.0 (dev; contact@foodscan.local)}") String userAgent,
            @Value("${foodscan.openfoodfacts.connect-timeout-ms:5000}") int connectTimeoutMs,
            @Value("${foodscan.openfoodfacts.read-timeout-ms:15000}") int readTimeoutMs
    ) {
        String normalized = baseUrl.endsWith("/") ? baseUrl.substring(0, baseUrl.length() - 1) : baseUrl;
        SimpleClientHttpRequestFactory requestFactory = new SimpleClientHttpRequestFactory();
        requestFactory.setConnectTimeout(connectTimeoutMs);
        requestFactory.setReadTimeout(readTimeoutMs);
        this.restClient = RestClient.builder()
                .baseUrl(normalized)
                .requestFactory(requestFactory)
                .defaultHeader("User-Agent", userAgent)
                .defaultHeader("Accept", "application/json")
                .build();
    }

    @SuppressWarnings("unchecked")
    public OpenFoodFactsProduct fetchByBarcode(String barcode) {
        String cleaned = barcode == null ? "" : barcode.trim();
        if (cleaned.isEmpty()) {
            return OpenFoodFactsProduct.notFound(cleaned);
        }

        try {
            Map<String, Object> body = restClient.get()
                    .uri("/api/v0/product/{barcode}.json", cleaned)
                    .retrieve()
                    .body(Map.class);

            if (body == null) {
                return OpenFoodFactsProduct.notFound(cleaned);
            }

            Object status = body.get("status");
            if (!(status instanceof Number number) || number.intValue() != 1) {
                return OpenFoodFactsProduct.notFound(cleaned);
            }

            Object productObj = body.get("product");
            if (!(productObj instanceof Map<?, ?> productMap)) {
                return OpenFoodFactsProduct.notFound(cleaned);
            }
            Map<String, Object> product = (Map<String, Object>) productMap;

            Map<String, Object> nutriments = product.get("nutriments") instanceof Map<?, ?> map
                    ? (Map<String, Object>) map
                    : Map.of();

            Double salt = asDouble(nutriments.get("salt_100g"));
            Double sodium = firstNonNull(
                    asDouble(nutriments.get("sodium_100g")),
                    salt == null ? null : salt * 400.0
            );
            return new OpenFoodFactsProduct(
                    cleaned,
                    firstNonBlank(
                            asString(product.get("product_name")),
                            asString(product.get("generic_name")),
                            "Unknown product"
                    ),
                    firstNonBlank(asString(product.get("brands")), null),
                    asString(product.get("quantity")),
                    firstNonBlank(
                            asString(product.get("ingredients_text_en")),
                            asString(product.get("ingredients_text")),
                            ""
                    ),
                    asString(product.get("categories")),
                    asDouble(nutriments.get("sugars_100g")),
                    salt,
                    firstNonNull(
                            asDouble(nutriments.get("energy-kcal_100g")),
                            asDouble(nutriments.get("energy-kcal_value"))
                    ),
                    asDouble(nutriments.get("proteins_100g")),
                    firstNonNull(
                            asDouble(nutriments.get("carbohydrates_100g")),
                            asDouble(nutriments.get("carbohydrates_value"))
                    ),
                    asDouble(nutriments.get("fat_100g")),
                    firstNonNull(
                            asDouble(nutriments.get("fiber_100g")),
                            asDouble(nutriments.get("fibre_100g"))
                    ),
                    asDouble(nutriments.get("saturated-fat_100g")),
                    sodium,
                    true
            );
        } catch (RestClientException ex) {
            log.warn("Open Food Facts lookup failed for barcode {}: {}", cleaned, ex.getMessage());
            throw new OpenFoodFactsUnavailableException(
                    "Could not reach the product database. Try again in a moment.",
                    ex
            );
        } catch (RuntimeException ex) {
            log.warn("Unexpected Open Food Facts parse error for barcode {}", cleaned, ex);
            throw new OpenFoodFactsUnavailableException(
                    "Could not read product data right now. Try again.",
                    ex
            );
        }
    }

    private static String asString(Object value) {
        return value == null ? null : value.toString().trim();
    }

    private static Double asDouble(Object value) {
        if (value instanceof Number number) {
            return number.doubleValue();
        }
        if (value instanceof String text && !text.isBlank()) {
            try {
                return Double.parseDouble(text.trim());
            } catch (NumberFormatException ignored) {
                return null;
            }
        }
        return null;
    }

    private static String firstNonBlank(String... values) {
        if (values == null) return null;
        for (String value : values) {
            if (value != null && !value.isBlank()) {
                return value;
            }
        }
        return null;
    }

    private static Double firstNonNull(Double... values) {
        if (values == null) return null;
        for (Double value : values) {
            if (value != null) {
                return value;
            }
        }
        return null;
    }
}
