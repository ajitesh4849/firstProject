import Link from "next/link";

type CTASectionProps = {
  title?: string;
  description?: string;
};

export function CTASection({
  title = "Ready to eat smarter?",
  description = "FoodScan lives on your phone. Use this site to learn the product, then try the mobile app when available.",
}: CTASectionProps) {
  return (
    <section
      id="try"
      className="border-y border-border bg-[linear-gradient(135deg,#e6f4f2_0%,#f3f6f4_50%,#f7edd9_100%)] py-20"
      aria-labelledby="cta-heading"
    >
      <div className="mx-auto max-w-6xl px-5 text-center md:px-8">
        <h2
          id="cta-heading"
          className="font-display text-3xl font-semibold tracking-tight text-foreground md:text-4xl"
        >
          {title}
        </h2>
        <p className="mx-auto mt-4 max-w-2xl text-base leading-relaxed text-muted">
          {description}
        </p>
        <div className="mt-8 flex flex-col items-center justify-center gap-3 sm:flex-row">
          <Link
            href="/contact"
            className="inline-flex items-center justify-center rounded-xl bg-primary px-6 py-3.5 text-base font-semibold text-white transition hover:bg-primary-dark"
          >
            Join the waitlist
          </Link>
          <Link
            href="/features"
            className="inline-flex items-center justify-center rounded-xl border border-border bg-surface px-6 py-3.5 text-base font-semibold text-foreground transition hover:border-primary/40"
          >
            Explore features
          </Link>
        </div>
      </div>
    </section>
  );
}
