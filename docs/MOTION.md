# Motion Guidelines for iOS 26

Target: **iOS 26**, **SwiftUI‑first**.
Audience: Cursor / coding agents implementing interaction and motion.
Goal: **Fluidity through seamless transitions.** The app is a continuously evolving space where elements can morph into each other when there is a strong, clear rationale.

---
## 1. Philosophy & Objectives

### 1.1 Motion Philosophy
- Motion is **structural**, not decorative.
- Every animation should answer: **what just changed and why?**
- The user should feel like they’re moving through **one continuous space**, not jumping between isolated screens.
- Any element can theoretically transform into another, **but only when it clarifies the mental model** (e.g., a tile becoming a full editor, a card becoming a detail view).

### 1.2 Design Objectives
- **Continuity**: preserve spatial + visual continuity when changing context.
- **Restraint**: fewer, higher‑quality motions > many small gimmicks.
- **Hierarchy**: motion should reinforce information hierarchy (primary elements move most, chrome moves least).
- **Directness**: user actions should map to visible, immediate reactions.

---
## 2. Motion Toolbox Hierarchy (SwiftUI‑First)

Always choose the **simplest tool** that achieves the desired clarity.

### 2.1 Levels of Motion

**Level 0 – No animation**
- Use when changes are subtle or frequent (e.g., counters, background sync) and animation would be distracting.

**Level 1 – Property Animations (default)**
- Tools: `withAnimation`, `.animation(_:value:)`, animatable view modifiers.
- Use for:
  - Small state changes (icon toggles, button pressed states, chips selecting/deselecting).
  - Layout shifts inside a single container where the relationship is obvious (e.g., reorder tiles, expand/collapse row).
- Preferred spring curves: system defaults (e.g., `.snappy`, `.bouncy`) or equivalent up‑to‑date presets in iOS 26.
- Durations:
  - Micro interactions: **0.12–0.2s**
  - Medium transitions: **0.25–0.35s**

**Level 2 – View Transitions**
- Tools: `.transition(_:)`, `.contentTransition(_:)`.
- Use for:
  - Show/hide of secondary UI (toolbars, trays, helper text).
  - Content swapping within a stable container (view/edit modes, filters, segmented control content).
- Rules:
  - Choose transitions that match directionality (e.g., `.move(edge: .bottom)` for trays from bottom).
  - Use `contentTransition(.opacity)` or similar for text/image changes when layout is stable.

**Level 3 – Navigation Transitions (preferred for screen changes)**
- Tool: `navigationTransition(_:)` on views inside `NavigationStack`.
- Use for:
  - **List → Detail** flows.
  - **Card → Fullscreen** flows when detail is presented via navigation.
  - Any push/pop where the user perceives moving deeper into the same space.
- Patterns:
  - Default to platform‑appropriate transitions unless you have a clear reason.
  - For hero/zoom flows (card grows into detail), prefer `.zoom` or equivalent high‑level navigation transition APIs instead of custom `matchedGeometryEffect`.

**Level 4 – Shared‑Element / Hero Transitions**
- Tools:
  - `navigationTransition(.zoom(sourceID:in:))` + `matchedTransitionSource(id:in:)` (for navigation flows).
  - `matchedGeometryEffect(id:in:properties:anchor:isSource:)` (for non‑navigation or custom flows).
- Use when:
  - A **specific element** clearly becomes another (tile → full editor, thumbnail → full image, chip → filter sheet header).
  - You need to communicate continuity across different parts of the view hierarchy.
- Rules:
  - Start with **navigation transitions + `matchedTransitionSource`** when possible.
  - Use raw `matchedGeometryEffect` when you’re not pushing a new navigation destination (e.g., overlay detail on top of grid, morph inside a single scene).
  - Limit to **one or two hero elements per transition** to avoid chaos.

**Level 5 – Multi‑Phase / Scripted Transitions**
- Tools: `PhaseAnimator`, `TransitionPhase`, `TransitionProperties` and similar multi‑phase APIs.
- Use when:
  - A transition needs **sequencing** (e.g., tile expands, then keyboard appears, then secondary controls fade in).
  - You want keyframe‑style control without leaving SwiftUI.
