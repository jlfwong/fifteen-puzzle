class @SolverState
  constructor: (@grid, steps) ->
    lowerSolutionBound = @grid.lowerSolutionBound()
    @steps = [].concat(steps)
    @solved = @grid.isSolved()
    @val = lowerSolutionBound + steps.length

class @SolverStateMinHeap
  maxSize: 100000

  constructor: ->
    @data = []

  enqueue: (pt) ->
    @data.push pt
    @bubbleUp @data.length - 1

    if @data.length == @maxSize
      @data.pop()

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
    leftPos  = curPos * 2 + 1
    rightPos = curPos * 2 + 2

    cur   = @data[curPos]
    left  = @data[leftPos]
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

@solve = (startGrid, {complete, error, frontier}) ->
  complete ?= $.noop
  error ?= $.noop

  if not frontier?
    frontier = new SolverStateMinHeap
    startState = new SolverState(startGrid, [])
    frontier.enqueue startState

  its = 0

  while not frontier.empty()
    its += 1
    if its > 1000
      window.setTimeout ->
        solve startGrid, {complete, error, frontier}
      , 10
      return

    curState = frontier.dequeue()

    if curState.solved
      steps = curState.steps

      complete {
        steps      : curState.steps
        iterations : its
      }
      return

    grid = curState.grid
    steps = curState.steps

    candidates = _.shuffle(grid.validMoves())

    lastStep = _.last(steps)
    if lastStep?
      candidates = _(candidates).filter (x) ->
        not directionsAreOpposites x, lastStep

    for sourceDirection in candidates
      nextGrid  = grid.applyMoveFrom sourceDirection
      nextSteps = steps.concat [sourceDirection]
      nextState = new SolverState(nextGrid, nextSteps)
      frontier.enqueue nextState
