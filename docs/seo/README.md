# Frontend SEO Playbook
- **Owner:** _TBD_
- **Last updated:** 2025-10-01

Use this guide to implement or reapply the SEO controls currently in place for the Next.js frontend. Each section explains the goal, the current approach, and exact steps/code snippets so you can reproduce the setup without guesswork.

---

## 1. Meta Tags, Titles, and Social Sharing

### Current Status
- Pages lacked consistent `<title>`, `<meta name="description">`, and Open Graph/Twitter tags.
- No shared SEO component existed, so tags were not standardised across pages.

### How to Implement
1. **Create a reusable SEO component**, e.g. `components/Seo.js`:
   ```jsx
   import Head from 'next/head';

   const Seo = ({
     title = 'BeWorking – Flexible Coworking & Office Spaces',
     description = 'Flexible coworking and office solutions tailored to your team. Join BeWorking today.',
     canonical = 'https://beworking.com',
     image = 'https://beworking.com/BeWorking.jpg',
     type = 'website',
   }) => (
     <Head>
       <title>{title}</title>
       <meta name="description" content={description} />
       <meta property="og:title" content={title} />
       <meta property="og:description" content={description} />
       <meta property="og:image" content={image} />
       <meta property="og:type" content={type} />
       <meta property="og:url" content={canonical} />
       <meta name="twitter:card" content="summary_large_image" />
       <meta name="twitter:title" content={title} />
       <meta name="twitter:description" content={description} />
       <meta name="twitter:image" content={image} />
       <link rel="canonical" href={canonical} />
     </Head>
   );

   export default Seo;
   ```
2. **Use the component in every page**:
   ```jsx
   // pages/index.js
   import Seo from '../components/Seo';

   export default function Home() {
     return (
       <>
         <Seo
           title="BeWorking – Coworking & Office Spaces in Madrid"
           description="Find flexible coworking desks, meeting rooms, and private offices with BeWorking."
         />
         {/* page content */}
       </>
     );
   }
   ```
3. Pass custom `title`, `description`, `image`, and `canonical` props per page for better keyword targeting.

---

## 2. Global Defaults (Language, Charset, Favicons)

### Current Status
- `_document.js` already sets `<html lang="en">` and `<meta charSet="utf-8">`.
- `favicon.ico` is referenced correctly.

### Enhancements
- Optional: add additional icons in `_document.js` for Apple devices or larger favicon sizes:
  ```jsx
  <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png" />
  <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png" />
  ```
- Maintain language attribute for accessibility and SEO.

---

## 3. Structured Data (JSON-LD)

### Current Status
- No structured data was present.

### How to Implement
1. Extend the `Seo` component or individual pages to include JSON-LD using `dangerouslySetInnerHTML`:
   ```jsx
   const organizationJsonLd = {
     '@context': 'https://schema.org',
     '@type': 'CoworkingSpace',
     name: 'BeWorking',
     url: 'https://beworking.com',
     logo: 'https://beworking.com/BeWorking.jpg',
     address: {
       '@type': 'PostalAddress',
       streetAddress: '123 Cowork Lane',
       addressLocality: 'Madrid',
       postalCode: '28001',
       addressCountry: 'ES',
     },
     contactPoint: {
       '@type': 'ContactPoint',
       contactType: 'Customer Service',
       telephone: '+34-555-123-456',
     },
   };
   ```
2. Inject on the desired page:
   ```jsx
   <Seo { ...props } />
   <script
     type="application/ld+json"
     dangerouslySetInnerHTML={{ __html: JSON.stringify(organizationJsonLd) }}
   />
   ```
3. Use Google’s Rich Results Test to validate your JSON-LD implementation.

---

## 4. Image Optimisation with `next/image`

### Current Status
- Legacy `<img>` tags prevented automatic optimisation and responsive sizing.

### How to Implement
1. Replace legacy `<img>` elements with Next.js `Image` component:
   ```jsx
   import Image from 'next/image';

   <Image
     src="/gallery/workspace.jpg"
     alt="BeWorking shared workspace"
     width={800}
     height={600}
     priority
   />
   ```
2. Provide descriptive `alt` text for accessibility and SEO.
3. Use the `priority` attribute for above-the-fold images and `loading="lazy"` for others.

---

## 5. Accessibility & Semantic HTML

### Current Status
- Some components were missing `alt` attributes or semantic wrappers.

