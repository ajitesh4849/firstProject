import type { Metadata } from "next";
import { siteConfig } from "@/lib/site";

export const metadata: Metadata = {
  title: "Privacy",
  description:
    "Placeholder privacy policy for FoodScan. Legal content will be reviewed before claiming compliance.",
};

export default function PrivacyPage() {
  return (
    <section className="px-5 py-16 md:px-8 md:py-20">
      <article className="mx-auto max-w-3xl">
        <p className="text-sm font-semibold uppercase tracking-[0.14em] text-primary">
          Legal placeholder
        </p>
        <h1 className="mt-3 font-display text-4xl font-semibold tracking-tight">
          Privacy Policy
        </h1>
        <p className="mt-6 text-base leading-relaxed text-muted">
          This page is a placeholder. It does not claim legal compliance and
          must be reviewed by counsel before launch.
        </p>
        <div className="mt-10 space-y-6 text-base leading-relaxed text-foreground">
          <p>
            {siteConfig.name} will collect account and usage information needed
            to provide food scanning and tracking features on mobile.
          </p>
          <p>
            Food images and profile details should be handled with secure
            storage, access controls, and clear retention practices once the
            backend is live.
          </p>
          <p>
            We will publish a complete policy covering data categories, lawful
            bases or notices as applicable, third-party processors, and user
            rights before collecting production user data.
          </p>
        </div>
      </article>
    </section>
  );
}
