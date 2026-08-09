import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Page not found",
  description: "The page you requested could not be found on FoodScan.",
};

export default function NotFound() {
  return (
    <section className="mx-auto flex max-w-3xl flex-col items-start px-5 py-24 md:px-8">
      <p className="text-sm font-semibold uppercase tracking-[0.14em] text-primary">
        404
      </p>
      <h1 className="mt-3 font-display text-4xl font-semibold tracking-tight">
        Page not found
      </h1>
      <p className="mt-4 text-base leading-relaxed text-muted">
        That URL does not exist on the FoodScan marketing site. Head home or
        explore how the mobile product works.
      </p>
      <div className="mt-8 flex flex-wrap gap-3">
        <Link
          href="/"
          className="inline-flex rounded-xl bg-primary px-5 py-3 text-sm font-semibold text-white hover:bg-primary-dark"
        >
          Back to home
        </Link>
        <Link
          href="/how-it-works"
          className="inline-flex rounded-xl border border-border bg-surface px-5 py-3 text-sm font-semibold text-foreground"
        >
          How it works
        </Link>
      </div>
    </section>
  );
}
