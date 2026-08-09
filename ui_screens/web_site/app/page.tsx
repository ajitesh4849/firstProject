import { AppPreview } from "@/components/AppPreview";
import { CTASection } from "@/components/CTASection";
import { FeatureCard } from "@/components/FeatureCard";
import { Hero } from "@/components/Hero";
import { HowItWorks } from "@/components/HowItWorks";
import { TrustDisclaimer } from "@/components/TrustDisclaimer";

const homeFeatures = [
  {
    title: "AI Food Scanner",
    description: "Identify dishes from a photo with a confidence score you can confirm or edit.",
  },
  {
    title: "Calorie Estimation",
    description: "Get estimated calories based on the portion you select.",
  },
  {
    title: "Protein / Carbs / Fat",
    description: "See macro breakdowns alongside calories for each logged meal.",
  },
  {
    title: "Daily Tracking",
    description: "Watch progress toward your daily calorie goal on Home / Today.",
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
            Everything you need to log a meal from a photo
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
