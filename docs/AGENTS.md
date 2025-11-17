# iykyk – North Star

## 1. Concept

iykyk is a social, user-generated word puzzle game inspired by NYT **Connections**. Players organize a 4×4 grid of 16 words into 4 groups of 4, each group sharing a hidden theme.

The twist: **puzzles are made by people you know**, so themes can be inside jokes, shared memories, niche references, and micro-cultures.

---
## 2. Core Audience

- People who enjoy **Connections-style** pattern recognition and word grouping.
- Friend groups, couples, families, coworkers who share experiences and references.
- Users who want lightweight, playful ways to connect asynchronously (send a puzzle, see how they do).

---
## 3. Core Loop (v1)

1. **Create** – A user creates a 4×4 puzzle:
   - 4 categories (groups) with a title each
   - 4 words per category

2. **Share** – The puzzle is shared with specific people (eventual goal is links / in-app social graph; early versions may be app-only).

3. **Play** – Recipients solve the puzzle using familiar Connections mechanics:
   - Tap 4 words → check if they form a valid group
   - Progress through the grid until all 4 groups are found
   - 3 wrong guesses allowed

4. **React** – Players see their result and can share their results via text message.

For the **current phase**, we are focused almost entirely on the **Create** part of this loop.

---
## 4. Phase Goals & Scope

### 4.1 Phase Goals

- **Primary goal:** Provide a minimal yet robust foundation for experimenting with multiple puzzle-creation UX flows for a fixed 4×4 iykyk puzzle.
- **In scope for this phase:**
  - Local-only data model for a single puzzle (4 groups × 4 words).
  - Local persistence so puzzles survive app restarts.
  - A clear, modular folder structure to host multiple creation UI variants.
  - SwiftUI previews for fast visual iteration.

### 4.2 Scope for Current Phase

#### In Scope

- Building a **minimal iOS SwiftUI app** targeting iOS 26 (latest iOS SDK in Xcode).
- Implementing a **4×4 puzzle data model** (4 groups × 4 words).
- Implementing **local-only persistence** (SwiftData) so puzzles survive restarts.
- Designing the project structure to support **multiple creation UX variants**.
- Prototyping the interaction design of puzzle creation.

#### Out of Scope (for now)

- Social graph, friend system, invites, and discovery.
- Cloud sync / multi-device accounts.
- Game meta systems (streaks, leaderboards, timers).
- Monetization, subscriptions, or IAP.

---
## 5. Design Principles

**Design: fluid, minimal, and tactile**
- Fluid transitions, strong typography, restrained color usage.
- Clear visual hierarchy and spacing; no visual noise.
- Make use of touch gestures.

---
## 6. Technical North Star (v1)

- **Platform:** iOS, phone-first.
- **UI:** SwiftUI app lifecycle.
- **Persistence:** SwiftData for local puzzles.
- **Architecture:**
  - Core models (`Puzzle`, `PuzzleGroup`, `PuzzleWord`) in a `Core` module.
  - Repository pattern (`PuzzleRepository`) with an in-memory implementation for previews and a SwiftData implementation for runtime.
  - Features organized by domain (e.g. `Features/PuzzleCreation`, `Features/PuzzleLibrary`).
  - Creation flow supports multiple **variants** living side-by-side so beta testers can compare different designs.

- **Design System:** Light, but intentional:
  - Shared typography & color tokens.
  - Reusable components (buttons, tiles) that match the visual identity.

- **Tooling & runtime:**
  - Target latest iOS SDK in Xcode (our stand-in for "iOS 26").
  - Language: Swift.
  - UI: SwiftUI app lifecycle.
  - Persistence: SwiftData, with test-friendly abstractions.
  - Concurrency: Structured concurrency (async/await) for future extensibility.

- **Apple frameworks to use or be aware of (current phase):**
  - **SwiftUI** – all UI, navigation, and previews.
  - **SwiftData** – local puzzle persistence.
  - **Foundation** – types like `UUID`, `Date`, etc.

