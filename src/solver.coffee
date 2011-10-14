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

  its = 0

  while not frontier.empty()
    its += 1
    if its > 10000
      # bail
      console.error('Failed to find solution')
      return []

    curState = frontier.dequeue()

    if curState.solved
      steps = curState.steps
      console.log("#{steps.length} step solution finished in #{its} iterations")
      return curState.steps

    grid = curState.grid
    steps = curState.steps

    candidates = grid.validMoves()

    lastStep = _.last(steps)
    if lastStep?
      candidates = _(candidates).filter (x) ->
        not directionsAreOpposites x, lastStep

    for sourceDirection in candidates
      nextGrid = grid.applyMoveFrom sourceDirection
      nextSteps = steps.concat [sourceDirection]
      nextState = new SolverState(nextGrid, nextSteps)
      frontier.enqueue nextState
