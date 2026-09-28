import type { Metadata } from "next";
import { siteConfig } from "@/lib/site";

export const metadata: Metadata = {
  title: "Privacy Policy",
  description: `How ${siteConfig.name} collects and uses account, photo, and nutrition data.`,
};

export default function PrivacyPage() {
  return (
    <section className="px-5 py-16 md:px-8 md:py-20">
      <article className="mx-auto max-w-3xl">
        <p className="text-sm font-semibold uppercase tracking-[0.14em] text-primary">
          Legal
        </p>
        <h1 className="mt-3 font-display text-4xl font-semibold tracking-tight">
          Privacy Policy
        </h1>
        <p className="mt-4 text-sm text-muted">Last updated: 28 September 2026</p>
        <p className="mt-6 text-base leading-relaxed text-muted">
          This policy describes how {siteConfig.name} handles personal data when
          you use our mobile app and website. It is written for launch readiness;
          have counsel review before treating it as final legal advice.
        </p>

        <div className="mt-10 space-y-8 text-base leading-relaxed text-foreground">
          <section className="space-y-3">
            <h2 className="text-xl font-semibold">1. Who we are</h2>
            <p>
              {siteConfig.name} (“we”, “us”) provides a mobile app for meal
              photos, packaged-product checks, and personal nutrition logging.
              Contact: privacy@{siteConfig.url.replace("https://", "")}.
            </p>
          </section>

          <section className="space-y-3">
            <h2 className="text-xl font-semibold">2. Data we collect</h2>
            <ul className="list-disc space-y-2 pl-5">
              <li>
                <strong>Account:</strong> email and hashed password when you
                sign up.
              </li>
              <li>
                <strong>Profile:</strong> age, height, weight, gender, activity
                level, goal, diet preference, and allergen notes you enter.
              </li>
              <li>
                <strong>Meal photos:</strong> images you choose to capture or
                upload for a scan session (used to create a scan record; not used
                for automatic dish recognition in the current release).
              </li>
              <li>
                <strong>Packaged scans:</strong> barcodes, ingredient text, and
                product details needed to analyze packaged foods.
              </li>
              <li>
                <strong>Usage logs:</strong> meals you log, scan metadata, and
                basic technical logs (e.g. errors, IP for rate limiting).
              </li>
            </ul>
          </section>

          <section className="space-y-3">
            <h2 className="text-xl font-semibold">3. How we use data</h2>
            <ul className="list-disc space-y-2 pl-5">
              <li>Create and secure your account</li>
              <li>Estimate nutrition from our food catalog and portion size</li>
              <li>Show daily totals, tips, and packaged-food warnings</li>
              <li>Improve reliability and prevent abuse</li>
            </ul>
            <p>
              Nutrition and ingredient guidance are for information only and are
              not medical advice.
            </p>
          </section>

          <section className="space-y-3">
            <h2 className="text-xl font-semibold">4. Sharing</h2>
            <p>
              We do not sell your personal data. We may use infrastructure
              providers (hosting, database, email) under contracts that require
              them to protect data. We may disclose information if required by
              law.
            </p>
          </section>

          <section className="space-y-3">
            <h2 className="text-xl font-semibold">5. Retention</h2>
            <p>
              We keep account and logging data while your account is active. When
              you delete your account in the app, we delete your profile, meals,
              scans, and user-contributed packaged catalog entries associated
              with your account.
            </p>
          </section>

          <section className="space-y-3">
            <h2 className="text-xl font-semibold">6. Your rights</h2>
            <p>
              You can update profile data in the app, log out, or delete your
              account (Profile → Delete account). Depending on your region you
              may have additional rights (access, correction, erasure). Contact
              us to exercise them.
            </p>
          </section>

          <section className="space-y-3">
            <h2 className="text-xl font-semibold">7. Security</h2>
            <p>
              We use HTTPS in production, hashed passwords, and access tokens.
              No method of transmission or storage is perfectly secure.
            </p>
          </section>

          <section className="space-y-3">
            <h2 className="text-xl font-semibold">8. Children</h2>
            <p>
              {siteConfig.name} is not directed to children under 13 (or the
              minimum age in your country). Do not create an account if you are
              under that age.
            </p>
          </section>

          <section className="space-y-3">
            <h2 className="text-xl font-semibold">9. Changes</h2>
            <p>
              We may update this policy. We will post the new version on this
              page and update the “Last updated” date.
            </p>
          </section>
        </div>
      </article>
    </section>
  );
}
