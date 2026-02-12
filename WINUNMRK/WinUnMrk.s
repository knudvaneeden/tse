/*
   Macro          WinUnMrk
   Author         Carlo.Hogeveen@xs4all.nl
   Date           19 Aug 2004
   Compatibility  TSE 4.0 upwards.

   Even when you have TSE completely configured as a Windows-like tool,
   it still sometimes doesn't unmark a Windows block when using a direction
   key. A Windows block is what TSE calls a _non_inclusive_ block.

   Therefore this macro unmarks _non_inclusive_ blocks in the current file
   after using a direction key.

   Installation:
      Copy this file to TSE's "mac" directory.
      Compile it.
      Add "WinUnMrk" to TSE's Macro AutoLOad List.
      Restart TSE.
*/

integer block_buffer_id    = 0
integer block_begin_line   = 0
integer block_begin_column = 0
integer block_end_line     = 0
integer block_end_column   = 0

proc init_block_data()
   block_begin_line   = 0
   block_begin_column = 0
   block_end_line     = 0
   block_end_column   = 0
end

proc get_block_data(var integer block_begin_line  ,
                    var integer block_begin_column,
                    var integer block_end_line    ,
                    var integer block_end_column  )
   PushPosition()
   PushBlock()
   GotoBlockBegin()
   block_begin_line   = CurrLine()
   block_begin_column = CurrCol()
   GotoBlockEnd()
   block_end_line     = CurrLine()
   block_end_column   = CurrCol()
   PopPosition()
   PopBlock()
end

proc after_command()
   integer new_block_begin_line   = 0
   integer new_block_begin_column = 0
   integer new_block_end_line     = 0
   integer new_block_end_column   = 0
   if isBlockInCurrFile() == 2
      if block_buffer_id == GetBufferId()
         get_block_data(new_block_begin_line, new_block_begin_column,
                        new_block_end_line  , new_block_end_column  )
         if  block_begin_line   == new_block_begin_line
         and block_begin_column == new_block_begin_column
         and block_end_line     == new_block_end_line
         and block_end_column   == new_block_end_column
            if Query(Key) in <CursorUp>,    <GreyCursorUp>,
                             <CursorDown>,  <GreyCursorDown>,
                             <CursorLeft>,  <GreyCursorLeft>,
                             <CursorRight>, <GreyCursorRight>,
                             <PgUp>,        <GreyPgUp>,
                             <PgDn>,        <GreyPgDn>,
                             <Home>,        <GreyHome>,
                             <end>,         <GreyEnd>
               UnMarkBlock()
               init_block_data()
            endif
         else
            get_block_data(block_begin_line, block_begin_column,
                           block_end_line  , block_end_column  )
         endif
      else
         block_buffer_id = GetBufferId()
         get_block_data(block_begin_line, block_begin_column,
                        block_end_line  , block_end_column  )
      endif
   else
      block_buffer_id = 0
      init_block_data()
   endif
end

proc WhenLoaded()
   Hook(_AFTER_COMMAND_, after_command)
end