- Rules:
  - Keep phases minimal (2–3 steps). Avoid long “animation choreographies.”
  - Use phases to clarify hierarchy (primary element moves first, supporting elements follow).

---
## 3. Shared‑Element & Layout Transition Rules

### 3.1 When to Use `navigationTransition` vs `matchedGeometryEffect`

**Prefer `navigationTransition` when:**
- You are **pushing/popping** in a `NavigationStack`.
- User mental model: *“I tapped a cell/card and went deeper into it.”*
- Example flows:
  - Puzzle list → puzzle detail.
  - Card in a grid → full puzzle board.

**Use `matchedGeometryEffect` when:**
- You are **not** using navigation for the transition:
  - Tile morphing into an in‑place editor overlay.
  - Toolbar chip transforming into a pinned header.
  - Reordering / regrouping tiles where elements need to “slide/morph” to new locations.
- You need to coordinate multiple views that don’t live in a simple parent/child relationship.

### 3.2 Guardrails for `matchedGeometryEffect`

Agents must:
- Use **stable IDs**: the `id` used for `matchedGeometryEffect` should be tied to underlying model identity, not transient indices.
- Use **one shared `Namespace.ID` per logical feature area** (e.g., one namespace for the board, one for navigation chrome if needed).
- Keep `properties` minimal (e.g., default or `.frame` only) unless more is clearly necessary.
- Test for:
  - Layout glitches when items appear/disappear mid‑animation.
  - Performance on low‑end devices (avoid animating huge stacks of views).

### 3.3 Choosing Simpler Tools First

Before reaching for `matchedGeometryEffect`, agents must check:
1. Can a basic `transition(.opacity)` or `contentTransition` communicate the change?
2. Can `navigationTransition` express this as a standard screen change with a hero source?
3. Is the shared element really helping the mental model, or just “looks cool”?

Only use shared‑element transitions when the answer to (3) is **yes** and (1)/(2) are insufficient.

---
## 4. Liquid Glass & `GlassEffectTransition`

Liquid Glass is a **visual treatment**, not a layout system. Motion rules for it are layered **on top of** the main motion hierarchy.

### 4.1 Core Concepts
- Use `GlassEffectContainer` to define regions where Liquid Glass can exist.
- Use `glassEffect` on individual surfaces (toolbars, trays, cards).
- Use `glassEffectID` / `glassEffectUnion` to describe how glass regions relate and merge.
- Use `.glassEffectTransition(_:)` to control how the **glass itself** animates when states change.

### 4.2 When to Use `GlassEffectTransition`

Only when the view uses Liquid Glass.

- **Default** (recommended):
  - Rely on the system default (typically `GlassEffectTransition.matchedGeometry`).
  - Good for pills, toolbars, tiles that resize/move: the glass “flows” and morphs.

- **Use `.materialize` when:**
  - A glass element is **appearing/disappearing**, not morphing from another.
  - Example: a new glassy tray sliding in from bottom that doesn’t map to an existing glass region.

- **Use `.identity` when:**
  - The layout transition is already complex (e.g., strong `matchedGeometryEffect` + navigation transition) and morphing glass would be visually noisy.

### 4.3 Practical Rules

- Think of `glassEffectTransition` as a **local style knob** for glass surfaces, not a way to orchestrate entire flows.
- The **primary transition decision** remains: normal transitions, navigation transitions, or shared elements.
- Glass motion should be **subtle and secondary**, reinforcing the main layout motion.

---
## 5. Technology Choices: SwiftUI vs UIKit vs Lower‑Level APIs

### 5.1 Default: SwiftUI‑Only

Agents should assume **SwiftUI‑only** for:
- Standard navigation, full‑screen transitions, sheets.
- Hero transitions List → Detail / Card → Fullscreen.
- Board/tile layouts where performance is acceptable with `LazyVGrid`/`ScrollView`.
- Most toolbar, tray, and panel show/hide animations.
- Micro interactions and multi‑phase transitions.

If SwiftUI can express the motion clearly and performantly, **do not** reach for UIKit.

