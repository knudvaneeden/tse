/*

Author: Ross Boyd

===

A Tic Tac Toe game for TSE (just for fun)

Uses a recursive alphabeta minimax search algorithm.
The board is represented by 18 bits (stored in one 32bit integer).

The lower 0-8 bits are the X bits,
The upper 9-17 bits are the O bits

Win/loss/draw detection is accelerated by use of an encoded 62 byte bitmap
to quickly detect wins (and thus avoid iterating rows,cols and diagonals).
To see how this works look at IsWin() and Init()

*/

#define O_WINS 1
#define X_WINS 2
#define INFINITY 1000
#define MATE 100

 string gwin[64] = ""
 integer gb // The board is an integer using 18 bits
 integer gXtm // X to move?
 integer pc_side // The side the PC is playing...

// Returns number of bits set in an integer
 integer proc BitCount(integer b)
 integer c = 0
while (b)
b = b & (b - 1)
c = c + 1
endwhile
return(c)
end

// This is faster than testing
// each row,column and diagonal...
// Returns win/loss or no result
// Assumes at least one move has been made
 integer proc IsWin(integer i)
if GetBit(gwin,i & 111111111b )
return (X_WINS)
elseif GetBit(gwin,i shr 9)
return (O_WINS)
endif
return (0)
end

proc Init()
 integer i

// Initialise the win/loss bit string...
for i = 1 to 111110000b
ClearBit(gwin,i)
if ((i & 111000000b) == 111000000b)
or ((i & 000111000b) == 000111000b)
or ((i & 000000111b) == 000000111b)
or ((i & 100100100b) == 100100100b)
or ((i & 010010010b) == 010010010b)
or ((i & 001001001b) == 001001001b)
or ((i & 100010001b) == 100010001b)
or ((i & 001010100b) == 001010100b)
SetBit(gwin,i)
endif
endfor
end

// The b variable is an integer bit string
// The first 9 bits are the Xs
// and the next 9 bits are the O's
 proc DisplayBoard(integer b)
 integer i,piece_mask
 string c196[3] = chr(196)+chr(196)+chr(196)

PutOemStrXY(1,2,"   " + chr(179) + "   " + chr(179) + "   ")
PutOemStrXY(1,3,c196 + chr(197) + c196 + chr(197) + c196)
PutOemStrXY(1,4,"   " + chr(179) + "   " + chr(179) + "   ")
PutOemStrXY(1,5,c196 + chr(197) + c196 + chr(197) + c196)
PutOemStrXY(1,6,"   " + chr(179) + "   " + chr(179) + "   ")

for i = 1 to 9
VGotoXY(((i-1) mod 3)*4+2 ,(i-1)/3*2+2 )
piece_mask = 1 shl (i-1)
if b & piece_mask
PutStr("X",127)
elseif (b shr 9) & piece_mask
PutStr("O",126)
else
PutStr(Str(i),119)
endif
endfor

end

 proc NewGame()
gb = 0 // global board bitmap
gXtm = 1 // X always moves first
DisplayBoard(gb)
end

 proc MakeMove(integer move)
if gXtm // X is the lower 9 bits
gb = gb | (1 shl (move-1))
else // O is the higher 9 bits
gb = gb | (1 shl (move+8))
endif
gXtm = gXtm ^ 1 // change side to move
end

 proc TakeBack(integer b)
gb = b // reset board to previous move
gXtm = gXtm ^ 1 // change side to move
end

// Return a score from the POV
// of the side to move...
 integer proc eval()
 integer score = 0

case IsWin(gb)
when X_WINS
score = MATE
when O_WINS
score = -MATE
endcase

if not gXtm
score = -score
endif

return(score)

end

 integer proc ABsearch(integer alpha,integer beta, integer depth)
 integer b,legals,move,score,bestscore,movemask

score = eval()

if depth == 0 or abs(score) == MATE
return(score)
endif

b = gb // Save board so we can easily takeback

// Generate legal move bitmap by
// ORing upper 9 bits with lower 9 bits
legals = (~(b | (b shr 9))) & 111111111b

score = -INFINITY
bestscore = -INFINITY
move = 1
movemask = 1
while legals
if legals & movemask
legals = legals ^ movemask // Clear move from legal list

// Make the move and call alpha beta
MakeMove(move)
score = -ABsearch(-beta,-alpha,depth-1)
TakeBack(b)
if score > bestscore
bestscore = score
alpha = score
if score >= beta
return (score)
endif
endif
endif
move = move + 1
movemask = movemask + movemask
endwhile
return (bestscore)
end

// Generates Move Candidates
// Makes move
// Does search
// Unmakes move
 integer proc think2()
 integer b,bestmove,legals,MaxDepth,move,bestscore,score,movemask

bestmove = 0
b = gb // Save board so we can takeback

MaxDepth = 9-BitCount(gb)
bestscore = -INFINITY

// Generate legal move list
legals = (~(b | (b shr 9))) & 111111111b
move = 1
movemask = 1
while legals
if legals & movemask
legals = legals ^ movemask // Clear move from legal list
// Now make the move and call alpha beta
MakeMove(move)
score = -ABsearch(-INFINITY,INFINITY,MaxDepth-1)
if score > bestscore
bestscore = score
bestmove = move
endif
TakeBack(b)
endif
move = move + 1
movemask = movemask + movemask
endwhile

return (bestmove)
end


 proc GameLoop()
 integer k,move

repeat

if gXtm == pc_side
move = think2()
MakeMove(move)
else
k = GetKey()
case k
when <Escape>
break
when <1>..<9>
move = k - 48
if not (gb & (1 shl (move-1)) or (gb & (1 shl (move+8)))) // Empty Slot?
MakeMove(move)
endif
endcase
endif

DisplayBoard(gb)

until IsWin(gb) or BitCount(gb)==9

end

 proc Main()
 string prompt[1] = ""
 integer again
 Warn( "input a number between 1 and 9 if you are on play" )
Init()

repeat

if PopWinOpen(2,4,38,17,1,"Tic Tac TSE",Query(attr))

ClrScr()
NewGame()
VGotoXY(1,9)
PutStr("X goes first",127)
VGotoXY(1,11)
PutStr("Do you want to be X? (Y/n) ",127)

if lRead(prompt,1)
if prompt in "Y","y"," "
pc_side = gXtm ^ 1
else
pc_side = gXtm
endif
VGotoXY(1, 9)
ClrEol()
VGotoXY(1,11)
ClrEol()

GameLoop()

VGotoXY(1,9)
if IsWin(gb) == X_WINS
PutStr("X won!",127)
elseif IsWin(gb) == O_WINS
PutStr("O won!",127)
elseif BitCount(gb)==9
PutStr("Draw!",127)
endif
endif

VGotoXY(1,11)
PutStr("Do you want to play again? (Y/n) ",127)
again = false
if lRead(prompt,1)
again = (prompt in "Y","y")
endif

PopWinClose()
endif

until not again

end

<Ctrl T><Ctrl T> Main()