- **Future frameworks to keep in mind (do not implement yet):**
  - **CloudKit / iCloud** – for sync and sharing.
  - **GameKit** – for leaderboards or friend-based gameplay.
  - **AuthenticationServices** – for Sign in with Apple if accounts are added.
  - **UserNotifications** – for notifying players of new puzzles.
  - **StoreKit** – if we add IAP or subscriptions.

---
## 7. Core Domain Model

We model a single iykyk puzzle with a hard 4×4 constraint.

### 7.1 Entities

**Puzzle**
- `id: UUID`
- `title: String` – human-readable name (e.g. "Hood River Trip").
- `hint: String?` – short theme hint.
- `creatorName: String?` – free-text for now.
- `createdAt: Date`
- `groups: [PuzzleGroup]`

**PuzzleGroup**
- `id: UUID`
- `title: String` – category name players are meant to infer.
- `position: Int` – row position (0-3) for stable ordering in creation UI.
- `words: [PuzzleWord]`

**PuzzleWord**
- `id: UUID`
- `text: String`
- `position: Int` – position within group (0-3) for stable ordering.

**WordTile** (UI-only for the player grid during gameplay)
- `id: UUID`
- `text: String`
- `groupID: UUID` – reference back to `PuzzleGroup`.

**Note:** `WordTile` is used exclusively for the play experience where words are shuffled and displayed in random order. The creation UI works directly with `Puzzle` → `PuzzleGroup` → `PuzzleWord` relationships, preserving the group structure and ordering.

### 7.2 Constraints & Validation

- A valid `Puzzle` must contain exactly 4 groups and 16 words.
- This should be enforced through a validation helper (e.g. `PuzzleValidator`) rather than assumptions in every view.

**Example validation responsibilities:**
- Check group count == 4.
- Check each group has exactly 4 words.
- Check group positions are 0-3 (unique and complete).
- Check word positions within each group are 0-3 (unique and complete).
- Check no duplicate word text within a puzzle (optional, but helpful).
- Provide a list of issues to the UI (not just a boolean).

---
## 8. Persistence & Repository Abstractions

### 8.1 SwiftData Usage

- Model `Puzzle`, `PuzzleGroup`, and `PuzzleWord` using SwiftData `@Model` classes.
- Configure a `ModelContainer` at the app entry point (e.g. in `iykykApp`).
- Use `@Query` for simple lists where appropriate.

### 8.2 Repository Protocol

UI code depends on a repository abstraction instead of SwiftData directly:

```swift
protocol PuzzleRepository {
    func allPuzzles() -> [Puzzle]
    func create(_ puzzle: Puzzle)
    func update(_ puzzle: Puzzle)
    func delete(_ puzzle: Puzzle)
}
```

**Implementations:**
- **`InMemoryPuzzleRepository`**
  - Backed by an in-memory store (array/dictionary).
  - Used by SwiftUI previews and unit tests.

- **`SwiftDataPuzzleRepository`**
  - Real implementation using SwiftData context.
  - Used by the live app.

Goal: We should be able to swap repositories easily in previews via dependency injection.

### 8.3 Fixtures & Sample Data

Create simple fixtures to bootstrap previews and manual testing:
- `sampleEmptyPuzzle()` – A new puzzle ready for creation. Contains 4 `PuzzleGroup` instances (positions 0-3, empty titles) each with 4 `PuzzleWord` instances (positions 0-3, empty text). This structure allows the creation UI to render a 4×4 grid immediately while still being functionally "blank."
- `samplePartialPuzzle()` – Some groups/words have content filled in, others remain empty.
- `sampleCompletedPuzzle()` – Fully valid 4×4 puzzle with all groups and words populated.

**Note on initialization:** When creating a new puzzle for the creation UI, always initialize with the full 4×4 structure (4 groups × 4 words) rather than starting with zero groups. This matches the UX expectation that users see a complete board from the start.

---
## 9. Project & Folder Structure

Design the project so multiple creation UIs can coexist and be compared.

### 9.1 Proposed Top-Level Layout

