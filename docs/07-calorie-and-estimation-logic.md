# FoodScan — Calorie & Estimation Logic Explainer

Use this document when someone asks **how FoodScan calculates calories**, **daily goals**, or **ingredient awareness**.

> **Important disclaimer (say this first):**  
> FoodScan values are **estimates for personal tracking**, not medical, clinical, or lab-certified nutrition advice.

---

## 1. Two different “calorie” numbers

| What | Where user sees it | What it means |
|------|--------------------|---------------|
| **Daily calorie target** | Profile + Home ring | How many kcal the user should roughly eat **today** |
| **Meal calories** | After scan → portion → Nutrition | Estimated kcal **in that meal/portion** |

These use **different formulas**. Do not mix them up when explaining.

---

## 2. Daily calorie target (Profile → Home)

### Purpose
Estimate a reasonable **daily kcal goal** from the user’s body metrics, activity, and fitness goal.

### When it recalculates
Every time the user taps **Save changes** on Profile.

Saved fields (Postgres `users` table):
- `age`, `weight_kg`, `height_cm`
- `gender`
- `activity_level`
- `goal`
- `daily_goal_kcal` ← computed result used by Home

Home loads this via `GET /api/v1/me/today` → `goalKcal`.

### Formula (Mifflin–St Jeor based)

**Step A — BMR (Basal Metabolic Rate)**  
Calories the body needs at rest:

```text
BMR = (10 × weight_kg) + (6.25 × height_cm) − (5 × age) + sex_constant
```

| Gender | `sex_constant` | Source |
|--------|------------------|--------|
| Male | `+5` | Mifflin–St Jeor (male) |
| Female | `−161` | Mifflin–St Jeor (female) |
| Prefer not to say (`UNSPECIFIED`) | `−78` | Midpoint of +5 and −161 |

**Step B — Maintenance (TDEE estimate)**  
Multiply BMR by activity:

```text
Maintenance = BMR × activity_multiplier
```

| Activity level (UI) | API value | Multiplier | Typical meaning |
|----------------------|-----------|------------|-----------------|
| Sedentary | `SEDENTARY` | **1.2** | Desk job, little/no exercise |
| Lightly active | `LIGHTLY_ACTIVE` | **1.375** | Light exercise 1–3 days/week |
| Moderately active | `MODERATELY_ACTIVE` | **1.55** | Exercise 3–5 days/week |
| Very active | `VERY_ACTIVE` | **1.725** | Hard exercise 6–7 days/week |

These multipliers are the **standard Harris–Benedict / Mifflin activity factors** used by many fitness apps.

**Step C — Goal adjustment**

| Goal (UI) | API value | Adjustment |
|-----------|-----------|-----------|
| Lose Weight | `LOSE_WEIGHT` | Maintenance **− 400** kcal |
| Maintain | `MAINTAIN` | Maintenance **+ 0** |
| Gain Muscle | `GAIN_MUSCLE` | Maintenance **+ 300** kcal |

±300 / ±400 are **common rule-of-thumb** surplus/deficit amounts (roughly associated with gradual weight change), not personalized prescriptions.

**Step D — Safety clamp**

```text
daily_goal_kcal = round( clamp(target, 1200, 4000) )
```

| Limit | Why |
|-------|-----|
| Min **1200** | Avoid unrealistically low targets from edge inputs |
| Max **4000** | Cap extreme outliers |

### Worked example (for demos)

Example profile:
- Age 30, Weight 70 kg, Height 170 cm  
- Gender: Male  
- Activity: Sedentary  
- Goal: Lose Weight  

```text
BMR = (10×70) + (6.25×170) − (5×30) + 5
    = 700 + 1062.5 − 150 + 5
    = 1617.5

Maintenance = 1617.5 × 1.2 ≈ 1941

Lose Weight target = 1941 − 400 = 1541
→ daily_goal_kcal ≈ 1541
```

### Code location
- `backend/.../nutrition/DailyCalorieGoalCalculator.java`
- Applied in `MeService.updateProfile(...)`

### What this is *not*
- Not measured energy expenditure (no wearable)
- Not adjusted for body fat %, medical conditions, or medications
- Not a dietitian plan

---

## 3. Meal calorie & macro estimation (after food scan)

### Purpose
After the AI (or user) identifies a dish name and the user picks a **portion in grams**, estimate:
- calories  
- protein (g)  
- carbs (g)  
- fat (g)

### Pipeline
```text
Photo → AI food name + confidence
     → User confirms / edits name
     → User selects portion (g)
     → Backend estimates nutrition per 100g for that name
     → Scale by portionGrams / 100
```

### Formula for a portion

Nutrition profiles are stored/estimated **per 100g**:

```text
factor = portionGrams / 100

calories      = round(caloriesPer100g × factor)
proteinGrams  = round1(proteinPer100g × factor)
carbsGrams    = round1(carbsPer100g × factor)
fatGrams      = round1(fatPer100g × factor)
```

### How per-100g values are chosen
`NutritionEstimator`:

1. **Exact name match** (normalized lowercase), e.g. `paneer butter masala`  
2. Else **partial name contains** known dish keys  
3. Else **keyword heuristics** (e.g. contains `pizza`, `salad`, `fried`)  
4. Else **default profile** (~180 kcal / 8p / 18c / 8f per 100g)

