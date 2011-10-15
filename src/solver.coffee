class @SolverState
  constructor: (@grid, steps) ->
    lowerSolutionBound = @grid.lowerSolutionBound()
    @steps = [].concat(steps)
    @solved = @grid.isSolved()
    @val = lowerSolutionBound + steps.length

class @SolverStateMinHeap
  constructor: ->
    @data = []

  enqueue: (pt) ->
    @data.push pt
    @bubbleUp @data.length - 1

  dequeue: ->
    ret = @data[0]
    end = @data.pop()

    if @data.length > 0
      @data[0] = end
      @bubbleDown 0

    return ret

  bubbleUp: (curPos) ->
    if curPos == 0
      return

    # ~~ is an optimized Math.floor
    parentPos = ~~((curPos - 1) / 2)

    cur = @data[curPos]
    parent = @data[parentPos]
    if cur.val < parent.val
      @data[curPos] = parent
      @data[parentPos] = cur

      @bubbleUp parentPos

  bubbleDown: (curPos) ->
    leftPos = curPos * 2 + 1
    rightPos = curPos * 2 + 2

    cur = @data[curPos]
    left = @data[leftPos]
    right = @data[rightPos]

    swapPos = null

    if left? and left.val < cur.val
      swapPos = leftPos

    if right? and right.val < left.val and right.val < cur.val
      swapPos = rightPos

    if swapPos?
      @data[curPos] = @data[swapPos]
      @data[swapPos] = cur
      @bubbleDown swapPos

  empty: -> (@data.length == 0)

@solve = (startGrid) ->
  frontier = new SolverStateMinHeap

  startState = new SolverState(startGrid, [])

  frontier.enqueue startState

  its = 0

  while not frontier.empty()
    its += 1
    if its > 300000
      # bail
      console.error('Failed to find solution for:')
      startGrid.log()
      return []

    curState = frontier.dequeue()

    if curState.solved
      steps = curState.steps
      console.log "Produced #{steps.length} step solution in #{its} iterations"
      return curState.steps

    grid = curState.grid
    steps = curState.steps

    candidates = _.shuffle(grid.validMoves())

    lastStep = _.last(steps)
    if lastStep?
      candidates = _(candidates).filter (x) ->
        not directionsAreOpposites x, lastStep

    for sourceDirection in candidates
      nextGrid = grid.applyMoveFrom sourceDirection
      nextSteps = steps.concat [sourceDirection]
      nextState = new SolverState(nextGrid, nextSteps)
      frontier.enqueue nextState
