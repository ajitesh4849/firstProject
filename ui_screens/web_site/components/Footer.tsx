import Link from "next/link";
import { navLinks, siteConfig } from "@/lib/site";

export function Footer() {
  return (
    <footer className="mt-auto border-t border-border bg-hero-deep text-white">
      <div className="mx-auto grid max-w-6xl gap-10 px-5 py-14 md:grid-cols-[1.4fr_1fr_1fr] md:px-8">
        <div>
          <p className="font-display text-2xl font-semibold">{siteConfig.name}</p>
          <p className="mt-3 max-w-sm text-sm leading-relaxed text-white/75">
            {siteConfig.tagline} Available on mobile — this site is for product
            information only.
          </p>
        </div>

        <div>
          <p className="text-sm font-semibold uppercase tracking-wide text-accent">
            Explore
          </p>
          <ul className="mt-4 space-y-2">
            {navLinks.map((link) => (
              <li key={link.href}>
                <Link
                  href={link.href}
                  className="text-sm text-white/80 transition hover:text-white"
                >
                  {link.label}
                </Link>
              </li>
            ))}
          </ul>
        </div>

        <div>
          <p className="text-sm font-semibold uppercase tracking-wide text-accent">
            Legal
          </p>
          <ul className="mt-4 space-y-2">
            <li>
              <Link
                href="/privacy"
                className="text-sm text-white/80 transition hover:text-white"
              >
                Privacy
              </Link>
            </li>
            <li>
              <Link
                href="/terms"
                className="text-sm text-white/80 transition hover:text-white"
              >
                Terms
              </Link>
            </li>
          </ul>
        </div>
      </div>

      <div className="border-t border-white/10">
        <div className="mx-auto flex max-w-6xl flex-col gap-2 px-5 py-5 text-xs text-white/60 md:flex-row md:items-center md:justify-between md:px-8">
          <p>© {new Date().getFullYear()} {siteConfig.name}. All rights reserved.</p>
          <p>{siteConfig.disclaimer}</p>
        </div>
      </div>
    </footer>
  );
}
