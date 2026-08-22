package com.foodscan.backend.nutrition;

import com.foodscan.backend.entity.FoodNutrition;
import com.foodscan.backend.repository.FoodNutritionRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/**
 * Seeds curated Indian + common meal nutrition into Postgres once, then warms the cache.
 * Does not run on the request path.
 */
@Component
@Order(20)
public class FoodNutritionSeedRunner implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(FoodNutritionSeedRunner.class);

    private final FoodNutritionRepository repository;
    private final FoodNutritionCache cache;

    public FoodNutritionSeedRunner(FoodNutritionRepository repository, FoodNutritionCache cache) {
        this.repository = repository;
        this.cache = cache;
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        long existing = repository.count();
        if (existing == 0) {
            List<FoodNutrition> seeds = buildSeeds();
            repository.saveAll(seeds);
            log.info("Seeded {} food nutrition rows", seeds.size());
        } else {
            log.info("Food nutrition table already has {} rows — skip seed", existing);
        }
        cache.reload();
    }

    private static List<FoodNutrition> buildSeeds() {
        List<FoodNutrition> list = new ArrayList<>();

        // North Indian
        add(list, "Roti", "chapati,phulka,roti", "NORTH_INDIAN", 297, 10, 48, 7, 7, 1.5, 220);
        add(list, "Paratha", "aloo paratha,plain paratha", "NORTH_INDIAN", 320, 7, 40, 14, 4, 2, 300);
        add(list, "Dal Tadka", "dal,dal fry,yellow dal", "NORTH_INDIAN", 130, 7, 16, 4, 4.5, 1.5, 320);
        add(list, "Dal Makhani", "maah dal", "NORTH_INDIAN", 170, 8, 14, 9, 5, 2, 380);
        add(list, "Rajma", "rajma masala,kidney beans curry", "NORTH_INDIAN", 140, 8, 20, 3, 6, 2, 360);
        add(list, "Chole", "chana masala,chole masala,chickpea curry", "NORTH_INDIAN", 160, 8, 22, 4.5, 6.5, 3, 400);
        add(list, "Paneer Butter Masala", "butter paneer,paneer makhani", "NORTH_INDIAN", 220, 10, 10, 16, 1.5, 4, 420);
        add(list, "Palak Paneer", "saag paneer", "NORTH_INDIAN", 180, 10, 8, 12, 2.5, 3, 380);
        add(list, "Shahi Paneer", null, "NORTH_INDIAN", 230, 11, 9, 17, 1.2, 4, 400);
        add(list, "Butter Chicken", "murgh makhani", "NORTH_INDIAN", 210, 14, 8, 14, 1, 5, 480);
        add(list, "Chicken Curry", "murgh curry", "NORTH_INDIAN", 175, 16, 6, 10, 1, 2, 420);
        add(list, "Chicken Biryani", "biryani", "NORTH_INDIAN", 190, 10, 24, 6, 1.5, 1, 390);
        add(list, "Veg Biryani", "vegetable biryani", "NORTH_INDIAN", 170, 5, 28, 5, 2.5, 2, 350);
        add(list, "Aloo Gobi", null, "NORTH_INDIAN", 110, 3, 14, 5, 3.5, 3, 300);
        add(list, "Bhindi Masala", "okra masala", "NORTH_INDIAN", 120, 3, 10, 8, 3, 2, 320);
        add(list, "Baingan Bharta", null, "NORTH_INDIAN", 100, 2.5, 10, 6, 3.5, 3, 280);
        add(list, "Kadhi Pakora", "kadhi", "NORTH_INDIAN", 120, 5, 12, 6, 1.5, 3, 350);
        add(list, "Poha", "kanda poha", "NORTH_INDIAN", 150, 3, 28, 3, 2, 2, 280);
        add(list, "White Rice", "steamed rice,plain rice,chawal", "NORTH_INDIAN", 130, 2.5, 28, 0.3, 0.4, 0.1, 5);
        add(list, "Jeera Rice", null, "NORTH_INDIAN", 145, 2.8, 28, 2.5, 0.5, 0.2, 180);
        add(list, "Khichdi", "khichadi", "NORTH_INDIAN", 140, 5, 22, 3, 2.5, 0.5, 250);
        add(list, "Curd", "dahi,yogurt", "NORTH_INDIAN", 60, 3.5, 4.5, 3, 0, 4, 50);
        add(list, "Raita", "cucumber raita", "NORTH_INDIAN", 55, 3, 5, 2.5, 0.5, 4, 80);

        // South Indian
        add(list, "Idli", "idly", "SOUTH_INDIAN", 120, 4, 22, 1, 1.5, 0.5, 280);
        add(list, "Dosa", "plain dosa", "SOUTH_INDIAN", 160, 4, 26, 4, 2, 1, 320);
        add(list, "Masala Dosa", "masaala dosa", "SOUTH_INDIAN", 170, 4, 28, 5, 2.5, 1.5, 350);
        add(list, "Rava Dosa", null, "SOUTH_INDIAN", 180, 4, 27, 6, 1.5, 1, 360);
        add(list, "Uttapam", null, "SOUTH_INDIAN", 165, 4.5, 26, 5, 2.5, 2, 340);
        add(list, "Medu Vada", "vada,ulundu vada", "SOUTH_INDIAN", 250, 8, 24, 14, 4, 1, 380);
        add(list, "Sambar", "sambhar", "SOUTH_INDIAN", 70, 3, 10, 2, 3, 2.5, 380);
        add(list, "Rasam", null, "SOUTH_INDIAN", 35, 1.5, 6, 0.5, 1, 1.5, 300);
        add(list, "Upma", "rava upma", "SOUTH_INDIAN", 140, 3.5, 24, 4, 2.5, 1.5, 350);
        add(list, "Pongal", "ven pongal", "SOUTH_INDIAN", 155, 4.5, 24, 5, 1.5, 0.5, 320);
        add(list, "Lemon Rice", "chitranna", "SOUTH_INDIAN", 160, 3, 28, 4, 1.5, 1, 300);
        add(list, "Curd Rice", "thayir sadam,dahi rice", "SOUTH_INDIAN", 120, 3.5, 20, 2.5, 0.5, 3, 250);
        add(list, "Coconut Chutney", "chutney", "SOUTH_INDIAN", 180, 3, 8, 16, 3, 2, 250);
        add(list, "Appam", null, "SOUTH_INDIAN", 150, 3, 28, 3, 1.5, 1, 200);
        add(list, "Puttu", null, "SOUTH_INDIAN", 145, 3.5, 28, 2, 2.5, 0.5, 150);

        // Snacks
        add(list, "Samosa", "aloo samosa", "SNACK", 260, 5, 28, 14, 2, 1.5, 400);
        add(list, "Pakora", "pakoda,bhajiya", "SNACK", 280, 6, 24, 18, 2.5, 2, 420);
        add(list, "Bhel Puri", "bhel", "SNACK", 160, 4, 28, 4, 3, 4, 380);
        add(list, "Pani Puri", "golgappa,puchka", "SNACK", 140, 3, 26, 3, 2, 1, 350);
        add(list, "Vada Pav", null, "SNACK", 250, 6, 32, 11, 2.5, 3, 450);
        add(list, "Pav Bhaji", null, "SNACK", 180, 5, 24, 8, 3, 4, 500);
        add(list, "Misal Pav", null, "SNACK", 190, 7, 22, 8, 4, 3, 480);
        add(list, "Dhokla", "khaman", "SNACK", 140, 5, 22, 4, 2, 2, 320);
        add(list, "Kachori", null, "SNACK", 300, 6, 30, 18, 2, 2, 400);
        add(list, "Namkeen", "mixture,chiwda", "SNACK", 520, 8, 48, 32, 4, 2, 700);
        add(list, "French Fries", "fries", "SNACK", 310, 3.5, 40, 15, 3.5, 0.5, 300);

        // Sweets
        add(list, "Gulab Jamun", null, "SWEET", 300, 4, 45, 12, 0.5, 35, 80);
        add(list, "Jalebi", null, "SWEET", 320, 2, 55, 10, 0.5, 40, 50);
        add(list, "Rasgulla", "rossogolla", "SWEET", 180, 5, 35, 2, 0, 30, 40);
        add(list, "Kaju Katli", "kaju barfi", "SWEET", 450, 8, 45, 25, 1, 35, 30);
        add(list, "Ladoo", "laddu,besan ladoo", "SWEET", 420, 7, 50, 20, 2, 30, 60);
        add(list, "Halwa", "gajar halwa,carrot halwa", "SWEET", 280, 4, 40, 12, 2, 28, 120);
        add(list, "Ice Cream", null, "SWEET", 210, 3.5, 24, 11, 0.5, 21, 80);

        // Protein / lighter
        add(list, "Grilled Chicken", "tandoori chicken,chicken tikka", "PROTEIN", 165, 31, 0, 3.5, 0, 0, 250);
        add(list, "Egg Bhurji", "anda bhurji,scrambled eggs", "PROTEIN", 180, 13, 3, 13, 0.5, 1.5, 320);
        add(list, "Boiled Egg", "egg", "PROTEIN", 155, 13, 1.1, 11, 0, 1.1, 124);
        add(list, "Chicken Salad", null, "PROTEIN", 120, 18, 4, 4, 1.5, 2, 280);
        add(list, "Sprouts Salad", "sprouts", "PROTEIN", 90, 7, 14, 1, 4, 2, 150);
        add(list, "Paneer Tikka", null, "PROTEIN", 200, 14, 6, 13, 1, 3, 380);

        // Global / common
        add(list, "Garden Salad", "salad,green salad", "GENERAL", 45, 2, 6, 1.5, 2.5, 2.5, 80);
        add(list, "Caesar Salad", null, "GENERAL", 120, 7, 6, 8, 2, 2, 420);
        add(list, "Margherita Pizza", "pizza", "GENERAL", 250, 11, 30, 9, 2, 3.5, 520);
        add(list, "Hamburger", "burger", "GENERAL", 265, 13, 24, 14, 1.5, 5, 480);
        add(list, "Pasta", "spaghetti,noodles", "GENERAL", 160, 6, 28, 3, 2, 1.5, 250);
        add(list, "Sandwich", null, "GENERAL", 230, 10, 28, 9, 2.5, 4, 450);
        add(list, "Oats", "oatmeal", "GENERAL", 70, 2.5, 12, 1.5, 2, 0.5, 40);
        add(list, "Apple", null, "FRUIT", 52, 0.3, 14, 0.2, 2.4, 10, 1);
        add(list, "Banana", null, "FRUIT", 89, 1.1, 23, 0.3, 2.6, 12, 1);
        add(list, "Mango", null, "FRUIT", 60, 0.8, 15, 0.4, 1.6, 14, 1);
        add(list, "Unknown Food", null, "GENERAL", 180, 8, 18, 8, 2.5, 3, 220);

        return list;
    }

    private static void add(
            List<FoodNutrition> list,
            String name,
            String aliases,
            String category,
            int calories,
            double protein,
            double carbs,
            double fat,
            double fibre,
            double sugar,
            double sodiumMg
    ) {
        FoodNutrition row = new FoodNutrition();
        row.setName(name);
        row.setNormalizedName(name.trim().toLowerCase(Locale.ENGLISH));
        row.setAliases(aliases);
        row.setCategory(category);
        row.setCaloriesPer100g(calories);
        row.setProteinPer100g(protein);
        row.setCarbsPer100g(carbs);
        row.setFatPer100g(fat);
        row.setFibrePer100g(fibre);
        row.setSugarPer100g(sugar);
        row.setSodiumMgPer100g(sodiumMg);
        row.setSource("SEED");
        list.add(row);
    }
}
