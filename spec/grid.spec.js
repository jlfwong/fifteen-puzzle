(function() {
  describe('originalPosition', function() {
    it('returns the original position of 8', function() {
      return expect(originalPosition(8)).toEqual([1, 3]);
    });
    return it('returns the original position of 15', function() {
      return expect(originalPosition(15)).toEqual([3, 2]);
    });
  });
  describe('rectilinearDistance', function() {
    var check;
    check = function(number, expected) {
      var calculatedDist, colNum, expectedDist, rowNum, _results;
      _results = [];
      for (rowNum in expected) {
        rowNum = parseInt(rowNum, 10);
        _results.push((function() {
          var _results2;
          _results2 = [];
          for (colNum in expected[rowNum]) {
            colNum = parseInt(colNum, 10);
            expectedDist = expected[rowNum][colNum];
            calculatedDist = rectilinearDistance(number, rowNum, colNum);
            _results2.push(expect(calculatedDist).toEqual(expectedDist));
          }
          return _results2;
        })());
      }
      return _results;
    };
    it('returns as expected for all positions of 6', function() {
      return check(6, [[2, 1, 2, 3], [1, 0, 1, 2], [2, 1, 2, 3], [3, 2, 3, 4]]);
    });
    return it('returns as expected for all positions of 12', function() {
      return check(12, [[5, 4, 3, 2], [4, 3, 2, 1], [3, 2, 1, 0], [4, 3, 2, 1]]);
    });
  });
  describe('Grid', function() {
    var testGrid;
    testGrid = new Grid([[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 0, 11], [13, 14, 15, 12]], [2, 2]);
    describe('::applyMoveFrom', function() {
      return it('returns a new, correctly modified grid', function() {
        expect(testGrid.applyMoveFrom(LEFT).grid).toEqual([[1, 2, 3, 4], [5, 6, 7, 8], [9, 0, 10, 11], [13, 14, 15, 12]]);
        expect(testGrid.applyMoveFrom(RIGHT).grid).toEqual([[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 0], [13, 14, 15, 12]]);
        expect(testGrid.applyMoveFrom(ABOVE).grid).toEqual([[1, 2, 3, 4], [5, 6, 0, 8], [9, 10, 7, 11], [13, 14, 15, 12]]);
        return expect(testGrid.applyMoveFrom(BELOW).grid).toEqual([[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 15, 11], [13, 14, 0, 12]]);
      });
    });
    describe('::applyMoves', function() {
      return expect(testGrid.applyMoves([LEFT, LEFT]).grid).toEqual([[1, 2, 3, 4], [5, 6, 7, 8], [0, 9, 10, 11], [13, 14, 15, 12]]);
    });
    return describe('::lowerSolutionBound', function() {
      it('returns 0 for solved grid', function() {
        return expect((new Grid).lowerSolutionBound()).toEqual(0);
      });
      it('returns 1 one move away from solution', function() {
        var grid, sourceDir, _i, _len, _ref, _results;
        _ref = [LEFT, ABOVE];
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          sourceDir = _ref[_i];
          grid = (new Grid).applyMoveFrom(sourceDir);
          _results.push(expect(grid.lowerSolutionBound()).toEqual(1));
        }
        return _results;
      });
      it('returns 2 two moves away from solution', function() {
        var dir1, dir2, grid, _i, _len, _ref, _ref2, _results;
        _ref = [[LEFT, ABOVE], [ABOVE, LEFT]];
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          _ref2 = _ref[_i], dir1 = _ref2[0], dir2 = _ref2[1];
          grid = (new Grid).applyMoveFrom(dir1).applyMoveFrom(dir2);
          _results.push(expect(grid.lowerSolutionBound()).toEqual(2));
        }
        return _results;
      });
      return it('returns as expected for a shuffled grid', function() {
        return expect(new Grid([[1, 2, 3, 4], [5, 6, 7, 11], [9, 10, 8, 12], [13, 14, 15, 0]]).lowerSolutionBound()).toEqual(4);
      });
    });
  });
}).call(this);
