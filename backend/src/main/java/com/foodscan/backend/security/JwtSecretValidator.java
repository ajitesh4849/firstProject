package com.foodscan.backend.security;

import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class JwtSecretValidator {

    private static final Logger log = LoggerFactory.getLogger(JwtSecretValidator.class);
    private static final String WEAK_DEV_SECRET = "foodscan-dev-secret-change-me-please-32chars-min";

    private final String secret;
    private final boolean allowWeakSecret;

    public JwtSecretValidator(
            @Value("${foodscan.jwt.secret}") String secret,
            @Value("${foodscan.jwt.allow-weak-secret:true}") boolean allowWeakSecret
    ) {
        this.secret = secret;
        this.allowWeakSecret = allowWeakSecret;
    }

    @PostConstruct
    void validate() {
        if (secret == null || secret.getBytes().length < 32) {
            throw new IllegalStateException(
                    "foodscan.jwt.secret must be at least 32 bytes. Set JWT_SECRET in the environment."
            );
        }

        if (WEAK_DEV_SECRET.equals(secret)) {
            if (!allowWeakSecret) {
                throw new IllegalStateException(
                        "Refusing to start with the default JWT_SECRET. Set a unique JWT_SECRET."
                );
            }
            log.warn("Using the default JWT_SECRET. Set a unique JWT_SECRET before any real deployment.");
        }
    }
}
