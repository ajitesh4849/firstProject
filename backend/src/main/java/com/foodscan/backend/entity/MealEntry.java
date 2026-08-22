package com.foodscan.backend.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "meals")
public class MealEntry {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private UUID userId;

    @Column(nullable = false)
    private String foodName;

    @Column(nullable = false)
    private Integer portionGrams;

    @Column(nullable = false)
    private Integer calories;

    @Column(nullable = false)
    private Double proteinGrams;

    @Column(nullable = false)
    private Double carbsGrams;

    @Column(nullable = false)
    private Double fatGrams;

    @Column
    private Double fibreGrams = 0.0;

    @Column
    private Double sugarGrams = 0.0;

    @Column(nullable = false)
    private LocalDate mealDate;

    @Column(nullable = false, updatable = false)
    private Instant createdAt;

    @PrePersist
    void onCreate() {
        createdAt = Instant.now();
        if (mealDate == null) {
            mealDate = LocalDate.now();
        }
        if (fibreGrams == null) {
            fibreGrams = 0.0;
        }
        if (sugarGrams == null) {
            sugarGrams = 0.0;
        }
    }

    public UUID getId() {
        return id;
    }

    public UUID getUserId() {
        return userId;
    }

    public void setUserId(UUID userId) {
        this.userId = userId;
    }

    public String getFoodName() {
        return foodName;
    }

    public void setFoodName(String foodName) {
        this.foodName = foodName;
    }

    public Integer getPortionGrams() {
        return portionGrams;
    }

    public void setPortionGrams(Integer portionGrams) {
        this.portionGrams = portionGrams;
    }

    public Integer getCalories() {
        return calories;
    }

    public void setCalories(Integer calories) {
        this.calories = calories;
    }

    public Double getProteinGrams() {
        return proteinGrams;
    }

    public void setProteinGrams(Double proteinGrams) {
        this.proteinGrams = proteinGrams;
    }

    public Double getCarbsGrams() {
        return carbsGrams;
    }

    public void setCarbsGrams(Double carbsGrams) {
        this.carbsGrams = carbsGrams;
    }

    public Double getFatGrams() {
        return fatGrams;
    }

    public void setFatGrams(Double fatGrams) {
        this.fatGrams = fatGrams;
    }

    public Double getFibreGrams() {
        return fibreGrams;
    }

    public void setFibreGrams(Double fibreGrams) {
        this.fibreGrams = fibreGrams;
    }

    public Double getSugarGrams() {
        return sugarGrams;
    }

    public void setSugarGrams(Double sugarGrams) {
        this.sugarGrams = sugarGrams;
    }

    public LocalDate getMealDate() {
        return mealDate;
    }

    public void setMealDate(LocalDate mealDate) {
        this.mealDate = mealDate;
    }
}