### Code location
- `backend/.../nutrition/NutritionEstimator.java`
- Used by `ScanService.nutritionFor(...)`

### What this is *not*
- Not a lab analysis of the plate  
- Not USDA-certified lookup for every dish  
- Restaurant vs homemade versions can differ a lot  

---

## 4. Ingredient awareness (additives / colors / swaps)

### Purpose
Give **educational tips** for the dish **category** (e.g. restaurant gravy, fried foods).

Shown on the Detection screen as:
- Likely additives / colors  
- Healthier swaps  
- Disclaimer

### How it works
Match food **name keywords** → category template (not pixel-level chemical detection).

Examples:
- `butter masala`, `korma`, `gravy` → Restaurant-style gravy tips  
- `samosa`, `fries`, `fried` → Deep-fried tips  
- `pizza`, `burger` → Processed / fast food tips  
- sweets / biryani / salad categories similarly  

### Disclaimer (must say)
> “Based on typical preparation for this dish category — **not a lab analysis of this plate**.”

### Why we cannot detect chemicals from the photo alone
A photo can suggest the **dish**. It cannot prove specific additives (E-numbers, MSG, food colors) in that exact kitchen’s recipe.

### Code locations
- Backend: `backend/.../awareness/IngredientAwarenessService.java` (attached to scan API `food.awareness`)
- Mobile: `ui_screens/mobile/lib/models/ingredient_awareness.dart` (also recomputes if user renames food)

---

## 5. Food recognition (AI) vs nutrition math

| Step | Component | Output |
|------|-----------|--------|
| Identify dish | AI service (mock or OpenAI vision) | `foodName`, `confidence` |
| Daily goal | Backend calculator | `dailyGoalKcal` |
| Meal macros | Backend estimator | calories + P/C/F for portion |
| Awareness | Rule templates by name | tips + disclaimer |

Clients never call the AI service directly; mobile talks to **Spring Boot**, which calls AI.

---

## 6. Talking points (short answers)

**Q: How do you calculate daily calories?**  
A: Mifflin–St Jeor BMR from age/weight/height/gender, times activity factor, then adjust for lose/maintain/gain, clamped to 1200–4000.

**Q: Are meal calories exact?**  
A: No — estimated from dish name and portion size using approximate per-100g profiles.

**Q: Can you detect harmful chemicals in the photo?**  
A: No. We show category-based awareness tips for typical preparations, with a clear non-lab disclaimer.

**Q: How does packaged scanning work?**  
A: Barcode → Open Food Facts via backend → rule flags (E-numbers, sugar/salt, keywords) + swaps. No AI in Phase 1.

**Q: Why am I still logged in after closing the app?**  
A: JWT is stored on device; Splash validates it and opens Home when still valid. Profile → Log out clears it.

**Q: Where is data stored?**  
A: User profile and daily goal in Postgres `users`; meals in meal entries; scans store detected food name/confidence. Packaged lookups are not persisted as meals in Phase 1.

---

## 7. Future improvements (if asked “what’s next?”)

1. Optional sex already added; could add **Extra active (×1.9)** later  
2. Better meal nutrition via branded food DB / barcode / label OCR  
3. Let advanced users **manually override** daily kcal  
4. Activity from wearables (Apple Health / Google Fit)

---

## 8. Key source files

| Topic | File |
|-------|------|
| Daily goal formula | `backend/src/main/java/com/foodscan/backend/nutrition/DailyCalorieGoalCalculator.java` |
| Profile save applies goal | `backend/src/main/java/com/foodscan/backend/service/MeService.java` |
| Meal nutrition estimate | `backend/src/main/java/com/foodscan/backend/nutrition/NutritionEstimator.java` |
| Ingredient awareness (API) | `backend/src/main/java/com/foodscan/backend/awareness/IngredientAwarenessService.java` |
| Ingredient awareness (app) | `ui_screens/mobile/lib/models/ingredient_awareness.dart` |
| Profile UI | `ui_screens/mobile/lib/screens/profile/profile_screen.dart` |
| Packaged barcode API | `backend/src/main/java/com/foodscan/backend/controller/PackagedFoodController.java` |
| Packaged risk rules | `backend/src/main/java/com/foodscan/backend/packaged/PackagedFoodRiskAnalyzer.java` |

---

## 9. Packaged food barcode check (no AI)

### Purpose
Scan a packaged product barcode and flag likely unhealthy ingredients using:
1. **Open Food Facts** product lookup (free public DB)
2. **Rule engine** in the backend (E-numbers, sugar/salt thresholds, keyword risks)
3. **Healthier swap** suggestions by product category

### API
`GET /api/v1/packaged/barcode/{barcode}` (auth required)

### Score
- `BETTER` — no major rule hits  
- `OK` — some medium concerns  
- `CAUTION` — multiple / high-severity concerns  

### Disclaimer
Educational label/rules check — not a lab test or medical advice.

### Later (optional AI)
Use AI only for OCR / unlisted products / deeper explanations when barcode lookup fails.

### Mobile path
Scan → **Packaged** tab → Scan barcode → result (flags + swaps)
