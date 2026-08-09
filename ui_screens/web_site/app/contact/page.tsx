import type { Metadata } from "next";
import { ContactForm } from "@/components/ContactForm";

export const metadata: Metadata = {
  title: "Contact",
  description:
    "Contact the FoodScan team with product questions, partnership ideas, or waitlist interest.",
};

export default function ContactPage() {
  return (
    <section className="px-5 py-16 md:px-8 md:py-20">
      <div className="mx-auto grid max-w-6xl gap-12 md:grid-cols-[1fr_1.1fr]">
        <div>
          <p className="text-sm font-semibold uppercase tracking-[0.14em] text-primary">
            Contact
          </p>
          <h1 className="mt-3 font-display text-4xl font-semibold tracking-tight md:text-5xl">
            Talk to us
          </h1>
          <p className="mt-4 max-w-md text-base leading-relaxed text-muted">
            Questions about FoodScan, early access, or partnerships? Send a
            message. Phase 2 uses a mock success state — no email backend yet.
          </p>
        </div>
        <ContactForm />
      </div>
    </section>
  );
}
