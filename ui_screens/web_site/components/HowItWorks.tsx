const steps = [
  {
    number: "01",
    title: "Scan food",
    description: "Point your phone camera at your meal or choose a photo.",
  },
  {
    number: "02",
    title: "AI identifies the dish",
    description: "FoodScan suggests a dish name with a confidence score.",
  },
  {
    number: "03",
    title: "Estimate portion and nutrition",
    description:
      "Pick a portion size and review estimated calories, protein, carbs, and fat.",
  },
  {
    number: "04",
    title: "Track daily intake",
    description: "Add the meal to today and review history as you go.",
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
          From photo to daily log in four steps
        </h2>
        <ol className="mt-12 grid gap-10 md:grid-cols-2 lg:grid-cols-4">
          {steps.map((step) => (
            <li key={step.number}>
              <p className="font-display text-4xl font-semibold text-primary/25">
                {step.number}
              </p>
              <h3 className="mt-3 font-display text-xl font-semibold">
                {step.title}
              </h3>
              <p className="mt-2 text-sm leading-relaxed text-muted">
                {step.description}
              </p>
            </li>
          ))}
        </ol>
      </div>
    </section>
  );
}
