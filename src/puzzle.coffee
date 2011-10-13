class PuzzleCellView
  constructor: (num) ->
    @node = $ "<div/>",
      text: num
      css:
        width      : "#{CELL_SIZE - 2}px"
        height     : "#{CELL_SIZE - 2}px"
        textAlign  : "center"
        lineHeight : "#{CELL_SIZE}px"
        fontSize   : "30px"
        border     : "1px solid black"
        position   : "absolute"

    origRowNum = parseInt((num - 1) / 4, 10)
    origColNum = parseInt((num - 1) % 4, 10)

    if (origRowNum + origColNum) % 2 == 0
      @node.css
        backgroundColor: 'black'
        color: 'white'
    else
      @node.css
        backgroundColor: 'white'
        color: 'black'

  setPosition: (rowNum, colNum, duration=0, cb=$.noop) ->
    @node.animate {
      top  : "#{rowNum * CELL_SIZE}px"
      left : "#{colNum * CELL_SIZE}px"
    }, duration, cb

class PuzzleGridView
  constructor: ($el, grid) ->
    $el.css
      position : "relative"
      width    : "#{4 * CELL_SIZE}px"
      height   : "#{4 * CELL_SIZE}px"

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
          cell = new PuzzleCellView(num)
          cell.setPosition rowNum, colNum

          $el.append(cell.node)

        @cellViews[rowNum].push(cell)

  queueMoves: (moves) ->
    @moveQueue = @moveQueue.concat(moves)

  runQueue: (duration) ->
    if @moveQueue.length != 0
      @moveFrom @moveQueue.shift(), duration, =>
        @runQueue(duration)

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

randomMoveList = (grid, nMoves, moveList=[]) ->
  if moveList.length == nMoves
    return moveList

  validMoves = grid.validMoves()

  if moveList.length > 0
    # Don't just revert the last move
    last = _.last(moveList)
    [ldr, ldc] = directionToDelta last
    validMoves = _.filter validMoves, (m) ->
      [mdr, mdc] = directionToDelta m
      (ldr + mdr != 0) || (ldc + mdc != 0)

  sourceDirection = _.shuffle(validMoves)[0]
  nextGrid = grid.applyMoveFrom sourceDirection
  moveList.push sourceDirection

  return randomMoveList(nextGrid, nMoves, moveList)

class @Puzzle
  constructor: ($el) ->
    @grid = new Grid(INIT_GRID, [3, 3])

    @gridView = new PuzzleGridView($el, INIT_GRID)

    @gridView.queueMoves randomMoveList(@grid, 50)
    @gridView.runQueue 100
