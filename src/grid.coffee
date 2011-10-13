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
    @emptyPos = _.clone emptyPos

    @grid = []
    for row in grid
      @grid.push _.clone(row)

  validMoves: ->
    [rowNum, colNum] = @emptyPos
    valid = []
    valid.push LEFT  if colNum != 0
    valid.push RIGHT if colNum != 3
    valid.push ABOVE if rowNum != 0
    valid.push BELOW if rowNum != 3
    return valid

  applyMoveFrom: (sourceDirection) ->
    [targetRow, targetCol] = @emptyPos
    [deltaRow, deltaCol] = directionToDelta sourceDirection
    emptyPos = [sourceRow, sourceCol] = [
      targetRow + deltaRow,
      targetCol + deltaCol
    ]

    grid = []
    for row in @grid
      grid.push _.clone(row)

    grid[targetRow][targetCol] = grid[sourceRow][sourceCol]
    grid[sourceRow][sourceCol] = 0

    return new Grid(grid, emptyPos)

  lowerSolutionBound: ->
    ###
      This calculates a lower bound on the minimum
      number of steps required to solve the puzzle

      This is the sum of the rectilinear distances
      from where each number is to where it should
      be
    ###

