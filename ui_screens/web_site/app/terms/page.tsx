import type { Metadata } from "next";
import { siteConfig } from "@/lib/site";

export const metadata: Metadata = {
  title: "Terms of Use",
  description: `Terms for using the ${siteConfig.name} mobile app and website.`,
};

export default function TermsPage() {
  return (
    <section className="px-5 py-16 md:px-8 md:py-20">
      <article className="mx-auto max-w-3xl">
        <p className="text-sm font-semibold uppercase tracking-[0.14em] text-primary">
          Legal
        </p>
        <h1 className="mt-3 font-display text-4xl font-semibold tracking-tight">
          Terms of Use
        </h1>
        <p className="mt-4 text-sm text-muted">Last updated: 28 September 2026</p>
        <p className="mt-6 text-base leading-relaxed text-muted">
          By creating an account or using {siteConfig.name}, you agree to these
          terms. Have counsel review before treating this as final legal advice.
        </p>

        <div className="mt-10 space-y-8 text-base leading-relaxed text-foreground">
          <section className="space-y-3">
            <h2 className="text-xl font-semibold">1. The service</h2>
            <p>
              {siteConfig.name} helps you log meals and review packaged
              products. Current meal-photo flow asks you to name the dish from
              our food catalog; it does not automatically identify food with
              vision AI. Calories and macros come from our database scaled by
              portion size.
            </p>
          </section>

          <section className="space-y-3">
            <h2 className="text-xl font-semibold">2. Not medical advice</h2>
            <p>
              Estimates, scores, allergy flags, and tips are educational only.
              They are not a diagnosis, lab analysis, or substitute for a
              qualified clinician or dietitian.
            </p>
          </section>

          <section className="space-y-3">
            <h2 className="text-xl font-semibold">3. Your account</h2>
            <p>
              You are responsible for keeping your login credentials secure and
              for activity under your account. You may delete your account at
              any time in the app (Profile → Delete account).
            </p>
          </section>

          <section className="space-y-3">
            <h2 className="text-xl font-semibold">4. Acceptable use</h2>
            <ul className="list-disc space-y-2 pl-5">
              <li>Do not misuse the API or attempt unauthorized access</li>
              <li>Do not upload unlawful or harmful content</li>
              <li>Do not reverse engineer the service except as allowed by law</li>
            </ul>
          </section>

          <section className="space-y-3">
            <h2 className="text-xl font-semibold">5. Intellectual property</h2>
            <p>
              App software, branding, and catalog content belong to{" "}
              {siteConfig.name} or its licensors. You retain rights to photos you
              upload, and you grant us a limited license to process them to
              provide the service.
            </p>
          </section>

          <section className="space-y-3">
            <h2 className="text-xl font-semibold">6. Disclaimer &amp; liability</h2>
            <p>
              The service is provided “as is.” To the fullest extent permitted by
              law, we are not liable for decisions you make based on estimates or
              for indirect or consequential damages.
            </p>
          </section>

          <section className="space-y-3">
            <h2 className="text-xl font-semibold">7. Changes &amp; contact</h2>
            <p>
              We may update these terms by posting a new version on this page.
              Questions: support@{siteConfig.url.replace("https://", "")}.
            </p>
          </section>
        </div>
      </article>
    </section>
  );
}
