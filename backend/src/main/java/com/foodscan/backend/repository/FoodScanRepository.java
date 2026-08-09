package com.foodscan.backend.repository;

import com.foodscan.backend.entity.FoodScan;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface FoodScanRepository extends JpaRepository<FoodScan, String> {
    Optional<FoodScan> findByIdAndUserId(String id, UUID userId);
}
