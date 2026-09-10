/*****************************************************************************
  2 May 93: G. Grafton Cole                                  BLOCK FUNCTIONS

  I burned these macros into SE.  They cost bytes but I use the heck out of
    blocks.  They were hacked rather quickly and I am sure they can be
    improved and made more elegant, but I have not had time.
 ****************************************************************************/

integer                                  // global
   blockfill_mode,                  // block fill toggle flag
   blockoverwrite_mode,             // block overwrite toggle flag
   mark_flag                        // block begin mark flag

/*******************  Block Overwrite Toggle Flag *************************/
proc BlockOverwriteToggle()                   // Over write toggle
  blockoverwrite_mode = blockoverwrite_mode ^ 1
  set(ShowHelpLine, BlockOverWrite_mode | BlockFill_mode)
  Message("Block overwrite turned ", iif(blockoverwrite_mode, "ON", "OFF"))
end

/*******************  Block Fill Toggle Flag ******************************/
proc BlockFillToggle()                       // Fill toggle
  blockfill_mode = blockfill_mode ^ 1
  set(ShowHelpLine, BlockOverWrite_mode | BlockFill_mode)
  Message("Block fill turned ", iif(blockfill_mode, "ON", "OFF"))
end

/***************************************************************************
  Modified Block Copy:  a toggle determins type of copy
       when SET  blockoverwrite_mode:    copy overwrites existing text
       else:                             does a normal Block Copy

         _OVERWRITE_ works only with column block operations
 **************************************************************************/
proc mCopyBlock()
  if blockoverwrite_mode
    CopyBlock(_OVERWRITE_)
  else
    CopyBlock()
  endif
end

/***************************************************************************
  Modified Block Delete:  a toggle determins type of delete
       when SET  blockfill_mode:    deleted block is filled with spaces
       else:                        does a normal Block Delete
 **************************************************************************/
proc mDelBlock()
  if blockfill_mode
    FillBlock(" ")
  else
    DelBlock()
  endif
end

/***************************************************************************
  Modified Block Move:  two toggle determine type of move
       when set  blockfill_mode:         source block is filled with spaces
                 blockoverwrite_mode:    moved block overwrites existing text
       else:                             does a normal Block Move

    A char block must contain full lines ie, block begin and end must be
    in column 1, else overwrite is ignored.

         _OVERWRITE_ works only with column block operations
 **************************************************************************/
proc mMoveBlock()
  integer
       type = IsBlockMarked(),      // type of block
       temp_id,                     // temp buffer id
       curr_id = GetBufferId(),     // current file id
       num_lines,                   // number of lines in source block
       j = 1

  If not (BlockOverWrite_mode or BlockFill_mode)    // no fill or overwrite
     MoveBlock()                                    // do it and leave
     goto DONE
  endif

  PushPosition()                    // save TARGET block cursor position
  GotoBlockEnd()                    // save the position of the source
  PushPosition()                    //   block end
  GotoBlockBegin()                  // save the position of the source
  PushPosition()                    //   block start

  temp_id = CreateTempBuffer()      // create temp buffer
  CopyBlock()                       // copy source block to temp
  PushBlock()                       // save it
  num_lines = NumLines()             // get # lines in block

  GotoBufferId(curr_id)             // return current file
  PopPosition()                     // cursor to beginning source block

  if type == _COLUMN_               // COLUMN BLOCK
    CopyBlock(_OVERWRITE_)          // put source block back
    mDelBlock()                     // delete and/or fill
    KillPosition()                  // discard source block end cursor position
  else                              // CHR BLOCK
    MarkChar()                      // begin marking
    PopPosition()                   // end block cursor position
    MarkChar()
    mDelBlock()
  endif

  GotoBufferId(temp_id)             // back to temp
  PopBlock()                        // get block back

  GotoBufferId(curr_id)             // back to current file
  PopPosition()                     // back to target cursor position

  if BlockOverWrite_mode
    if type == _COLUMN_
      CopyBlock(_OVERWRITE_)
    else                            // CHR BLOCK
      CopyBlock()                   // overwrite only if the block contains
      GotoBlockEnd()                // full lines.  If the beginning or end
      if CurrCol() == 1             // of the block does not fall in column 1
        GotoBlockBegin()            // make no attempt to delete those areas
        if CurrCol() == 1           // that would have been covered by the
          Up()                      // block.  Should have use a column block!
          while j < num_lines
            DelLine()
            j = j + 1
            Up()
          endwhile
        endif
      endif
    endif
  else
    CopyBlock()
  endif

DONE:
end

/****************************************************************************
  An enhanced 'all in one' move.  You can move blocks all over heck and gone
    and not loose formating.  Saves setting all the toggles.

        Set Block Fill and Block Over Write Modes ON
        Moves the Block and then unmarks it
        Then flips Fill and Over Write Modes to OFF
 ****************************************************************************/
proc mMarkColumnMove()
   blockoverwrite_mode = 1        // force fill and overwrite true
   blockfill_mode = 1

   mMoveBlock()
   BlockOverwriteToggle()
   BlockFillToggle()
   UnMarkBlock()
end

/*****************************************************************************
  Save current Column block position when marking.  When assigned to a key you
    can return to the source block after moving it.
 ****************************************************************************/

proc mKN()
   mark_flag = mark_flag ^ 1
   if mark_flag                        // mark it only once
     PlaceMark("block")
   endif
   MarkColumn()
end

proc mKB()
   PlaceMark("block")
   MarkChar()
end

/************* If block marked print it else print entire file  **************/
proc mKP()
   If Query(BlockId)
      PrintBlock()
   else
      PrintFile()
   endif
end

/*-----------------------  END BLOCK MACROS  ------------------------------*/
