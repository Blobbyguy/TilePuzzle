````markdown
# **Project Guidelines: Puzzle-Solving Board Game**

## **1. Overview**
Create a puzzle-solving game engine and UI.

The user defines:
- A board size (e.g., `8×8`)
- A list of pieces (various shapes made of connected squares)

The solver attempts to place **all** pieces on the board without overlap and within bounds.

The system must:
- Attempt to solve the puzzle automatically.
- Stream solver attempts live to the UI.
- Track and display the *closest attempt* (highest number of successfully placed pieces).
- Allow users to visually inspect attempts as they happen.

---

## **2. Core Requirements**

### **2.1 Board**
A rectangular grid defined by:
- `width`
- `height`

**Example**
```json
{ "width": 10, "height": 6 }
````

---

### **2.2 Pieces**

A piece is a set of cells described by coordinates relative to a local origin.

**Examples**

**Line**

```
[[0,0],[1,0],[2,0],[3,0]]
```

**L-Shape**

```
[[0,0],[0,1],[0,2],[1,2]]
```

**2×2 Block**

```
[[0,0],[1,0],[0,1],[1,1]]
```

Each piece has:

* `id`
* `cells`
* `rotatable` (boolean)
* `color` (optional)

---

## **3. Solver Algorithm**

### **3.1 Algorithm Basics**

* Input: board + pieces
* Tries to place pieces sequentially
* Supports backtracking
* Supports heuristics

### **3.2 Required Heuristics**

* **Piece ordering heuristic**
  Try larger pieces first.
  Example: place a 5-cell T-shape before a 2-cell domino.
* **Placement heuristic**
  Try coordinates near the top-left first.
* **Rotation / mirroring support**
  Optional, but design must allow it.

### **3.3 Required Output**

The solver must stream attempt events to the UI.

**Attempt Event Example**

```json
{
  "attemptId": 42,
  "placedPieces": [
    { "pieceId": "L1", "position": [3,4], "rotation": 90 },
    { "pieceId": "LINE1", "position": [0,2], "rotation": 0 }
  ]
}
```

### **3.4 Closest Attempt Tracking**

* Track the attempt with the most successfully placed pieces.
* Update the UI whenever a new "best" attempt is found.

---

## **4. Live Feedback Requirements**

The UI must show:

* Live solver attempts
* Highlighted piece-placement
* Progress indicators:

    * current recursion depth
    * number of backtracks
    * pieces remaining
    * time elapsed

**Example UI messages**

* `Attempt 155: 3/7 pieces placed`
* `New Best: 5/7 pieces placed`

---

## **5. Game Flow**

1. User selects board size.
2. User loads predefined pieces.
3. Solver starts running.
4. UI streams solver events in real time.
5. If a complete solution is found:

    * Display final board
    * Stop solver
6. If no complete solution:

    * Show closest attempt
    * Allow export

---

## **6. UI Requirements**

### **6.1 Board Renderer**

* Grid-based display
* Each cell drawn as a square
* Piece colors used for clarity

### **6.2 Attempt Viewer**

* Animate or highlight active placement
* Show piece IDs visually

### **6.3 Controls**

* Start Solver
* Stop Solver
* Reset Puzzle
* Step Mode
* Solver Speed (slow → fast)

---

## **7. Data Structures**

### **Piece**

* `id: string`
* `cells: List<(int x, int y)>`
* `rotatable: bool`
* `color: string?`

### **Board**

* `width: int`
* `height: int`
* `cells: 2D array (nullable piece references)`

### **Solver**

* `pieces`
* `board`
* `heuristics`
* `onAttempt` callback

### **Attempt Event**

* `attemptId`
* `placedPieces[]`

---

## **8. Non-Functional Requirements**

* Must run smoothly on mobile + web.
* Solver must support cancellation.
* Efficient backtracking.
* Fast redraw performance.

---

## **9. Example Full Scenario**

### **Input**

Board: `8×8`
Pieces: L-shape, 2×2 block, 3-line, 4-line

### **Solver Flow Example**

* Try 4-line at `(0,0)`
* Rotate 4-line vertically
* Place 2×2 block
* Fail → backtrack
* Continue exploring positions

### **Closest Result Example**

* Best attempt: 3/4 placed
* UI highlights this attempt in a "Best Attempt" panel

```
```
