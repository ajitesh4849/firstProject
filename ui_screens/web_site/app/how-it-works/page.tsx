import type { Metadata } from "next";
import { CTASection } from "@/components/CTASection";
import { HowItWorks } from "@/components/HowItWorks";

export const metadata: Metadata = {
  title: "How It Works",
  description:
    "See how FoodScan scans meal photos for calories and packaged barcodes for ingredient awareness.",
};

export default function HowItWorksPage() {
  return (
    <>
      <section className="border-b border-border bg-surface px-5 py-16 md:px-8">
        <div className="mx-auto max-w-6xl">
          <p className="text-sm font-semibold uppercase tracking-[0.14em] text-primary">
            Product flow
          </p>
          <h1 className="mt-3 max-w-3xl font-display text-4xl font-semibold tracking-tight md:text-5xl">
            How FoodScan works on mobile
          </h1>
          <p className="mt-4 max-w-2xl text-base leading-relaxed text-muted">
            The full experience lives in the Flutter app. This page explains
            meal photo tracking and packaged barcode checks so you know what to
            expect before you open the camera.
          </p>
        </div>
      </section>
      <HowItWorks />
      <CTASection title="See it on your phone next" />
    </>
  );
}
