const mealSteps = [
  {
    number: "01",
    title: "Scan a meal photo",
    description: "Point your phone at a plated meal or pick a photo from your library.",
  },
  {
    number: "02",
    title: "Confirm the dish",
    description:
      "AI suggests a name with confidence. Edit if needed and see dish-style awareness tips.",
  },
  {
    number: "03",
    title: "Estimate nutrition",
    description:
      "Pick a portion and review estimated calories, protein, carbs, and fat.",
  },
  {
    number: "04",
    title: "Track your day",
    description: "Add the meal to today and review history against your calorie goal.",
  },
];

const packagedSteps = [
  {
    number: "01",
    title: "Scan the barcode",
    description: "Look up the pack in product data (or your FoodScan catalog).",
  },
  {
    number: "02",
    title: "Fallback photo if needed",
    description:
      "If the barcode isn’t found, photograph the ingredients list for a label read.",
  },
  {
    number: "03",
    title: "See watch / prefer marks",
    description:
      "Rule-based flags highlight ingredients to limit vs prefer — educational only.",
  },
  {
    number: "04",
    title: "Save for next time",
    description:
      "Optionally add the product to your local catalog so the next scan is faster.",
  },
];

type HowItWorksProps = {
  compact?: boolean;
};

export function HowItWorks({ compact = false }: HowItWorksProps) {
  return (
    <section className={compact ? "py-16" : "py-20 md:py-24"} aria-labelledby="how-heading">
      <div className="mx-auto max-w-6xl px-5 md:px-8">
        <p className="text-sm font-semibold uppercase tracking-[0.14em] text-primary">
          How it works
        </p>
        <h2
          id="how-heading"
          className="mt-3 max-w-2xl font-display text-3xl font-semibold tracking-tight text-foreground md:text-4xl"
        >
          Two ways to scan on mobile
        </h2>
        <p className="mt-4 max-w-2xl text-base leading-relaxed text-muted">
          Meal photos for calorie tracking. Packaged barcodes for ingredient
          awareness when you shop or snack.
        </p>

        <div className="mt-14">
          <h3 className="font-display text-xl font-semibold text-foreground">
            Meal photo
          </h3>
          <ol className="mt-8 grid gap-10 md:grid-cols-2 lg:grid-cols-4">
            {mealSteps.map((step) => (
              <li key={step.number}>
                <p className="font-display text-4xl font-semibold text-primary/25">
                  {step.number}
                </p>
                <h4 className="mt-3 font-display text-lg font-semibold">
                  {step.title}
                </h4>
                <p className="mt-2 text-sm leading-relaxed text-muted">
                  {step.description}
                </p>
              </li>
            ))}
          </ol>
        </div>

        <div className="mt-16 border-t border-border pt-14">
          <h3 className="font-display text-xl font-semibold text-foreground">
            Packaged food
          </h3>
          <ol className="mt-8 grid gap-10 md:grid-cols-2 lg:grid-cols-4">
            {packagedSteps.map((step) => (
              <li key={step.number}>
                <p className="font-display text-4xl font-semibold text-accent/35">
                  {step.number}
                </p>
                <h4 className="mt-3 font-display text-lg font-semibold">
                  {step.title}
                </h4>
                <p className="mt-2 text-sm leading-relaxed text-muted">
                  {step.description}
                </p>
              </li>
            ))}
          </ol>
        </div>
      </div>
    </section>
  );
}
