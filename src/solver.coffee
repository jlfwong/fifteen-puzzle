stateCmp = (a, b) ->
  b.val - a.val

class @SolverState
  constructor: (@grid, steps) ->
    lowerSolutionBound = @grid.lowerSolutionBound()
    @steps = [].concat(steps)
    @solved = (lowerSolutionBound == 0)
    @val = lowerSolutionBound + steps.length

class @PriorityQueue
  constructor: (cmp) ->
    @cmp = cmp
    @data = []

  enqueue: (pt) ->
    @data.push pt
    @data.sort @cmp

  dequeue: (pt) -> @data.pop()

  empty: -> (@data.length == 0)

@solve = (startGrid) ->
  frontier = new PriorityQueue(stateCmp)

  startState = new SolverState(startGrid, [])

  frontier.enqueue startState

  while not frontier.empty()
    curState = frontier.dequeue()

    if curState.solved
      return curState.steps

    grid = curState.grid
    steps = curState.steps

    for sourceDirection in grid.validMoves()
      nextGrid = grid.applyMoveFrom sourceDirection
      nextSteps = steps.concat [sourceDirection]
      nextState = new SolverState(nextGrid, nextSteps)
      frontier.enqueue nextState
