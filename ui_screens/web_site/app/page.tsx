import { AppPreview } from "@/components/AppPreview";
import { CTASection } from "@/components/CTASection";
import { FeatureCard } from "@/components/FeatureCard";
import { Hero } from "@/components/Hero";
import { HowItWorks } from "@/components/HowItWorks";
import { TrustDisclaimer } from "@/components/TrustDisclaimer";

const homeFeatures = [
  {
    title: "Meal photo scan",
    description:
      "Identify dishes from a photo, confirm or edit the name, and get portion-based calorie estimates.",
  },
  {
    title: "Packaged barcode check",
    description:
      "Scan a barcode for ingredient flags. If it’s missing, photograph the ingredients label instead.",
  },
  {
    title: "Watch / Prefer marks",
    description:
      "See soft labels on ingredients to limit vs prefer — rule-based and educational, not medical advice.",
  },
  {
    title: "Daily calorie goal",
    description:
      "Profile-based daily target with Home progress for today’s logged meals.",
  },
];

export default function HomePage() {
  return (
    <>
      <Hero />
      <HowItWorks compact />
      <section className="border-y border-border bg-surface py-20" aria-labelledby="features-heading">
        <div className="mx-auto max-w-6xl px-5 md:px-8">
          <p className="text-sm font-semibold uppercase tracking-[0.14em] text-primary">
            Key features
          </p>
          <h2
            id="features-heading"
            className="mt-3 max-w-2xl font-display text-3xl font-semibold tracking-tight md:text-4xl"
          >
            Meals and packs — awareness on your phone
          </h2>
          <div className="mt-12 grid gap-10 sm:grid-cols-2">
            {homeFeatures.map((feature) => (
              <FeatureCard
                key={feature.title}
                title={feature.title}
                description={feature.description}
              />
            ))}
          </div>
        </div>
      </section>
      <AppPreview />
      <TrustDisclaimer />
      <CTASection />
    </>
  );
}
