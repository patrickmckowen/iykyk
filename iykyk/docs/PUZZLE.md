# iykyk – Puzzle Model, Creation, and Play

This doc covers **how puzzles are modeled, created, validated, and played** in detail. For high-level product context and architectural strategy, see `AGENTS.md`.

---

## 1. Puzzle Model (4×4)

### 1.1 Puzzle

`@Model final class Puzzle`

| Field | Type | Description |
|-------|------|-------------|
| `id` | `UUID` | Unique identifier |
| `sequenceNumber` | `Int?` | Auto-assigned puzzle number for display |
| `title` | `String` | Human-readable name (e.g. "Hood River Trip") |
| `creatorName` | `String?` | Optional creator attribution |
| `createdAt` | `Date` | Creation timestamp |
| `publishedAt` | `Date?` | When published (nil = draft) |
| `groups` | `[PuzzleGroup]` | SwiftData `@Relationship`, cascade delete |
| `playStatusRaw` | `String` | Backing store for `playStatus` enum |

**Computed properties:**
- `playStatus: PuzzlePlayStatus` – `.notStarted`, `.inProgress`, `.won`, `.lost`
- `isPublished: Bool` – `publishedAt != nil`
- `publishStatusText: String` – Display string for publish state
- `isPlayable: Bool` – Whether puzzle can be played

### 1.2 PuzzleGroup

`@Model final class PuzzleGroup`

| Field | Type | Description |
|-------|------|-------------|
| `id` | `UUID` | Unique identifier |
| `title` | `String` | Group name players must infer |
| `position` | `Int` | Row position (0–3), determines difficulty color |
| `words` | `[PuzzleWord]` | SwiftData relationship |
| `puzzle` | `Puzzle?` | Back-reference to parent |

### 1.3 PuzzleWord

`@Model final class PuzzleWord`

| Field | Type | Description |
|-------|------|-------------|
| `id` | `UUID` | Unique identifier |
| `text` | `String` | The word/phrase content |
| `position` | `Int` | Position within group (0–3) |
| `group` | `PuzzleGroup?` | Back-reference to parent |

### 1.4 WordTile (UI-only)

`struct WordTile: Identifiable, Equatable`

Used exclusively for the play experience where words are shuffled:

| Field | Type | Description |
|-------|------|-------------|
| `id` | `UUID` | Mirrors `PuzzleWord.id` |
| `text` | `String` | Word content |
| `groupID` | `UUID` | Reference to `PuzzleGroup.id` |

**Note:** The creation UI works directly with `Puzzle` → `PuzzleGroup` → `PuzzleWord` relationships, preserving group structure and ordering. `WordTile` is only used for gameplay.

### 1.5 Fixed 4×4 Constraint

- Exactly **4 groups** and **4 words per group** (16 words total).
- All logic assumes this structure; enforced via `PuzzleValidator`.

---

## 2. Validation

### 2.1 PuzzleValidator

`PuzzleValidator.validate(_:) -> [ValidationIssue]`

Each `ValidationIssue` has a `message: String` describing the problem.

**Checks performed:**
- Group count == 4
- Group positions are exactly `{0, 1, 2, 3}` (unique and complete)
- Each group has exactly 4 words
- Word positions within each group are `{0, 1, 2, 3}`
- No empty group titles (after trimming whitespace)
- No empty word text (after trimming whitespace)
- No duplicate words within a puzzle (case-insensitive, trimmed)

**Convenience:**
- `PuzzleValidator.isValid(_:) -> Bool` – Returns `true` if no issues.

**Usage:** `PuzzlePreviewView` runs validation before allowing preview/play or publishing.

---

## 3. Fixtures & Sample Data

`PuzzleFixtures` provides sample puzzles for previews and testing:

| Method | Description |
|--------|-------------|
| `sampleEmptyPuzzle()` | 4 groups × 4 words, all empty. Ready for creation UI. |
| `samplePartialPuzzle()` | Mixed-filled example for testing partial states. |
| `sampleCompletedPuzzle()` | Fully valid 4×4 puzzle for previews/tests. |

