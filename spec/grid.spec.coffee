describe 'originalPosition', ->
  it '''
    returns the original position of 8
  ''', ->
    expect(originalPosition(8)).toEqual([1,3])

  it '''
    returns the original position of 15
  ''', ->
    expect(originalPosition(15)).toEqual([3,2])

describe 'rectilinearDistance', ->
  check = (number, expected) ->
    for rowNum of expected
      rowNum = parseInt(rowNum, 10)
      for colNum of expected[rowNum]
        colNum = parseInt(colNum, 10)

        expectedDist = expected[rowNum][colNum]

        calculatedDist = rectilinearDistance(number, rowNum, colNum)
        expect(calculatedDist).toEqual expectedDist

  it '''
    returns as expected for all positions of 6
  ''', ->
    check 6, [
      [2, 1, 2, 3]
      [1, 0, 1, 2]
      [2, 1, 2, 3]
      [3, 2, 3, 4]
    ]

  it '''
    returns as expected for all positions of 12
  ''', ->
    check 12, [
      [5, 4, 3, 2]
      [4, 3, 2, 1]
      [3, 2, 1, 0]
      [4, 3, 2, 1]
    ]

describe 'Grid', ->
  testGrid = (new Grid([
    [1  , 2  , 3  , 4  ],
    [5  , 6  , 7  , 8  ],
    [9  , 10 , 0  , 11 ],
    [13 , 14 , 15 , 12 ]
  ], [2, 2]))

  describe '::applyMoveFrom', ->
    it 'returns a new, correctly modified grid', ->
      expect(testGrid.applyMoveFrom(LEFT).grid).toEqual([
        [1  , 2  , 3  , 4  ],
        [5  , 6  , 7  , 8  ],
        [9  , 0  , 10 , 11 ],
        [13 , 14 , 15 , 12 ]
      ])

      expect(testGrid.applyMoveFrom(RIGHT).grid).toEqual([
        [1  , 2  , 3  , 4  ],
        [5  , 6  , 7  , 8  ],
        [9  , 10 , 11 , 0  ],
        [13 , 14 , 15 , 12 ]
      ])

      expect(testGrid.applyMoveFrom(ABOVE).grid).toEqual([
        [1  , 2  , 3  , 4  ],
        [5  , 6  , 0  , 8  ],
        [9  , 10 , 7  , 11 ],
        [13 , 14 , 15 , 12 ]
      ])

      expect(testGrid.applyMoveFrom(BELOW).grid).toEqual([
        [1  , 2  , 3  , 4  ],
        [5  , 6  , 7  , 8  ],
        [9  , 10 , 15 , 11 ],
        [13 , 14 , 0  , 12 ]
      ])

  describe '::applyMoves', ->
      expect(testGrid.applyMoves([LEFT, LEFT]).grid).toEqual([
        [1  , 2  , 3  , 4  ],
        [5  , 6  , 7  , 8  ],
        [0  , 9  , 10 , 11 ],
        [13 , 14 , 15 , 12 ]
      ])


  describe '::lowerSolutionBound', ->
    it 'returns 0 for solved grid', ->
      expect((new Grid).lowerSolutionBound()).toEqual 0

    it 'returns 1 one move away from solution', ->
      for sourceDir in [LEFT, ABOVE]
        grid = (new Grid).applyMoveFrom sourceDir
        expect(grid.lowerSolutionBound()).toEqual 1

    it 'returns 2 two moves away from solution', ->
      for [dir1, dir2] in [[LEFT, ABOVE], [ABOVE, LEFT]]
        grid = (new Grid).
          applyMoveFrom(dir1).
          applyMoveFrom(dir2)

        expect(grid.lowerSolutionBound()).toEqual 2

    it 'returns as expected for a shuffled grid', ->
      expect(new Grid([
        [1  , 2  , 3  , 4  ],
        [5  , 6  , 7  , 11 ],
        [9  , 10 , 8  , 12 ],
        [13 , 14 , 15 , 0  ]
      ]).lowerSolutionBound()).toEqual 4
