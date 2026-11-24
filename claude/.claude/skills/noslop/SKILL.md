---
name: noslop
description: "Anti-slop UI styling principles: eliminates generic AI visual tropes, decorative gimmicks and filler copy. Use when designing or reviewing UI."
---

# Anti-Slop UI Styling Workflow

This workflow enforces clean, industrial, and purpose-driven interface design. It strictly bans the generic aesthetic tropes and filler content produced by default AI models.

---

## 1. The Core Philosophy

**Form follows function.** Interfaces should look like serious, professional software engineered for utility, not a Dribbble concept or a cookie-cutter SaaS marketing mockup.

- Prefer solid surfaces over blurry transparencies.
- Prefer crisp borders over glowing halos.
- Prefer honest, direct labels over corporate filler jargon.
- Prefer semantic layout over floating card syndrome.

---

## 2. The 8 Hallmarks of AI Slop Styling (Strictly Banned)

Every design and code review must actively screen for and eliminate these 8 anti-patterns:

### 1. The Glowing Orb / Radial Aura Trap

- **The Slop:** Backgrounds featuring soft radial gradients, blurry colored blobs in corners, glowing top-down spotlights, or neon light leaks (`bg-[radial-gradient(ellipse_at_top,...)]`).
- **The Rule:** Zero ambient glow orbs. Use solid, deliberate background tokens (`bg-background`). Depth is achieved through clean border contrast, layer elevation, and whitespace—never decorative light leaks.

### 2. The Floating Glassmorphism Box

- **The Slop:** Cramming every screen into a centered `bg-card/80 backdrop-blur border shadow-2xl` rounded rectangle floating in an empty void.
- **The Rule:** Design real full-screen viewports. Ground the view with structural layouts (e.g., split shells, sidebars, anchored headers, or clean canvas alignment). Only use floating cards when modal containment is functionally required.

### 3. Decorative Trust Badges & Floating Pills

- **The Slop:** Placing a rounded pill badge above titles with arbitrary icons (e.g., `<Shield> ENTERPRISE GRADE`, `<Sparkles> AI POWERED`, `<Lock> SECURE PORTAL`).
- **The Rule:** Real tools do not paste decorative badges to validate their existence. Delete all decorative status pills and artificial trust badges unless displaying a live, dynamic system status indicator.

### 4. Hallucinated Corporate Marketing / Filler Copy

- **The Slop:** Text like _"Enter your administrative credentials to access the governance control plane"_, _"Experience seamless operational excellence"_, or _"All access is strictly monitored and audited"_.
- **The Rule:** Write terse, human, functional copy. State what the screen does in 3 to 6 words:
  - Slop: _"Administrative access and governance gateway"_ → **Clean: "Sign in"**
  - Slop: _"Enter your email below to access your account dashboard"_ → **Clean: "Enter your email"**

### 5. Gradient Text & Gratuitous Accent Highlights

- **The Slop:** `bg-gradient-to-r from-blue-400 to-emerald-400 bg-clip-text text-transparent`, multi-colored border gradients, or bright accent colors applied to standard body text.
- **The Rule:** Use high-contrast, solid foreground tokens (`text-foreground`). Restrict accent and CTA colors strictly to primary interactive actions and state changes.

### 6. Icon Pollution

- **The Slop:** Prepending every single label, button, tab, and card title with a generic line icon (e.g., email icon inside the email label, lock icon inside password label, user icon on user header).
- **The Rule:** Icons must convey structural information or provide functional affordances (e.g., clear indicator, toggle visibility, loading spinner, error alert). If an icon is purely decorative and repeats what the label already says, remove it.

### 7. Disproportional Typography & Cramped Elements

- **The Slop:** Huge display headings (`text-4xl`) placed right above miniature, tight inputs (`h-7`), or random font sizes without an underlying scale.
- **The Rule:** Match heading scale to container width. Maintain ergonomic tap/click heights on interactive elements (minimum 32px–40px on primary actions). Align type scales consistently.

### 8. Faux-Enterprise Symmetry

- **The Slop:** Centering every single element—center-aligned headers, center-aligned descriptions, center-aligned inputs, center-aligned footers.
- **The Rule:** Left-align forms, data, and technical content by default. Natural reading order creates faster visual processing than centered blocks.

---

## 3. The Non-Slop Replacement Checklist

Before finalizing any UI implementation, run this verification:

- [ ] **Background**: Is the canvas solid and clean without glowing radial orbs or blurry color spots?
- [ ] **Badges**: Are there zero decorative pill tags or fake trust icons?
- [ ] **Copy**: Is every heading and description brief, direct, and free of marketing buzzwords?
- [ ] **Contrast**: Are borders and text crisp, high-contrast, and legible according to the design system?
- [ ] **Icons**: Does every single icon serve an actual functional purpose?
- [ ] **Rhythm**: Are element heights, paddings, and font sizes balanced and comfortable to interact with?
- [ ] **Alignment**: Is content aligned naturally rather than arbitrarily centered?
