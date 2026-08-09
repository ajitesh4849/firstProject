import type { Metadata } from "next";
import { CTASection } from "@/components/CTASection";
import { FeatureCard } from "@/components/FeatureCard";

export const metadata: Metadata = {
  title: "Features",
  description:
    "Explore FoodScan features: AI food scanner, calorie estimation, macros, daily tracking, history, and mobile experience.",
};

const features = [
  {
    title: "AI Food Scanner",
    description:
      "Capture a meal and get a suggested dish name with confidence so you can confirm or edit.",
  },
  {
    title: "Calorie Estimation",
    description:
      "Translate portion size into estimated calories — clearly labeled as approximate.",
  },
  {
    title: "Protein / Carbs / Fat",
    description:
      "Review macro estimates for each meal before adding it to your day.",
  },
  {
    title: "Daily Tracking",
    description:
      "See today’s intake against your goal with a simple progress view.",
  },
  {
    title: "History & Insights",
    description:
      "Look back across recent days and weekly averages to spot patterns.",
  },
  {
    title: "Mobile Experience",
    description:
      "Designed for Android and iOS — scan where you eat, not on a desktop dashboard.",
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
            Built around the scan journey
          </h1>
          <p className="mt-4 max-w-2xl text-base leading-relaxed text-muted">
            FoodScan focuses on a clear mobile loop: scan, confirm, portion,
            estimate, and track.
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
