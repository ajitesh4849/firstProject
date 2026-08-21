import type { Metadata } from "next";
import { CTASection } from "@/components/CTASection";
import { siteConfig } from "@/lib/site";

export const metadata: Metadata = {
  title: "About",
  description:
    "Learn about FoodScan’s mission, vision, and responsible approach to AI nutrition estimates.",
};

export default function AboutPage() {
  return (
    <>
      <section className="border-b border-border bg-surface px-5 py-16 md:px-8">
        <div className="mx-auto max-w-6xl">
          <p className="text-sm font-semibold uppercase tracking-[0.14em] text-primary">
            About
          </p>
          <h1 className="mt-3 max-w-3xl font-display text-4xl font-semibold tracking-tight md:text-5xl">
            Making everyday eating easier to understand
          </h1>
        </div>
      </section>

      <section className="py-20">
        <div className="mx-auto grid max-w-6xl gap-12 px-5 md:grid-cols-2 md:px-8">
          <article>
            <h2 className="font-display text-2xl font-semibold">Mission</h2>
            <p className="mt-3 text-base leading-relaxed text-muted">
              Help people see what they eat — quickly — whether that’s a plated
              meal estimate or a packaged label check they can understand and
              track.
            </p>
          </article>
          <article>
            <h2 className="font-display text-2xl font-semibold">Vision</h2>
            <p className="mt-3 text-base leading-relaxed text-muted">
              Become the simplest mobile companion for food awareness,
              especially for everyday and regional meals, without pretending
              estimates are laboratory measurements.
            </p>
          </article>
          <article>
            <h2 className="font-display text-2xl font-semibold">Why FoodScan</h2>
            <p className="mt-3 text-base leading-relaxed text-muted">
              Manual logging is slow. FoodScan focuses on mobile scanning —
              meals for calories, packs for ingredient awareness — so tracking
              fits real life instead of a spreadsheet mindset.
            </p>
          </article>
          <article>
            <h2 className="font-display text-2xl font-semibold">
              Responsible AI
            </h2>
            <p className="mt-3 text-base leading-relaxed text-muted">
              {siteConfig.disclaimer} We design the product to show confidence,
              allow edits, and keep disclaimers visible.
            </p>
          </article>
        </div>
      </section>

      <CTASection />
    </>
  );
}
