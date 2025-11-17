# iykyk – Puzzle Creation UX

## 1. Overall Mental Model

* The **4×4 grid (“board view”) is home base** for creation and later gameplay.
* Users always start by seeing all **16 word tiles** arranged in 4 horizontal rows.
* Each **row represents a category** (group) but **category names are not shown** in the board view to mimic the player experience.
* Creation feels like **designing a board**, not filling out a form.

## 2. Board View (Default State)

* Layout:

  * 4×4 grid of tiles, all visible at once.
  * Tiles are grouped into **4 horizontal rows**.
* Visual grouping:

  * Each row has a **subtle container background** or tint to imply grouping.
  * The styling is calm and minimal (no loud colors).
* No category names in this view:

  * Keeps the board visually clean.
  * Reinforces the idea that the creator is seeing roughly what the player will see.

## 3. Category-Level Editing (Zoomed State)

* Tapping **any tile in a row** selects that row’s category and enters **edit mode for that category**.
* We **zoom into the category**, not individual words, to reduce taps and mental overhead.
* In edit mode:

  * The **row’s container expands to fill the screen** as a card/sheet.
  * A **category name text field appears at the top**.
  * The **4 tiles/fields for that category move up** under the title, staying visually anchored to their origin row.
  * Tiles from the other 3 categories **fade/dim out** and are effectively hidden while editing.
* This keeps the interaction focused while maintaining a mental link to the board.

## 4. Transition & Motion Principles

* Transitions should feel **fluid and continuous**, not like jumping between separate screens.
* We use a shared-element style pattern conceptually (SwiftUI `matchedGeometryEffect` later in implementation):

  * The **row background** and possibly a representative tile share a visual identity between board and edit states.
  * When entering edit mode, the selected row appears to **lift off the grid and expand** into a full-screen editor.
  * When exiting, it **shrinks and returns** to its row position.
* Other rows lightly **scale/fade back** during the transition to emphasize focus on the active category.
* The interaction is a **mode shift**, but feels like one continuous space.

## 5. Keyboard & Layout Considerations

* The **on-screen keyboard takes significant vertical space** during editing.
* Edit mode layout must be designed so that, with the keyboard up:

  * The category name field, 4 word tiles/fields, and a clear Done control all remain usable.
  * Content sits **just above the keyboard** without awkward scrolling or overlap.
* Flow when a tile is tapped:

  1. Category row visually expands and transitions into edit mode.
  2. Only once the layout is stable, the **keyboard appears**.
  3. The **tapped tile’s text field becomes focused**, allowing immediate typing.
* We accept that keyboard choreography may require a slight pause between animation and focus to keep things smooth.

## 6. Mode Exit / Done Affordance

* Edit mode needs a **clear, explicit way** to return to board view.
* Preferred pattern: a **`✓ Done` control** (icon + text) in a predictable location (e.g., top-right).
* Secondary dismiss options (tap outside card, swipe down) are optional and can be layered on later, but **Done** is the primary, reliable exit.
* When Done is tapped:

  * We animate the editor back into its row on the board.
  * Category/word changes remain visible in the board view tiles.

## 7. What We Intentionally Exclude (For Now)

* **No microcopy or onboarding hints** in this prototype:

  * We are not adding helper text like “Tap a word to edit” yet.
  * New-user education will be solved later once core interactions feel right.
* **No visual labeling of “your group” vs AI groups**:

  * All four categories should feel equally authored by the creator in the final UX.
  * We avoid anything that fragments ownership or emphasizes which parts were assisted.
* **No puzzle validation or AI assistance here**:

  * This prototype focuses solely on the board ↔ category edit interaction, motion, and keyboard handling.

## 8. Quality Bar for Visual & Interaction Craft

* Visual design: **minimal, calm, and precise**.

  * Strong typography and spacing.
  * Restrained color, mainly used for subtle row differentiation and state.
* Motion design:

  * Transitions should feel **smooth, confident, and “expensive”**.
  * No gratuitous animation; just enough to explain spatial relationships.
* Accessibility / resilience:

  * Interaction should still work and feel reasonable with reduced motion enabled.

These decisions define the UX target for the first set of prototypes around the board and category edit interaction. We’ll only add complexity (validation, AI assist, onboarding) once this foundation feels excellent on-device.
