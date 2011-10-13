@CELL_SIZE = 100

@ABOVE = 0
@RIGHT = 1
@LEFT  = 2
@BELOW = 3

directionToDelta = (direction) ->
  switch direction
    when ABOVE then [-1, 0]
    when RIGHT then [0, 1]
    when BELOW then [1, 0]
    when LEFT  then [0, -1]

@INIT_GRID = [
  [1  , 2  , 3  , 4  ]
  [5  , 6  , 7  , 8  ]
  [9  , 10 , 11 , 12 ]
  [13 , 14 , 15 , 0  ]
]

