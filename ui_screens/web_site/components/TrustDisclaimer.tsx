import { siteConfig } from "@/lib/site";

export function TrustDisclaimer() {
  return (
    <section className="py-16" aria-labelledby="trust-heading">
      <div className="mx-auto max-w-6xl px-5 md:px-8">
        <div className="border-l-4 border-accent bg-surface px-6 py-8 md:px-8">
          <h2
            id="trust-heading"
            className="font-display text-2xl font-semibold text-foreground"
          >
            Responsible estimates
          </h2>
          <p className="mt-3 max-w-3xl text-base leading-relaxed text-muted">
            {siteConfig.disclaimer} FoodScan helps you stay aware of meals and
            packaged labels — it is not a medical device and does not provide
            medical advice. Ingredient marks are rule-based educational cues,
            not lab analysis.
          </p>
        </div>
      </div>
    </section>
  );
}
