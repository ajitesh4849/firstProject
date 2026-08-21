import type { Metadata } from "next";
import { CTASection } from "@/components/CTASection";
import { FeatureCard } from "@/components/FeatureCard";

export const metadata: Metadata = {
  title: "Features",
  description:
    "Explore FoodScan features: meal photo scan, packaged barcodes, ingredient marks, calorie goals, macros, and mobile tracking.",
};

const features = [
  {
    title: "Meal photo scanner",
    description:
      "Capture a meal and get a suggested dish name with confidence so you can confirm or edit.",
  },
  {
    title: "Ingredient awareness",
    description:
      "For common dish types, see typical preparation tips — why it may be heavy and what to prefer.",
  },
  {
    title: "Calorie & macro estimates",
    description:
      "Translate portion size into estimated calories, protein, carbs, and fat — clearly approximate.",
  },
  {
    title: "Packaged barcode check",
    description:
      "Look up packs by barcode. If not found, photograph the ingredients panel as a fallback.",
  },
  {
    title: "Watch / Prefer ingredient marks",
    description:
      "Highlight additives and refined signals to watch, and whole-food style ingredients to prefer.",
  },
  {
    title: "Daily goal & history",
    description:
      "Profile-based calorie target, today’s progress, and recent history on Android and iOS.",
  },
];

export default function FeaturesPage() {
  return (
    <>
      <section className="border-b border-border bg-surface px-5 py-16 md:px-8">
        <div className="mx-auto max-w-6xl">
          <p className="text-sm font-semibold uppercase tracking-[0.14em] text-primary">
            Features
          </p>
          <h1 className="mt-3 max-w-3xl font-display text-4xl font-semibold tracking-tight md:text-5xl">
            Built around meal and package scanning
          </h1>
          <p className="mt-4 max-w-2xl text-base leading-relaxed text-muted">
            FoodScan focuses on a clear mobile loop: scan a meal or pack,
            understand what you’re looking at, and track what you choose to log.
          </p>
        </div>
      </section>

      <section className="py-20">
        <div className="mx-auto grid max-w-6xl gap-10 px-5 sm:grid-cols-2 lg:grid-cols-3 md:px-8">
          {features.map((feature) => (
            <FeatureCard
              key={feature.title}
              title={feature.title}
              description={feature.description}
            />
          ))}
        </div>
      </section>

      <CTASection />
    </>
  );
}
