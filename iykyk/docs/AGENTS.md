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

2. **Style** – (future) User customizes the visual style of the puzzle (wallpaper, tile style, typography).

3. **Share** – The puzzle is shared with specific people (eventual goal is links / in-app social graph; early versions may be app-only).

4. **Play** – Recipients solve the puzzle using familiar Connections mechanics:
   - Tap 4 words → check if they form a valid group
   - Progress through the grid until all 4 groups are found
   - A limited number of wrong guesses allowed (currently 4)

5. **React** – Players see their result and can share their results via text message.

For the **current phase**, we are focused primarily on the **Create** part of this loop, with a minimal but functional play experience.

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

- Building a **minimal iOS SwiftUI app** targeting the latest iOS SDK.
- Implementing a **4×4 puzzle data model** (4 groups × 4 words).
- Implementing **local-only persistence** (SwiftData) so puzzles survive restarts.
- Implementing the **puzzle creation and play flows** (see `PUZZLE.md`).

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
  - Core models (`Puzzle`, `PuzzleGroup`, `PuzzleWord`, `PuzzlePlaySession`, `WordTile`) in a `Core` module.
  - Repository pattern (`PuzzleRepository`) with an in-memory implementation for previews and a SwiftData implementation for runtime.
  - Features organized by domain (e.g. `Features/PuzzleCreation`, `Features/PuzzleLibrary`, `Features/PuzzlePlay`).

- **Tooling & runtime:**
  - Target latest iOS SDK in Xcode.
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
## 7. Domain Model Overview

We model a single iykyk puzzle with a hard 4×4 constraint:

- **Puzzle** – The top-level entity containing metadata, 4 groups, and persisted game progress (solved groups, guesses remaining).
- **PuzzleGroup** – A group with a title and 4 words; position determines difficulty row (0-3).
- **PuzzleWord** – A single word within a group.
- **WordTile** – UI-only struct for gameplay (shuffled grid, selection state).
- **PuzzlePlaySession** – In-memory model managing active game run; restores state from Puzzle on init and syncs progress back.

**See `PUZZLE.md` for complete field definitions, validation rules, and implementation details.**

---
## 8. Persistence Strategy

- **SwiftData** is used for persisting `Puzzle`, `PuzzleGroup`, and `PuzzleWord`.
- **Game progress** is persisted on `Puzzle`: `solvedGroupPositions`, `guessesRemaining`, and `playStatus` are saved after each guess, allowing players to resume in-progress games.
- A **repository protocol** (`PuzzleRepository`) abstracts data access:
  - `InMemoryPuzzleRepository` for previews and tests.
  - `SwiftDataPuzzleRepository` for the live app.
- **Fixtures** (`PuzzleFixtures`) provide sample puzzles for previews and testing.

**See `PUZZLE.md` for repository protocol details and fixture descriptions.**

---
## 9. SwiftUI Preview Strategy

Previews are a lightweight way to **visually iterate on a screen as if it were running in the simulator**, without modeling lots of different states.

**Preview rules:**

1. **One preview per view**
   - Each SwiftUI view should have **a single preview block** (either a `#Preview` or a `PreviewProvider`).
   - Avoid multiple preview variants, `Group` wrappers, or separate preview types for different scenarios.

2. **Single, minimal configuration**
   - The preview should show **one realistic configuration** of the view that you can scroll, tap, and type into.
   - Do not model "empty / partial / complete" or other multi-state permutations in separate previews.
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
## 10. Inject Hot Reloading for SwiftUI Views

