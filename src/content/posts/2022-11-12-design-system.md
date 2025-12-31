---
title:  "The Rise and Fall (and Rebuild) of Talend/UI: Lessons from a Design System Gone Wrong"
categories: ["en"]
tags: ["Talend", "TypeScript", "Design System", "React", "Architecture"]
date: 2022-11-12
---

Five years ago, Talend decided to build a design system. Codename: "Coral". Public repository: Talend/UI. It was supposed to unify the experience across all products, eliminate inconsistencies, and make development faster. 

What happened instead was a cautionary tale about technology choices, adoption, and the cost of betting on unstable libraries. And somehow, I ended up owning the wreckage.

## The Initial Excitement (and My Skepticism)

When the design system initiative was announced, I was... conflicted.

On one hand: **YES.** We needed consistency. Every product at Talend looked slightly different. The user experience was a mess. A centralized design system sounded perfect.

On the other hand: **ARE YOU KIDDING?** We already had Bootstrap. We had CSS. Why would we recreate a button?

I was **blind**. Willfully blind.

## The Bootstrap Problem Nobody Talks About

This is what I didn't understand at the time: **Bootstrap was killing us.**

It's not that Bootstrap is bad. Bootstrap 3 was great when it came out in 2012. But by 2018, it had become a technology graveyard.

**The problems we faced:**

1. **Global CSS is unmaintainable** : Every Talend product had Bootstrap. But every product had also added its own CSS overrides. Tons of them. Trying to upgrade Bootstrap meant auditing 50+ CSS files to see what would break.

2. **Customization is a nightmare** : Want to change the button color globally? Good luck. Bootstrap's variables were top-level, so you'd have to recompile everything. And if someone had added a CSS rule targeting `.btn`, recompiling wouldn't help.

3. **No real versioning** : Bootstrap was a global dependency. If Product A needed Button v1 and Product B needed Button v2, you were out of luck. They shared the same styles.

4. **CSS specificity wars** : Each product tried to override Bootstrap in different ways. Some used `!important`. Some added wrapper classes. Some added inline styles. It was chaos.

5. **Consistency was impossible** : The button in Product A looked different from the button in Product B. Not intentionally. Just because each team had tweaked Bootstrap differently.

I remember spending an entire day trying to figure out why a button in one product had different padding. The answer? Someone had added a `.btn { padding: 12px !important; }` in one of six CSS files. Finding it took forever.

**This is what Bootstrap looks like at scale.** It's not the framework's fault. It's the inevitable result of treating global styles as a free good.

## The Designer Problem: Adoption from the Design Side

Here's something nobody talks about in design system articles: **designers have the exact same adoption problem as developers.**

When the design system team proposed Coral, they were excited. They had created beautiful, modern, accessible components in Figma. They had done extensive user research. They had created design guidelines. Everything was perfect.

Then they tried to get designers from other products to use the design system.

**What happened?** Nothing. Or worse, adoption was slower than molasses.

**Why?**

1. **Senior designers resisted change** : Some of the most experienced designers at Talend had built their own design patterns over years. They had a vision. Asking them to use someone else's components felt like losing creative control. "This button is nice, but our product needed something different," they'd say.

2. **"But our users expect it to look this way"** : Just like developers with Bootstrap, designers had trained their users on specific UI patterns. A new design system meant re-educating users. That's scary.

3. **Design tokens were abstract** : We kept talking about "design tokens" and "system thinking." But to a designer working on a specific product, it felt like corporate constraints. "I need this color to be #FF5733, not your #FF5722."

4. **No single source of truth between design and code** : Designers would create in Figma. Developers would implement in React. They'd drift. Designers would complain. Developers would say "that's not what you designed." Both were right.

5. **Lack of designer involvement** : The first Coral team was mostly developers. There wasn't enough designer voice in the early decisions. This led to beautiful components that didn't match how designers actually wanted to work.

6. **Customization felt impossible** : A senior designer at one of our biggest products asked: "Can I use these components but customize the spacing?" The answer was basically "no." So they didn't use it.

The lesson? **Design systems fail not because of code. They fail because people (both designers and developers) feel constrained.**

A good design system needs:
- **Flexibility, not rigidity** : Allow customization at the edges
- **Designer buy-in, not just developer buy-in** : Involve senior designers from day one
- **Clear documentation of the "why"** : Not just rules, but reasoning
- **Opt-in adoption, not mandate** : Let teams choose to switch, don't force them
- **Regular user research** : Talk to both designers and developers using the system

What I should have done: involved senior designers as co-architects, not just stakeholders. Their resistance wasn't obstinacy. It was expertise. They saw problems the younger team didn't.

## Design Tokens: The Secret Weapon

