(function() {
  describe('SolverStateMinHeap', function() {
    return it('works correctly', function() {
      var q;
      q = new SolverStateMinHeap;
      q.enqueue({
        val: 1
      });
      q.enqueue({
        val: 7
      });
      q.enqueue({
        val: 5
      });
      q.enqueue({
        val: 19
      });
      expect(q.dequeue()).toEqual({
        val: 1
      });
      expect(q.dequeue()).toEqual({
        val: 5
      });
      expect(q.dequeue()).toEqual({
        val: 7
      });
      q.enqueue({
        val: 12
      });
      expect(q.dequeue()).toEqual({
        val: 12
      });
      return expect(q.dequeue()).toEqual({
        val: 19
      });
    });
  });
  describe('solve', function() {
    var expectSolution, expectToReverse, grid, size;
    expectSolution = function(_arg) {
      var done, expectedSolution, grid, solution;
      grid = _arg.forGrid, expectedSolution = _arg.toBe;
      done = false;
      solution = [];
      runs(function() {
        return solve(grid, {
          complete: function(_arg2) {
            var steps;
            steps = _arg2.steps;
            done = true;
            return solution = steps;
          },
          error: function(_arg2) {
            var msg;
            msg = _arg2.msg;
            return done = true;
          }
        });
      });
      waitsFor((function() {
        return done;
      }), 'solution to complete', 3000);
      return runs(function() {
        return expect(solution).toEqual(expectedSolution);
      });
    };
    it('returns [] for an already solved puzzle', function() {
      return expectSolution({
        forGrid: new Grid,
        toBe: []
      });
    });
    it('returns [RIGHT] for input [LEFT]', function() {
      var grid;
      grid = (new Grid).applyMoveFrom(LEFT);
      return expectSolution({
        forGrid: grid,
        toBe: [RIGHT]
      });
    });
    it('returns [BELOW] for input [ABOVE]', function() {
      var grid;
      grid = (new Grid).applyMoveFrom(ABOVE);
      return expectSolution({
        forGrid: grid,
        toBe: [BELOW]
      });
    });
    it('returns [RIGHT, RIGHT] for input [LEFT, LEFT]', function() {
      var grid;
      grid = (new Grid).applyMoveFrom(LEFT).applyMoveFrom(LEFT);
      return expectSolution({
        forGrid: grid,
        toBe: [RIGHT, RIGHT]
      });
    });
    it('returns [BELOW, BELOW] for input [ABOVE, ABOVE]', function() {
      var grid;
      grid = (new Grid).applyMoveFrom(ABOVE).applyMoveFrom(ABOVE);
      return expectSolution({
        forGrid: grid,
        toBe: [BELOW, BELOW]
      });
    });
    it('can solve a simple input', function() {
      return expectSolution({
        forGrid: new Grid([[0, 2, 3, 4], [1, 6, 7, 8], [5, 10, 11, 12], [9, 13, 14, 15]], [0, 0]),
        toBe: [BELOW, BELOW, BELOW, RIGHT, RIGHT, RIGHT]
      });
    });
    it('can solve a simple rotation', function() {
      return expectSolution({
        forGrid: new Grid([[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 15, 11], [13, 14, 0, 12]], [3, 2]),
        toBe: [ABOVE, RIGHT, BELOW]
      });
    });
    expectToReverse = function(grid, moveList, cb) {
      var done, shuffledGrid, solution;
      shuffledGrid = grid.applyMoves(moveList);
      done = false;
      solution = [];
      runs(function() {
        return solve(shuffledGrid, {
          complete: function(_arg) {
            var steps;
            steps = _arg.steps;
            if (cb != null) {
              cb();
            }
            done = true;
            return solution = steps;
          },
          error: function(_arg) {
            var msg;
            msg = _arg.msg;
            return done = true;
          }
        });
      });
      waitsFor((function() {
        return done;
      }), 'solution to complete', 3000);
      return runs(function() {
        var solvedGrid;
        solvedGrid = shuffledGrid.applyMoves(solution);
        return expect(solvedGrid.isSolved()).toBe(true);
      });
    };
    grid = new Grid;
    size = 5;
    while (size <= 35) {
      (function(size) {
        return it("can solve random shuffles of " + size + " moves", function() {
          var i, _results;
          console.warn("Solving 5 random shuffles of " + size + " moves");
          console.time("Size " + size);
          _results = [];
          for (i = 1; i <= 5; i++) {
            _results.push(expectToReverse(grid, randomMoveList(grid, size), function() {
              return console.timeEnd("Size " + size);
            }));
          }
          return _results;
        });
      })(size);
      size += 5;
    }
    it('can solve a 20 step sequence', function() {
      grid = new Grid;
      return expectToReverse(grid, [ABOVE, ABOVE, LEFT, LEFT, ABOVE, RIGHT, BELOW, LEFT, LEFT, BELOW, BELOW, RIGHT, ABOVE, RIGHT, RIGHT, BELOW, LEFT, LEFT, LEFT, ABOVE]);
    });
    return xit('can solve a 45 step sequence', function() {
      grid = new Grid;
      return expectToReverse(grid, [LEFT, LEFT, ABOVE, RIGHT, BELOW, RIGHT, ABOVE, ABOVE, LEFT, ABOVE, LEFT, LEFT, BELOW, BELOW, BELOW, RIGHT, ABOVE, RIGHT, BELOW, RIGHT, ABOVE, ABOVE, LEFT, LEFT, ABOVE, RIGHT, RIGHT, BELOW, LEFT, BELOW, LEFT, ABOVE, LEFT, ABOVE, RIGHT, BELOW, LEFT, ABOVE, RIGHT, RIGHT, BELOW, RIGHT, ABOVE, LEFT, BELOW]);
    });
  });
}).call(this);