We use [Inject](https://github.com/krzysztofzablocki/Inject) for hot reloading during development.

### 10.1 Project setup (one-time)

- The `Inject` Swift package is already added to the app target.
- `OTHER_LDFLAGS` for the Debug configuration includes `-Xlinker -interposable` so injection can swizzle symbols at runtime.
- To use injection while running the app:
  - Launch the InjectionIII app and point it at this project.
  - Run the app in Debug from Xcode.

### 10.2 How to wire a new SwiftUI view for injection

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

---
## 11. Project Structure

```
iykyk/
├── Core/
│   ├── DesignSystem/
│   │   ├── Components/   # Shared UI components (AutoSizingTileText, SolvedGroupRow, etc.)
│   │   ├── Effects/      # Animation effects (ShakeEffect)
│   │   ├── Styles/       # Button styles (CapsuleButtonStyle)
│   │   ├── GroupColors.swift
│   │   └── GroupDifficulty.swift
│   ├── Extensions/       # Swift type extensions (e.g., String+Extensions)
│   ├── Models/           # Domain models (Puzzle, PuzzleGroup, PuzzleWord, etc.)
│   ├── Persistence/      # Repository protocol + implementations
│   └── Services/         # Validation, fixtures, numbering, utilities
│
├── Features/
│   ├── PuzzleCreation/
│   │   ├── Views/        # PuzzleCreationView, PuzzlePreviewView
│   │   ├── Components/   # EditableWordTile, GroupRowView
│   │   └── Models/       # PuzzleCreationFocusField
│   ├── PuzzleLibrary/
│   │   ├── Views/        # PuzzleLibraryView
│   │   ├── Components/   # PuzzleCard, EmptyStateView
│   │   └── Models/       # LibraryMode
│   └── PuzzlePlay/
│       └── Views/        # PuzzlePlayView
│
├── docs/
│   ├── AGENTS.md         # This file (high-level context)
│   └── PUZZLE.md         # Detailed puzzle implementation reference
│
├── Resources/            # Asset catalogs, etc.
├── iykykApp.swift        # App entry point, ModelContainer setup
└── RootView.swift        # Root TabView navigation
```

### 11.1 Where to Put New Code

| Type | Location | Example |
|------|----------|---------|
| Domain model | `Core/Models/` | `Puzzle.swift` |
| SwiftData repository | `Core/Persistence/` | `SwiftDataPuzzleRepository.swift` |
| Validation / business logic | `Core/Services/` | `PuzzleValidator.swift` |
| Shared UI component | `Core/DesignSystem/Components/` | `AutoSizingTileText.swift` |
| Shared button style | `Core/DesignSystem/Styles/` | `CapsuleButtonStyle.swift` |
| Shared animation effect | `Core/DesignSystem/Effects/` | `ShakeEffect.swift` |
| UI constants (colors, fonts) | `Core/DesignSystem/` | `GroupColors.swift` |
| Feature screen | `Features/{FeatureName}/Views/` | `PuzzleCreationView.swift` |
| Feature-specific component | `Features/{FeatureName}/Components/` | `EditableWordTile.swift` |
| Feature-specific model/enum | `Features/{FeatureName}/Models/` | `PuzzleCreationFocusField.swift` |
| Shared Swift extensions | `Core/Extensions/` | `String+Extensions.swift` |

### 11.2 Naming Conventions

- **Files** match the primary type they contain: `PuzzleValidator.swift` → `struct PuzzleValidator`
- **Views** end with `View`: `PuzzleCreationView`, `GroupRowView`
- **Repositories** end with `Repository`: `InMemoryPuzzleRepository`
- **Extensions** use `TypeName+Extensions.swift` format
- **Test files** use `TypeNameTests.swift` format

### 11.3 Adding a New Feature

1. Create a folder under `Features/{FeatureName}/`
2. Add a `Views/` subfolder for main screens
3. Add a `Components/` subfolder for feature-specific reusable components
4. Add a `Models/` subfolder for feature-specific enums or models (if needed)
5. If the feature needs shared domain models, add them to `Core/Models/`
6. If the feature needs shared UI components, add them to `Core/DesignSystem/Components/`
7. Wire navigation in `RootView.swift` or the appropriate parent view
8. Add Inject support to new views for hot reloading (see Section 10.2)

### 11.4 Shared DesignSystem Components

The following shared components are available in `Core/DesignSystem/`:

**Components:**
- `AutoSizingTileText` – Text that auto-sizes to fit within a container
- `SolvedGroupRow` – Displays a solved group with title and words
- `GameTileButton` – Interactive tile button for gameplay
- `MistakesRemainingView` – Shows remaining incorrect guesses
- `GameControlsView` – Shuffle/Deselect All/Submit button row
- `ProgressRing` – Circular progress indicator
- `PuzzleThumbnail` – 1×4 mini-grid showing group completion/solve status

**Styles:**
- `CapsuleButtonStyle` – Capsule-shaped button style for game controls

**Effects:**
- `ShakeEffect` – Horizontal shake animation for incorrect guesses
