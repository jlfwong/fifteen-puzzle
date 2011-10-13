describe 'PriorityQueue', ->
  it 'works correctly', ->
    cmp = (a, b) -> b - a
    q = new PriorityQueue(cmp)
    q.enqueue 1
    q.enqueue 7
    q.enqueue 5
    q.enqueue 19

    expect(q.dequeue()).toEqual 1
    expect(q.dequeue()).toEqual 5
    expect(q.dequeue()).toEqual 7

    q.enqueue 12

    expect(q.dequeue()).toEqual 12
    expect(q.dequeue()).toEqual 19

describe 'solve', ->
  it 'returns [] for an already solved puzzle', ->
    expect(solve(new Grid)).toEqual []

  it 'returns [RIGHT] for input [LEFT]', ->
    grid = (new Grid).applyMoveFrom LEFT
    expect(solve(grid)).toEqual [RIGHT]

  it 'returns [BELOW] for input [ABOVE]', ->
    grid = (new Grid).applyMoveFrom ABOVE
    expect(solve(grid)).toEqual [BELOW]

  it 'returns [RIGHT, RIGHT] for input [LEFT, LEFT]', ->
    grid = (new Grid).
      applyMoveFrom(LEFT).
      applyMoveFrom(LEFT)

    expect(solve(grid)).toEqual [RIGHT, RIGHT]

  it 'returns [BELOW, BELOW] for input [ABOVE, ABOVE]', ->
    grid = (new Grid).
      applyMoveFrom(ABOVE).
      applyMoveFrom(ABOVE)

    expect(solve(grid)).toEqual [BELOW, BELOW]

  it 'can solve a simple input', ->
    expect(solve(new Grid [
      [0  , 2  , 3  , 4  ]
      [1  , 6  , 7  , 8  ]
      [5  , 10 , 11 , 12 ]
      [9  , 13 , 14 , 15 ]
    ], [0, 0])).toEqual([
      BELOW, BELOW, BELOW,
      RIGHT, RIGHT, RIGHT
    ])

  it 'can solve a simple rotation', ->
    expect(solve(new Grid [
      [1  , 2  , 3  , 4  ]
      [5  , 6  , 7  , 8  ]
      [9  , 10 , 15 , 11 ]
      [13 , 14 , 0  , 12 ]
    ], [3, 2])).toEqual([
      ABOVE, RIGHT, BELOW
    ])

  it 'can solve a random shuffle of 10 moves', ->
    grid = new Grid
    moves = randomMoveList grid, 10
    shuffledGrid = grid.applyMoves moves

    expect(shuffledGrid.lowerSolutionBound()).not.toEqual 0

    solution = solve shuffledGrid
    console.log 'Soln', solution, 'MoveList', moves
    shuffledGrid.log()
    console.log '---'
    grid.log()

    expect(solution.length > 0).toEqual true
    expect(solution.length <= 10).toEqual true

    expect(shuffledGrid.applyMoves(solution).lowerSolutionBound()).toEqual 0