Here's the thing that actually works: **Design Tokens.**

Design tokens are the single biggest win of the Coral project. They're understated, boring, but incredibly powerful.

A design token is simply: **a named value representing a design decision.**

Instead of:

```css
/* BAD: Magic colors scattered everywhere */
button {
  background-color: #007BFF;
  color: white;
  padding: 10px 20px;
  border-radius: 4px;
}

.button-danger {
  background-color: #DC3545;
}

.button-success {
  background-color: #28A745;
}
```

You have:

```json
{
  "color": {
    "primary": {
      "value": "#007BFF"
    },
    "danger": {
      "value": "#DC3545"
    },
    "success": {
      "value": "#28A745"
    }
  },
  "spacing": {
    "xs": { "value": "4px" },
    "sm": { "value": "8px" },
    "md": { "value": "12px" },
    "lg": { "value": "16px" }
  }
}
```

Then your component becomes:

```typescript
import tokens from '@talend/tokens';

const buttonStyles = {
  backgroundColor: tokens.color.primary.value,
  color: '#FFF',
  padding: `${tokens.spacing.md.value} ${tokens.spacing.lg.value}`,
  borderRadius: tokens.spacing.xs.value,
};
```

**Why is this so powerful?**

### 1. Design and Code Speak the Same Language

Designers work with the same token names as developers:

**In Figma:**
```
Fill: color/primary
Padding: spacing/lg
```

**In Code:**
```typescript
backgroundColor: tokens.color.primary.value
padding: tokens.spacing.lg.value
```

No translation layer. No confusion. Designers specify "color/primary" and developers use "color/primary."

### 2. Theming Becomes Trivial

Want a dark mode? Create a new token file:

```json
// tokens-light.json
{ "color": { "primary": "#007BFF" } }

// tokens-dark.json
{ "color": { "primary": "#0099FF" } }
```

Then switch:

```typescript
import tokens from process.env.THEME === 'dark' 
  ? '@talend/tokens-dark'
  : '@talend/tokens-light';
```

No component code changes. At all.

### 3. Global Updates Become Real

When your CEO says "change all buttons to red," instead of:

1. Edit Figma (10 components)
2. Alert all designers (email)
3. Developers update each component (5 files)
4. Test 20 products (days)
5. Deploy (days)

You do:

1. Change one token file: `color.primary: #FF0000`
2. Deploy token package
3. All products automatically use the new color

### 4. Maintainability Explodes

With tokens, the source of truth is **one file per category**:

```
tokens/
├── color.json
├── spacing.json
├── typography.json
├── shadow.json
└── border-radius.json
```

Not scattered through 100 CSS files. Not duplicated. Not magical.

### 5. Scalability for Multiple Products

At Talend, we have 10+ products. Before tokens:

- Product A uses `--color-primary: #007BFF`
- Product B uses `--primary-color: #007BFF`
- Product C uses `primaryColor = 0x007BFF`

All the same color. Three different names. Impossible to sync.

With tokens, **all products use the same token file.** Done.

### 6. Tokens Enable Micro-Customization

A product wants to use your design system but needs slightly different spacing? Instead of forking the entire system:

```json
{
  "extends": "@talend/tokens",
  "spacing": {
    "md": { "value": "14px" }  // Override just this
  }
}
```

Clean. Simple. Mergeable.

### 7. Design Token Tools Exist Now

In 2024, there are amazing tools for managing tokens:

- **Figma Tokens** : Design tokens directly in Figma, sync to code
- **Tokens Studio** : Token management with version control
- **Style Dictionary** : Transform tokens to any format (CSS, JS, JSON, etc.)
- **Specify** : Cloud-based token management

We could have used these from day one. We didn't. Mistake.

## How Design Tokens Should Have Worked at Coral

Here's what I'd do if I could rewind:

**Year 1:**
1. Create tokens file: colors, spacing, typography, shadows
2. Publish as a package: `@talend/tokens`
3. Use Figma Tokens plugin to keep Figma and JSON in sync
4. Designers and developers use the same token names
5. Zero components yet. Just tokens.

**Year 2:**
1. Build first 5 components using the tokens
2. Token file becomes the single source of truth
3. Any product can customize by extending the tokens
4. Publish both light and dark token sets

**Year 3:**
1. Add more components
2. Token system is stable and proven
3. Adoption happens naturally because tokens work

What actually happened:

**Year 1:**
- Build 50 components immediately
- Hard-code colors everywhere
- Designers ignore the token layer
- Developers confused about what to override

**Year 2:**
- Try to retrofit tokens into existing components
- It's messy. It's complicated.
- Nobody agrees on token names
- Adoption is still low

Tokens should have been the foundation. Everything else builds on top.

## The Token Lesson

