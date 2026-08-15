package com.foodscan.backend.awareness;

import com.foodscan.backend.dto.IngredientAwarenessDto;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Locale;

/**
 * Educational dish-category tips. Not a lab analysis of the photographed plate.
 */
@Component
public class IngredientAwarenessService {

    public static final String DISCLAIMER =
            "Based on typical preparation for this dish category — not a lab analysis of this plate.";

    public IngredientAwarenessDto forFoodName(String foodName) {
        String name = foodName == null ? "" : foodName.trim().toLowerCase(Locale.ENGLISH);

        if (containsAny(name, "butter masala", "butter chicken", "makhani", "tikka masala", "korma", "gravy")) {
            return awareness(
                    "Restaurant-style gravy",
                    List.of(
                            "Artificial orange/red food colors are sometimes used for richer gravy look",
                            "Flavor enhancers (e.g. MSG) may be added in commercial kitchens",
                            "Cream, butter, and excess oil are common in restaurant versions"
                    ),
                    List.of(
                            "Ask for less oil/butter, or choose a tomato-based home-style curry",
                            "Pair with salad or grilled sides instead of fried starters",
                            "Prefer homemade versions with natural tomato/spice color"
                    )
            );
        }

        if (containsAny(name, "samosa", "pakora", "french fries", "fried", "nugget", "bhaji", "puri")) {
            return awareness(
                    "Deep-fried foods",
                    List.of(
                            "Reused frying oil can degrade and form unwanted compounds over time",
                            "Commercial coatings may include artificial color for golden appearance",
                            "Often high in refined flour and salt"
                    ),
                    List.of(
                            "Choose baked/air-fried options when available",
                            "Limit portion size and balance with vegetables or dal",
                            "Prefer freshly fried oil over leftover oil when cooking at home"
                    )
            );
        }

        if (containsAny(name, "pizza", "burger", "hamburger", "sandwich", "hot dog")) {
            return awareness(
                    "Processed / fast food",
                    List.of(
                            "Processed meats and sauces may include preservatives and color additives",
                            "Refined flour bases and high sodium are common",
                            "Cheese analogues or flavor boosters can appear in cheaper versions"
                    ),
                    List.of(
                            "Choose thinner crust, extra veggies, and lighter cheese",
                            "Skip sugary drinks; drink water",
                            "Prefer grilled over deep-fried sides"
                    )
            );
        }

        if (containsAny(name, "biryani", "pulao", "fried rice", "noodles", "pasta")) {
            return awareness(
                    "Rice / grain mains",
                    List.of(
                            "Restaurant coloring (yellow/orange) is sometimes used for visual appeal",
                            "Excess oil/ghee and salt are common in commercial batches",
                            "Flavor enhancers may be used in takeaway versions"
                    ),
                    List.of(
                            "Ask for less oil and less salt",
                            "Add a side of raita, salad, or dal for balance",
                            "Prefer brown rice / millet versions when available"
                    )
            );
        }

        if (containsAny(name, "sweet", "ladoo", "halwa", "ice cream", "cake", "mithai", "dessert", "gulab")) {
            return awareness(
                    "Sweets & desserts",
                    List.of(
                            "Bright artificial colors are frequently used in commercial sweets",
                            "High refined sugar and sometimes non-dairy fat substitutes",
                            "Silver leaf / decorative coatings may be cosmetic rather than nutritious"
                    ),
                    List.of(
                            "Share a smaller portion or choose fruit-based desserts",
                            "Prefer homemade sweets with less sugar and natural color",
                            "Check packaged labels for E-number colors when buying boxed sweets"
                    )
            );
        }

        if (containsAny(name, "salad", "grilled", "idli", "idly", "steamed", "soup", "dal")) {
            return awareness(
                    "Generally lighter choice",
                    List.of(
                            "Dressings/chutneys can still hide added sugar, salt, or color",
                            "Store-bought sauces may include preservatives"
                    ),
                    List.of(
                            "Keep dressings on the side",
                            "Favor steamed/grilled preparations",
                            "Watch portion of oily tadka or creamy dressings"
                    )
            );
        }

        return awareness(
                "General meal",
                List.of(
                        "Restaurant and packaged versions may include artificial colors or flavor enhancers",
                        "Oil, salt, and sugar levels vary widely by kitchen"
                ),
                List.of(
                        "Prefer home-cooked meals with whole ingredients when possible",
                        "For packaged foods, read the ingredient list for colors and preservatives",
                        "Balance richer dishes with vegetables, yogurt, or salad"
                )
        );
    }

    private IngredientAwarenessDto awareness(
            String category,
            List<String> additives,
            List<String> swaps
    ) {
        return new IngredientAwarenessDto(category, additives, swaps, DISCLAIMER);
    }

    private static boolean containsAny(String name, String... keywords) {
        for (String keyword : keywords) {
            if (name.contains(keyword)) {
                return true;
            }
        }
        return false;
    }
}
