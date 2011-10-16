(function() {
  this.originalPosition = function(num) {
    return [parseInt((num - 1) / 4, 10), parseInt((num - 1) % 4, 10)];
  };
  this.rectilinearDistance = function(num, curRow, curCol) {
    var origCol, origRow, _ref;
    _ref = originalPosition(num), origRow = _ref[0], origCol = _ref[1];
    return Math.abs(origRow - curRow) + Math.abs(origCol - curCol);
  };
  this.Grid = (function() {
    function Grid(grid, emptyPos) {
      var row, _i, _len;
      if (grid == null) {
        grid = INIT_GRID;
      }
      if (emptyPos == null) {
        emptyPos = [3, 3];
      }
      this.emptyPos = [].concat(emptyPos);
      this.grid = [];
      for (_i = 0, _len = grid.length; _i < _len; _i++) {
        row = grid[_i];
        this.grid.push([].concat(row));
      }
    }
    Grid.prototype.validMoves = function() {
      var colNum, rowNum, valid, _ref;
      _ref = this.emptyPos, rowNum = _ref[0], colNum = _ref[1];
      valid = [];
      if (colNum !== 0) {
        valid.push(LEFT);
      }
      if (colNum !== 3) {
        valid.push(RIGHT);
      }
      if (rowNum !== 0) {
        valid.push(ABOVE);
      }
      if (rowNum !== 3) {
        valid.push(BELOW);
      }
      return valid;
    };
    Grid.prototype.positionToMove = function(rowNum, colNum) {
      var emptyCol, emptyRow, _ref;
      _ref = this.emptyPos, emptyRow = _ref[0], emptyCol = _ref[1];
      if (rowNum === emptyRow) {
        if (colNum === emptyCol - 1) {
          return LEFT;
        }
        if (colNum === emptyCol + 1) {
          return RIGHT;
        }
      }
      if (colNum === emptyCol) {
        if (rowNum === emptyRow - 1) {
          return ABOVE;
        }
        if (rowNum === emptyRow + 1) {
          return BELOW;
        }
      }
      return null;
    };
    Grid.prototype.applyMoveFrom = function(sourceDirection) {
      var deltaCol, deltaRow, emptyPos, grid, nextGrid, number, row, sourceCol, sourceRow, targetCol, targetRow, _i, _len, _ref, _ref2, _ref3, _ref4;
      _ref = this.emptyPos, targetRow = _ref[0], targetCol = _ref[1];
      _ref2 = directionToDelta(sourceDirection), deltaRow = _ref2[0], deltaCol = _ref2[1];
      emptyPos = (_ref3 = [targetRow + deltaRow, targetCol + deltaCol], sourceRow = _ref3[0], sourceCol = _ref3[1], _ref3);
      grid = [];
      _ref4 = this.grid;
      for (_i = 0, _len = _ref4.length; _i < _len; _i++) {
        row = _ref4[_i];
        grid.push([].concat(row));
      }
      grid[targetRow][targetCol] = grid[sourceRow][sourceCol];
      grid[sourceRow][sourceCol] = 0;
      nextGrid = new Grid(grid, emptyPos);
      number = grid[targetRow][targetCol];
      nextGrid._lowerSolutionBound = this.lowerSolutionBound() - rectilinearDistance(number, sourceRow, sourceCol) + rectilinearDistance(number, targetRow, targetCol);
      return nextGrid;
    };
    Grid.prototype.applyMoves = function(sourceDirections) {
      var dir, nextGrid, _i, _len;
      nextGrid = this;
      for (_i = 0, _len = sourceDirections.length; _i < _len; _i++) {
        dir = sourceDirections[_i];
        nextGrid = nextGrid.applyMoveFrom(dir);
      }
      return nextGrid;
    };
    Grid.prototype.lowerSolutionBound = function() {
      /*
            This calculates a lower bound on the minimum
            number of steps required to solve the puzzle
      
            This is the sum of the rectilinear distances
            from where each number is to where it should
            be
          */      var colNum, moveCount, number, rowNum;
      if (!(this._lowerSolutionBound != null)) {
        moveCount = 0;
        for (rowNum in this.grid) {
          rowNum = parseInt(rowNum, 10);
          for (colNum in this.grid[rowNum]) {
            colNum = parseInt(colNum, 10);
            number = this.grid[rowNum][colNum];
            if (number === 0) {
              continue;
            }
            moveCount += rectilinearDistance(number, rowNum, colNum);
          }
        }
        this._lowerSolutionBound = moveCount;
      }
      return this._lowerSolutionBound;
    };
    Grid.prototype.isSolved = function() {
      return this.lowerSolutionBound() === 0;
    };
    Grid.prototype.log = function() {
      var row, _i, _len, _ref, _results;
      console.log("Empty: " + this.emptyPos);
      _ref = this.grid;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        row = _ref[_i];
        _results.push(console.log(JSON.stringify(row)));
      }
      return _results;
    };
    return Grid;
  })();
}).call(this);
