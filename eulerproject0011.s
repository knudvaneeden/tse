/*
   TSE SAL program
   Project Euler problem 11
   Greatest product of four adjacent numbers in a 20 x 20 grid

   Result:
   70600674
*/

integer proc GetCell(integer row, integer col)
    string s[80]
    integer p

    s = ''

    if row == 1
        s = '08 02 22 97 38 15 00 40 00 75 04 05 07 78 52 12 50 77 91 08'
    elseif row == 2
        s = '49 49 99 40 17 81 18 57 60 87 17 40 98 43 69 48 04 56 62 00'
    elseif row == 3
        s = '81 49 31 73 55 79 14 29 93 71 40 67 53 88 30 03 49 13 36 65'
    elseif row == 4
        s = '52 70 95 23 04 60 11 42 69 24 68 56 01 32 56 71 37 02 36 91'
    elseif row == 5
        s = '22 31 16 71 51 67 63 89 41 92 36 54 22 40 40 28 66 33 13 80'
    elseif row == 6
        s = '24 47 32 60 99 03 45 02 44 75 33 53 78 36 84 20 35 17 12 50'
    elseif row == 7
        s = '32 98 81 28 64 23 67 10 26 38 40 67 59 54 70 66 18 38 64 70'
    elseif row == 8
        s = '67 26 20 68 02 62 12 20 95 63 94 39 63 08 40 91 66 49 94 21'
    elseif row == 9
        s = '24 55 58 05 66 73 99 26 97 17 78 78 96 83 14 88 34 89 63 72'
    elseif row == 10
        s = '21 36 23 09 75 00 76 44 20 45 35 14 00 61 33 97 34 31 33 95'
    elseif row == 11
        s = '78 17 53 28 22 75 31 67 15 94 03 80 04 62 16 14 09 53 56 92'
    elseif row == 12
        s = '16 39 05 42 96 35 31 47 55 58 88 24 00 17 54 24 36 29 85 57'
    elseif row == 13
        s = '86 56 00 48 35 71 89 07 05 44 44 37 44 60 21 58 51 54 17 58'
    elseif row == 14
        s = '19 80 81 68 05 94 47 69 28 73 92 13 86 52 17 77 04 89 55 40'
    elseif row == 15
        s = '04 52 08 83 97 35 99 16 07 97 57 32 16 26 26 79 33 27 98 66'
    elseif row == 16
        s = '88 36 68 87 57 62 20 72 03 46 33 67 46 55 12 32 63 93 53 69'
    elseif row == 17
        s = '04 42 16 73 38 25 39 11 24 94 72 18 08 46 29 32 40 62 76 36'
    elseif row == 18
        s = '20 69 36 41 72 30 23 88 34 62 99 69 82 67 59 85 74 04 36 16'
    elseif row == 19
        s = '20 73 35 29 78 31 90 01 74 31 49 71 48 86 81 16 23 57 05 54'
    elseif row == 20
        s = '01 70 54 71 83 51 54 69 16 92 33 48 61 43 52 01 89 19 67 48'
    else
        return(0)
    endif

    p = 1 + (col - 1) * 3
    return(Val(SubStr(s, p, 2)))
end

proc Main()
    integer row
    integer col
    integer p
    integer maxP
    integer a
    integer b
    integer c
    integer d
    string bestDir[40]
    string bestNums[40]
    string bestPos[40]

    maxP = 0
    bestDir = ''
    bestNums = ''
    bestPos = ''

    for row = 1 to 20
        for col = 1 to 20

            if col <= 17
                a = GetCell(row, col)
                b = GetCell(row, col + 1)
                c = GetCell(row, col + 2)
                d = GetCell(row, col + 3)
                p = a * b * c * d
                if p > maxP
                    maxP = p
                    bestDir = 'right'
                    bestNums = Format(a, ' * ', b, ' * ', c, ' * ', d)
                    bestPos  = Format('row=', row, ', col=', col)
                endif
            endif

            if row <= 17
                a = GetCell(row, col)
                b = GetCell(row + 1, col)
                c = GetCell(row + 2, col)
                d = GetCell(row + 3, col)
                p = a * b * c * d
                if p > maxP
                    maxP = p
                    bestDir = 'down'
                    bestNums = Format(a, ' * ', b, ' * ', c, ' * ', d)
                    bestPos  = Format('row=', row, ', col=', col)
                endif
            endif

            if row <= 17 and col <= 17
                a = GetCell(row, col)
                b = GetCell(row + 1, col + 1)
                c = GetCell(row + 2, col + 2)
                d = GetCell(row + 3, col + 3)
                p = a * b * c * d
                if p > maxP
                    maxP = p
                    bestDir = 'diag down-right'
                    bestNums = Format(a, ' * ', b, ' * ', c, ' * ', d)
                    bestPos  = Format('row=', row, ', col=', col)
                endif
            endif

            if row <= 17 and col >= 4
                a = GetCell(row, col)
                b = GetCell(row + 1, col - 1)
                c = GetCell(row + 2, col - 2)
                d = GetCell(row + 3, col - 3)
                p = a * b * c * d
                if p > maxP
                    maxP = p
                    bestDir = 'diag down-left'
                    bestNums = Format(a, ' * ', b, ' * ', c, ' * ', d)
                    bestPos  = Format('row=', row, ', col=', col)
                endif
            endif

        endfor
    endfor

    Warn(Format('Greatest product = ', maxP))
    Warn(Format('Direction        = ', bestDir))
    Warn(Format('Start position    = ', bestPos))
    Warn(Format('Numbers           = ', bestNums))
end
