package com.foodscan.backend.nutrition;

import com.foodscan.backend.entity.FoodNutrition;
import com.foodscan.backend.repository.FoodNutritionRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class FoodNutritionCacheTest {

    @Mock
    private FoodNutritionRepository repository;

    private FoodNutritionCache cache;

    @BeforeEach
    void setUp() {
        cache = new FoodNutritionCache(repository);
    }

    @Test
    void findsExactAndAliasFromMemory() {
        FoodNutrition roti = new FoodNutrition();
        roti.setName("Roti");
        roti.setNormalizedName("roti");
        roti.setAliases("chapati,phulka");
        roti.setCaloriesPer100g(297);
        roti.setProteinPer100g(10.0);
        roti.setCarbsPer100g(48.0);
        roti.setFatPer100g(7.0);
        roti.setFibrePer100g(7.0);
        roti.setSugarPer100g(1.5);
        roti.setSodiumMgPer100g(220.0);

        when(repository.findAll()).thenReturn(List.of(roti));
        cache.reload();

        assertEquals(297, cache.find("Roti").orElseThrow().caloriesPer100g());
        assertEquals(297, cache.find("chapati").orElseThrow().caloriesPer100g());
        assertEquals(297, cache.find("butter roti plate").orElseThrow().caloriesPer100g());
        assertTrue(cache.size() >= 3);
    }
}
