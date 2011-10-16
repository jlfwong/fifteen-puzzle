describe 'SolverStateMinHeap', ->
  it 'works correctly', ->
    q = new SolverStateMinHeap
    q.enqueue val: 1
    q.enqueue val: 7
    q.enqueue val: 5
    q.enqueue val: 19

    expect(q.dequeue()).toEqual val: 1
    expect(q.dequeue()).toEqual val: 5
    expect(q.dequeue()).toEqual val: 7

    q.enqueue val: 12

    expect(q.dequeue()).toEqual val: 12
    expect(q.dequeue()).toEqual val: 19

describe 'solve', ->
  expectSolution = ({forGrid: grid, toBe: expectedSolution}) ->
    done = false
    solution = []

    runs ->
      solve grid, {
        complete: ({steps}) ->
          done = true
          solution = steps

        error: ({msg}) ->
          done = true
      }

    waitsFor (-> done), 'solution to complete', 3000

    runs ->
      expect(solution).toEqual(expectedSolution)

  it 'returns [] for an already solved puzzle', ->
    expectSolution forGrid: new Grid, toBe: []

  it 'returns [RIGHT] for input [LEFT]', ->
    grid = (new Grid).applyMoveFrom LEFT
    expectSolution forGrid: grid, toBe: [RIGHT]

  it 'returns [BELOW] for input [ABOVE]', ->
    grid = (new Grid).applyMoveFrom ABOVE
    expectSolution forGrid: grid, toBe: [BELOW]

  it 'returns [RIGHT, RIGHT] for input [LEFT, LEFT]', ->
    grid = (new Grid).
      applyMoveFrom(LEFT).
      applyMoveFrom(LEFT)

    expectSolution forGrid: grid, toBe: [RIGHT, RIGHT]

  it 'returns [BELOW, BELOW] for input [ABOVE, ABOVE]', ->
    grid = (new Grid).
      applyMoveFrom(ABOVE).
      applyMoveFrom(ABOVE)

    expectSolution forGrid: grid, toBe: [BELOW, BELOW]

  it 'can solve a simple input', ->
    expectSolution forGrid: new Grid([
      [0  , 2  , 3  , 4  ]
      [1  , 6  , 7  , 8  ]
      [5  , 10 , 11 , 12 ]
      [9  , 13 , 14 , 15 ]
    ], [0,0]), toBe: [
      BELOW, BELOW, BELOW,
      RIGHT, RIGHT, RIGHT
    ]

  it 'can solve a simple rotation', ->
    expectSolution forGrid: new Grid([
      [1  , 2  , 3  , 4  ]
      [5  , 6  , 7  , 8  ]
      [9  , 10 , 15 , 11 ]
      [13 , 14 , 0  , 12 ]
    ], [3, 2]), toBe: [
      ABOVE, RIGHT, BELOW
    ]

  expectToReverse = (grid, moveList, cb) ->
    shuffledGrid = grid.applyMoves moveList
    done = false
    solution = []

    runs ->
      solve shuffledGrid, {
        complete: ({steps}) ->
          cb() if cb?
          done = true
          solution = steps

        error: ({msg}) ->
          done = true
      }

    waitsFor (-> done), 'solution to complete', 3000

    runs ->
      solvedGrid = shuffledGrid.applyMoves(solution)
      expect(solvedGrid.isSolved()).toBe true

  grid = new Grid
  size = 5

  while size <= 35
    do (size) ->
      it "can solve random shuffles of #{size} moves", ->
        console.warn "Solving 5 random shuffles of #{size} moves"
        console.time "Size #{size}"
        for i in [1..5]
          expectToReverse grid, randomMoveList(grid, size), ->
            console.timeEnd "Size #{size}"

    size += 5

  it 'can solve a 20 step sequence', ->
    grid = new Grid
    expectToReverse grid, [
      ABOVE , ABOVE , LEFT  , LEFT  ,
      ABOVE , RIGHT , BELOW , LEFT  ,
      LEFT  , BELOW , BELOW , RIGHT ,
      ABOVE , RIGHT , RIGHT , BELOW ,
      LEFT  , LEFT  , LEFT  , ABOVE ,
    ]

  xit 'can solve a 45 step sequence', ->
    grid = new Grid
    expectToReverse grid, [
      LEFT  , LEFT  , ABOVE , RIGHT , BELOW ,
      RIGHT , ABOVE , ABOVE , LEFT  , ABOVE ,
      LEFT  , LEFT  , BELOW , BELOW , BELOW ,
      RIGHT , ABOVE , RIGHT , BELOW , RIGHT ,
      ABOVE , ABOVE , LEFT  , LEFT  , ABOVE ,
      RIGHT , RIGHT , BELOW , LEFT  , BELOW ,
      LEFT  , ABOVE , LEFT  , ABOVE , RIGHT ,
      BELOW , LEFT  , ABOVE , RIGHT , RIGHT ,
      BELOW , RIGHT , ABOVE , LEFT  , BELOW ,
    ]
