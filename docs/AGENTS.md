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
   - 4 groups with a title each
   - 4 words per group

2. **Style** - User previews how the puzzle will appear to the player and can select from different design templates and customize the individual styles:
   - Wallpaper (image, emoji wallpaper, color, gradient)
   - WordTile (glass, retro 3D, classic, etc)
   - WordTile text (font family and color)

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

- **Primary goal:** Provide a minimal yet robust foundation for building the puzzle creation UX for a fixed 4×4 iykyk puzzle.
- **In scope for this phase:**
  - Local-only data model for a single puzzle (4 groups × 4 words).
  - Local persistence so puzzles survive app restarts.
  - SwiftUI previews for fast visual iteration.

### 4.2 Scope for Current Phase

#### In Scope

- Building a **minimal iOS SwiftUI app** targeting iOS 26 (latest iOS SDK in Xcode).
- Implementing a **4×4 puzzle data model** (4 groups × 4 words).
- Implementing **local-only persistence** (SwiftData) so puzzles survive restarts.
- Implementing the **puzzle creationg flow** (see /docs/CREATE.md).

#### Out of Scope (for now)

- Customizing the puzzle styles
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
- `creatorName: String?` – automatically populated from the logged-in user’s display name.
- `createdAt: Date`
- `groups: [PuzzleGroup]`

**PuzzleGroup**
- `id: UUID`
- `title: String` – group name players are meant to infer.
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

Design the project with a **single primary creation UI** to keep scope tight and complexity low, while leaving room to evolve in future iterations if needed.

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
      ViewModels/
        PuzzleCreationViewModel.swift
      Views/
        CreationView.swift
        CreationView_Previews.swift
        GroupEditorView.swift
        WordListEditorView.swift
        PuzzleSummaryView.swift
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

---
## 10. SwiftUI Preview Strategy

Previews are a lightweight way to **visually iterate on a screen as if it were running in the simulator**, without modeling lots of different states.

**Preview rules:**

1. **One preview per view**
   - Each SwiftUI view should have **a single preview block** (either a `#Preview` or a `PreviewProvider`).
   - Avoid multiple preview variants, `Group` wrappers, or separate preview types for different scenarios.

2. **Single, minimal configuration**
   - The preview should show **one realistic configuration** of the view that you can scroll, tap, and type into.
   - Do not model “empty / partial / complete” or other multi-state permutations in separate previews.
   - For navigation-based screens, it is fine to wrap the view in a simple `NavigationStack` so it behaves like it does in the app.

3. **Simple data and dependencies**
   - Use the **simplest possible data setup** that makes the view usable:
     - For SwiftData-backed views, use an in-memory container (for example, `.modelContainer(for: Puzzle.self, inMemory: true)`).
     - For other dependencies, prefer a single fixture instance or an in-memory repository with a minimal sample puzzle.
   - Keep any setup inline in the preview body or in a small local wrapper view; avoid complex preview-only infrastructure.

4. **Purpose**
   - The goal of a preview is to **quickly see and interact with the view**, not to exhaustively test all of its states.
   - If you find yourself adding multiple scenarios or complex wiring, prefer to test those flows in the simulator instead.

---
## 11. Minimal App Shell

Even though previews are primary, we still need a thin shell for running on device.

**App entry flow:**
- Root view displays **Puzzle Library** as the home screen.
- Floating action button at bottom-right to create new puzzle.

**`PuzzleLibraryView` responsibilities:**
- Display all puzzles from SwiftData using `@Query`, sorted by creation date (most recent first).
- Each puzzle row shows title (or "Untitled Puzzle"), word count progress, and creation date.
- Tap to edit an existing puzzle via the creation flow.
- Swipe to delete puzzles.
- Floating action button opens creation flow for new puzzle.

**Autosave behavior:**
- Puzzles are automatically inserted into SwiftData when creation begins.
- Changes are saved automatically as the user edits.
- Back navigation triggers a final save before dismissing.
- No explicit "Save" button needed—changes persist immediately.

Keep navigation minimal and avoid over-engineering router patterns at this stage.

---
## 12. Gameplay Rules

This section defines the minimal gameplay contract required for building consistent previews and interactions across the creation UX.

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
- The tiles have some fun animation.
- Those 4 tiles are visually marked and removed or locked from future interaction.

**Incorrect guess**
- The tiles shake after a slight delay.
- The selected words are deselected automatically.
- The number of guesses left decrements by 1.

### 12.5 Win Condition

The puzzle is solved when all 4 groups have been correctly identified.

---
## 13. Inject Hot Reloading for SwiftUI Views

We use [Inject](https://github.com/krzysztofzablocki/Inject) for hot reloading during development (see also the reference example commit: [InjectSwiftUIExample](https://github.com/MarcoEidinger/InjectSwiftUIExample/commit/35716d596028439732cdf190c7acb6686221fdd2)).

### 13.1 Project setup (one-time)

- The `Inject` Swift package is already added to the app target.
- `OTHER_LDFLAGS` for the Debug configuration includes `-Xlinker -interposable` so injection can swizzle symbols at runtime.
- To use injection while running the app:
  - Launch the InjectionIII app and point it at this project.
  - Run the app in Debug from Xcode.

You usually don’t have to touch this project-level setup unless Xcode/project settings change.

### 13.2 How to wire a new SwiftUI view for injection

For any SwiftUI `View` where you want hot reloading:

1. **Import Inject** at the top of the file:

   ```swift
   import Inject
   ```

2. **Add the injection observer** inside the view:

   ```swift
   struct MyView: View {
       @ObserveInjection private var inject
       // other properties...
   }
   ```

3. **Enable injection on the outermost view in `body`**:

   ```swift
   var body: some View {
       SomeContainerView {
           // your content
       }
       .enableInjection()
   }
   ```

Guidelines:
- Put `.enableInjection()` as far out as possible in the view hierarchy (usually on the root container, like a `NavigationStack`, `VStack`, or `ZStack`).
- Child views nested under an instrumented parent will still participate in injection when you edit them, but for frequently edited leaf views it can be useful to wire them up directly as well.
- Keep this strictly as a **development tool**; do not rely on Inject for any production behavior.
