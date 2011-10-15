@originalPosition = (num) ->
  [
    parseInt((num-1) / 4, 10),
    parseInt((num-1) % 4, 10)
  ]

@rectilinearDistance = (num, curRow, curCol) ->
  [origRow, origCol] = originalPosition(num)
  return Math.abs(origRow - curRow) + Math.abs(origCol - curCol)

class @Grid
  constructor: (grid=INIT_GRID, emptyPos=[3,3]) ->
    @emptyPos = [].concat(emptyPos)

    @grid = []
    for row in grid
      @grid.push([].concat(row))

  validMoves: ->
    [rowNum, colNum] = @emptyPos
    valid = []
    valid.push LEFT  if colNum != 0
    valid.push RIGHT if colNum != 3
    valid.push ABOVE if rowNum != 0
    valid.push BELOW if rowNum != 3
    return valid

  positionToMove: (rowNum, colNum) ->
    [emptyRow, emptyCol] = @emptyPos
    if rowNum == emptyRow
      if colNum == emptyCol - 1
        return LEFT
      if colNum == emptyCol + 1
        return RIGHT
    if colNum == emptyCol
      if rowNum == emptyRow - 1
        return ABOVE
      if rowNum == emptyRow + 1
        return BELOW

    return null

  applyMoveFrom: (sourceDirection) ->
    [targetRow, targetCol] = @emptyPos
    [deltaRow, deltaCol] = directionToDelta sourceDirection
    emptyPos = [sourceRow, sourceCol] = [
      targetRow + deltaRow,
      targetCol + deltaCol
    ]

    grid = []
    for row in @grid
      grid.push([].concat(row))

    grid[targetRow][targetCol] = grid[sourceRow][sourceCol]
    grid[sourceRow][sourceCol] = 0

    nextGrid = new Grid(grid, emptyPos)

    number = grid[targetRow][targetCol]
    nextGrid._lowerSolutionBound = @lowerSolutionBound() -
      rectilinearDistance(number, sourceRow, sourceCol) +
      rectilinearDistance(number, targetRow, targetCol)

    return nextGrid

  applyMoves: (sourceDirections) ->
    nextGrid = @
    for dir in sourceDirections
      nextGrid = nextGrid.applyMoveFrom dir

    return nextGrid

  lowerSolutionBound: ->
    ###
      This calculates a lower bound on the minimum
      number of steps required to solve the puzzle

      This is the sum of the rectilinear distances
      from where each number is to where it should
      be
    ###
    if not @_lowerSolutionBound?

      moveCount = 0

      for rowNum of @grid
        rowNum = parseInt(rowNum, 10)
        for colNum of @grid[rowNum]
          colNum = parseInt(colNum, 10)

          number = @grid[rowNum][colNum]

          continue if number == 0

          moveCount += rectilinearDistance number, rowNum, colNum

      @_lowerSolutionBound = moveCount

    return @_lowerSolutionBound

  isSolved: -> @lowerSolutionBound() == 0

  log: ->
    console.log "Empty: #{@emptyPos}"
    for row in @grid
      console.log JSON.stringify(row)