```text
iykyk/
  iykykApp.swift
  Resources/
    Assets.xcassets
    PreviewAssets/
  Core/
    Models/
      Puzzle.swift
      PuzzleGroup.swift
      PuzzleWord.swift
    Persistence/
      SwiftDataModelContainer.swift
      PuzzleRepository.swift
      InMemoryPuzzleRepository.swift
      SwiftDataPuzzleRepository.swift
    Services/
      PuzzleValidator.swift
      PuzzleFixtures.swift
  Features/
    PuzzleCreation/
      Shared/
        ViewModels/
          PuzzleCreationViewModel.swift
        Views/
          Common/
            CategoryEditorView.swift
            WordListEditorView.swift
            PuzzleSummaryView.swift
      Variants/
        LinearForm/
          LinearCreationView.swift
          LinearCreationView_Previews.swift
        GridFirst/
          GridCreationView.swift
          GridCreationView_Previews.swift
        CardStack/
          CardStackCreationView.swift
          CardStackCreationView_Previews.swift
    PuzzlePlay/
      (Stub or minimal implementation)
    PuzzleLibrary/
      PuzzleLibraryView.swift
  DesignSystem/
    Typography.swift
    Colors.swift
    Components/
      PrimaryButton.swift
      TileView.swift
  PreviewSupport/
    PreviewPuzzleProvider.swift
    PreviewRepositories.swift
```

Notes for agents:
- **Do not** over-abstract early. It’s OK if this evolves.
- Prioritize clarity and isolation of each creation variant under `Variants/`.
- Shared subviews and view models go under `Shared/`.

---
## 10. SwiftUI Preview Strategy

Previews are central to this phase.

1. Every major creation view (e.g. `LinearCreationView`, `GridCreationView`, `CardStackCreationView`) must have a `PreviewProvider`.
2. Previews must:
   - Use `InMemoryPuzzleRepository` or fixture instances.
   - Simulate at least three states where applicable:
     - **Empty** – new puzzle, no categories/words yet.
     - **Partial** – some categories/words filled in.
     - **Completed** – 4×4 valid puzzle.
3. Consider using preview helpers in `PreviewSupport` to keep preview code DRY.

Goal: We should be able to open Xcode’s preview canvas and visually compare different creation flows without running the full app.

---
## 11. Minimal App Shell

Even though previews are primary, we still need a thin shell for running on device.

**App entry flow suggestions:**
- Simple root view with:
  - A button to open **Puzzle Library** (list of saved puzzles).
  - A button to create a new puzzle using a **default creation variant**.

**`PuzzleLibraryView` responsibilities:**
- Display all puzzles from `PuzzleRepository`.
- Tap to edit an existing puzzle via the default creation variant.
- Optionally, allow deletion for cleanup.

Keep navigation minimal and avoid over-engineering router patterns at this stage.

---
## 12. Gameplay Rules

This section defines the minimal gameplay contract required for building consistent previews and interactions across all creation UX variants.

### 12.1 Puzzle Structure

- A puzzle always contains 4 groups.
- Each group contains exactly 4 words.
- A puzzle is considered complete when all 4 groups have been correctly identified.

### 12.2 Player Interactions

- Words are displayed in a 4×4 grid in randomized order.
- Players tap to select or deselect words.
- The system allows selecting up to 4 words at any time.

### 12.3 Guessing & Validation

- A guess is submitted when the player has exactly 4 words selected.
- A guess is correct when all 4 selected words belong to the same `PuzzleGroup`.
- A guess is incorrect when the 4 selected words do not all belong to the same group.
- 3 incorrect guesses are allowed before game over.

### 12.4 Feedback Model

**Correct guess**
- The group is “solved.”
- Those 4 tiles are visually marked and removed or locked from future interaction.

**Incorrect guess**
- The tiles shake after a slight delay.
- The selected words are deselected automatically.
- The number of guesses left decrements by 1.

### 12.5 Win Condition

The puzzle is solved when all 4 groups have been correctly identified.
