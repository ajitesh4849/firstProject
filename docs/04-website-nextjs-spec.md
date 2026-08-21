# FoodScan – Public Website Specification

## Role

This is the **public marketing website** for FoodScan.

It is **not** the calorie-tracking application. Tracking lives in the Flutter mobile app.

Phase 2 builds this marketing surface only.

## Technology

- React
- Next.js
- TypeScript
- Responsive design
- SEO-friendly
- Component-based architecture

Use the Next.js App Router.

## Suggested Structure

```text
ui_screens/web_site/
├── app/
│   ├── page.tsx
│   ├── how-it-works/
│   │   └── page.tsx
│   ├── features/
│   │   └── page.tsx
│   ├── pricing/
│   │   └── page.tsx
│   ├── about/
│   │   └── page.tsx
│   ├── contact/
│   │   └── page.tsx
│   ├── privacy/
│   │   └── page.tsx
│   └── terms/
│       └── page.tsx
├── components/
│   ├── Navbar.tsx
│   ├── Footer.tsx
│   ├── Hero.tsx
│   ├── FeatureCard.tsx
│   ├── HowItWorks.tsx
│   └── CTASection.tsx
├── public/
└── package.json
```

## Home

Hero:
- “Scan food. Know calories. Eat smarter.”
- Supporting copy explaining AI-powered food calorie estimation.
- CTA: “Try FoodScan Free” (may link to store / waitlist / placeholder)
- Secondary CTA: “See How It Works”

Sections:
1. Hero
2. How it works
3. Key features
4. Product/app preview
5. Trust/disclaimer
6. CTA
7. Footer

## How It Works

**Meal photo**
1. Scan food
2. AI identifies the dish (+ awareness tips)
3. Estimate portion and nutrition
4. Track daily intake

**Packaged food**
1. Scan barcode
2. Fallback: photograph ingredients if not found
3. Watch / Prefer ingredient marks + flags
4. Optional save to local catalog

## Features

Cards:
- Meal photo scanner
- Ingredient awareness (dish tips)
- Calorie & macro estimates
- Packaged barcode check
- Watch / Prefer ingredient marks
- Daily goal & history / mobile experience

## Pricing

Initial UI:
- Free
- Pro
- Family

Do not implement payment processing yet.

Clearly mark pricing as placeholder if real pricing has not been finalized.

## About

Sections:
- Mission
- Vision
- Why FoodScan
- Responsible AI / estimation disclaimer

## Contact

Form:
- Name
- Email
- Message
- Submit

For initial implementation, submission can be mocked or show success state.

## Privacy and Terms

Create clean placeholder pages. Do not claim legal compliance until legal content is reviewed.

## Website Rules

- SEO metadata for every public page
- Responsive desktop/tablet/mobile
- Reusable Navbar/Footer
- Semantic HTML
- Accessible buttons/forms
- Avoid unnecessary client-side JavaScript
- **Do not** build the authenticated calorie-tracking dashboard in the marketing website
- **Do not** wire scan, meal, today, history, or profile APIs into this site for MVP
- Emphasize that the product experience is on mobile
