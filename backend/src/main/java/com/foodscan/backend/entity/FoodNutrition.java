package com.foodscan.backend.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;

import java.time.Instant;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Curated meal nutrition per 100g (Indian + common dishes).
 * Loaded into an in-memory cache at startup — request path does not query Postgres.
 */
@Entity
@Table(
        name = "food_nutrition",
        uniqueConstraints = @UniqueConstraint(name = "uk_food_nutrition_name", columnNames = "normalized_name"),
        indexes = {
                @Index(name = "idx_food_nutrition_category", columnList = "category")
        }
)
public class FoodNutrition {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, length = 160)
    private String name;

    @Column(name = "normalized_name", nullable = false, length = 160)
    private String normalizedName;

    /** Comma-separated aliases (e.g. "chapati,phulka"). */
    @Column(length = 512)
    private String aliases;

    @Column(nullable = false, length = 64)
    private String category = "GENERAL";

    @Column(nullable = false)
    private Integer caloriesPer100g;

    @Column(nullable = false)
    private Double proteinPer100g;

    @Column(nullable = false)
    private Double carbsPer100g;

    @Column(nullable = false)
    private Double fatPer100g;

    @Column(nullable = false)
    private Double fibrePer100g = 0.0;

    @Column(nullable = false)
    private Double sugarPer100g = 0.0;

    @Column(nullable = false)
    private Double sodiumMgPer100g = 0.0;

    @Column(nullable = false, length = 32)
    private String source = "SEED";

    @Column(nullable = false, updatable = false)
    private Instant createdAt;

    @Column(nullable = false)
    private Instant updatedAt;

    @PrePersist
    void onCreate() {
        Instant now = Instant.now();
        createdAt = now;
        updatedAt = now;
        normalizeFields();
    }

    @PreUpdate
    void onUpdate() {
        updatedAt = Instant.now();
        normalizeFields();
    }

    private void normalizeFields() {
        if (name != null) {
            normalizedName = name.trim().toLowerCase(Locale.ENGLISH);
        }
        if (fibrePer100g == null) {
            fibrePer100g = 0.0;
        }
        if (sugarPer100g == null) {
            sugarPer100g = 0.0;
        }
        if (sodiumMgPer100g == null) {
            sodiumMgPer100g = 0.0;
        }
    }

    public List<String> aliasList() {
        if (aliases == null || aliases.isBlank()) {
            return List.of();
        }
        return Arrays.stream(aliases.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .map(s -> s.toLowerCase(Locale.ENGLISH))
                .distinct()
                .collect(Collectors.toList());
    }

    public UUID getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getNormalizedName() {
        return normalizedName;
    }

    public void setNormalizedName(String normalizedName) {
        this.normalizedName = normalizedName;
    }

    public String getAliases() {
        return aliases;
    }

    public void setAliases(String aliases) {
        this.aliases = aliases;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public Integer getCaloriesPer100g() {
        return caloriesPer100g;
    }

    public void setCaloriesPer100g(Integer caloriesPer100g) {
        this.caloriesPer100g = caloriesPer100g;
    }

    public Double getProteinPer100g() {
        return proteinPer100g;
    }

    public void setProteinPer100g(Double proteinPer100g) {
        this.proteinPer100g = proteinPer100g;
    }

    public Double getCarbsPer100g() {
        return carbsPer100g;
    }

    public void setCarbsPer100g(Double carbsPer100g) {
        this.carbsPer100g = carbsPer100g;
    }

    public Double getFatPer100g() {
        return fatPer100g;
    }

    public void setFatPer100g(Double fatPer100g) {
        this.fatPer100g = fatPer100g;
    }

    public Double getFibrePer100g() {
        return fibrePer100g;
    }

    public void setFibrePer100g(Double fibrePer100g) {
        this.fibrePer100g = fibrePer100g;
    }

    public Double getSugarPer100g() {
        return sugarPer100g;
    }

    public void setSugarPer100g(Double sugarPer100g) {
        this.sugarPer100g = sugarPer100g;
    }

    public Double getSodiumMgPer100g() {
        return sodiumMgPer100g;
    }

    public void setSodiumMgPer100g(Double sodiumMgPer100g) {
        this.sodiumMgPer100g = sodiumMgPer100g;
    }

    public String getSource() {
        return source;
    }

    public void setSource(String source) {
        this.source = source;
    }
}
