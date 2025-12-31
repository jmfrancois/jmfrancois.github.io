---
title:  "Tailwind but runtime"
categories: ["en"]
tags: ["Talend", "TypeScript", "Design System", "React","Qlik"]
date: 2025-12-31
---

After years of shipping design systems, we wanted the speed of Tailwind without the global-CSS baggage and without leaking raw values. So we built a **runtime Tailwind-alike** powered by CSS Modules and our design tokens.

## Constraints we had to solve

- **No global CSS**: collision-free by construction, no `.btn` surprises.
- **Tokens everywhere**: not a single hardcoded px/rem/hex in the API surface.
- **Readable semantics**: utility classes that mean something (`p-s`, `bg_default`, `text_brand`), no magic numbers.
- **Composable with components**: works with our React component library; no extra wrapper or provider.
- **Zero-prefixed responsive hacks**: we refused `md:p-4`-style prefixes; media/container logic must live in CSS, not in class names or JS.

## The idea: utilities at runtime, scoped by CSS Modules

Instead of shipping a giant global stylesheet, we generate scoped utility classes through CSS Modules. Each file imports a small set of prebuilt utilities derived from tokens.

Example usage in a component:

```tsx
import styles from './box.module.css';
import { classNames } from '@qlik/our-lib'; // token-based utilities

export function Card({ children }) {
	return (
		<div className={classNames("bg_default", "p_m", "radius_m", styles.card)}>
			{children}
		</div>
	);
}
```

And the local CSS for component-specific tweaks:

```css
/* box.module.css */
.card {
	border: var(--token-border-weak);
	box-shadow: var(--token-shadow-sm);
}
```

No globals, no name collisions. Utilities are just module exports.

## T-shirt sizing, not numbers

We dropped numeric scales (`p-4`) and kept **t-shirt sizes** mapped to tokens:

- Spacing: `p_xs`, `p_s`, `p_m`, `p_l`, `p_xl`
- Gap: `gap_s`, `gap_m`
- Radius: `radius_s`, `radius_m`, `radius_l`
- Typography: `text_body`, `text_caption`, `text_title`

Everything resolves to design tokens at build time; no arbitrary values sneak in.

## Underscore not dash

Because each class is extracted as a javascript attribute our original API was exposing that object. classNames cames after so yes it could be reworked using dash but we have decided to keep it for now as it is.

## Color and state semantics

We kept naming semantic instead of chromatic:

- Background: `bg_default`, `bg_weak`, `bg_strong`, `bg_danger`
- Text: `text_primary`, `text_muted`, `text_inverse`
- Border: `border_default`, `border_weak`, `border_danger`

Tokens drive the actual color values, so theming is just swapping token files.

## Responsive without prefixed classes

We killed `sm:`, `md:` prefixes. Responsive rules live in CSS Modules via container queries and media queries, still token-driven:

```css
/* layout.module.css */
.grid {
	display: grid;
	grid-template-columns: 1fr;
	gap: var(--token-space-m);
}

@container (min-width: 720px) {
	.grid {
		grid-template-columns: 1fr 1fr;
	}
}

@media (min-width: 1024px) {
	.grid {
		grid-template-columns: repeat(3, 1fr);
	}
}
```

No class prefixes, no JS-based media API to maintain. The runtime stays lean, and semantics stay clean.

## Advanced needs: go local

When someone needs a custom animation, a specific layout hack, or an experimental pattern, they add a `*.module.css` next to the component and still consume tokens:

```css
/* hero.module.css */
.shine {
	background: linear-gradient(90deg, var(--token-bg-weak), var(--token-bg-strong));
	animation: shine 1.8s linear infinite;
}

@keyframes shine {
	from { background-position: 0% 50%; }
	to { background-position: 100% 50%; }
}
```

Utilities cover 80%. Modules handle the last mile. No globals, no overrides.

## Why the frontend teams love it

- **Speed**: utility ergonomics without hunting class collisions.
- **Predictability**: every class maps to a token; design and dev share the same vocabulary.
- **Portability**: no global stylesheet to import; tree-shaking keeps bundles small.
- **Less JS**: container/media logic stays in CSS; we removed our custom JS media API.
- **Escape hatches**: module CSS exists for edge cases, so the utility set stays tight.

## The takeaway

You can have Tailwind-like velocity **and** strong design system guarantees if you:

1. Scope utilities with CSS Modules (no globals).
2. Base every utility on design tokens (no raw values).
3. Prefer semantic naming (t-shirt sizes, intent-based colors).
4. Keep responsive logic in CSS (container/media), not in class names or JS.
5. Leave room for local CSS so the utility surface stays small.

The result: happier frontend teams, a safer design system surface, and zero regrets about ditching global CSS.

