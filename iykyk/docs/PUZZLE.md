## iykyk – Puzzle Model, Creation, and Play

This doc summarizes how **puzzles are modeled, created, validated, and played** in the current app so agents can quickly build puzzle-related features.

---

## 1. Puzzle Model (4×4)

- **Puzzle**
  - `@Model final class Puzzle`
  - Key fields: `id`, `sequenceNumber?`, `title`, `creatorName?`, `createdAt`, `publishedAt?`
  - Relationships & status:
    - `groups: [PuzzleGroup]` (SwiftData `@Relationship`, cascade delete)
    - `playStatus: PuzzlePlayStatus` via stored `playStatusRaw` (`notStarted`, `inProgress`, `won`, `lost`)
    - Convenience: `isPublished`, `publishStatusText`, `isPlayable`

- **PuzzleGroup**
  - `@Model final class PuzzleGroup`
  - Fields: `id`, `title`, `position`, `words: [PuzzleWord]`, `puzzle: Puzzle?`
  - `position` is **0–3**, used to keep rows ordered in creation and play UIs.

- **PuzzleWord**
  - `@Model final class PuzzleWord`
  - Fields: `id`, `text`, `position`, `group: PuzzleGroup?`
  - `position` is **0–3**, used to keep words ordered within a row.

- **WordTile**
  - `struct WordTile: Identifiable, Equatable`
  - UI-only, derived from a `Puzzle`:
    - `id` (mirrors `PuzzleWord.id`)
    - `text`
    - `groupID` (`PuzzleGroup.id`)
  - Used to drive shuffling, selection, and animations in preview and play views.

- **Fixed 4×4 constraint**
  - Exactly **4 groups** and **4 words per group**.
  - All logic assumes a 4×4 structure; use fixtures/validator to maintain this invariant.

---

## 2. Fixtures, Validation, and Repositories

- **Fixtures – `PuzzleFixtures`**
  - `sampleEmptyPuzzle()`: 4 groups × 4 words, all empty, ready for creation UI.
  - `samplePartialPuzzle()`: mixed-filled example.
  - `sampleCompletedPuzzle()`: fully valid example used in previews/tests.
  - Uses `PuzzleNumberingService` to assign `sequenceNumber`.

- **Validation – `PuzzleValidator`**
  - `validate(_:) -> [ValidationIssue]` (each issue has `message`).
  - Checks:
    - 4 groups, positions exactly `{0,1,2,3}`.
    - Each group has 4 words, positions `{0,1,2,3}`.
    - No empty group titles or empty word text.
    - No duplicate non-empty words (case-insensitive, trimmed).
  - `isValid(_:)` convenience wrapper.
  - **Usage:** `PuzzlePreviewView` runs validation before allowing preview/play.

- **Repositories**
  - `protocol PuzzleRepository { allPuzzles(), create(_), update(_), delete(_)}`
  - `InMemoryPuzzleRepository`:
    - Simple `@Observable` in-memory array, used for previews/tests.
  - `SwiftDataPuzzleRepository`:
    - Backed by `ModelContext`; sorts by `createdAt` (descending).
    - Inserts, saves, deletes `Puzzle` models.
  - Most runtime UI currently uses **SwiftData directly** via `@Query` + `ModelContext`, but the protocol is available for future abstraction or testing.

---

## 3. App Shell and Navigation

- **Root structure – `RootView`**
  - `TabView` with two tabs:
    - **Create** (`scribble.variable`):
      - `NavigationStack` → `PuzzleLibraryView(mode: .create)`
      - Destinations:
        - `Puzzle`: if `puzzle.isPublished` → `PuzzlePreviewView(puzzle:)`
        - `Puzzle`: else → `PuzzleCreationView(puzzle:)`
        - `"create"` (String): → `PuzzleCreationView()` (new puzzle)
    - **Play** (`xmark.triangle.circle.square`):
      - `NavigationStack` → `PuzzleLibraryView(mode: .play)`
      - Destination for `Puzzle`: `PuzzlePlayView(puzzle:)`

- **SwiftData setup – `iykykApp`**
  - `ModelContainer` configured for `Puzzle`, `PuzzleGroup`, `PuzzleWord`.
  - Handles schema errors by resetting the store in debug builds.
  - Backfills or assigns `sequenceNumber` for existing puzzles, then updates `PuzzleNumberingService`.

---

## 4. Puzzle Library (Create vs Play)

- **`PuzzleLibraryView`**
  - `mode: LibraryMode = .create | .play`
  - `@Query(sort: \Puzzle.createdAt, order: .reverse)` to load all puzzles.

