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

