import { siteConfig } from "@/lib/site";

export function AppPreview() {
  return (
    <section className="py-20 md:py-24" aria-labelledby="preview-heading">
      <div className="mx-auto grid max-w-6xl items-center gap-12 px-5 md:grid-cols-2 md:px-8">
        <div>
          <p className="text-sm font-semibold uppercase tracking-[0.14em] text-primary">
            Mobile app
          </p>
          <h2
            id="preview-heading"
            className="mt-3 font-display text-3xl font-semibold tracking-tight md:text-4xl"
          >
            Built for the phone in your hand
          </h2>
          <p className="mt-4 text-base leading-relaxed text-muted">
            Scan, confirm, portion, and log — without leaving a desktop
            dashboard. FoodScan is designed as a mobile-first experience for
            Android and iOS.
          </p>
        </div>

        <div
          className="relative mx-auto w-full max-w-sm"
          aria-hidden="true"
        >
          <div className="rounded-[2rem] border border-border bg-surface p-3 shadow-[0_30px_80px_-40px_rgba(6,46,43,0.45)]">
            <div className="overflow-hidden rounded-[1.5rem] bg-[linear-gradient(180deg,#062e2b_0%,#0f766e_55%,#e6f4f2_55%,#ffffff_100%)] px-5 pb-6 pt-8">
              <p className="font-display text-2xl font-semibold text-white">
                {siteConfig.name}
              </p>
              <p className="mt-1 text-sm text-white/70">Today</p>
              <div className="mt-8 rounded-2xl bg-white p-5 text-foreground shadow-[0_8px_24px_rgba(21,32,27,0.06)]">
                <p className="text-sm text-muted">Daily intake</p>
                <p className="mt-1 text-3xl font-bold tracking-tight">
                  1850 / 2200
                </p>
                <div className="mt-4 h-2 overflow-hidden rounded-full bg-border">
                  <div className="h-full w-[84%] rounded-full bg-primary" />
                </div>
                <ul className="mt-5 space-y-2 text-sm">
                  <li className="flex justify-between border-t border-border pt-2">
                    <span>Breakfast</span>
                    <span className="font-semibold text-primary-dark">450 kcal</span>
                  </li>
                  <li className="flex justify-between border-t border-border pt-2">
                    <span>Lunch</span>
                    <span className="font-semibold text-primary-dark">680 kcal</span>
                  </li>
                  <li className="flex justify-between border-t border-border pt-2">
                    <span>Dinner</span>
                    <span className="font-semibold text-primary-dark">720 kcal</span>
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
