package com.foodscan.backend.repository;

import com.foodscan.backend.entity.PackagedProductSeed;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface PackagedProductSeedRepository extends JpaRepository<PackagedProductSeed, UUID> {
    Optional<PackagedProductSeed> findByBarcode(String barcode);
}
