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

  expectToReverse = (grid, moveList) ->
    shuffledGrid = grid.applyMoves moveList
    solution = solve shuffledGrid

    expect(shuffledGrid.applyMoves(solution).lowerSolutionBound()).toEqual 0

  it 'can solve random shuffles of various sizes', ->
    grid = new Grid
    size = 5
    while size <= 40
      console.warn "Solving 5 random shuffles of #{size} moves"
      console.time "Size #{size}"
      for i in [1..5]
        expectToReverse(grid, randomMoveList(grid, size))
      console.timeEnd "Size #{size}"

      size += 5

  ###
  it 'can solve a random shuffle of 50 moves', ->
    grid = new Grid
    for i in [1..5]
      expectToReverse(grid, randomMoveList(grid, 25))
  ###

  it 'can solve a 20 step sequence', ->
    grid = new Grid
    expectToReverse grid, [
      ABOVE, ABOVE, LEFT, LEFT,
      ABOVE, RIGHT, BELOW, LEFT,
      LEFT, BELOW, BELOW, RIGHT,
      ABOVE, RIGHT, RIGHT, BELOW,
      LEFT, LEFT, LEFT, ABOVE
    ]
