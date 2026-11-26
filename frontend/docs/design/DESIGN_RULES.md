# Design rules

1. Every value comes from `tokens.md`. No raw hex, px font sizes or one-off shadows in components.
2. Mobile first. Every screen works at 375 px with no horizontal scroll.
3. Light and dark themes both pass WCAG AA contrast (4.5:1 text, 3:1 large text and UI).
4. Every interactive element is reachable and usable by keyboard, with a visible focus ring.
5. Empty, loading and error states are designed, not left to chance.
6. One primary action per view.
7. Motion respects `prefers-reduced-motion`.
8. A new screen is done when its Stitch export (or sketch), tokens and Playwright screenshots are in this folder or the PR.
