@ABOVE = "ABOVE"
@RIGHT = "RIGHT"
@LEFT  = "LEFT"
@BELOW = "BELOW"

@directionToDelta = (direction) ->
  switch direction
    when ABOVE then [-1, 0]
    when RIGHT then [0, 1]
    when BELOW then [1, 0]
    when LEFT  then [0, -1]

@directionsAreOpposites = (a, b) ->
    [adr, adc] = directionToDelta a
    [bdr, bdc] = directionToDelta b
    return (adr + bdr == 0) && (adc + bdc == 0)

@INIT_GRID = [
  [1  , 2  , 3  , 4  ]
  [5  , 6  , 7  , 8  ]
  [9  , 10 , 11 , 12 ]
  [13 , 14 , 15 , 0  ]
]

