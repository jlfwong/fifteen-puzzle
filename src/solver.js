(function() {
  this.SolverState = (function() {
    function SolverState(grid, steps) {
      var lowerSolutionBound;
      this.grid = grid;
      lowerSolutionBound = this.grid.lowerSolutionBound();
      this.steps = [].concat(steps);
      this.solved = this.grid.isSolved();
      this.val = lowerSolutionBound + steps.length;
    }
    return SolverState;
  })();
  this.SolverStateMinHeap = (function() {
    SolverStateMinHeap.prototype.maxSize = 100000;
    function SolverStateMinHeap() {
      this.data = [];
    }
    SolverStateMinHeap.prototype.enqueue = function(pt) {
      this.data.push(pt);
      this.bubbleUp(this.data.length - 1);
      if (this.data.length === this.maxSize) {
        return this.data.pop();
      }
    };
    SolverStateMinHeap.prototype.dequeue = function() {
      var end, ret;
      ret = this.data[0];
      end = this.data.pop();
      if (this.data.length > 0) {
        this.data[0] = end;
        this.bubbleDown(0);
      }
      return ret;
    };
    SolverStateMinHeap.prototype.bubbleUp = function(curPos) {
      var cur, parent, parentPos;
      if (curPos === 0) {
        return;
      }
      parentPos = ~~((curPos - 1) / 2);
      cur = this.data[curPos];
      parent = this.data[parentPos];
      if (cur.val < parent.val) {
        this.data[curPos] = parent;
        this.data[parentPos] = cur;
        return this.bubbleUp(parentPos);
      }
    };
    SolverStateMinHeap.prototype.bubbleDown = function(curPos) {
      var cur, left, leftPos, right, rightPos, swapPos;
      leftPos = curPos * 2 + 1;
      rightPos = curPos * 2 + 2;
      cur = this.data[curPos];
      left = this.data[leftPos];
      right = this.data[rightPos];
      swapPos = null;
      if ((left != null) && left.val < cur.val) {
        swapPos = leftPos;
      }
      if ((right != null) && right.val < left.val && right.val < cur.val) {
        swapPos = rightPos;
      }
      if (swapPos != null) {
        this.data[curPos] = this.data[swapPos];
        this.data[swapPos] = cur;
        return this.bubbleDown(swapPos);
      }
    };
    SolverStateMinHeap.prototype.empty = function() {
      return this.data.length === 0;
    };
    return SolverStateMinHeap;
  })();
  this.solve = function(startGrid, _arg) {
    var candidates, complete, curState, error, frontier, grid, its, lastStep, nextGrid, nextState, nextSteps, sourceDirection, startState, steps, _results;
    complete = _arg.complete, error = _arg.error, frontier = _arg.frontier;
        if (complete != null) {
      complete;
    } else {
      complete = $.noop;
    };
        if (error != null) {
      error;
    } else {
      error = $.noop;
    };
    if (!(frontier != null)) {
      frontier = new SolverStateMinHeap;
      startState = new SolverState(startGrid, []);
      frontier.enqueue(startState);
    }
    its = 0;
    _results = [];
    while (!frontier.empty()) {
      its += 1;
      if (its > 1000) {
        window.setTimeout(function() {
          return solve(startGrid, {
            complete: complete,
            error: error,
            frontier: frontier
          });
        }, 10);
        return;
      }
      curState = frontier.dequeue();
      if (curState.solved) {
        steps = curState.steps;
        complete({
          steps: curState.steps,
          iterations: its
        });
        return;
      }
      grid = curState.grid;
      steps = curState.steps;
      candidates = _.shuffle(grid.validMoves());
      lastStep = _.last(steps);
      if (lastStep != null) {
        candidates = _(candidates).filter(function(x) {
          return !directionsAreOpposites(x, lastStep);
        });
      }
      _results.push((function() {
        var _i, _len, _results2;
        _results2 = [];
        for (_i = 0, _len = candidates.length; _i < _len; _i++) {
          sourceDirection = candidates[_i];
          nextGrid = grid.applyMoveFrom(sourceDirection);
          nextSteps = steps.concat([sourceDirection]);
          nextState = new SolverState(nextGrid, nextSteps);
          _results2.push(frontier.enqueue(nextState));
        }
        return _results2;
      })());
    }
    return _results;
  };
}).call(this);
