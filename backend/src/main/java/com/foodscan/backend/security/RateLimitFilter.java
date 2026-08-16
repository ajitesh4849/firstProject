package com.foodscan.backend.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.foodscan.backend.dto.ApiErrorResponse;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.time.Instant;
import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedDeque;

/**
 * Simple in-memory IP rate limiter for auth and scan endpoints.
 */
@Component
@Order(Ordered.HIGHEST_PRECEDENCE + 20)
public class RateLimitFilter extends OncePerRequestFilter {

    private final ObjectMapper objectMapper;
    private final int authLimit;
    private final int scanLimit;
    private final long windowMs;

    private final ConcurrentHashMap<String, ConcurrentLinkedDeque<Long>> hits = new ConcurrentHashMap<>();

    public RateLimitFilter(
            ObjectMapper objectMapper,
            @Value("${foodscan.rate-limit.auth-per-minute:20}") int authLimit,
            @Value("${foodscan.rate-limit.scan-per-minute:30}") int scanLimit,
            @Value("${foodscan.rate-limit.window-ms:60000}") long windowMs
    ) {
        this.objectMapper = objectMapper;
        this.authLimit = authLimit;
        this.scanLimit = scanLimit;
        this.windowMs = windowMs;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getRequestURI();
        return !(path.startsWith("/api/v1/auth/") || path.startsWith("/api/v1/scans")
                || path.startsWith("/api/v1/packaged/"));
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {
        String path = request.getRequestURI();
        int limit = path.startsWith("/api/v1/auth/") ? authLimit : scanLimit;
        String key = clientKey(request) + "|" + (path.startsWith("/api/v1/auth/") ? "auth" : "scan");

        if (!allow(key, limit)) {
            response.setStatus(429);
            response.setContentType(MediaType.APPLICATION_JSON_VALUE);
            objectMapper.writeValue(
                    response.getOutputStream(),
                    new ApiErrorResponse("RATE_LIMITED", "Too many requests. Try again shortly.", null)
            );
            return;
        }

        filterChain.doFilter(request, response);
    }

    private boolean allow(String key, int limit) {
        long now = Instant.now().toEpochMilli();
        long cutoff = now - windowMs;
        ConcurrentLinkedDeque<Long> timestamps = hits.computeIfAbsent(key, ignored -> new ConcurrentLinkedDeque<>());

        synchronized (timestamps) {
            while (!timestamps.isEmpty() && timestamps.peekFirst() < cutoff) {
                timestamps.pollFirst();
            }
            if (timestamps.size() >= limit) {
                return false;
            }
            timestamps.addLast(now);
        }

        // Light cleanup to avoid unbounded growth of idle keys
        if (hits.size() > 10_000) {
            pruneOldKeys(cutoff);
        }
        return true;
    }

    private void pruneOldKeys(long cutoff) {
        Iterator<Map.Entry<String, ConcurrentLinkedDeque<Long>>> iterator = hits.entrySet().iterator();
        while (iterator.hasNext()) {
            Map.Entry<String, ConcurrentLinkedDeque<Long>> entry = iterator.next();
            ConcurrentLinkedDeque<Long> deque = entry.getValue();
            synchronized (deque) {
                while (!deque.isEmpty() && deque.peekFirst() < cutoff) {
                    deque.pollFirst();
                }
                if (deque.isEmpty()) {
                    iterator.remove();
                }
            }
        }
    }

    private static String clientKey(HttpServletRequest request) {
        String forwarded = request.getHeader("X-Forwarded-For");
        if (forwarded != null && !forwarded.isBlank()) {
            return forwarded.split(",")[0].trim();
        }
        return request.getRemoteAddr() == null ? "unknown" : request.getRemoteAddr();
    }
}