### 5.2 When UIKit is Necessary

Use UIKit via `UIViewRepresentable` / `UIViewControllerRepresentable` when **one of these is true**:

1. **Custom Keyboard & Input Chrome**
   - You need advanced control over keyboard accessory views beyond what SwiftUI’s `toolbar(placement: .keyboard)` and text field modifiers provide.
   - You need behaviors like:
     - Highly customized input accessory bars with complex interaction.
     - Fine‑grained control of first responder / keyboard dismissal sequences.

2. **Complex Collection‑Style Layouts**
   - You need advanced, highly tuned layouts similar to `UICollectionViewCompositionalLayout` with pinned headers, orthogonal scrolling sections, or heavy item counts where SwiftUI struggles.
   - Motion still follows the same design rules, but layout and scrolling behavior may live in UIKit.

3. **Physics‑Driven or Highly Custom Interactions**
   - You need realistic physics (spring chains, inertia, collision) that are difficult to approximate in SwiftUI.
   - Example: a card that can be flung and bounces off edges, or complex drag interactions with multiple snapping points.

4. **Custom View Controller Transitions**
   - You need transitions that operate at the **window / root controller** level and cannot be done inside a SwiftUI navigation system.

### 5.3 Bridging Rules

When using UIKit:
- Keep UIKit scoped to **the minimal surface necessary** (e.g., keyboard host controller, advanced collection view).
- Wrap the UIKit component in SwiftUI representable types and expose:
  - Simple, declarative bindings for SwiftUI state.
  - Callbacks for significant interaction events (drag ended, selection changed, etc.).
- Motion design still follows the **same hierarchy**:
  - Use UIKit’s equivalent of property animations, navigation transitions, and shared elements.
  - Avoid mixing conflicting transition systems (e.g., two different controllers animating the same element in incompatible ways).

---
## 6. Implementation Heuristics for Agents

When implementing any feature that changes layout or context, follow this checklist:

1. **Clarify the user story**
   - What is the user doing?
   - What changed in their mental model (zoom into, expand, filter, edit, dismiss)?

2. **Pick the lowest motion level that works**
   - Can Level 1 (property animation) explain it?
   - If it’s a screen change, can `navigationTransition` express it?
   - Only if continuity between specific elements is crucial, consider shared‑element transitions.

3. **Decide if a hero element exists**
   - Identify *one* main element that “drives” the transition.
   - Map that element through `navigationTransition` + `matchedTransitionSource` or via `matchedGeometryEffect`.

4. **Apply Liquid Glass rules (if relevant)**
   - Is this surface glass? If yes, choose an appropriate `glassEffectTransition`.
   - Keep glass motion subtle and supportive.

5. **Evaluate technology choice**
   - Can SwiftUI handle the motion + layout with acceptable performance?
   - If no, define a narrow UIKit bridge and keep motion rules consistent.

6. **Test for clarity and performance**
   - Does the user clearly perceive what changed?
   - Is the animation smooth at target frame rates on lower‑end hardware?
   - Are durations and curves consistent across similar interactions?

---
## 7. Anti‑Patterns (What Agents Should Avoid)

- Using `matchedGeometryEffect` as the **default** for all changes.
- Animating many unrelated properties at once (creates noise and confusion).
- Introducing custom transitions without a clear user story.
- Making Liquid Glass motion more prominent than the main content motion.
- Mixing SwiftUI and UIKit transitions in a way that causes visual fighting (e.g., double animations).

---
## 8. Summary for Agents

1. Start with **SwiftUI**, simple property animations, and basic transitions.
2. Use `navigationTransition` for most screen‑to‑screen changes.
3. Use shared‑element transitions (`matchedTransitionSource` / `matchedGeometryEffect`) **only** when they clarify continuity.
4. Treat Liquid Glass motion as a **secondary, supporting layer** controlled by `glassEffectTransition`.
5. Pull in UIKit only when SwiftUI cannot meet layout or interaction requirements.
6. Always optimize for **clarity, continuity, and restraint**: the app should feel like one fluid, evolving space, not a stage for animation tricks.

