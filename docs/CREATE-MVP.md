# iykyk – Puzzle Creation MVP

## 1. Core Principle

**Inline editing with full spatial context through scrolling.**

This MVP prioritizes simplicity, speed of implementation, and comfortable tap targets over forcing content into constrained space. The interaction model is straightforward: tap any element to edit it inline. When the keyboard appears, the active field scrolls into view while maintaining access to all other rows via natural scrolling.

---

## 2. Overall Layout

```
┌─────────────────────────────┐
│   Puzzle Title              │  ← Editable text field
│                             │
│  ╔══ SCROLLABLE CONTENT ══╗ │
│  ║ Category 1 ────────────║ │  ← Tap category label to edit
│  ║ ┌────┬────┬────┬────┐ ║ │
│  ║ │ W1 │ W2 │ W3 │ W4 │ ║ │  ← Tap any word to edit
│  ║ └────┴────┴────┴────┘ ║ │
│  ║                        ║ │
│  ║ Category 2 ────────────║ │
│  ║ ┌────┬────┬────┬────┐ ║ │
│  ║ │ W1 │ W2 │ W3 │ W4 │ ║ │
│  ║ └────┴────┴────┴────┘ ║ │
│  ║                        ║ │
│  ║ Category 3 ────────────║ │  ← May be partially visible
│  ║ ┌────┬────┬────┬────┐ ║ │     depending on device size
│  ║ │ W1 │ W2 │ W3 │ W4 │ ║ │     when keyboard is up
│  ║ └────┴────┴────┴────┘ ║ │
│  ║                        ║ │
│  ║ Category 4 ────────────║ │  ← Scroll down to access
│  ║ ┌────┬────┬────┬────┐ ║ │
│  ║ │ W1 │ W2 │ W3 │ W4 │ ║ │
│  ║ └────┴────┴────┴────┘ ║ │
│  ╚════════════════════════╝ │
│                             │
│  [Save Draft] [Preview]    │  ← Bottom actions
└─────────────────────────────┘
     ▲
     │
  [Keyboard appears here]
   (Active field auto-scrolls into view)
```

**Key layout principle:** Content is designed with comfortable tap targets (44pt minimum). The `ScrollView` content (`VStack`) naturally sizes itself based on its children—no hardcoded heights. The board extends beyond the keyboard-up viewport on smaller devices, with smooth scrolling to access all content.

---

## 3. Interaction Model

### 3.1 Editing Words

**Tap any word tile** → that tile becomes an editable text field:
- Tile subtly changes visual state (e.g., slight scale, border highlight, background shift)
- Keyboard appears
- Text cursor is placed in the field
- Other tiles remain visible and tappable
- **Tap another tile** → focus moves to that tile (keyboard stays up)
- **Tap outside tiles or keyboard Return key** → field loses focus, keyboard may dismiss

**Visual state:**
- **Empty tiles** show placeholder text like "WORD" in a muted color
- **Active tile** (currently editing) has a distinct border or glow
- **Filled tiles** show the word text in primary color

### 3.2 Editing Category Names

**Tap the category label** (e.g., "Category 1") → it becomes an editable field:
- Small inline text field expands from the label position
- Keyboard appears
- User types the category name
- Field has a character limit (e.g., 24 characters) with counter shown
- **Return key or tap outside** → field saves and collapses back to label

**Empty state:**
- Default labels: "Category 1", "Category 2", etc. in placeholder style
- Once edited, shows user's custom name

### 3.3 Row Visual Grouping

- Each row (category) has a **subtle background container** that groups its 4 tiles together
- Category label is positioned immediately above its row
- Tapping anywhere in the row background *except* on a tile or label does nothing (allows for accidental touches)

---

## 4. Navigation & Actions

### 4.1 Top Navigation Bar
- **Cancel** (left): Discards unsaved changes, returns to library
- **Title**: "New Puzzle"
- *(No right button needed—saves happen automatically)*

### 4.2 Bottom Actions
- **Save Draft**: Saves puzzle to library (always available, even if incomplete)
- **Preview**: Opens preview mode to see puzzle as player would (shuffled tiles)
  - Available only when puzzle is valid (4 categories × 4 words all filled)

### 4.3 Auto-save Behavior
- Changes are auto-saved locally as user types
- "Save Draft" button provides explicit confirmation and returns to library
- No risk of data loss

---

## 5. Keyboard Choreography

### 5.1 Layout Strategy
- Board content uses a `ScrollView` containing a `VStack`
- Total board height is determined naturally by component sizes:
  - Puzzle title field + padding
  - 4 category sections (label + 4-tile row + spacing) × 4
  - Bottom action buttons
- When keyboard appears, SwiftUI's automatic keyboard avoidance scrolls the active field into view
- User can manually scroll to see other rows while keyboard remains up
- **On larger devices** (iPhone 15 Pro, Pro Max): More content stays visible above keyboard
- **On smaller devices** (iPhone SE): Active field + adjacent rows visible, others accessible via scroll

