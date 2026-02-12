/*

ÚÄÄÄÄÄÄÄÄÄ¿
³ MarkPal ³
ÀÄÄÄÄÄÄÄÄÄÙ

Title:  TSE macro implements: NextMark, PrevMark, ListMarks
Keywords: TSE 2.0 MACRO AUTOMATIC BOOKMARKS RING LIST

Is it difficult to keep track of all the BookMarks you have placed?
MarkPal implements a bookmark ring similar to the file ring. One key
will take you to the next or previous mark. Add a mark without need to
specify a letter for it (the next available letter will be used). The
ListMarks function displays a picklist of current bookmarks beside the
text of the corresponding lines.

Usage
ÄÄÄÄÄ

Here is a description of available functions, compatible with the PlaceMark()
and GotoMark() commands.

NEXTMARK:
Go to the next mark in alphabetical order.

PREVMARK:
As above, in reverse.

PLACEAUTOMARK:
Place a mark using the next available letter. A message will indicate which
letter was used.

LISTMARKS:
Display a picklist of current bookmarks. Beside each mark, the text of the
target line is displayed. Select a mark and hit <Enter> to go there.

ListMarks allows you to create a "hot index" to a documentation file. When
you save a bookmark, make shure that the cursor is positioned on a line
containing significant text (such as a title, table name...), since that text
will be displayed in the picklist.
(the index can be permanent if the bookmarks are saved to disk using the
companion macro:  FILEPAL)


Installation
ÄÄÄÄÄÄÄÄÄÄÄÄ

1) Copy MARKPAL.S to your macro directory (usually C:\TSE\MAC).

2) Load MARKPAL.S and edit the key definitions at the very end of this file to
   your preference.

3) Compile MARKPAL.S

4) I suggest you add this macro to your AutoLoad list.


                                            Jean Heroux
                                            CIS [73257,2074]
*/

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

integer curr_mark_no = 96

integer proc mMarkExists(integer mark_no)
    integer answer=FALSE, start_file = GetBufferId()
    PushPosition()
    if GotoMark(Chr(mark_no))
        answer=TRUE
    endif
    GotoBufferId(start_file)
    PopPosition()
    return(answer)
end

proc mPlaceAutoMark()
    integer new_mark_no = 97
    while mMarkExists(new_mark_no)
        new_mark_no = new_mark_no + 1
        if new_mark_no > 122
            Message('Too many marks')
            return()
        endif
    endwhile
    PlaceMark(Chr(new_mark_no))
    Message('Placed mark '+Chr(new_mark_no))
    curr_mark_no = new_mark_no
end

proc mPlaceMark(string mark_str)
    PlaceMark(mark_str)
    Message('Placed mark '+mark_str)
    curr_mark_no = Asc(mark_str)
end

proc mGotoMark(string mark_str)
    if GotoMark(mark_str)
        Message('Mark '+mark_str)
        curr_mark_no = Asc(mark_str)
        Message('Mark '+mark_str)
    else
        Message('Mark '+mark_str+' does not exist')
    endif
end

proc mPrevMark()
    integer i=0, to_mark_no = curr_mark_no
    repeat
        to_mark_no = iif(to_mark_no>97, to_mark_no-1, 122)
        i = i + 1
        if i > 27
            Message('No marks')
            return()
        endif
    until mMarkExists(to_mark_no)
    GotoMark(Chr(to_mark_no))
    curr_mark_no = to_mark_no
    Message('Mark '+Chr(curr_mark_no))
end

proc mNextMark()
    integer i=0, to_mark_no = curr_mark_no
    repeat
        to_mark_no = iif(to_mark_no<122, to_mark_no+1, 97)
        i = i + 1
        if i > 27
            Message('No marks')
            return()
        endif
    until mMarkExists(to_mark_no)
    GotoMark(Chr(to_mark_no))
    curr_mark_no = to_mark_no
    Message('Mark '+Chr(curr_mark_no))
end

proc mListMarks()
    integer i=97, start_file, mrk_list
    string texte[72]='', marque[1]=''
    start_file=GetBufferId()
    PushPosition()
    mrk_list=CreateTempBuffer()
    repeat
        if GotoMark(Chr(i))
            texte=GetText(1, CurrLineLen())
            GotoBufferId(mrk_list)
            AddLine()
            BegLine()
            marque=Chr(i)
            InsertText(marque+': '+texte)
        endif
        i=i+1
    until i > 122
    if NumLines()<1
        Message('Pas de marque')
        AbandonFile()
        GotoBufferId(start_file)
        PopPosition()
        return()
    endif
    BegFile()
    if List('Bookmarks', 76)
        marque=(GetText(1,1))
        AbandonFile()
        KillPosition()
        GotoMark(marque)
        Message('Mark '+marque)
        curr_mark_no = Asc(marque)
    else
        AbandonFile()
        PopPosition()
    endif
end

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//   Key definitions

<F9>                        mNextMark()
<Shift F9>                  mPrevMark()
<Ctrl F9>                   mPlaceAutoMark()
<Alt F9>                    mListMarks()

<Ctrl 0>                    PlaceMark()
<Alt  0>                    GotoMark()
