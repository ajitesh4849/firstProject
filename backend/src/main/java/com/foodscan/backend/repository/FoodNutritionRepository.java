package com.foodscan.backend.repository;

import com.foodscan.backend.entity.FoodNutrition;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface FoodNutritionRepository extends JpaRepository<FoodNutrition, UUID> {
    Optional<FoodNutrition> findByNormalizedName(String normalizedName);

    boolean existsByNormalizedName(String normalizedName);

    long count();
}
