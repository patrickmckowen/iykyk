## Planning Guidelines for New Features

When creating a plan for any new feature, follow these steps to keep work safe, reviewable, and aligned with project goals.

### 1. Branching and Scope
- **Always create a new branch** for each feature or change.
- **Scope for a single pull request**:
  - Small enough to be **easy to review, test, and debug**.
  - Large enough to represent **meaningful progress** toward project goals.
- **Avoid** mixing unrelated changes in the same branch or pull request.

### 2. Break Work into Chunks
- **Decompose the feature** into a small set of clearly defined chunks of work.
- For each chunk, specify:
  - **Goal**: What exactly will be delivered when this chunk is complete?
  - **Dependencies**: What needs to be done before this chunk can start?
  - **Validation**: How will you verify this chunk is correct (e.g., tests, manual checks, UI states)?
- Prefer **short, sequential chunks** over a single large, ambiguous task.

### 3. Plan Structure
When writing a plan, at minimum include:
- **Overview**: 1–3 sentences describing the feature and its purpose.
- **Branch Name**: Proposed branch name (e.g., `feature/<short-purpose>`).
- **Chunks**: Numbered list of work chunks. For each item:
  - **Title**: Short, action-oriented name.
  - **Description**: What will be implemented.
  - **Validation**: How to confirm it works.

### 4. Validation and Completion
- Ensure **every chunk has at least one clear validation step**.
- At the end of the plan, include:
  - **Completion criteria**: What must be true for the feature to be considered done.
  - **Risks / unknowns** (if any) and how they will be handled.