**Design principle:** Prioritize comfortable tap targets (44pt minimum) and legibility over forcing everything into constrained space. Let SwiftUI naturally size the content based on its children. Spatial context comes from quick, natural scrolling between visible rows.

### 5.2 Component Sizing

Each component naturally defines its own size:

**Puzzle Title Field**
- Height: ~44-50pt (TextField with padding)
- Top/bottom padding: 8-12pt

**Category Row (each of 4)**
- Category label: 16-18pt font + 4-8pt padding = ~24-28pt
- Word tiles row: 44pt minimum height + 8pt internal padding = ~52pt
- Bottom spacing: 12pt
- **Total per category: ~88-92pt**

**Bottom Actions Bar**
- Height: ~60pt (buttons + padding)

**Estimated Total Content Height**
- Title: 50pt
- 4 categories: 4 × 90pt = 360pt
- Actions: 60pt
- **Total: ~470pt**

This naturally exceeds the ~280pt available above keyboard on iPhone SE, confirming scrolling is necessary. SwiftUI's `VStack` calculates this automatically—no manual height setting required.

### 5.3 Focus Management
- Tapping a tile/category field brings up keyboard and focuses that field
- **Keyboard toolbar** Moves focus through fields in logical order (left-to-right, top-to-bottom)
- **Return key**: Defocuses current field, keyboard dismisses

---

## 6. Visual & Interaction Craft

### 6.1 Visual Design
- **Calm, minimal aesthetic**
  - Subtle row backgrounds (e.g., very light tint or translucent fill)
  - Clear tile borders or shadows to define tappable areas
  - Strong, readable typography for tile text
- **Restrained color usage**
  - Each category has it's own unique color to identify difficulty like NYT Connections.  The color coding is persistent globally across all puzzles in iykyk
  - Active/focused state uses accent color or gentle glow
- **Spacing & rhythm**
  - Consistent padding within and between rows
  - Tiles sized for comfortable tapping and reading

### 6.2 Motion & Transitions
- **Minimal animation**
  - Fluid continuity when transitioning elements between views
  - Subtle spring physics
  - Smooth keyboard appearance (native iOS behavior)
- **Fast and responsive**
  - Taps register immediately
  - Keyboard appears promptly
  - No artificial delays or pauses

### 6.3 Accessibility
- All tiles and labels meet minimum tap target size (44×44pt)
- High contrast text
- Supports Dynamic Type
- Works with VoiceOver (field labels, hints)

---

## 7. States & Edge Cases

### 7.1 New Puzzle State
- All 16 word tiles show "WORD" placeholder
- Category labels show "Category 1", "Category 2", etc.
- Puzzle title shows "New Puzzle"

### 7.2 Partially Complete Puzzle
- Some tiles filled, others empty
- Can save at any state
- Preview button disabled until all fields filled

### 7.3 Validation (Minimal for MVP)
- **No in-your-face validation errors**
- Preview button is simply disabled if puzzle incomplete
- Optionally: subtle red tint or icon on Save/Preview if there are issues (like duplicate words)
- **No blocking alerts or modals**—keep flow uninterrupted

---

**MVP scope:**
- Single-screen, inline editing
- Auto-save to local persistence
- Ability to create and save a valid 4×4 puzzle
- Ability to preview puzzle as player would see it

---

## 8. Preview Mode (Minimal Spec)

**Accessed via "Preview" button** when puzzle is complete.

**Layout:**
- Full-screen view
- 16 tiles in a 4×4 grid, **shuffled randomly** (order different from creation view)
- Tiles look like they will in gameplay (no category grouping visible)
- **No gameplay interaction** in MVP—this is purely visual preview
- **Back** to return and keep editing
- **Publish** to finish

**Purpose:**
- Let creator see puzzle from solver's perspective
- Check that words make sense when randomized
- Verify difficulty feels appropriate

**Future enhancement:**
- Allow creator to play through their own puzzle (with guessing mechanics)

---

## 10. Technical Implementation Notes

### 10.1 Data Model
- Uses existing `Puzzle`, `PuzzleGroup`, `PuzzleWord` models from AGENTS.md
- Puzzle initialized with 4 groups × 4 words (positions 0-3) with empty strings

### 10.2 SwiftUI Structure

**Recommended view hierarchy:**
```
CreationView (main container)
├─ VStack (spacing: 0) [fills available height]
│  ├─ PuzzleTitleField (editable, fixed height with padding)
│  ├─ ScrollView (flexible, takes remaining space)
│  │  └─ VStack (spacing: 12) [naturally sized by children]
│  │     ├─ CategoryRowView (group 0)
│  │     │  ├─ CategoryLabelField (16-18pt font + padding)
│  │     │  └─ HStack (4 word tiles, each 44pt min height)
│  │     ├─ CategoryRowView (group 1)
│  │     ├─ CategoryRowView (group 2)
│  │     └─ CategoryRowView (group 3)
│  └─ BottomActionsView (fixed height, Save/Preview buttons)
```

