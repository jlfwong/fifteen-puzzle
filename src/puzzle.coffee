class PuzzleCellView
  spacing: 5
  cellSize: 100

  constructor: ({@number, @controller}) ->
    @node = $ "<div/>",
      class: 'cell'
      text: @number

    @node.click =>
      @controller.handleCellClicked @rowNum, @colNum

    origRowNum = parseInt((@number - 1) / 4, 10)
    origColNum = parseInt((@number - 1) % 4, 10)

    if (origRowNum + origColNum) % 2 == 0
      @node.addClass 'dark'
    else
      @node.addClass 'light'

  setPosition: (@rowNum, @colNum, duration=0, cb=$.noop) ->
    @node.animate {
      top  : "#{@spacing + @rowNum * (@spacing + @cellSize)}px"
      left : "#{@spacing + @colNum * (@spacing + @cellSize)}px"
    }, duration, cb

class PuzzleGridView
  constructor: ({@controller, @node, grid}) ->
    @node.addClass 'puzzle'

    @moving = false
    @moveQueue = []
    @cellViews = []

    for rowNum of grid
      rowNum = parseInt(rowNum, 10)
      @cellViews[rowNum] = []
      for colNum of grid[rowNum]
        colNum = parseInt(colNum, 10)

        num = grid[rowNum][colNum]

        if num == 0
          cell = null
          @emptyPos = [rowNum, colNum]
        if num != 0
          cell = new PuzzleCellView {
            number: num
            controller: @controller
          }
          cell.setPosition rowNum, colNum

          @node.append(cell.node)

        @cellViews[rowNum].push(cell)

  queueMoves: (moves) ->
    @moveQueue = @moveQueue.concat(moves)

  runQueue: (duration, pause) ->
    return if @moveQueue.length == 0

    @moving = true
    @moveFrom @moveQueue.shift(), duration, =>
      if @moveQueue.length > 0
        setTimeout =>
          @runQueue duration, pause
        , pause
      else
        @moving = false

  moveFrom: (sourceDirection, duration, cb) ->
    [targetRow, targetCol] = @emptyPos
    [deltaRow, deltaCol] = directionToDelta sourceDirection
    @emptyPos = [sourceRow, sourceCol] = [
      targetRow + deltaRow,
      targetCol + deltaCol
    ]

    cellView = @cellViews[sourceRow][sourceCol]
    @cellViews[targetRow][targetCol] = cellView
    @cellViews[sourceRow][sourceCol] = null

    cellView.setPosition targetRow, targetCol, duration, cb

@randomMoveList = (grid, nMoves, moveList=[]) ->
  if moveList.length == nMoves
    return moveList

  validMoves = grid.validMoves()

  if moveList.length > 0
    # Don't just revert the last move
    last = _.last(moveList)
    [ldr, ldc] = directionToDelta last
    validMoves = _.filter validMoves, (m) ->
      not directionsAreOpposites last, m

  sourceDirection = _.shuffle(validMoves)[0]
  nextGrid = grid.applyMoveFrom sourceDirection
  moveList.push sourceDirection

  return randomMoveList(nextGrid, nMoves, moveList)

class @Puzzle
  moveDuration: 400
  movePause: 100

  constructor: (@node) ->
    @grid = new Grid(INIT_GRID, [3, 3])
    @gridView = new PuzzleGridView {
      node       : @node
      grid       : INIT_GRID
      controller : this
    }

  shuffle: (nMoves=10) ->
    @applyMoves randomMoveList(@grid, nMoves)

  applyMoves: (moves) ->
    @grid = @grid.applyMoves moves
    @gridView.queueMoves moves
    @gridView.runQueue @moveDuration, @movePause, =>
      @moving = false

  handleCellClicked: (rowNum, colNum) ->
    if not @gridView.moving
      move = @grid.positionToMove rowNum, colNum
      if move?
        @applyMoves [move]
