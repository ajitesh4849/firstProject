package com.foodscan.backend.packaged;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClientResponseException;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

/**
 * Fetches packaged product data from Open Food Facts (no AI).
 */
@Component
public class OpenFoodFactsClient {

    private final RestTemplate restTemplate;
    private final String baseUrl;

    public OpenFoodFactsClient(
            @Value("${foodscan.openfoodfacts.base-url:https://world.openfoodfacts.org}") String baseUrl
    ) {
        this.restTemplate = new RestTemplate();
        this.baseUrl = baseUrl.endsWith("/") ? baseUrl.substring(0, baseUrl.length() - 1) : baseUrl;
    }

    @SuppressWarnings("unchecked")
    public OpenFoodFactsProduct fetchByBarcode(String barcode) {
        String cleaned = barcode == null ? "" : barcode.trim();
        if (cleaned.isEmpty()) {
            return OpenFoodFactsProduct.notFound(cleaned);
        }

        try {
            String url = baseUrl + "/api/v0/product/" + cleaned + ".json";
            Map<String, Object> body = restTemplate.getForObject(url, Map.class);
            if (body == null) {
                return OpenFoodFactsProduct.notFound(cleaned);
            }

            Object status = body.get("status");
            if (!(status instanceof Number number) || number.intValue() != 1) {
                return OpenFoodFactsProduct.notFound(cleaned);
            }

            Map<String, Object> product = (Map<String, Object>) body.get("product");
            if (product == null) {
                return OpenFoodFactsProduct.notFound(cleaned);
            }

            Map<String, Object> nutriments = product.get("nutriments") instanceof Map<?, ?> map
                    ? (Map<String, Object>) map
                    : Map.of();

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
                    asDouble(nutriments.get("salt_100g")),
                    firstNonNull(
                            asDouble(nutriments.get("energy-kcal_100g")),
                            asDouble(nutriments.get("energy-kcal_value"))
                    ),
                    true
            );
        } catch (RestClientResponseException | RuntimeException ex) {
            return OpenFoodFactsProduct.notFound(cleaned);
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
