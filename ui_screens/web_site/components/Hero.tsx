import Link from "next/link";
import { siteConfig } from "@/lib/site";

export function Hero() {
  return (
    <section className="relative min-h-[88vh] overflow-hidden bg-hero-deep text-white">
      <div
        className="pointer-events-none absolute inset-0 opacity-80"
        aria-hidden="true"
        style={{
          background:
            "radial-gradient(ellipse 80% 60% at 70% 20%, rgba(201,120,22,0.28), transparent 55%), radial-gradient(ellipse 70% 50% at 15% 80%, rgba(15,118,110,0.55), transparent 50%), linear-gradient(160deg, #062e2b 0%, #0b5c56 45%, #041f1d 100%)",
        }}
      />
      <div
        className="pointer-events-none absolute -right-16 top-24 h-72 w-72 rounded-full bg-accent/20 blur-3xl animate-soft-pulse"
        aria-hidden="true"
      />
      <div
        className="pointer-events-none absolute bottom-10 left-10 h-56 w-56 rounded-full bg-primary/40 blur-3xl animate-float"
        aria-hidden="true"
      />

      <div className="relative mx-auto flex min-h-[88vh] max-w-6xl flex-col justify-end px-5 pb-16 pt-28 md:justify-center md:px-8 md:pb-24 md:pt-20">
        <p className="animate-fade-up font-display text-5xl font-semibold tracking-tight sm:text-6xl md:text-7xl">
          {siteConfig.name}
        </p>
        <h1 className="animate-fade-up-delay mt-5 max-w-3xl font-display text-3xl font-medium leading-tight text-white/95 sm:text-4xl md:text-5xl">
          {siteConfig.tagline}
        </h1>
        <p className="animate-fade-up-delay-2 mt-6 max-w-xl text-base leading-relaxed text-white/75 md:text-lg">
          Scan a plated meal for calorie estimates, or scan a packaged barcode
          for ingredient watch/prefer marks. Confirm, track your day, and stay
          aware — with clear estimate disclaimers, not medical claims.
        </p>
        <div className="animate-fade-up-delay-2 mt-10 flex flex-col gap-3 sm:flex-row sm:items-center">
          <Link
            id="try"
            href="/#try"
            className="inline-flex items-center justify-center rounded-xl bg-accent px-6 py-3.5 text-base font-semibold text-hero-deep transition hover:brightness-105"
          >
            Try FoodScan Free
          </Link>
          <Link
            href="/how-it-works"
            className="inline-flex items-center justify-center rounded-xl border border-white/30 bg-white/5 px-6 py-3.5 text-base font-semibold text-white transition hover:bg-white/10"
          >
            See How It Works
          </Link>
        </div>
        <p className="mt-5 text-sm text-white/55">
          Mobile app experience — this website is informational.
        </p>
      </div>
    </section>
  );
}