**Initialization note:** When creating a new puzzle for the creation UI, always initialize with the full 4×4 structure (4 groups × 4 words with empty content) rather than zero groups. This matches the UX expectation that users see a complete board from the start.

Uses `PuzzleNumberingService` to assign `sequenceNumber`.

---

## 4. Repositories

### 4.1 Protocol

```swift
protocol PuzzleRepository {
    func allPuzzles() -> [Puzzle]
    func create(_ puzzle: Puzzle)
    func update(_ puzzle: Puzzle)
    func delete(_ puzzle: Puzzle)
}
```

### 4.2 Implementations

**InMemoryPuzzleRepository**
- Simple `@Observable` in-memory array.
- Used for SwiftUI previews and unit tests.

**SwiftDataPuzzleRepository**
- Backed by `ModelContext`.
- Sorts by `createdAt` (descending).
- Inserts, saves, and deletes `Puzzle` models.

**Note:** Most runtime UI currently uses SwiftData directly via `@Query` + `ModelContext`, but the protocol is available for future abstraction or testing.

---

## 5. App Shell & Navigation

### 5.1 iykykApp (Entry Point)

- Configures `ModelContainer` for `Puzzle`, `PuzzleGroup`, `PuzzleWord`.
- Handles schema errors by resetting the store in debug builds.
- Backfills or assigns `sequenceNumber` for existing puzzles, then updates `PuzzleNumberingService`.

### 5.2 RootView

`TabView` with two tabs:

**Create tab** (`scribble.variable`):
- `NavigationStack` → `PuzzleLibraryView(mode: .create)`
- Destinations:
  - `Puzzle` (published) → `PuzzlePreviewView(puzzle:)`
  - `Puzzle` (draft) → `PuzzleCreationView(puzzle:)`
  - `"create"` (String) → `PuzzleCreationView()` (new puzzle)

**Play tab** (`xmark.triangle.circle.square`):
- `NavigationStack` → `PuzzleLibraryView(mode: .play)`
- Destination: `Puzzle` → `PuzzlePlayView(puzzle:)`

---

## 6. Puzzle Library

### 6.1 PuzzleLibraryView

`mode: LibraryMode` – `.create` or `.play`

Uses `@Query(sort: \Puzzle.createdAt, order: .reverse)` to load all puzzles.

### 6.2 Create Mode (`.create`)

- Shows **all puzzles** (draft + published) in a `List`.
- Rows: `PuzzleRowView(puzzle:, showPlayStatus: false)`
  - Displays `#sequenceNumber` (or `#?`), publish status capsule, `wordCount/16`, and created date.
- Toolbar: `+` button (`NavigationLink` value `"create"`) to start a new puzzle.
- Swipe-to-delete removes puzzle from `ModelContext`.

### 6.3 Play Mode (`.play`)

- Filters to **published puzzles only** (`puzzle.isPublished`).
- Rows: `PuzzleRowView(puzzle:, showPlayStatus: true)`
  - Status capsule shows `puzzle.playStatus.displayText` with color:
    - `Not started`, `In progress`, `Won`, `Lost`
- Selecting a row navigates to `PuzzlePlayView(puzzle:)`.

### 6.4 Empty States

`EmptyStateView(mode:)`:
- `.create`: "No Puzzles Yet" with hint to tap `+`.
- `.play`: "No Published Puzzles" with hint to publish from Create mode.

---

## 7. Creation Flow

### 7.1 PuzzleCreationView

**Entry:**
- New puzzle: `PuzzleCreationView()` constructs `PuzzleFixtures.sampleEmptyPuzzle()` and marks it as `isNewPuzzle`.
- Existing puzzle: `PuzzleCreationView(puzzle:)` edits an already-inserted `Puzzle`.

