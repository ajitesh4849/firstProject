package com.foodscan.backend.packaged;

import com.foodscan.backend.entity.PackagedProductSeed;
import com.foodscan.backend.repository.PackagedProductSeedRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 * Seeds a curated India packaged-food catalog (barcode → label data).
 * Inserts only missing barcodes — never overwrites user-saved products.
 */
@Component
@Order(25)
public class PackagedProductSeedRunner implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(PackagedProductSeedRunner.class);

    private final PackagedProductSeedRepository repository;

    public PackagedProductSeedRunner(PackagedProductSeedRepository repository) {
        this.repository = repository;
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        int inserted = 0;
        for (Seed row : SEEDS) {
            if (repository.findByBarcode(row.barcode()).isPresent()) {
                continue;
            }
            PackagedProductSeed seed = new PackagedProductSeed();
            seed.setBarcode(row.barcode());
            seed.setProductName(row.name());
            seed.setBrand(row.brand());
            seed.setQuantity(row.quantity());
            seed.setIngredientsText(row.ingredients());
            seed.setCategories(row.categories());
            seed.setSugarPer100g(row.sugar());
            seed.setSaltPer100g(row.salt());
            seed.setEnergyKcalPer100g(row.kcal());
            seed.setSource("SEED");
            repository.save(seed);
            inserted++;
        }
        log.info(
                "Packaged seed catalog: {} new rows (total seeds in DB: {})",
                inserted,
                repository.count()
        );
    }

    /**
     * Demo barcodes use India GS1 prefix 890 + FoodScan series 10…
     * Approximate label values for education — not lab-certified.
     */
    private static final Seed[] SEEDS = {
            // Instant noodles / snacks
            seed("8901000000001", "2-Minute Masala Noodles", "Maggi", "70g",
                    "en:instant-noodles,en:snacks",
                    "Refined wheat flour (maida), palm oil, iodised salt, wheat gluten, "
                            + "thickeners (508, 412), acidity regulators (501(i), 500(i), 330), "
                            + "humectant (451(i)), taste enhancer (627, 631), spices & condiments, "
                            + "sugar, mineral (ferrous sulphate), colour (150d)",
                    2.8, 3.8, 420),
            seed("8901000000002", "Classic Salted Potato Chips", "Lay's", "52g",
                    "en:chips,en:snacks,en:potato-crisps",
                    "Potato, edible vegetable oil (palmolein), iodised salt",
                    0.5, 1.4, 536),
            seed("8901000000003", "Magic Masala Chips", "Lay's", "52g",
                    "en:chips,en:snacks",
                    "Potato, edible vegetable oil, spices & condiments, sugar, iodised salt, "
                            + "flavour enhancer (635), acidity regulator (330)",
                    1.2, 1.6, 540),
            seed("8901000000004", "Aloo Bhujia", "Haldiram's", "200g",
                    "en:namkeen,en:snacks,en:bhujia",
                    "Potato, edible vegetable oil, chickpea flour (besan), spices, iodised salt, "
                            + "citric acid, antioxidant (319)",
                    2.0, 2.2, 560),
            seed("8901000000005", "Moong Dal Namkeen", "Haldiram's", "200g",
                    "en:namkeen,en:snacks",
                    "Moong dal, edible vegetable oil, iodised salt, spices",
                    1.5, 1.8, 520),
            seed("8901000000006", "Kurkure Masala Munch", "Kurkure", "90g",
                    "en:snacks,en:extruded-snacks",
                    "Corn meal, edible vegetable oil, rice meal, spices & condiments, sugar, "
                            + "iodised salt, flavour enhancer (635), colour (110, 122)",
                    3.5, 2.0, 545),

            // Biscuits / sweets
            seed("8901000000010", "Glucose Biscuits", "Parle-G", "100g",
                    "en:biscuits,en:cookies,en:sweet",
                    "Wheat flour, sugar, edible vegetable oil, invert sugar syrup, leavening agents "
                            + "(503(ii), 500(ii)), milk solids, iodised salt, emulsifier (322)",
                    25.0, 0.9, 450),
            seed("8901000000011", "Good Day Butter Cookies", "Britannia", "100g",
                    "en:biscuits,en:cookies,en:sweet",
                    "Refined wheat flour, sugar, edible vegetable oil, butter, milk solids, "
                            + "invert syrup, raising agents, iodised salt, emulsifiers",
                    28.0, 0.8, 510),
            seed("8901000000012", "Bourbon Cream Biscuits", "Britannia", "100g",
                    "en:biscuits,en:chocolate,en:sweet",
                    "Wheat flour, sugar, edible vegetable fat, cocoa solids, invert syrup, "
                            + "raising agents, emulsifiers, iodised salt, artificial flavouring",
                    32.0, 0.7, 495),
            seed("8901000000013", "Marie Gold Biscuits", "Britannia", "100g",
                    "en:biscuits,en:cookies",
                    "Wheat flour, sugar, edible vegetable oil, invert syrup, raising agents, "
                            + "milk solids, iodised salt, emulsifier",
                    18.0, 0.85, 430),
            seed("8901000000014", "Dark Fantasy Choco Fills", "Sunfeast", "75g",
                    "en:biscuits,en:chocolate,en:sweet",
                    "Wheat flour, sugar, edible vegetable fat, cocoa solids, cocoa butter, "
                            + "milk solids, emulsifiers, raising agents, artificial colours",
                    35.0, 0.6, 520),

            // Soft drinks
            seed("8901000000020", "Thums Up", "Coca-Cola", "750ml",
                    "en:soft-drinks,en:beverages,en:cola,en:soda",
                    "Carbonated water, sugar, acidity regulator (338), caffeine, natural flavouring colours",
                    10.6, 0.02, 42),
            seed("8901000000021", "Coca-Cola", "Coca-Cola", "750ml",
                    "en:soft-drinks,en:beverages,en:cola,en:soda",
                    "Carbonated water, sugar, colour (150d), acidity regulator (338), natural flavouring",
                    10.6, 0.01, 42),
            seed("8901000000022", "Sprite", "Coca-Cola", "750ml",
                    "en:soft-drinks,en:beverages,en:soda",
                    "Carbonated water, sugar, acidity regulators (330, 331), natural lemon-lime flavour",
                    10.1, 0.02, 40),
            seed("8901000000023", "Maaza Mango", "Coca-Cola", "600ml",
                    "en:beverages,en:juice-drink,en:mango-drink",
                    "Water, sugar, mango pulp, acidity regulator (330), preservative (211), "
                            + "stabiliser (440), artificial flavour",
                    12.5, 0.05, 52),
            seed("8901000000024", "Frooti", "Parle Agro", "160ml",
                    "en:beverages,en:juice-drink",
                    "Water, sugar, mango pulp, acidity regulator, preservatives, stabilisers, colour",
                    13.0, 0.04, 54),

            // Dairy / staples
            seed("8901000000030", "Amul Pasteurised Butter", "Amul", "100g",
                    "en:dairy,en:butter",
                    "Butter (from milk), salt",
                    0.5, 1.5, 720),
            seed("8901000000031", "Amul Taaza Toned Milk", "Amul", "1L",
                    "en:dairy,en:milk",
                    "Toned milk",
                    5.0, 0.1, 58),
            seed("8901000000032", "Amul Cheese Slices", "Amul", "200g",
                    "en:dairy,en:cheese",
                    "Cheese, emulsifying salts, preservative, iodised salt",
                    1.5, 2.2, 300),
            seed("8901000000033", "Mother Dairy Classic Curd", "Mother Dairy", "400g",
                    "en:dairy,en:curd,en:yogurt",
                    "Milk, milk solids, live cultures",
                    4.5, 0.1, 60),
            seed("8901000000034", "Amul Cool Cafe Coffee", "Amul", "200ml",
                    "en:beverages,en:dairy-drink",
                    "Milk, sugar, coffee solids, stabilisers",
                    9.0, 0.15, 75),

            // Breakfast / cereal
            seed("8901000000040", "Corn Flakes", "Kellogg's", "475g",
                    "en:breakfast-cereals,en:cereal",
                    "Milled corn, sugar, malt flavouring, iodised salt, vitamins & minerals",
                    8.0, 1.1, 378),
            seed("8901000000041", "Chocos", "Kellogg's", "375g",
                    "en:breakfast-cereals,en:cereal,en:sweet",
                    "Wheat flour, sugar, cocoa, edible vegetable oil, iodised salt, vitamins, colour",
                    28.0, 0.9, 390),
            seed("8901000000042", "Saffola Masala Oats", "Saffola", "40g",
                    "en:breakfast-cereals,en:oats,en:cereal",
                    "Oats, dehydrated vegetables, spices & condiments, iodised salt, sugar",
                    3.5, 1.8, 380),
            seed("8901000000043", "Quaker Oats", "Quaker", "1kg",
                    "en:breakfast-cereals,en:oats,en:cereal",
                    "Whole grain oats",
                    1.0, 0.02, 379),

            // Spreads / condiments
            seed("8901000000050", "Kissan Mixed Fruit Jam", "Kissan", "500g",
                    "en:spreads,en:jam,en:sweet",
                    "Sugar, mixed fruit pulp, acidity regulator (330), preservative (211), pectin",
                    55.0, 0.05, 260),
            seed("8901000000051", "Kissan Fresh Tomato Ketchup", "Kissan", "500g",
                    "en:sauces,en:ketchup",
                    "Tomato paste, sugar, iodised salt, acidity regulator, spices, preservative",
                    22.0, 2.5, 110),
            seed("8901000000052", "Maggi Rich Tomato Ketchup", "Maggi", "500g",
                    "en:sauces,en:ketchup",
                    "Tomato paste, sugar, iodised salt, spices, acidity regulator, preservative",
                    23.0, 2.8, 115),
            seed("8901000000053", "Peanut Butter Crunchy", "Pintola", "350g",
                    "en:spreads,en:peanut-butter,en:nuts",
                    "Roasted peanuts, sugar, edible vegetable oil, iodised salt",
                    8.0, 0.8, 590),
            seed("8901000000054", "Nutella Hazelnut Spread", "Ferrero", "350g",
                    "en:spreads,en:chocolate,en:sweet,en:nuts",
                    "Sugar, palm oil, hazelnuts, skimmed milk powder, fat-reduced cocoa, lecithin, vanillin",
                    56.0, 0.1, 539),

            // Bakery / bread
            seed("8901000000060", "Whole Wheat Bread", "Britannia", "400g",
                    "en:breads,en:bakery",
                    "Whole wheat flour, water, yeast, sugar, edible vegetable oil, iodised salt, gluten",
                    4.0, 1.0, 245),
            seed("8901000000061", "White Bread", "Modern", "400g",
                    "en:breads,en:bakery",
                    "Refined wheat flour (maida), water, yeast, sugar, edible oil, iodised salt",
                    5.0, 1.1, 265),
            seed("8901000000062", "Sandwich Bread", "English Oven", "400g",
                    "en:breads,en:bakery",
                    "Wheat flour, water, yeast, sugar, vegetable oil, iodised salt, emulsifiers",
                    4.5, 1.0, 255),

            // Ready to eat / other
            seed("8901000000070", "MTR Ready Ready-to-Eat Dal Makhani", "MTR", "300g",
                    "en:ready-meals,en:indian-meals",
                    "Water, black gram, kidney beans, tomato, cream, butter, spices, iodised salt, oil",
                    3.0, 1.2, 130),
            seed("8901000000071", "Bingo Mad Angles", "Bingo", "80g",
                    "en:snacks,en:chips",
                    "Corn meal, edible vegetable oil, rice meal, spices, sugar, iodised salt, "
                            + "flavour enhancer, colour (110)",
                    2.5, 1.9, 530),
            seed("8901000000072", "Uncle Chipps Spicy Treat", "Uncle Chipps", "55g",
                    "en:chips,en:snacks",
                    "Potato, edible vegetable oil, spices & condiments, iodised salt, flavour enhancer",
                    1.0, 1.5, 535),
            seed("8901000000073", "Cadbury Dairy Milk", "Cadbury", "50g",
                    "en:chocolate,en:candy,en:sweet",
                    "Sugar, milk solids, cocoa butter, cocoa solids, emulsifiers, artificial flavouring",
                    55.0, 0.2, 535),
            seed("8901000000074", "Perk", "Cadbury", "22g",
                    "en:chocolate,en:candy,en:sweet",
                    "Sugar, wheat flour, edible vegetable fat, cocoa solids, milk solids, emulsifiers",
                    45.0, 0.3, 500),
            seed("8901000000075", "Hide & Seek Chocolate Chip Cookies", "Parle", "100g",
                    "en:biscuits,en:cookies,en:chocolate,en:sweet",
                    "Wheat flour, sugar, edible vegetable fat, chocolate chips, milk solids, "
                            + "raising agents, emulsifiers, iodised salt",
                    30.0, 0.7, 505),
            seed("8901000000076", "Real Fruit Power Mixed Fruit", "Dabur", "1L",
                    "en:beverages,en:juice-drink",
                    "Water, sugar, mixed fruit concentrates, acidity regulator, preservative, flavour",
                    11.5, 0.03, 48),
            seed("8901000000077", "Tropicana 100% Orange", "Tropicana", "1L",
                    "en:beverages,en:juice",
                    "Orange juice from concentrate",
                    9.0, 0.01, 45),
            seed("8901000000078", "Act II Microwave Popcorn Butter", "Act II", "70g",
                    "en:snacks,en:popcorn",
                    "Corn, palm oil, salt, natural & artificial butter flavour, colour",
                    0.5, 2.0, 480),
            seed("8901000000079", "Yippee Magic Masala Noodles", "Sunfeast", "70g",
                    "en:instant-noodles,en:snacks",
                    "Refined wheat flour, palm oil, iodised salt, spices, taste enhancers, "
                            + "acidity regulators, colour (150d)",
                    2.5, 3.5, 430),
            seed("8901000000080", "Knorr Soup Tomato Chatpata", "Knorr", "45g",
                    "en:soups,en:instant",
                    "Sugar, corn starch, iodised salt, tomato powder, spices, acidity regulator, flavour enhancers",
                    18.0, 8.0, 350),
    };

    private static Seed seed(
            String barcode,
            String name,
            String brand,
            String quantity,
            String categories,
            String ingredients,
            double sugar,
            double salt,
            double kcal
    ) {
        return new Seed(barcode, name, brand, quantity, categories, ingredients, sugar, salt, kcal);
    }

    private record Seed(
            String barcode,
            String name,
            String brand,
            String quantity,
            String categories,
            String ingredients,
            double sugar,
            double salt,
            double kcal
    ) {
    }
}