### How to Implement
1. Ensure every image includes a meaningful `alt` description.
2. Structure pages with `<header>`, `<nav>`, `<main>`, `<section>`, `<footer>` tags.
3. For interactive elements, ensure keyboard accessibility and ARIA labels when necessary.
4. Run automated checks (Lighthouse, axe) to catch remaining issues.

---

## 6. robots.txt and Sitemap

### Current Status
- `robots.txt` and `sitemap.xml` were created and exposed at the root domain using `next-sitemap`.

### How to Reproduce
1. Install and configure `next-sitemap`:
   ```bash
   npm install next-sitemap
   ```
   ```js
   // next-sitemap.config.js
   module.exports = {
     siteUrl: 'https://beworking.com',
     generateRobotsTxt: true,
     sitemapSize: 7000,
   };
   ```
2. Update `package.json` scripts:
   ```json
   "scripts": {
     "postbuild": "next-sitemap"
   }
   ```
3. Generate files during build: `npm run build && npm run postbuild`.
4. Example `public/robots.txt`:
   ```
   User-agent: *
   Allow: /
   Sitemap: https://beworking.com/sitemap.xml
   ```
5. Deploy and verify the sitemap at `https://beworking.com/sitemap.xml`.

---

## 7. Canonical URLs

### Current Status
- Canonical tags now default to the non-`www` domain and can be overridden per page.

### How to Implement
1. The `Seo` component already renders `<link rel="canonical">` (see Section 1).
2. To set a custom canonical on any page:
   ```jsx
   <Seo canonical="https://beworking.com/workspaces" />
   ```
3. Configure DNS or hosting to redirect `www.beworking.com` → `beworking.com` via 301.

---

## 8. Performance Optimisation (Preload/Preconnect)

### Current Status
- No preconnect/preload hints were defined.

### How to Implement
1. Add hints to `_document.js` for critical external resources:
   ```jsx
   <Head>
     <link rel="preconnect" href="https://fonts.googleapis.com" />
     <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
     <link rel="preload" href="/fonts/Inter-Variable.woff2" as="font" type="font/woff2" crossOrigin="anonymous" />
   </Head>
   ```
2. Audit with Lighthouse to identify render-blocking assets and address them iteratively.
3. Optimise hero images by leveraging `priority` and the `sizes` prop.

---

## 9. Optional Enhancements

These tasks drive deeper SEO gains and can be tackled incrementally:

1. **Core Web Vitals:** Run Lighthouse or WebPageTest, fix issues with LCP, CLS, TBT.
2. **Internationalisation:** If adding languages, configure Next.js i18n and render `hreflang` tags.
3. **PWA Support:** Add `manifest.json`, additional icons, and consider service workers.
4. **Analytics:** Integrate Google Analytics, GA4, or Tag Manager to monitor SEO performance.
5. **Custom Error Pages:** Build informative 404/500 pages for better UX.
6. **Social Preview Testing:** Use Facebook Sharing Debugger and Twitter Card Validator to confirm OG/Twitter tags.
7. **Breadcrumb Schema:** Add breadcrumb JSON-LD if site navigation becomes deep.
8. **Content Freshness:** Update pages regularly and include `lastmod` in sitemaps.
9. **Specialised Schema:** Implement review, event, or product schema as applicable.
10. **Accessibility Audits:** Schedule periodic audits using automated and manual tools.

---

## Quick Reference Table
| Area | Files / Components | Action |
| --- | --- | --- |
| Meta tags & OG | `components/Seo.js`, individual pages | Use reusable component with per-page props |
| Structured data | Pages using `Seo` | Inject JSON-LD via `<script>` tags |
| Image optimisation | `components/GallerySection.js`, etc. | Swap `<img>` for `next/image`, add alt text |
| Accessibility | Page layouts, components | Use semantic HTML, run Lighthouse/axe |
| Robots & sitemap | `next-sitemap.config.js`, `public/robots.txt` | Generate sitemap, expose robots.txt |
| Canonical URLs | `components/Seo.js`, DNS config | Set canonical tags, redirect `www` → root |
| Performance hints | `_document.js` | Add preconnect/preload for fonts/resources |

---

## Maintenance Checklist
1. Run a full Lighthouse audit monthly and address regressions.
2. Test structured data with Google Rich Results after any content changes.
3. Update sitemap/robots configuration when adding sections or subdomains.
4. Revisit meta descriptions to align with current marketing messaging.
5. Document any new SEO helper components in this playbook.

Keep this README up to date as your frontend evolves so future iterations can replicate the same SEO baseline quickly.
