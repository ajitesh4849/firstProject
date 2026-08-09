import type { Metadata } from "next";
import Link from "next/link";
import { CTASection } from "@/components/CTASection";

export const metadata: Metadata = {
  title: "Pricing",
  description:
    "Placeholder FoodScan pricing for Free, Pro, and Family plans. Payments are not enabled yet.",
};

const plans = [
  {
    name: "Free",
    price: "₹0",
    description: "Core scanning and daily tracking for getting started.",
    items: ["Limited scans / day", "Daily calorie view", "Basic history"],
  },
  {
    name: "Pro",
    price: "TBD",
    description: "For frequent logging and richer insights.",
    items: ["Higher scan limits", "Macro insights", "Priority improvements"],
    featured: true,
  },
  {
    name: "Family",
    price: "TBD",
    description: "Shared household access when family accounts ship.",
    items: ["Multiple profiles", "Shared visibility", "Coming later"],
  },
];

export default function PricingPage() {
  return (
    <>
      <section className="border-b border-border bg-surface px-5 py-16 md:px-8">
        <div className="mx-auto max-w-6xl">
          <p className="text-sm font-semibold uppercase tracking-[0.14em] text-primary">
            Pricing
          </p>
          <h1 className="mt-3 max-w-3xl font-display text-4xl font-semibold tracking-tight md:text-5xl">
            Simple plans — prices TBD
          </h1>
          <p className="mt-4 max-w-2xl text-base leading-relaxed text-muted">
            These tiers are placeholders for UI and messaging. Payment
            processing is not implemented yet.
          </p>
        </div>
      </section>

      <section className="py-20">
        <div className="mx-auto grid max-w-6xl gap-8 px-5 md:grid-cols-3 md:px-8">
          {plans.map((plan) => (
            <article
              key={plan.name}
              className={`flex flex-col border p-6 ${
                plan.featured
                  ? "border-primary bg-surface shadow-[0_20px_50px_-30px_rgba(27,122,78,0.55)]"
                  : "border-border bg-background"
              }`}
            >
              <h2 className="font-display text-2xl font-semibold">{plan.name}</h2>
              <p className="mt-3 font-display text-4xl font-semibold text-primary-dark">
                {plan.price}
              </p>
              <p className="mt-3 text-sm leading-relaxed text-muted">
                {plan.description}
              </p>
              <ul className="mt-6 flex-1 space-y-2 text-sm text-foreground">
                {plan.items.map((item) => (
                  <li key={item} className="border-t border-border pt-2">
                    {item}
                  </li>
                ))}
              </ul>
              <Link
                href="/contact"
                className={`mt-8 inline-flex items-center justify-center rounded-xl px-4 py-3 text-sm font-semibold ${
                  plan.featured
                    ? "bg-primary text-white hover:bg-primary-dark"
                    : "border border-border bg-surface text-foreground hover:border-primary/40"
                }`}
              >
                Ask about {plan.name}
              </Link>
            </article>
          ))}
        </div>
        <p className="mx-auto mt-10 max-w-6xl px-5 text-sm text-muted md:px-8">
          Placeholder pricing only. Final amounts and entitlements will be
          confirmed before launch.
        </p>
      </section>

      <CTASection />
    </>
  );
}
