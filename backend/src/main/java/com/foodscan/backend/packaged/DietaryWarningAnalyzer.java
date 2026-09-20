package com.foodscan.backend.packaged;

import com.foodscan.backend.dto.AllergyWarningDto;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Set;

/**
 * Soft allergy / diet checks from ingredient text — educational aid, not a guarantee.
 */
@Component
public class DietaryWarningAnalyzer {

    public List<AllergyWarningDto> warnings(String ingredientsText, String dietPreference, String allergensCsv) {
        String text = ingredientsText == null ? "" : ingredientsText.toLowerCase(Locale.ENGLISH);
        List<AllergyWarningDto> out = new ArrayList<>();
        Set<String> allergens = parseCsv(allergensCsv);

        if (allergens.contains("PEANUT") && containsAny(text, "peanut", "groundnut")) {
            out.add(warn("PEANUT", "May contain peanut", "Peanut-related wording found in the ingredient text."));
        }
        if (allergens.contains("NUT") && containsAny(text, "almond", "cashew", "walnut", "pistachio", "hazelnut", "tree nut")) {
            out.add(warn("NUT", "May contain tree nuts", "Nut-related wording found in the ingredient text."));
        }
        if (allergens.contains("DAIRY") && containsAny(text, "milk", "butter", "cream", "whey", "casein", "ghee", "curd", "cheese")) {
            out.add(warn("DAIRY", "May contain dairy", "Dairy-related wording found in the ingredient text."));
        }
        if (allergens.contains("GLUTEN") && containsAny(text, "wheat", "maida", "gluten", "barley", "rye", "atta")) {
            out.add(warn("GLUTEN", "May contain gluten", "Gluten/wheat-related wording found in the ingredient text."));
        }

        String diet = dietPreference == null ? "NONE" : dietPreference.trim().toUpperCase(Locale.ENGLISH);
        if ("VEGAN".equals(diet) && containsAny(text, "milk", "egg", "honey", "ghee", "butter", "whey", "casein", "gelatin", "fish", "chicken", "meat")) {
            out.add(warn("VEGAN", "May not fit vegan preference", "Animal-derived wording appears in the ingredient list."));
        } else if ("VEGETARIAN".equals(diet) && containsAny(text, "chicken", "mutton", "beef", "fish", "meat", "gelatin", "lard")) {
            out.add(warn("VEGETARIAN", "May not fit vegetarian preference", "Non-vegetarian wording appears in the ingredient list."));
        }

        return out;
    }

    private static AllergyWarningDto warn(String code, String title, String detail) {
        return new AllergyWarningDto(
                code,
                title,
                detail + " Educational aid only — labels and manufacturing can change."
        );
    }

    private static Set<String> parseCsv(String csv) {
        if (csv == null || csv.isBlank()) {
            return Set.of();
        }
        String[] parts = csv.split(",");
        java.util.HashSet<String> set = new java.util.HashSet<>();
        for (String part : parts) {
            String p = part.trim().toUpperCase(Locale.ENGLISH);
            if (!p.isEmpty()) {
                set.add(p);
            }
        }
        return set;
    }

    private static boolean containsAny(String text, String... keywords) {
        for (String keyword : keywords) {
            if (text.contains(keyword)) {
                return true;
            }
        }
        return false;
    }
}