- **Create mode (`.create`)**
  - Shows all puzzles (draft + published) in a `List`.
  - Rows: `PuzzleRowView(puzzle:, showPlayStatus: false)`
    - Displays `#sequenceNumber` (or `#?`), publish status capsule, `wordCount/16`, and created date.
  - Toolbar: `+` button (NavigationLink value `"create"`) to start a new puzzle.
  - Swipe-to-delete deletes `Puzzle` from `ModelContext` and saves.

- **Play mode (`.play`)**
  - Filters to `publishedPuzzles` (`puzzle.isPublished`).
  - Rows: `PuzzleRowView(puzzle:, showPlayStatus: true)`
    - Status capsule shows `puzzle.playStatus.displayText` (`Not started`, `In progress`, `Won`, `Lost`) with color.
  - Selecting a row navigates to `PuzzlePlayView(puzzle:)`.

- **Empty states**
  - `EmptyStateView(mode:)`:
    - `.create`: "No Puzzles Yet" with hint to tap `+`.
    - `.play`: "No Published Puzzles" with hint to publish from Create mode.

---

## 5. Creation Flow – `PuzzleCreationView`

- **Entry**
  - New puzzle: `PuzzleCreationView()` constructs `PuzzleFixtures.sampleEmptyPuzzle()` and marks it as `isNewPuzzle`.
  - Existing puzzle: `PuzzleCreationView(puzzle:)` edits an already-inserted `Puzzle`.

- **Persistence**
  - On first `onAppear` for a new puzzle: inserts into `modelContext` once, tracked by `hasBeenInserted`.
  - Autosaves on changes to `puzzle.groups` (via `onChange`) and on `onDisappear`.

- **Layout and editing**
  - `ScrollView` → `VStack` of `GroupRowView` for each `PuzzleGroup` sorted by `position`.
  - Tapping anywhere outside fields clears focus.
  - Navigation bar:
    - Title: `"New Puzzle"` or `"Edit Puzzle"`.
    - `Next` button:
      - Enabled if **any word** has non-empty, non-whitespace text.
      - Pushes `PuzzlePreviewView(puzzle:)`.
  - Published puzzles:
    - Editing is disabled (`ScrollView.disabled(puzzle.isPublished)`), but view is still readable.

- **Focus and keyboard**
  - Uses `@FocusState` with `PuzzleCreationFocusField`:
    - `.groupName(groupIndex:)`
    - `.word(groupIndex:, wordIndex:)`
  - Keyboard toolbar:
    - Up/down chevrons move through word fields in row-major order (0,0) → (3,3).
    - Group name fields are *not* part of the keyboard navigation chain (edited via tap/focus only).
  - `ScrollView` uses `.scrollDismissesKeyboard(.interactively)` for natural keyboard avoidance.

- **Group rows – `GroupRowView`**
  - `@Bindable var group: PuzzleGroup`
  - Group name:
    - `TextField("Group name", text: $group.title)` styled as a row title.
    - Focused when corresponding `.groupName(group.position)` is active.
    - Difficulty label: `GroupDifficulty.label(for: group.position)` + color.
  - Words:
    - `HStack` of 4 `EditableWordTile` views for `group.words.sorted(by: position)`.
    - Each tile is bound into the underlying `PuzzleWord.text`.

- **Word tiles – `EditableWordTile`**
  - Inline `TextField("WORD", text: $text, axis: .vertical)` styled as a square tile.
  - Behavior:
    - Tapping anywhere in the tile sets `focusedField = fieldID`.
    - Autocorrection disabled; text auto-capitalized as characters (good for short words/phrases).
    - Strips newline characters; entering return dismisses focus instead of creating multi-line manual breaks.
  - Typography:
    - Maintains legible text in a square tile by dynamically choosing a font size between ~10–14pt.
    - Special-case emoji: enlarged font size.
    - Uses simple geometry-based sizing (no external layout measurement types).

---

## 6. Preview Flow – `PuzzlePreviewView`

- **Purpose**
  - Let the **creator** see and play their puzzle as a solver would.
  - Gate publishing behind basic structural validation.

- **Validation gate**
  - On `onAppear`, runs `PuzzleValidator.validate(puzzle)`.
  - If any issues exist:
    - `playSession` is `nil`.
    - Shows a "Puzzle Needs Fixes" view with a bullet list of issues and hint to return to editing.

- **Play session in preview**
  - If validation passes:
    - Initializes `PuzzlePlaySession(puzzle:)`.
    - Shows:
      - Solved groups area (cards per solved group, using `GroupColors` and `group.title` + words).
      - 4×4 grid of active tiles (`session.activeTiles`) as tappable buttons with `AutoSizingTileText`.
      - Controls: `Shuffle`, `Deselect All`, `Submit`.
      - "Mistakes Remaining" row of 4 dots (`guessesRemaining` starts at 4, one removed per incorrect guess).
  - `Submit` is enabled when exactly 4 tiles are selected and session is in progress.
  - Guess handling:
    - **Correct**: moves that group into `solvedGroupIDs`, animates tiles into the solved section; if 4 groups solved, state becomes `.won`.
    - **Incorrect**: selected tiles shake, then `applyIncorrectGuessPenalty()` runs:
      - `guessesRemaining -= 1`, selection cleared.
      - When `guessesRemaining == 0`, state becomes `.lost`.