Here's the real insight: **Design systems are really about creating a shared vocabulary.**

Design tokens are that vocabulary. They're boring. They're simple. They're not exciting.

But they work.

Senior designers didn't resist tokens. They resisted 50 pre-built components they didn't choose. They resisted losing creative control.

But tokens? Tokens let designers and developers collaborate. They make theming easy. They make updates global.

If Coral had been "design tokens + whatever components you need," it would have been adopted immediately.

Instead, it was "here are 50 components, use them all or nothing."

Big difference.

## Enter Coral: The Design System

So the design system team proposed a solution. Their proposal:

- **TypeScript** - Good, type safety for components
- **Styled Components** - For scoped CSS
- **React Aria** - For accessibility (but in alpha)
- **React** - For the component framework

As an architect, I was... hesitant.

Not because the tech was bad. But because:

1. **React Aria was in alpha** : We were betting on a library that wasn't stable
2. **Styled Components adds bundle size** : Shipping a CSS-in-JS library with every component
3. **Uncontrolled patterns only** : The first versions only supported uncontrolled components (`<input defaultValue="..." />`). React best practices call for controlled components (`<input value={...} onChange={...} />`).
4. **Button size was different** : The new design system button was a different size than the Bootstrap button. Good design, sure. But **adoption suicide.**

But you know what? The team had conviction. They were excited. They had a vision. And that matters.

So we got on board. We built the infrastructure. We created a CDN for distribution (remember the Yarn article? That was part of this effort). We committed to the push.

## Two Years of... Not Much

What happened next was frustrating.

The design system team spent two years building components, refining APIs, and pushing for adoption.

The adoption... didn't happen.

**Why?**

1. **The button looked different** : Product teams had trained their users on the current button. Switching meant a breaking change to the user experience. "Is the button still clickable?" customers would ask. Silly? Yes. Real? Also yes.

2. **Uncontrolled pattern limitation** : Developers wanted to write:
```javascript
const [value, setValue] = useState('');
<Input value={value} onChange={(e) => setValue(e.target.value)} />
```

But Coral only offered:
```javascript
<Input defaultValue='' />
```

Uncontrolled components are simpler but less flexible. Most React developers had moved to controlled components because they're more powerful.

3. **React Aria concerns** : React Aria was (and still is) a heavy library. Developers worried about bundle size. They worried about stability. The accessibility was great, but at what cost?

4. **The design system looked... corporate** : And that's fine! But some teams wanted customization that Coral's strict design didn't allow.

So most teams continued using Bootstrap. Some started the migration. Many created workarounds.

The design system existed, but as a **library without adoption**. A solution without a problem.

## The Crisis: The Entire Team Left

Then came 2024. The entire design system team left Talend.

All of them. Gone.

And guess who became the owner of Talend/UI?

Me.

I inherited:
- A React component library using styled-components and React Aria
- A build infrastructure worth maintaining
- Zero dedicated resources
- Hundreds of thousands of lines of code

Oh, and **a legacy of low adoption.**

## The Audit: What Do We Actually Need?

Once I owned the system, I had to ask hard questions:

1. **What's actually being used?** : By looking at npm download stats and internal metrics, I found that only 30% of the components were actively used. Some components had zero downloads.

2. **What's our real problem?** : It wasn't "lack of a design system." It was "legacy Bootstrap is killing us, but we can't all migrate together."

3. **What should the solution be?** : A lightweight, stable, HTML-centric component library. Not another Figma-to-code pipeline. Just components that work.

## The Realization: UI Libraries Are Unstable

This is the biggest lesson I learned:

**You should not build products on top of unstable UI libraries.**

Here's why:

1. **Libraries evolve, your code doesn't** : React Aria changes its API. Styled-components changes how it handles SSR. Your code has to adapt or break.

2. **Dependencies become liabilities** : React Aria depends on 5 other libraries. Styled-components depends on 3. If any of those breaks, your design system breaks. And every product depending on your design system breaks.

3. **Bundle size compounds** : You add React Aria (+30KB). You add styled-components (+15KB). You add date-picker library (+40KB). Suddenly your button component is 85KB.

4. **Maintenance burden grows** : When React Aria releases a breaking change, you have to update it. When styled-components fixes a bug, you need to test it. You become a coordinator, not a builder.

5. **You lose control** : The library maintainers own your component behavior. If they decide to deprecate something, you have to follow.

## The New Direction: Own the HTML

So here's what I'm doing now:

**Remove React Aria. Remove styled-components. Use native HTML.**

Instead:

```typescript
// Old approach (Coral v1)
import { Button } from '@talend/components';
import styled from 'styled-components';

export function MyButton() {
  return <Button variant="primary" />;
}

// New approach (Coral v2)
import { Button } from '@talend/components';

export function MyButton() {
  return <Button className="primary" />;
}
```

