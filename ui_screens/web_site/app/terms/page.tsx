import type { Metadata } from "next";
import { siteConfig } from "@/lib/site";

export const metadata: Metadata = {
  title: "Terms",
  description:
    "Placeholder terms of use for FoodScan. Legal content will be reviewed before launch.",
};

export default function TermsPage() {
  return (
    <section className="px-5 py-16 md:px-8 md:py-20">
      <article className="mx-auto max-w-3xl">
        <p className="text-sm font-semibold uppercase tracking-[0.14em] text-primary">
          Legal placeholder
        </p>
        <h1 className="mt-3 font-display text-4xl font-semibold tracking-tight">
          Terms of Use
        </h1>
        <p className="mt-6 text-base leading-relaxed text-muted">
          This page is a placeholder. It does not constitute final legal terms
          and must be reviewed before release.
        </p>
        <div className="mt-10 space-y-6 text-base leading-relaxed text-foreground">
          <p>
            {siteConfig.name} provides estimated nutrition information from
            images. Estimates are approximate and are not medical advice.
          </p>
          <p>
            Users are responsible for how they use the app. Do not rely on
            FoodScan as a substitute for professional medical or dietary
            guidance.
          </p>
          <p>
            Final terms will cover acceptable use, account responsibilities,
            intellectual property, limitation of liability, and governing law.
          </p>
        </div>
      </article>
    </section>
  );
}
