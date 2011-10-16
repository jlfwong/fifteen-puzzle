(function() {
  var ControlBarView, OverlayView, PuzzleCellView, PuzzleView;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  PuzzleCellView = (function() {
    PuzzleCellView.prototype.spacing = 5;
    PuzzleCellView.prototype.cellSize = 100;
    function PuzzleCellView(_arg) {
      var origColNum, origRowNum;
      this.number = _arg.number, this.controller = _arg.controller;
      this.node = $('<div/>', {
        "class": 'cell',
        text: this.number
      });
      this.node.mousedown(__bind(function() {
        return this.controller.handleCellClicked(this.rowNum, this.colNum);
      }, this));
      origRowNum = parseInt((this.number - 1) / 4, 10);
      origColNum = parseInt((this.number - 1) % 4, 10);
      if ((origRowNum + origColNum) % 2 === 0) {
        this.node.addClass('dark');
      } else {
        this.node.addClass('light');
      }
    }
    PuzzleCellView.prototype.setPosition = function(rowNum, colNum, duration, cb) {
      this.rowNum = rowNum;
      this.colNum = colNum;
      if (duration == null) {
        duration = 0;
      }
      if (cb == null) {
        cb = $.noop;
      }
      return this.node.animate({
        top: "" + (this.spacing + this.rowNum * (this.spacing + this.cellSize)) + "px",
        left: "" + (this.spacing + this.colNum * (this.spacing + this.cellSize)) + "px"
      }, duration, cb);
    };
    return PuzzleCellView;
  })();
  ControlBarView = (function() {
    function ControlBarView(_arg) {
      var shuffleBtn, solveBtn, titleText;
      this.controller = _arg.controller;
      this.node = $('<div/>', {
        "class": 'control-bar'
      });
      this.controls = $('<div/>');
      shuffleBtn = $('<div/>', {
        text: 'shuffle',
        "class": 'shuffle-button',
        click: __bind(function() {
          return this.controller.handleShuffleClicked();
        }, this)
      });
      titleText = $('<div/>', {
        text: 'Fifteen',
        "class": 'title-text'
      });
      solveBtn = $('<div/>', {
        text: 'solve',
        "class": 'solve-button',
        click: __bind(function() {
          return this.controller.handleSolveClicked();
        }, this)
      });
      this.controls.append(shuffleBtn);
      this.controls.append(titleText);
      this.controls.append(solveBtn);
      this.node.append(this.controls);
    }
    return ControlBarView;
  })();
  OverlayView = (function() {
    function OverlayView(_arg) {
      this.controller = _arg.controller;
      this.node = $('<div/>', {
        "class": 'overlay-container'
      });
      this.overlay = $('<div/>', {
        "class": 'overlay'
      });
      this.glowing = false;
      this.node.append(this.overlay);
      this.node.hide();
    }
    OverlayView.prototype.setMessage = function(msg) {
      return this.overlay.text(msg);
    };
    OverlayView.prototype.show = function(msg, cb) {
      if (msg != null) {
        this.setMessage(msg);
      }
      return this.node.fadeIn(__bind(function() {
        if (cb) {
          cb();
        }
        this.glowing = true;
        return this.glowOut();
      }, this));
    };
    OverlayView.prototype.hide = function(cb) {
      this.glowing = false;
      return this.node.fadeOut(cb);
    };
    OverlayView.prototype.glowOut = function() {
      if (!this.glowing) {
        return;
      }
      return this.overlay.animate({
        opacity: 0.6
      }, 1000, __bind(function() {
        return this.glowIn();
      }, this));
    };
    OverlayView.prototype.glowIn = function() {
      if (!this.glowing) {
        return;
      }
      return this.overlay.animate({
        opacity: 0.8
      }, 1000, __bind(function() {
        return this.glowOut();
      }, this));
    };
    return OverlayView;
  })();
  PuzzleView = (function() {
    function PuzzleView(_arg) {
      var cell, colNum, grid, num, rowNum;
      this.controller = _arg.controller, this.container = _arg.container, grid = _arg.grid;
      this.container.addClass('puzzle-container');
      this.node = $('<div/>').addClass('puzzle').appendTo(this.container);
      this.controlsShown = true;
      this.moving = false;
      this.moveQueue = [];
      this.cellViews = [];
      for (rowNum in grid) {
        rowNum = parseInt(rowNum, 10);
        this.cellViews[rowNum] = [];
        for (colNum in grid[rowNum]) {
          colNum = parseInt(colNum, 10);
          num = grid[rowNum][colNum];
          if (num === 0) {
            cell = null;
            this.emptyPos = [rowNum, colNum];
          }
          if (num !== 0) {
            cell = new PuzzleCellView({
              number: num,
              controller: this.controller
            });
            cell.setPosition(rowNum, colNum);
            this.node.append(cell.node);
          }
          this.cellViews[rowNum].push(cell);
        }
      }
      this.controlBarView = new ControlBarView({
        controller: this.controller
      });
      this.node.append(this.controlBarView.node);
      this.overlayView = new OverlayView({
        controller: this.controller
      });
      this.node.append(this.overlayView.node);
    }
    PuzzleView.prototype.queueMoves = function(moves) {
      return this.moveQueue = this.moveQueue.concat(moves);
    };
    PuzzleView.prototype.runQueue = function(duration, pause, cb) {
      if (cb == null) {
        cb = $.noop;
      }
      if (this.moveQueue.length === 0) {
        cb();
        return;
      }
      this.moving = true;
      return this.moveFrom(this.moveQueue.shift(), duration, __bind(function() {
        if (this.moveQueue.length > 0) {
          return setTimeout(__bind(function() {
            return this.runQueue(duration, pause, cb);
          }, this), pause);
        } else {
          this.moving = false;
          return cb();
        }
      }, this));
    };
    PuzzleView.prototype.moveFrom = function(sourceDirection, duration, cb) {
      var cellView, deltaCol, deltaRow, sourceCol, sourceRow, targetCol, targetRow, _ref, _ref2, _ref3;
      _ref = this.emptyPos, targetRow = _ref[0], targetCol = _ref[1];
      _ref2 = directionToDelta(sourceDirection), deltaRow = _ref2[0], deltaCol = _ref2[1];
      this.emptyPos = (_ref3 = [targetRow + deltaRow, targetCol + deltaCol], sourceRow = _ref3[0], sourceCol = _ref3[1], _ref3);
      cellView = this.cellViews[sourceRow][sourceCol];
      this.cellViews[targetRow][targetCol] = cellView;
      this.cellViews[sourceRow][sourceCol] = null;
      return cellView.setPosition(targetRow, targetCol, duration, cb);
    };
    PuzzleView.prototype.hideControls = function(cb) {
      this.controlsShown = false;
      return $(this.node).animate({
        height: "-=50px"
      }, cb);
    };
    PuzzleView.prototype.showControls = function(cb) {
      this.controlsShown = true;
      return $(this.node).animate({
        height: "+=50px"
      }, cb);
    };
    PuzzleView.prototype.showOverlay = function(msg, cb) {
      return this.overlayView.show(msg, cb);
    };
    PuzzleView.prototype.setOverlayMessage = function(msg) {
      return this.overlayView.setMessage(msg);
    };
    PuzzleView.prototype.hideOverlay = function(cb) {
      return this.overlayView.hide(cb);
    };
    PuzzleView.prototype.isInteractive = function() {
      return this.controlsShown && !this.moving;
    };
    return PuzzleView;
  })();
  this.randomMoveList = function(grid, nMoves, moveList) {
    var last, ldc, ldr, nextGrid, sourceDirection, validMoves, _ref;
    if (moveList == null) {
      moveList = [];
    }
    if (moveList.length === nMoves) {
      return moveList;
    }
    validMoves = grid.validMoves();
    if (moveList.length > 0) {
      last = _.last(moveList);
      _ref = directionToDelta(last), ldr = _ref[0], ldc = _ref[1];
      validMoves = _.filter(validMoves, function(m) {
        return !directionsAreOpposites(last, m);
      });
    }
    sourceDirection = _.shuffle(validMoves)[0];
    nextGrid = grid.applyMoveFrom(sourceDirection);
    moveList.push(sourceDirection);
    return randomMoveList(nextGrid, nMoves, moveList);
  };
  this.Puzzle = (function() {
    Puzzle.prototype.moveDuration = 100;
    Puzzle.prototype.movePause = 20;
    function Puzzle(container) {
      this.container = container;
      this.grid = new Grid(INIT_GRID, [3, 3]);
      this.view = new PuzzleView({
        container: this.container,
        grid: INIT_GRID,
        controller: this
      });
    }
    Puzzle.prototype.shuffle = function(nMoves, cb) {
      return this.applyMoves(randomMoveList(this.grid, nMoves), cb);
    };
    Puzzle.prototype.applyMoves = function(moves, cb) {
      this.grid = this.grid.applyMoves(moves);
      this.view.queueMoves(moves);
      return this.view.runQueue(this.moveDuration, this.movePause, cb);
    };
    Puzzle.prototype.handleShuffleClicked = function() {
      if (this.view.isInteractive()) {
        this.view.showOverlay('shuffling');
        return this.view.hideControls(__bind(function() {
          return this.shuffle(25, __bind(function() {
            this.view.hideOverlay();
            return this.view.showControls();
          }, this));
        }, this));
      }
    };
    Puzzle.prototype.handleSolveClicked = function() {
      if (this.view.isInteractive() && !this.grid.isSolved()) {
        return this.view.hideControls(__bind(function() {
          return this.view.showOverlay('solving', __bind(function() {
            return solve(this.grid, {
              complete: __bind(function(_arg) {
                var steps;
                steps = _arg.steps;
                return this.view.hideOverlay(__bind(function() {
                  return this.applyMoves(steps, __bind(function() {
                    return this.view.showControls();
                  }, this));
                }, this));
              }, this),
              error: __bind(function(_arg) {
                var msg;
                msg = _arg.msg;
                this.view.hideOverlay();
                return this.view.showControls();
              }, this)
            });
          }, this));
        }, this));
      }
    };
    Puzzle.prototype.handleCellClicked = function(rowNum, colNum) {
      var move;
      if (this.view.isInteractive()) {
        move = this.grid.positionToMove(rowNum, colNum);
        if (move != null) {
          return this.applyMoves([move]);
        }
      }
    };
    return Puzzle;
  })();
}).call(this);
