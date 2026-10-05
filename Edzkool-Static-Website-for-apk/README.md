# Next-js-Edzkool 🚀
### Edzkool International Website in Design System

This project is a high-converting, modern, **SEO-optimized Next.js 14+ (App Router)** website for **Edzkool International** (Abroad Consultancy). It fuses the authentic content, offerings, medical universities, and trust markers from **Edzkool** (`edzkool.in`) with the high-energy design system, vibrant color palette, rounded components, marquee ticker, floating lead booking form, and card grids.

---

## 🎨 Theme & Design System

- **Primary Brand Purple**: `#4D3BC2` (Logo, headers, main action CTAs)
- **Secondary Bright Violet**: `#B178FA` (Header gradients, section accents)
- **Highlight Gold**: `#FFCE00` (Rating stars, urgency badges, discount pills)
- **Mint Teal**: `#00E2A3` (Tech accents, checkmarks, trust markers)
- **Typography**: `Nunito` & `Nunito Sans` (Google Fonts)
- **Card Radius**: `20px` to `24px` rounded corners with soft elevation shadows.
- **Pills**: `9999px` fully rounded badges & interactive selectors.

---

## 📁 Project Structure

```
Next-js-Edzkool/
├── app/
│   ├── layout.tsx              # Root layout with Nunito font, OpenGraph & JSON-LD schema
│   ├── page.tsx                # Main homepage combining all sections
│   ├── globals.css             # Tailwind imports & marquee animation
│   ├── sitemap.ts              # XML Sitemap generator for search engines
│   ├── robots.ts               # Robots.txt crawler rules
│   └── countries/
│       └── [slug]/
│           └── page.tsx        # Dynamic SEO destination pages (Russia, Georgia, etc.)
├── components/
│   ├── TopMarquee.tsx          # top ticker banner
│   ├── Navbar.tsx              # Sticky navbar with logo badge & call CTA
│   ├── HeroSection.tsx         # Headline + Interactive Lead Registration Card
│   ├── StatsBar.tsx            # Key metrics (300+ Students, 12+ Centers)
│   ├── CountryTabs.tsx         # Pill-based destination selector
│   ├── ServiceCards.tsx        # 6 End-to-end medical admission services
│   ├── ComparisonSection.tsx   # Unverified Agents vs The Edzkool Way
│   ├── UniversityGrid.tsx      # NMC-approved medical universities
│   ├── LeadershipSection.tsx   # Edzkool leadership message & mission
│   ├── Testimonials.tsx        # Rating cards with student reviews
│   ├── FaqSection.tsx          # Interactive FAQ accordion
│   ├── LeadModal.tsx           # Lead booking popup dialog
│   ├── Footer.tsx              # Dark multi-column footer with global offices
│   └── JsonLdSchema.tsx        # Schema.org EducationalOrganization & FAQPage JSON-LD
├── data/
│   └── edzkool-data.ts        # All authentic Edzkool content & structured data
├── package.json
├── tailwind.config.ts
├── tsconfig.json
├── next.config.ts
└── postcss.config.mjs
```

---

## ⚡ Quick Start Instructions

1. Open a terminal inside the project directory:
   ```bash
   cd Next-js-Edzkool
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Run the development server:
   ```bash
   npm run dev
   ```

4. Open [http://localhost:3000](http://localhost:3000) in your browser.

---

## 🔍 SEO Features Built-In

- **Meta Tags & OpenGraph**: Pre-configured social media cards, meta description, and keywords.
- **JSON-LD Schema**: Schema.org `EducationalOrganization` and `FAQPage` rich snippets.
- **Dynamic Country Pages**: Dynamic routing for `/countries/russia`, `/countries/georgia`, `/countries/kazakhstan`, and `/countries/uzbekistan`.
- **Sitemap & Robots**: Automated `sitemap.xml` and `robots.txt`.