**Persistence (autosave):**
- On first `onAppear` for a new puzzle: inserts into `modelContext` once, tracked by `hasBeenInserted`.
- Autosaves on changes to `puzzle.groups` (via `onChange`) and on `onDisappear`.
- No explicit "Save" button needed—changes persist immediately.

**Layout:**
- `ScrollView` → `VStack` of `GroupRowView` for each `PuzzleGroup` sorted by `position`.
- Tapping anywhere outside fields clears focus.
- Navigation bar:
  - Title: `"New Puzzle"` or `"Edit Puzzle"`.
  - `Next` button:
    - Enabled if **any word** has non-empty, non-whitespace text.
    - Pushes `PuzzlePreviewView(puzzle:)`.
- Published puzzles: Editing is disabled (`ScrollView.disabled(puzzle.isPublished)`), but view is still readable.

### 7.2 Focus & Keyboard

Uses `@FocusState` with `PuzzleCreationFocusField`:
- `.groupName(groupIndex:)`
- `.word(groupIndex:, wordIndex:)`

**Keyboard toolbar:**
- Up/down chevrons move through word fields in row-major order (0,0) → (3,3).
- Group name fields are *not* part of the keyboard navigation chain.

**Keyboard behavior:**
- `.scrollDismissesKeyboard(.interactively)` for natural keyboard avoidance.

### 7.3 GroupRowView

`@Bindable var group: PuzzleGroup`

**Group name:**
- `TextField("Group name", text: $group.title)` styled as a row title.
- Focused when corresponding `.groupName(group.position)` is active.
- Difficulty label: `GroupDifficulty.label(for: group.position)` + color.

**Words:**
- `HStack` of 4 `EditableWordTile` views for `group.words.sorted(by: position)`.
- Each tile is bound to the underlying `PuzzleWord.text`.

### 7.4 EditableWordTile

Inline `TextField("WORD", text: $text, axis: .vertical)` styled as a square tile.

**Behavior:**
- Tapping anywhere in the tile sets `focusedField = fieldID`.
- Autocorrection disabled; text auto-capitalized as characters.
- Strips newline characters; return dismisses focus.

**Typography:**
- Dynamic font size between ~10–14pt based on geometry.
- Special-case emoji: enlarged font size.

---

## 8. Preview Flow

### 8.1 PuzzlePreviewView

**Purpose:** Let the **creator** see and play their puzzle as a solver would, and gate publishing behind validation.

**Validation gate:**
- On `onAppear`, runs `PuzzleValidator.validate(puzzle)`.
- If any issues exist:
  - `playSession` is `nil`.
  - Shows a "Puzzle Needs Fixes" view with a bullet list of issues and hint to return to editing.

### 8.2 Play Session in Preview

If validation passes:
- Initializes `PuzzlePlaySession(puzzle:)`.
- Shows:
  - Solved groups area (colored cards with `group.title` + words).
  - 4×4 grid of active tiles (`session.activeTiles`) as tappable buttons with `AutoSizingTileText`.
  - Controls: `Shuffle`, `Deselect All`, `Submit`.
  - "Mistakes Remaining" row of 4 dots (starts at 4, one removed per incorrect guess).
- `Submit` is enabled when exactly 4 tiles are selected and session is in progress.

**Guess handling:**
- **Correct**: Moves group into `solvedGroupIDs`, animates tiles; if 4 groups solved, state becomes `.won`.
- **Incorrect**: Selected tiles shake, then `applyIncorrectGuessPenalty()` runs (clears selection, decrements guesses; state becomes `.lost` when `guessesRemaining == 0`).

### 8.3 Publishing

Top-right `Publish` / `Published` button:
- Available only when:
  - Puzzle is not yet published, and
  - `playSession` exists (puzzle is structurally valid).
- On publish:
  - Sets `puzzle.publishedAt = Date()` and `puzzle.playStatus = .notStarted`.
  - Saves via `modelContext`.
  - Briefly shows a "✓ Puzzle Published" banner.

