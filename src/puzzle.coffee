class PuzzleCellView
  spacing: 5
  cellSize: 100

  constructor: ({@number, @controller}) ->
    @node = $ '<div/>',
      class: 'cell'
      text: @number

    @node.mousedown =>
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

class ControlBarView
  constructor: ({@controller}) ->
    @node = $ '<div/>',
      class: 'control-bar'

    @controls = $ '<div/>'

    shuffleBtn = $ '<div/>',
      text:  'shuffle'
      class: 'shuffle-button'
      click: => @controller.handleShuffleClicked()

    titleText = $ '<div/>',
      text:  'Fifteen'
      class: 'title-text'

    solveBtn = $ '<div/>',
      text: 'solve'
      class: 'solve-button'
      click: => @controller.handleSolveClicked()

    @controls.append shuffleBtn
    @controls.append titleText
    @controls.append solveBtn

    @node.append @controls

class OverlayView
  constructor: ({@controller}) ->
    @node = $ '<div/>',
      class: 'overlay-container'

    @overlay = $ '<div/>',
      class: 'overlay'

    @glowing = false

    @node.append @overlay
    @node.hide()

  setMessage: (msg) ->
    @overlay.text msg

  show: (msg, cb) ->
    if msg?
      @setMessage msg

    @node.fadeIn =>
      cb() if cb
      @glowing = true
      @glowOut()

  hide: (cb) ->
    @glowing = false
    @node.fadeOut cb

  glowOut: ->
    return if not @glowing
    @overlay.animate {
      opacity: 0.6
    }, 1000, => @glowIn()

  glowIn: ->
    return if not @glowing
    @overlay.animate {
      opacity: 0.8
    }, 1000, => @glowOut()

class PuzzleView
  constructor: ({@controller, @container, grid}) ->
    @container.addClass('puzzle-container')

    @node = $('<div/>').addClass('puzzle').appendTo @container

    @controlsShown = true

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

    @controlBarView = new ControlBarView {
      controller: @controller
    }

    @node.append(@controlBarView.node)

    @overlayView = new OverlayView {
      controller: @controller
    }

    @node.append(@overlayView.node)

  queueMoves: (moves) ->
    @moveQueue = @moveQueue.concat(moves)

  runQueue: (duration, pause, cb=$.noop) ->
    if @moveQueue.length == 0
      cb()
      return

    @moving = true
    @moveFrom @moveQueue.shift(), duration, =>
      if @moveQueue.length > 0
        setTimeout =>
          @runQueue duration, pause, cb
        , pause
      else
        @moving = false
        cb()

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

  hideControls: (cb) ->
    @controlsShown = false
    $(@node).animate height: "-=50px", cb

  showControls: (cb) ->
    @controlsShown = true
    $(@node).animate height: "+=50px", cb

  showOverlay: (msg, cb) ->
    @overlayView.show msg, cb

  setOverlayMessage: (msg) ->
    @overlayView.setMessage msg

  hideOverlay: (cb) ->
    @overlayView.hide cb

  isInteractive: -> @controlsShown and not @moving

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
  moveDuration: 100
  movePause: 20

  constructor: (@container) ->
    @grid = new Grid(INIT_GRID, [3, 3])
    @view = new PuzzleView {
      container  : @container
      grid       : INIT_GRID
      controller : this
    }

  shuffle: (nMoves, cb) ->
    @applyMoves randomMoveList(@grid, nMoves), cb

  applyMoves: (moves, cb) ->
    @grid = @grid.applyMoves moves
    @view.queueMoves moves
    @view.runQueue @moveDuration, @movePause, cb

  handleShuffleClicked: ->
    if @view.isInteractive()
      @view.showOverlay 'shuffling'

      @view.hideControls =>
        @shuffle 25, =>
          @view.hideOverlay()

          @view.showControls()

  handleSolveClicked: ->
    if @view.isInteractive() and not @grid.isSolved()
      @view.hideControls =>

        @view.showOverlay 'solving', =>
          solve @grid, {
            complete: ({steps}) =>
              @view.hideOverlay =>
                @applyMoves steps, =>
                  @view.showControls()

            error: ({msg}) =>
              @view.hideOverlay()

              @view.showControls()
          }

  handleCellClicked: (rowNum, colNum) ->
    if @view.isInteractive()
      move = @grid.positionToMove rowNum, colNum
      if move?
        @applyMoves [move]