- **Publishing**
  - Top-right `Publish` / `Published` button:
    - Available only when:
      - Puzzle is not yet published, and
      - `playSession` exists (i.e., puzzle is structurally valid).
    - On publish:
      - Sets `puzzle.publishedAt = Date()` and `puzzle.playStatus = .notStarted`.
      - Saves via `modelContext`.
      - Briefly shows a "✓ Puzzle Published" banner.

---

## 7. Player Play Flow – `PuzzlePlayView`

- **Entry**
  - From **Play** tab → `PuzzleLibraryView(mode: .play)` → select a published puzzle.
  - `PuzzlePlayView(puzzle:)` is used directly; it reads and persists `puzzle.playStatus`.

- **State handling**
  - If `puzzle.playStatus` is `.won` or `.lost`:
    - Does **not** create a new session.
    - Shows an end-state view with:
      - A result banner ("You solved it!" or "Better luck next time!").
      - All 4 groups rendered as colored rows (title + words).
  - If `playStatus` is `.notStarted`:
    - Sets `playStatus = .inProgress` and saves.
    - Creates a new `PuzzlePlaySession(puzzle:)`.
  - If `playStatus` is `.inProgress`:
    - Creates a new `PuzzlePlaySession(puzzle:)` for the current run (session state itself is not persisted; only `playStatus` is).

- **Gameplay UI**
  - Very similar to `PuzzlePreviewView` but driven by the live `puzzle.playStatus`:
    - Solved groups section using `session.solvedTiles` and `session.solvedGroupIDs`.
    - 4×4 grid of active tiles using `WordTile` + `AutoSizingTileText`.
    - Controls: `Shuffle`, `Deselect All`, `Submit`.
    - "Mistakes Remaining" indicator based on `guessesRemaining` (starts at 4).
  - Guess logic:
    - Delegates to `PuzzlePlaySession` (`toggleSelection`, `submitGuess`, `applyIncorrectGuessPenalty`).
    - On **win**: sets `puzzle.playStatus = .won` and saves.
    - On **lose**: after penalties exhaust remaining guesses, sets `puzzle.playStatus = .lost` and saves.

---

## 8. PuzzlePlaySession Logic (Shared by Preview and Play)

- **Core**
  - `@Observable class PuzzlePlaySession`
  - Derived from a `Puzzle`:
    - Builds `tiles: [WordTile]` by flattening groups/words, then shuffles.
    - Builds `groupsByID` to look up group titles by `groupID`.
  - Mutable state:
    - `selectedTileIDs: Set<UUID>`
    - `solvedGroupIDs: [UUID]` (in solve order)
    - `guessesRemaining: Int = 4`
    - `state: PuzzlePlayState = .inProgress`
    - `lastGuessResult: GuessResult?`

- **Helpers**
  - `activeTiles`: `tiles` filtered to those not in solved groups.
  - `solvedTiles`: tiles in solved groups, sorted by `solvedGroupIDs` order.
  - `canSubmitGuess`: exactly 4 tiles selected and state is `.inProgress`.

- **Interactions**
  - `toggleSelection(for:)`:
    - No-op if game not in progress or tile already solved.
    - Selects/deselects up to 4 tiles.
  - `submitGuess()`:
    - If 4 selected tiles all share the same `groupID` and that group not already solved:
      - Marks group as solved and clears selection.
      - If 4 groups solved, sets `state = .won`.
      - Returns `.correct(groupID:, groupTitle:)`.
    - Otherwise:
      - Leaves selection as-is (caller typically triggers animations first).
      - Returns `.incorrect`.
  - `applyIncorrectGuessPenalty()`:
    - Clears selection.
    - Decrements `guessesRemaining`; on zero, sets `state = .lost`.
  - `clearSelection()` and `shuffle()` for supporting controls.

---

## 9. Inject / Previews

- Most puzzle-related views (`RootView`, `PuzzleLibraryView`, `PuzzleCreationView`, `GroupRowView`, `EditableWordTile`, `PuzzlePreviewView`, `PuzzlePlayView`) are wired with **Inject**:
  - `import Inject`
  - `@ObserveInjection private var inject`
  - `.enableInjection()` on an outer container.
- Previews:
  - Use in-memory SwiftData containers: `.modelContainer(for: Puzzle.self, inMemory: true)`.
  - Prefer a **single preview per view** with realistic data (fixtures) and minimal wiring.

This doc should be the **single source of truth** for puzzle-related flows; see `AGENTS.md` for broader product and architectural context.



