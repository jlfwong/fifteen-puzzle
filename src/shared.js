(function() {
  this.ABOVE = "ABOVE";
  this.RIGHT = "RIGHT";
  this.LEFT = "LEFT";
  this.BELOW = "BELOW";
  this.directionToDelta = function(direction) {
    switch (direction) {
      case ABOVE:
        return [-1, 0];
      case RIGHT:
        return [0, 1];
      case BELOW:
        return [1, 0];
      case LEFT:
        return [0, -1];
    }
  };
  this.directionsAreOpposites = function(a, b) {
    var adc, adr, bdc, bdr, _ref, _ref2;
    _ref = directionToDelta(a), adr = _ref[0], adc = _ref[1];
    _ref2 = directionToDelta(b), bdr = _ref2[0], bdc = _ref2[1];
    return (adr + bdr === 0) && (adc + bdc === 0);
  };
  this.INIT_GRID = [[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12], [13, 14, 15, 0]];
}).call(this);