The new components are:

- **TypeScript for type safety** - Good
- **CSS Modules for scoping** - Simple and stable
- **Plain React for interactivity** - No synthetic complications
- **HTML semantics first** - `<button>`, `<input>`, `<form>`, etc.
- **Optional: Radix UI or Headless UI for the really complex stuff** - But only when we REALLY need it

**Why this works:**

1. **HTML is stable** : The `<button>` element will work the same way in 10 years
2. **CSS Modules are simple** : No black magic, just CSS with local scope
3. **Less dependencies** : Fewer things can break
4. **Smaller bundle** : We're not shipping extra libraries
5. **Easy to maintain** : You can see exactly what the button does by reading the code
6. **Developer friendly** : React developers understand `<button>` immediately

## The Migration Plan

Now I'm planning a migration from Coral v1 (styled-components + React Aria) to Coral v2 (TypeScript + CSS Modules + HTML).

Here's my strategy:

1. **Start with the most-used components** : Button, Input, Select, Modal
2. **Build v2 alongside v1** : No breaking changes yet
3. **Migrate product teams gradually** : They choose when to switch
4. **Deprecate v1 slowly** : Give teams time to adapt
5. **Document the hell out of it** : Make migration easy

This will take time. But it's the right approach.

## The Lessons

Here's what I learned from this entire journey:

### 1. Bootstrap isn't the problem; global CSS is

The mistake wasn't using Bootstrap. The mistake was using global CSS at scale. Any framework would have the same problem.

### 2. Don't bet on alpha libraries for production

React Aria is great. But building a design system on an alpha library was risky. We should have waited for stability.

### 3. Adoption is harder than tech

The best design system in the world won't be adopted if it breaks the user experience. A 30% larger button is not a "design improvement." It's a breaking change.

### 4. Uncontrolled patterns are a limiting pattern

Controlled components are the React default for good reasons. Building a design system that doesn't support them is a losing bet.

### 5. Bundle size matters

Each library adds cost. styled-components + React Aria sounds like "just two libraries." But each pulls in more dependencies. Before you know it, your button is 100KB.

### 6. Fewer dependencies = less maintenance

This is the big one. **UI libraries are not stable enough to be used in products. You should build your own and own the entire HTML rendering.**

Use a library when you REALLY need one. Not because it sounds cool or makes the code "cleaner."

For Talend/UI v2, I'm building 95% in-house HTML. The remaining 5% will use Radix UI or Headless UI for extremely complex components (like the autocomplete with virtualization).

But the button? That's ours. The input? Ours. The modal? Ours.

We own the HTML. We own the behavior. We own the future.

## What I'd Do Differently

If I could go back in time and advise the 2018 design system team:

1. **Start smaller** : One product, one button, solve the real problem
2. **Own the HTML** : Build components with plain React + CSS Modules from day one
3. **Focus on adoption** : Make the new button exactly match the old one initially, then iterate
4. **Use libraries strategically** : Only for things we can't build (like date picker with virtualization)
5. **Build incrementally** : Bootstrap → Coral v0 (same look) → Coral v1 (new look with opt-in) → Full migration
6. **Measure adoption** : Make adoption easy to measure and a team KPI

## Where We Are Now

It's 2022. I'm maintaining Talend/UI.

The new v2 is simpler, faster, and more maintainable.

The bundle size will going down as adoption increase.

The code is easier to read.

And most importantly: **we own our UI layer**. That ownership is worth every day I spend rebuilding this.

## Conclusion

Design systems are hard. Really hard.

The hardest part isn't the technology. It's the adoption. It's making decisions that balance innovation with backward compatibility. It's owning the consequences of those decisions.

Coral wasn't a failure. It was a learning experience. And sometimes, the best design system is the one you build incrementally, starting small, with a deep commitment to owning your own code.

If you're building a design system, here's my advice:

- **Own the HTML**. Don't bet on unstable libraries.
- **Focus on adoption**. Tech is easy; people are hard.
- **Start small**. One component, get it right, then scale.
- **Measure everything**. You can't improve what you don't measure.
- **Be willing to rewrite**. If it's not working, the cost of starting over is usually less than the cost of pushing forward.

And if you inherit a design system that's struggling? It's okay to rebuild. Sometimes the best path forward is to acknowledge that the previous approach didn't work and start fresh with what you've learned.

---

**Talend/UI Resources:**
- [Talend/UI on GitHub](https://github.com/Talend/ui)
- [Design System Lessons from Airbnb](https://www.designsystems.com/case-study-airbnb/)
- [Building a design system: the practical guide](https://www.designsystems.com/)