---

## 9. Player Play Flow

### 9.1 PuzzlePlayView

**Entry:** From Play tab → `PuzzleLibraryView(mode: .play)` → select a published puzzle.

### 9.2 State Handling

| `playStatus` | Behavior |
|--------------|----------|
| `.won` or `.lost` | Shows end-state view with result banner and all 4 groups rendered as colored rows. |
| `.notStarted` | Sets `playStatus = .inProgress`, saves, creates new `PuzzlePlaySession`. |
| `.inProgress` | Creates new `PuzzlePlaySession` for current run. |

**Note:** Session state itself is not persisted; only `playStatus` is saved.

### 9.3 Gameplay UI

Similar to `PuzzlePreviewView`:
- Solved groups section using `session.solvedTiles` and `session.solvedGroupIDs`.
- 4×4 grid of active tiles using `WordTile` + `AutoSizingTileText`.
- Controls: `Shuffle`, `Deselect All`, `Submit`.
- "Mistakes Remaining" indicator (starts at 4).

**Guess logic:**
- Delegates to `PuzzlePlaySession` (`toggleSelection`, `submitGuess`, `applyIncorrectGuessPenalty`).
- On **win**: sets `puzzle.playStatus = .won` and saves.
- On **lose**: sets `puzzle.playStatus = .lost` and saves.

---

## 10. PuzzlePlaySession Logic

### 10.1 Core

`@Observable class PuzzlePlaySession`

Derived from a `Puzzle`:
- Builds `tiles: [WordTile]` by flattening groups/words, then shuffles.
- Builds `groupsByID` to look up group titles by `groupID`.

**Mutable state:**
- `selectedTileIDs: Set<UUID>`
- `solvedGroupIDs: [UUID]` (in solve order)
- `guessesRemaining: Int = 4`
- `state: PuzzlePlayState = .inProgress`
- `lastGuessResult: GuessResult?`

### 10.2 Computed Properties

- `activeTiles`: Tiles not in solved groups.
- `solvedTiles`: Tiles in solved groups, sorted by `solvedGroupIDs` order.
- `canSubmitGuess`: Exactly 4 tiles selected and state is `.inProgress`.

### 10.3 Interactions

**`toggleSelection(for:)`**
- No-op if game not in progress or tile already solved.
- Selects/deselects up to 4 tiles.

**`submitGuess() -> GuessResult`**
- If 4 selected tiles share the same `groupID` and group not already solved:
  - Marks group as solved, clears selection.
  - If 4 groups solved, sets `state = .won`.
  - Returns `.correct(groupID:, groupTitle:)`.
- Otherwise:
  - Leaves selection as-is (caller triggers animations first).
  - Returns `.incorrect`.

**`applyIncorrectGuessPenalty()`**
- Clears selection.
- Decrements `guessesRemaining`; on zero, sets `state = .lost`.

**`clearSelection()`** – Deselects all tiles.

**`shuffle()`** – Randomizes tile order.

---

## 11. Gameplay Rules Summary

| Rule | Value |
|------|-------|
| Grid size | 4×4 (16 words) |
| Groups | 4 |
| Words per group | 4 |
| Max selection | 4 tiles |
| Incorrect guesses allowed | 4 |
| Win condition | All 4 groups correctly identified |
| Lose condition | Exhaust all 4 incorrect guesses |

**Feedback:**
- **Correct guess**: Group solved, tiles animate to solved section.
- **Incorrect guess**: Tiles shake, selection cleared, guess count decremented.

---

## 12. Views with Inject Hot Reloading

The following views are wired with **Inject** for hot reloading during development:

- `RootView`
- `PuzzleLibraryView`
- `PuzzleCreationView`
- `GroupRowView`
- `EditableWordTile`
- `PuzzlePreviewView`
- `PuzzlePlayView`

See `AGENTS.md` section 10 for setup instructions.
