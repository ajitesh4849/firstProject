package com.foodscan.backend.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;

import java.time.Instant;
import java.util.UUID;

/**
 * Local catalog of packaged products (India seed + user contributions).
 * Looked up by barcode before Open Food Facts — indexed, so it stays fast.
 */
@Entity
@Table(
        name = "packaged_product_seeds",
        uniqueConstraints = @UniqueConstraint(name = "uk_packaged_seed_barcode", columnNames = "barcode")
)
public class PackagedProductSeed {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, length = 32)
    private String barcode;

    @Column(nullable = false, length = 255)
    private String productName;

    @Column(length = 255)
    private String brand;

    @Column(length = 64)
    private String quantity;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String ingredientsText;

    @Column(length = 512)
    private String categories;

    private Double sugarPer100g;
    private Double saltPer100g;
    private Double energyKcalPer100g;

    private UUID createdByUserId;

    @Column(nullable = false, length = 32)
    private String source = "USER";

    @Column(nullable = false, updatable = false)
    private Instant createdAt;

    @Column(nullable = false)
    private Instant updatedAt;

    @PrePersist
    void onCreate() {
        Instant now = Instant.now();
        createdAt = now;
        updatedAt = now;
    }

    @PreUpdate
    void onUpdate() {
        updatedAt = Instant.now();
    }

    public UUID getId() {
        return id;
    }

    public String getBarcode() {
        return barcode;
    }

    public void setBarcode(String barcode) {
        this.barcode = barcode;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getBrand() {
        return brand;
    }

    public void setBrand(String brand) {
        this.brand = brand;
    }

    public String getQuantity() {
        return quantity;
    }

    public void setQuantity(String quantity) {
        this.quantity = quantity;
    }

    public String getIngredientsText() {
        return ingredientsText;
    }

    public void setIngredientsText(String ingredientsText) {
        this.ingredientsText = ingredientsText;
    }

    public String getCategories() {
        return categories;
    }

    public void setCategories(String categories) {
        this.categories = categories;
    }

    public Double getSugarPer100g() {
        return sugarPer100g;
    }

    public void setSugarPer100g(Double sugarPer100g) {
        this.sugarPer100g = sugarPer100g;
    }

    public Double getSaltPer100g() {
        return saltPer100g;
    }

    public void setSaltPer100g(Double saltPer100g) {
        this.saltPer100g = saltPer100g;
    }

    public Double getEnergyKcalPer100g() {
        return energyKcalPer100g;
    }

    public void setEnergyKcalPer100g(Double energyKcalPer100g) {
        this.energyKcalPer100g = energyKcalPer100g;
    }

    public UUID getCreatedByUserId() {
        return createdByUserId;
    }

    public void setCreatedByUserId(UUID createdByUserId) {
        this.createdByUserId = createdByUserId;
    }

    public String getSource() {
        return source;
    }

    public void setSource(String source) {
        this.source = source;
    }
}
