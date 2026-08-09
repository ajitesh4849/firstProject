package com.foodscan.backend.repository;

import com.foodscan.backend.entity.MealEntry;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public interface MealEntryRepository extends JpaRepository<MealEntry, UUID> {
    List<MealEntry> findByUserIdAndMealDateOrderByCreatedAtAsc(UUID userId, LocalDate mealDate);

    List<MealEntry> findByUserIdAndMealDateBetweenOrderByMealDateAsc(
            UUID userId,
            LocalDate start,
            LocalDate end
    );
}