**Key layout principles:**
- Outer `VStack` uses `.frame(maxHeight: .infinity)` to fill screen
- `ScrollView` is given flexible space via `Spacer()` or flexible frame
- Inner `VStack` inside `ScrollView` naturally sizes based on its children
- No hardcoded total heights—each component defines its own size
- SwiftUI handles all content sizing and scrolling automatically

**Example layout code structure:**

```swift
VStack(spacing: 0) {
    // Fixed-height title
    PuzzleTitleField()
        .padding()
    
    // Flexible scrollable content
    ScrollView {
        VStack(spacing: 12) {  // Natural sizing
            ForEach(puzzle.groups) { group in
                CategoryRowView(group: group)
            }
        }
        .padding(.horizontal)
    }
    
    // Fixed-height actions
    BottomActionsView()
}
.frame(maxHeight: .infinity)
```

### 10.3 State Management
- Single `@StateObject` view model (`PuzzleCreationViewModel`)
- Holds mutable `Puzzle` instance
- Handles save/update via `PuzzleRepository`
- Manages validation state for enabling/disabling Preview button

### 10.4 Focus Management
- Use `@FocusState` for tracking which field is active
- Enum to represent all focusable fields (puzzle title, 4 category names, 16 word fields)

### 10.5 Keyboard Handling
- Rely on SwiftUI's native keyboard avoidance (`.scrollDismissesKeyboard(.interactively)`)
- Active field automatically scrolls into view when focused
- `ScrollView`'s inner `VStack` sizes naturally based on its children—no `.frame(height:)` needed
- SwiftUI's automatic content sizing and keyboard avoidance handles everything
- No `GeometryReader` or custom calculations required

### 10.6 Word Editing & Tile Typography

This MVP uses a consistent, predictable typography system for word tiles that keeps puzzles legible while allowing short phrases:
- Default font size: **14pt**
- Minimum font size: **12pt**
- Tiles support up to **2 lines** of text
- Long single words shrink in place as they approach tile bounds
- Multi-word phrases wrap to a second line (max 2) and then shrink if needed
- Overflow beyond 2 lines is clipped (no ellipsis) to preserve the grid look
- Dynamic Type scaling is **not** used for tiles; typography is fixed for game consistency

**Implementation approach (per tile):**
- Each editable word tile is backed by a SwiftUI `TextField` configured for vertical axis:
  - `TextField("", text: $text, axis: .vertical)`
  - `.lineLimit(2)`
  - `.fixedSize(horizontal: false, vertical: true)`
- The visible `TextField`:
  - Uses `.textFieldStyle(.plain)` and tile chrome (padding, background, rounded corners) so it looks like a static tile
  - Applies `.font(.system(size: fontSize))` where `fontSize` is managed per tile
- A hidden mirror `Text` is used to measure rendered size and keep `fontSize` within bounds:
  - `Text(text)` with the same font and `lineLimit(2)`, wrapped in a `GeometryReader`
  - Size is reported via a `PreferenceKey` (e.g., `TextSizePreferenceKey`)
  - On preference change, the tile recomputes `fontSize` to keep text within the tile’s width/height, clamped to the 12–14pt range
- `fontSize` changes are animated with a light `.easeInOut` to avoid jarring jumps
- The tile view clips its content so any residual overflow is hidden
- Optional: strip explicit newline characters in `onChange(of: text)` to avoid users forcing more than 2 lines

This keeps the creation and preview experiences aligned: creators edit directly in the same tile that will be shown to solvers, and typography behavior is consistent across both.

---

## 11. Success Criteria for MVP

**UX:**
- Tapping any tile immediately allows editing with no mode-switching
- Active field automatically scrolls into view when keyboard appears
- Smooth, natural scrolling to access all categories while editing
- Flow feels fast, direct, and unobstructed
- Comfortable tap targets and readable text throughout

**Technical:**
- Puzzle persists across app restarts (SwiftData)
- Preview mode shows randomized word order
- Previews render correctly in Xcode canvas

**Craft:**
- Interaction feels polished despite simplicity
- Typography and spacing feel confident and intentional
- No awkward scrolling, jumping, or layout shifts

---

## 12. Post-MVP Enhancements (Not Now)

Once this foundation is solid, consider:
- Tap outside focused field to dismiss keyboard
- Duplicate word detection (show subtle warning)
- Swipe category row to delete/reorder
- Drag-and-drop words between categories
- More sophisticated preview with full gameplay
- Transition animations for entering/exiting preview
- Puzzle title suggestions based on category names
- Character count indicators on fields

---

## Summary

This MVP trades elaborate transitions and category-level editing for **directness, clarity, and full spatial context**. By keeping the entire board visible and allowing inline editing, we eliminate mode-switching complexity and make the creation process feel immediate and transparent.

The interaction model is as simple as it gets: **tap what you want to edit, type, done.** This aligns with native iOS conventions, requires minimal custom code, and lets us focus on polish within a constrained scope.

