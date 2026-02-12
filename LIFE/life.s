/*
   Macro          Life
   Author         Carlo.Hogeveen@xs4all.nl
   Compatibility  TSE Pro v2.80h upwards
   Version        1.2.1   -   27 May 2020

   This macro macro implements Conway's well-known game of Life.

   Installation:
      Put this source in TSE's "mac" directory, and compile it.

   Usage:
      Just run the macro.

   Documentation:
      All built-in: run the macro, then read the status line.

   Tip:
      If you make your font smaller and/or maximize your TSE window before
      running Life, then you get a bigger universe.


   History

      1.0.0    3 December 2006
         Initial release.

      1.1.0    4 December 2006
         Added menu's to save/load universes, and to initialize a universe
         with nothing, with random cells, or with some predefined shapes.

      1.2.0    9 December 2006
         Added the Gosper Glider Gun, which eventually shoots itself.
         Significantly optimized the program and menu structure.

      1.2.1    27 May 2020
         No new features:
         Life was made compatible with TSE Pro v4.41.38 upwards.
*/

#ifdef EDITOR_VERSION
#else
   #define EDITOR_VERSION 2800h
#endif

FORWARD STRING PROC FNListS( STRING s )
FORWARD INTEGER PROC FNBlockChangeRleConvertToCellsFormatB( INTEGER buffer1I )
FORWARD STRING PROC FNStringGetInStringS( INTEGER maxI, STRING inS )

integer show_delay_duration = 54

integer old_id     = 0
integer new_id     = 0
integer life_cols  = 0
integer life_rows  = 0
integer generation = 0
string  mode  [10] = ""

proc show_help_line(string help_line)
   PutStrAttrXY(1,
                life_rows + 1,
                Format("   " + help_line : -1 * Query(ScreenCols)),
                "",
                Color(black ON white))
end

integer proc count_line_neighbours(integer x, integer y)
   integer result = 0
   GotoLine(y)
   if     x == 1
      result = Val(GetText(life_cols,1))+Val(GetText(x,1))+Val(GetText(x+1,1))
   elseif x == life_cols
      result = Val(GetText(x-1,1))+Val(GetText(x,1))+Val(GetText(1,1))
   else
      result = Val(GetText(x-1,1))+Val(GetText(x,1))+Val(GetText(x+1,1))
   endif
   return(result)
end

integer proc count_neighbours(integer x, integer y)
   integer result = 0
   GotoBufferId(old_id)
   if y == 1
      result = count_line_neighbours(x, life_rows)
             + count_line_neighbours(x, y)
             + count_line_neighbours(x, y + 1)
   elseif y == life_rows
      result = count_line_neighbours(x, y - 1)
             + count_line_neighbours(x, y)
             + count_line_neighbours(x, 1)
   else
      result = count_line_neighbours(x, y - 1)
             + count_line_neighbours(x, y)
             + count_line_neighbours(x, y + 1)
   endif
   GotoBufferId(new_id)
   return(result)
end

proc draw_life(string dead, string alive)
   integer x, y
   GotoBufferId(new_id)
   BufferVideo()
   Set(Attr, Color(bright white ON black))
   ClrScr()
   for y = 1 to life_rows
      GotoLine(y)
      for x = 1 to life_cols
         if Val(GetText(x, 1)) == 0
            PutCharXY((x * 2) - 1, y, dead)
         else
            PutCharXY((x * 2) - 1, y, alive)
         endif
      endfor
   endfor
   UnBufferVideo()
end

proc goto_wikipedia()
   integer org_id = GetBufferId()
   integer tmp_id = 0
   string tmp_dir [255] = GetEnvStr("tmp")
   if tmp_dir == ""
      tmp_dir = GetEnvStr("temp")
   endif
   if tmp_dir == ""
      Warn("Error: No directory environment variable TMP or TEMP defined")
      Warn('Work-around: google or wikipedia "conway life" yourself')
   elseif not EditFile(tmp_dir + "\tmp.html", _DONT_PROMPT_)
      Warn("Error: cannot open a file ", tmp_dir, "\tmp.html")
      Warn('Work-around: google or wikipedia "conway life" yourself')
   else
      tmp_id = GetBufferId()
      EmptyBuffer()
      AddLine("<html>")
      AddLine("   <head>")
      AddLine('      <meta http-equiv="refresh" content="3; url=http://en.wikipedia.org/wiki/Conway%27s_Game_of_Life">')
      AddLine("   </head>")
      AddLine("   <body>")
      AddLine("      <br> <br> <br> <br> <br>")
      AddLine('      <a href="http://en.wikipedia.org/wiki/Conway%27s_Game_of_Life">')
      AddLine("         Conway's Game of Life")
      AddLine("      </a>")
      AddLine("   </body>")
      AddLine("</html>")
      if not SaveAs(CurrFilename(), _OVERWRITE_|_DONT_PROMPT_)
         Warn("Error: cannot save a file ", tmp_dir, "\tmp.html")
         Warn('Work-around: google or wikipedia "conway life" yourself')
      else
         Dos(QuotePath(CurrFilename()), _DONT_PROMPT_|_DONT_CLEAR_)
      endif
      GotoBufferId(org_id)
      AbandonFile(tmp_id)
   endif
end

#if EDITOR_VERSION <= 4400h
   integer seed = 1

   integer proc random()
      integer lo, hi, test
      hi = seed  /  127773
      lo = seed mod 127773
      test = 16807 * lo - (2147483647 mod 16807) * hi
      if test > 0
         seed = test
      else
         seed = test + 2147483647
      endif
      return(seed)
   end
#endif

integer proc random_bit()
   return(random() mod 2)
end

proc pause(integer delay_duration)
   integer i = delay_duration
   while i > 0
   and not KeyPressed()
      if i < 18
         Delay(i)
         i = 0
      else
         Delay(18)
         i = i - 18
      endif
   endwhile
end

proc show_delay(integer delay_duration)
   integer i = show_delay_duration
   integer show_color = Color(black ON white)
   PopWinOpen(Query(ScreenCols) / 2 - 15,
              Query(ScreenRows) / 2 -  2,
              Query(ScreenCols) / 2 + 15,
              Query(ScreenRows) / 2 +  2,
              1,
              "Time delay per generation",
              show_color)
   Set(Attr, show_color)
   ClrScr()
   PutStrAttrXY(5,
                2,
                Format(delay_duration / 18,
                       ".",
                       (delay_duration mod 18) * 1000 / 18 :3:"0",
                       "   seconds"),
                "",
                show_color)
   repeat
      Delay(1)
      if KeyPressed()
         i = 0
      else
         i = i - 1
      endif
   until i == 0
   PopWinClose()
end

proc setup_universe(string name)
   integer row = 0
   integer col = 0
   STRING s[255] = ""
STRING s1[255] = "g:\mydownloadfiles\from_job_to_home\life\dddall\zweiback.cells" // change this
   INTEGER bufferI = 0
   INTEGER buffer_I = 0
   INTEGER bufferCurrentI = GetBufferId()
   INTEGER lineLengthI = 0
   INTEGER lineLengthLongestI = 0
   INTEGER B = FALSE
   PushPosition()
   PushBlock()
   bufferI = CreateTempBuffer()
   PopBlock()
   PopPosition()
   PushPosition()
   PushBlock()
   buffer_I = CreateTempBuffer()
   PopBlock()
   PopPosition()
   case name
      when "format: cells"
         //
         s1 = FNListS( "g:\mydownloadfiles\from_job_to_home\life\dddall\" ) // change this directory, it points to the folder where you unzipped the file https://conwaylife.com/patterns/all.zip into
         //
         IF ( Ask( ".cells or .rle filename to load = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 )
          //
          // insert the file
          //
          GotoBufferId( bufferI )
          InsertFile( s1 )
          //
          // convert .rle to .cells
          //
          GotoBufferId( bufferI )
          IF EquiStr( SplitPath( s1, _EXT_ ), ".rle" )
           PushPosition()
           PushBlock()
           MarkLine( 1, NumLines() )
           B = FNBlockChangeRleConvertToCellsFormatB( buffer_I )
           GotoBufferId( buffer_I )
           IF ( NOT B )
            Warn( "Error: conversion of .rle to .cells had an issue. Please check" )
           ENDIF
           GotoBufferId( buffer_I )
           MarkLine( 1, NumLines() )
           CopyToWinClip()
           GotoBufferId( bufferI )
           MarkLine( 1, NumLines() )
           Cut()
           PasteFromWinClip()
           PopBlock()
           PopPosition()
          ENDIF
          //
          // get the longest line
          //
          GotoBufferId( bufferI )
          BegFile()
          DO NumLines() TIMES
           IF ( LFind( "0", "cg" ) OR LFind( "1", "cg" ) OR LFind( ".", "cg" ) OR LFind( "O", "cg" ) ) AND ( NOT LFind( "!", "cg" ) )
            LineLengthI = CurrLineLen()
            IF ( LineLengthLongestI <  LineLengthI )
             LineLengthLongestI = LineLengthI
            ENDIF
           ENDIF
           Down()
          ENDDO
          //
          // if the total linelength of the given pattern in the .cells file is greater than the current column width in the original buffer, then redraw the raster with zeroes
          //
          GotoBufferId( bufferCurrentI )
          IF LineLengthLongestI > life_cols
           life_cols = lineLengthLongestI
           EmptyBuffer()
           for row = 1 to life_rows
            AddLine(Format("":life_cols:"0"), old_id)
            AddLine(Format("":life_cols:"0"), new_id)
           endfor
          ENDIF
          //
          // Goto the default home location in the original buffer
          //
          GotoBufferId( bufferCurrentI )
          GotoLine  (1)
          GotoColumn(1)
          //
          // get the .cells lines, replace to default "0" and "1" if applicable
          //
          GotoBufferId( bufferI )
          BegFile()
          REPEAT
           IF NOT LFind( "^$", "cgx" ) // skip empty lines
            IF ( LFind( "0", "cg" ) OR LFind( "1", "cg" ) OR LFind( ".", "cg" ) OR LFind( "O", "cg" ) ) AND ( NOT LFind( "!", "cg" ) )
             UpDateDisplay() // IF WaitForKeyPressed( 0 ) ENDIF // Activate if using a loop
             s = GetText( 1, MAXSTRINGLEN )
             s = Trim( s )
             s = StrReplace( ".", s, "0", "" ) // replace dots '.' with zeroes '0' (which is the default zero here)
             s = StrReplace( "O", s, "1", "" ) // replace 'O' with ones '1' (which is the default 1 here)
             // s = Format( s : -lineLengthLongestI : "0" )
             s = Format( s : - life_cols : "0" )
             // Warn( s ) // debug
             AddLine( s, bufferCurrentI )
            ENDIF
           ENDIF
          UNTIL NOT Down()
          AbandonFile( bufferI )
          AbandonFile( buffer_I )
          GotoBufferId( bufferCurrentI )
          //
         ENDIF
         //
      when "empty"
         generation = 0
         EmptyBuffer()
         for row = 1 to life_rows
            AddLine(Format("":life_cols:"0"), old_id)
            AddLine(Format("":life_cols:"0"), new_id)
         endfor
      when "random"
         #if EDITOR_VERSION <= 4400h
            seed = (GetClockTicks() mod 99999) + 1
         #endif
         EmptyBuffer()
         for row = 1 to life_rows
            AddLine("")
            BegLine()
            for col = 1 to life_cols
               InsertText(Str(random_bit()))
            endfor
         endfor
      when "glider gun: gosper"
         GotoLine  (1)
         GotoColumn(1)
         InsertText("000000000000000000000000100000000000") Down() Left(36)
         InsertText("000000000000000000000010100000000000") Down() Left(36)
         InsertText("000000000000110000001100000000000011") Down() Left(36)
         InsertText("000000000001000100001100000000000011") Down() Left(36)
         InsertText("110000000010000010001100000000000000") Down() Left(36)
         InsertText("110000000010001011000010100000000000") Down() Left(36)
         InsertText("000000000010000010000000100000000000") Down() Left(36)
         InsertText("000000000001000100000000000000000000") Down() Left(36)
         InsertText("000000000000110000000000000000000000") Down() Left(36)
      when "glider gun: simkin"
         GotoLine  (1)
         GotoColumn(1)
         InsertText("OO11111OO111111111111111111111111") Down() Left(33)
         InsertText("OO11111OO111111111111111111111111") Down() Left(33)
         InsertText("111111111111111111111111111111111") Down() Left(33)
         InsertText("1111OO111111111111111111111111111") Down() Left(33)
         InsertText("1111OO111111111111111111111111111") Down() Left(33)
         InsertText("111111111111111111111111111111111") Down() Left(33)
         InsertText("111111111111111111111111111111111") Down() Left(33)
         InsertText("111111111111111111111111111111111") Down() Left(33)
         InsertText("111111111111111111111111111111111") Down() Left(33)
         InsertText("1111111111111111111111OO1OO111111") Down() Left(33)
         InsertText("111111111111111111111O11111O11111") Down() Left(33)
         InsertText("111111111111111111111O111111O11OO") Down() Left(33)
         InsertText("111111111111111111111OOO111O111OO") Down() Left(33)
         InsertText("11111111111111111111111111O111111") Down() Left(33)
         InsertText("111111111111111111111111111111111") Down() Left(33)
         InsertText("111111111111111111111111111111111") Down() Left(33)
         InsertText("111111111111111111111111111111111") Down() Left(33)
         InsertText("11111111111111111111OO11111111111") Down() Left(33)
         InsertText("11111111111111111111O111111111111") Down() Left(33)
         InsertText("111111111111111111111OOO111111111") Down() Left(33)
         InsertText("11111111111111111111111O111111111") Down() Left(33)
      when "methuselah: acorn"
         GotoLine  (life_rows / 2 - 1)
         GotoColumn(life_cols / 2 - 4)
         InsertText("0100000") Down() Left(7)
         InsertText("0001000") Down() Left(7)
         InsertText("1100111") Down() Left(7)
      when "methuselah: diehard"
         GotoLine  (life_rows / 2 - 1)
         GotoColumn(life_cols / 2 - 4)
         InsertText("00000010") Down() Left(8)
         InsertText("11000010") Down() Left(8)
         InsertText("01000111") Down() Left(8)
      when "methuselah: r-pentomino"
         GotoLine  (life_rows / 2 - 1)
         GotoColumn(life_cols / 2 - 4)
         InsertText("011") Down() Left(3)
         InsertText("110") Down() Left(3)
         InsertText("010") Down() Left(3)
      when "oscillator: beacon"
         GotoLine  (life_rows / 2 - 1)
         GotoColumn(life_cols / 2 - 1)
         InsertText("1100") Down() Left(4)
         InsertText("1000") Down() Left(4)
         InsertText("0001") Down() Left(4)
         InsertText("0011") Down() Left(4)
      when "oscillator: blinker"
         GotoLine  (life_rows / 2 - 1)
         GotoColumn(life_cols / 2 - 1)
         InsertText("010") Down() Left(3)
         InsertText("010") Down() Left(3)
         InsertText("010") Down() Left(3)
      when "oscillator: pentadecathlon"
         GotoLine  (life_rows / 2 - 1)
         GotoColumn(life_cols / 2 - 1)
         InsertText("0010000100") Down() Left(10)
         InsertText("1101111011") Down() Left(10)
         InsertText("0010000100") Down() Left(10)
      when "oscillator: pulsar"
         GotoLine  (life_rows / 2 - 1)
         GotoColumn(life_cols / 2 - 1)
         InsertText("0011100011100") Down() Left(13)
         InsertText("0000000000000") Down() Left(13)
         InsertText("1000010100001") Down() Left(13)
         InsertText("1000010100001") Down() Left(13)
         InsertText("1000010100001") Down() Left(13)
         InsertText("0011100011100") Down() Left(13)
         InsertText("0000000000000") Down() Left(13)
         InsertText("0011100011100") Down() Left(13)
         InsertText("1000010100001") Down() Left(13)
         InsertText("1000010100001") Down() Left(13)
         InsertText("1000010100001") Down() Left(13)
         InsertText("0000000000000") Down() Left(13)
         InsertText("0011100011100") Down() Left(13)
      when "oscillator: toad"
         GotoLine  (life_rows / 2 - 1)
         GotoColumn(life_cols / 2 - 1)
         InsertText("0111") Down() Left(4)
         InsertText("1110") Down() Left(4)
      when "spaceship: glider"
         GotoLine  (life_rows / 2 - 1)
         GotoColumn(life_cols / 2 - 1)
         InsertText("111") Down() Left(3)
         InsertText("100") Down() Left(3)
         InsertText("010") Down() Left(3)
      when "spaceship: hwss"
         GotoLine  (life_rows / 2 - 2)
         GotoColumn(life_cols / 2 - 2)
         InsertText("000100") Down() Left(6)
         InsertText("010001") Down() Left(6)
         InsertText("100000") Down() Left(6)
         InsertText("100001") Down() Left(6)
         InsertText("111110") Down() Left(6)
      when "spaceship: lwss"
         GotoLine  (life_rows / 2 - 2)
         GotoColumn(life_cols / 2 - 2)
         InsertText("01001") Down() Left(5)
         InsertText("10000") Down() Left(5)
         InsertText("10001") Down() Left(5)
         InsertText("11110") Down() Left(5)
      when "spaceship: mwss"
         GotoLine  (life_rows / 2 - 2)
         GotoColumn(life_cols / 2 - 2)
         InsertText("000100") Down() Left(6)
         InsertText("010001") Down() Left(6)
         InsertText("100000") Down() Left(6)
         InsertText("100001") Down() Left(6)
         InsertText("111110") Down() Left(6)
      when "still life: beehive"
         GotoLine  (life_rows / 2 - 1)
         GotoColumn(life_cols / 2 - 4)
         InsertText("0110") Down() Left(4)
         InsertText("1001") Down() Left(4)
         InsertText("0110") Down() Left(4)
      when "still life: block"
         GotoLine  (life_rows / 2 - 1)
         GotoColumn(life_cols / 2 - 4)
         InsertText("11") Down() Left(2)
         InsertText("11") Down() Left(2)
      when "still life: boat"
         GotoLine  (life_rows / 2 - 1)
         GotoColumn(life_cols / 2 - 4)
         InsertText("110") Down() Left(3)
         InsertText("101") Down() Left(3)
         InsertText("010") Down() Left(3)
      when "still life: loaf"
         GotoLine  (life_rows / 2 - 1)
         GotoColumn(life_cols / 2 - 4)
         InsertText("0110") Down() Left(4)
         InsertText("1001") Down() Left(4)
         InsertText("0101") Down() Left(4)
         InsertText("0010") Down() Left(4)
      when "still life: tub"
         GotoLine  (life_rows / 2 - 1)
         GotoColumn(life_cols / 2 - 4)
         InsertText("010") Down() Left(3)
         InsertText("101") Down() Left(3)
         InsertText("010") Down() Left(3)
   endcase
   draw_life(".", "*")
end

proc general_help()
   show_help_line("Close the browser to continue ...")
   goto_wikipedia()
   // draw_life(".", "*")
end

proc save_universe()
   SaveAs()
end

proc load_universe()
   EmptyBuffer()
   BegFile()
   InsertFile()
   UnMarkBlock()
end

proc set_mode(string new_mode)
   mode = new_mode
end

menu file_menu()
   history
   "&Save", save_universe(),,"Save the universe"
   "&Load", load_universe(),,"Load a universe"
end

menu initialize_menu()
   history
   "select a .cells or .rle f&Ile"              , setup_universe("format: cells")
   "", , divide
   "&Empty (clear the screen)"                  , setup_universe("empty")
   "", , divide
   "&Random (generate random pattern)"          , setup_universe("random")
   "", , divide
   "Glider gun: G&Osper"                        , setup_universe("glider gun: gosper")
   "Glider gun: Sim&Kin"                        , setup_universe("glider gun: simkin")
   "", , divide
   "Methusalah: A&Corn (5206 generations)"      , setup_universe("methuselah: acorn")
   "Methusalah: &Diehard (130 generations)"     , setup_universe("methuselah: diehard")
   "Methusalah: R&-pentomino"                   , setup_universe("methuselah: r-pentomino")
   "", , divide
   "Oscillator: &Beacon"                        , setup_universe("oscillator: beacon")
   "Oscilla&Tor: blinker"                       , setup_universe("oscillator: blinker")
   "Oscillator: &Pentadecathlon"                , setup_universe("oscillator: pentadecathlon")
   "Oscillator: p&Ulsar"                        , setup_universe("oscillator: pulsar")
   "Oscillator: to&Ad"                          , setup_universe("oscillator: toad")
   "", , divide
   "&Glider Space Ship"                         , setup_universe("spaceship: glider")
   "Light &Weight Space Ship (LWSS)"            , setup_universe("spaceship: mwss")
   "&Middle Weight Space Ship (MWSS)"           , setup_universe("spaceship: lwss")
   "&Heavy Weight Space Ship (HWSS)"            , setup_universe("spaceship: hwss")
   "", , divide
   "Still life: &1. Block"                      , setup_universe("still life: block")
   "Still life: &2. Beehive"                    , setup_universe("still life: beehive")
   "Still life: &3. Load"                       , setup_universe("still life: loaf")
   "Still life: &4. Boat"                       , setup_universe("still life: boat")
   "Still life: &5. Tub"                        , setup_universe("still life: tub")
   "", , divide
   "Information: &6. Wikipedia: Game of Life"   , StartPgm( "https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life" )
   "Information: &7. 1500 Game of Life patterns", StartPgm( "https://conwaylife.com/wiki/Category:Patterns" )
end

menu help_menu()
   history
   "&General help", general_help()
   "&About", Warn("Life v1.1.0 released 4 Dec 2006 by Carlo.Hogeveen@xs4all.nl at http://www.xs4all.nl/~hyphen/tse")
end

menu main_menu()
   history
   "&Initialize" , initialize_menu(), _MF_DONT_CLOSE_, "Big Bang?"
   "&Run"        , set_mode("run")  ,                , "Start a new Life"
   "&File"       , file_menu()      , _MF_DONT_CLOSE_, "Save or Load a universe"
   "&Help"       , help_menu()      , _MF_DONT_CLOSE_, "Get help with your life"
   "&Quit"       , set_mode("quit") ,                , "Quit the program"
end

proc Main()
   integer org_id = GetBufferId()
   integer old_attr = Set(Attr, Color(bright white ON black))
   integer old_cursor = Set(Cursor, OFF)
   integer old_insert = Set(Insert, OFF)
   integer x, y, mouse_x, mouse_y
   // integer delay_duration = 18
   // integer delay_duration = 1 // new [kn, ri, su, 17-04-2022 22:40:15]
   integer delay_duration = 0 // new [kn, ri, su, 17-04-2022 22:40:15]
   integer prev_clockticks = 0
   ClrScr()
   life_cols = Query(ScreenCols) / 2
   life_rows = Query(ScreenRows) - 1
   old_id = CreateTempBuffer()
   new_id = CreateTempBuffer()
   setup_universe("empty")
   PushKey( <F10> ) // new [kn, ri, su, 17-04-2022 22:40:07]
   repeat
      mode = "edit"
      repeat
         draw_life(".", "*")
         show_help_line(Format(generation,
            "   MouseLeft = (De)Select   MouseRight/F10 = Menu"))
         GetKey()
         case Query(Key)
            when <e>
             setup_universe("empty")
            when <f10>, <RightBtn>, <i>
               GotoBufferId(new_id)
               main_menu()
            when <LeftBtn>
               mouse_x = Query(MouseX)
               mouse_y = Query(MouseY)
               if mouse_x mod 2 <> 0
                  GotoBufferId(new_id)
                  GotoLine(mouse_y)
                  GotoColumn((mouse_x / 2) + 1)
                  if GetText(CurrCol(), 1) == "0"
                     InsertText("1")
                  else
                     InsertText("0")
                  endif
               endif
            when <r> // new [kn, ri, su, 17-04-2022 23:18:58]
             mode = "run" // new [kn, ri, su, 17-04-2022 23:19:01]
            when <Escape>
               mode = "quit"
         endcase
      until mode <> "edit"
      while mode == "run"
         if KeyPressed()
            GetKey()
            case Query(Key)
               when <f>, <F>
                  if GetClockTicks() - prev_clockticks < show_delay_duration
                     if delay_duration > 0
                        delay_duration = delay_duration - 1
                     endif
                  endif
                  prev_clockticks = GetClockTicks()
                  show_delay(delay_duration)
               when <s>, <S>
                  if GetClockTicks() - prev_clockticks < show_delay_duration
                     delay_duration = delay_duration + 1
                  endif
                  prev_clockticks = GetClockTicks()
                  show_delay(delay_duration)
               when <Escape>
                  mode = "quit"
               otherwise
                  mode = "edit"
            endcase
         else
            repeat
               draw_life(" ", "*")
               show_help_line(Format(generation,
                  "   F = Faster   S = Slower   OtherKey = EditMode"))
               pause(delay_duration)
               GotoBufferId(new_id)
               MarkLine(1, NumLines())
               Copy()
               GotoBufferId(old_id)
               EmptyBuffer()
               Paste()
               UnMarkBlock()
               GotoBufferId(new_id)
               for y = 1 to life_rows
                  GotoLine(y)
                  for x = 1 to life_cols
                     if Val(GetText(x, 1)) == 1
                        if not ((count_neighbours(x, y) - 1) in 2, 3)
                           GotoColumn(x)
                           InsertText("0")
                        endif
                     else
                        if count_neighbours(x, y) == 3
                           GotoColumn(x)
                           InsertText("1")
                        endif
                     endif
                  endfor
               endfor
               generation = generation + 1
            until KeyPressed()
               or mode <> "run"
         endif
      endwhile
   until mode == "quit"
   Set(Attr  , old_attr)
   Set(Cursor, old_cursor)
   Set(Insert, old_insert)
   GotoBufferId(org_id)
   AbandonFile(old_id)
   AbandonFile(new_id)
   UpdateDisplay(_ALL_WINDOWS_REFRESH_)
   PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end

STRING PROC FNListS( STRING directoryS )
 //
 STRING s[255] = ""
 //
 INTEGER bufferI = 0
 //
 PushPosition()
 bufferI = CreateTempBuffer()
 PopPosition()
 //
 PushPosition()
 PushBlock()
 GotoBufferId( bufferI )
 //
 InsertFile( "g:\mydownloadfiles\from_job_to_home\life\data.txt" ) // this is the full path to a file containing only the (.cells or .rle) filename. Change this on your system.
 //
 GotoLine( 1 )
 IF List( "Choose an .cells filename", 80 )
  s = Trim( GetText( 1, 255 ) )
 ELSE
  AbandonFile( bufferI )
  RETURN( "" )
 ENDIF
 AbandonFile( bufferI )
 PopBlock()
 PopPosition()
 //
 RETURN( Format( AddTrailingSlash( directoryS ), s ) )
 //
END

// library: block: change: rle: convert: to: cells: format <description></description> <version control></version control> <version>1.0.0.0.20</version> <version control></version control> (filenamemacro=chanblcf.s) [<Program>] [<Research>] [kn, ri, tu, 19-04-2022 01:41:38]
INTEGER PROC FNBlockChangeRleConvertToCellsFormatB( INTEGER bufferI )
 // e.g. PROC Main()
 // e.g.  INTEGER bufferI = 0
 // e.g.  PushPosition()
 // e.g.  bufferI = CreateTempBuffer()
 // e.g.  PopPosition()
 // e.g.  Message( FNBlockChangeRleConvertToCellsFormatB( bufferI ) ) // gives e.g. TRUE
 // e.g.  GotoBufferId( bufferI )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // ===
 //
 // Use case =
 //
 // ===
 //
 // ===
 //
 // Method =
 //
 //  If no integer number in front then that is the same as an integer number 1 to use
 //
 //  Otherwise if an integer number in front then that is the integer number to use
 //
 //  Then extract all the 'o' 'b' combinations after that number until found another number, or a '$' or a '!'
 //
 // ===
 //
 // Use STRING$ to multiply the found 'o' and 'b' strings an integer number of times.
 //
 // Maybe 'Format()' will be the simplest to implement BbcBasic STRING$.
 //
 // ===
 //
 // See also book: 'Algorithms + Data structures = Programs' by Niklaus Wirth about Backus Naur form (=BNF): Railroad diagram and 'Extended Backus Naur Form' (=EBNF)
 //
 // ===
 //
 // 'Extended Backus Naur Form' (=EBNF)
 //
 //   ( number? ( b | o )+ $? )+ !
 //
 /*
--- cut here: begin --------------------------------------------------
--- cut here: end ----------------------------------------------------
 */
 //
 // ===
 //
 // Regular expression
 //
 //  {{b}|{o}|{[0-9]#}|{\$}|{!}}
 //
 //  // {b|o|{[0-9]+}|\$|!}#\c
 //
 //  // {b|o|[0-9]|\$|!}#\c
 //
 //  // {{[0-9]+}?}{{b|o|[$]}#}\c
 //
 //  // {{[0-9]+}?}{{b|o}#}\c
 //
 //  // {{[0-9]+}?}{{b|o}#}\c
 //
 //  // {{{[0-9]#}?{{b|o}#}[$]?}#}\c
 //
 //  // {{{[0-9]#}?{{b|o}#}[$]}#}\c
 //
 //  // {{{[0-9]#}?{{b|o}#}[$]}#}{[!]?}\c
 //
 //  // {{{[0-9]#}?{{b|o}#}[$]?}#}{[!]?}\c
 //
 //  // {{{[0-9]+}?{{b|o}+}[$]?}+}{[!]?}\c
 //
 // ===
 //
 //  Backus Naur form (=BNF): Railroad diagram:
 //
 // Run Time Length Encoding (=RLE) ::==
 //
 //     +----------------------------------------------+
 //     |                                              |
 //     |                                              |
 //     |                                              |
 //  ->-+->-+->-[number]->-+->-+->-(b)->-+->-+->-($)->-+->-(!)->-
 //         |              |   |         |   |         |
 //         +->------------+   +->-(o)->-+   +->-------+
 //
 // ===
 //
 // number ::=
 //
 //    +-----------------+
 //    |                 |
 // ->-+->-+->-(0)->-+->-+->-
 //        |         |
 //        +->-(1)->-+
 //        |         |
 //        +->-(2)->-|
 //        |         |
 //        +->-(3)->-+
 //        |         |
 //        +->-(4)->-+
 //        |         |
 //        +->-(5)->-|
 //        |         |
 //        +->-(6)->-+
 //        |         |
 //        +->-(7)->-+
 //        |         |
 //        +->-(8)->-|
 //        |         |
 //        +->-(9)->-+
 //
 // ===
 //
 //  source code to get a number
 //
 //    REPEAT
 //     get character
 //    UNTIL NOT found 0..9
 //
 // ===
 //
 // Steps to create a parser for this particular language (=Run Length Encoding (=RLE))
 //
 //  1. -Once you have the railroad diagram, go from left to right through this railroad diagram
 //
 //  2. -Take each building block (e.g. IF, WHILE, CASE, REPEAT, ...)
 //
 //  3. -And (linearly) replace it with the equivalent (TSE) language construct (e.g. IF, WHILE, CASE, REPEAT, ...)
 //
 //  4. -That will you a simplest possible interpreter to analyze such strings.
 //
 // ===
 //
 // Direct linear translation of the railroad diagram to source code
 //
 // WHILE NOT found (!)
 //  //
 //  IF found [number]
 //   //
 //   get number
 //   //
 //  ENDIF
 //  //
 //  CASE character
 //   //
 //   WHEN "o"
 //   // do something
 //   WHEN "b"
 //    // do something
 //  ENDCASE
 //  //
 //  UNTIL NOT found (b) AND NOT found (o)
 //  //
 //  IF found ($)
 //   //
 //   get character
 //   //
 //  ENDIF
 //  //
 // ENDWHILE
 //
 // ===
 //
 // Example:
 //
 // Input:
 //
 // Input:
 //
 //   b2o$2o$bo!
 //
 //    This run length encoding (=rle) notation means first a '.', then followed by 2 'O' then followed by a 'new line ($)'.
 //    Then starting with 2 'O', followed by a new line,
 //    Then starting with a '.' and followed by an 'O'.
 //
 //    So in general only 1 'o' or 'b' after the number has to be taken, not more than 1 thus.
 //
 //    The '!' means that it is finished
 //
 //    So this converts into .cell format as follows:
 //
 //     .OO
 //     OO
 //     .O
 //
 //     Or thus in zero one format as follows:
 //
 //     011
 //     11
 //     01
 //
 /*
--- cut here: begin --------------------------------------------------
b2o$2o$bo!
--- cut here: end ----------------------------------------------------
 */
 //
 // Output:
 //
 /*
--- cut here: begin --------------------------------------------------
.OO
OO
.O
--- cut here: end ----------------------------------------------------
 */
 //
 // Input:
 //
 /*
--- cut here: begin --------------------------------------------------
     25ob3oo!
     25o
     bobbbbbbbboooooo
     24bo$22bobo$12b2o6b2o12b2o$11bo3bo4b2o12b2o$2o8bo5bo3b2o$2o8bo3bob2o4bobo$10bo
     5bo7bo$11bo3bo$12b2o!
--- cut here: end ----------------------------------------------------
 */
 //
 // Output:
 //
 /*
--- cut here: begin --------------------------------------------------
--- cut here: end ----------------------------------------------------
 */
 //
 // ===
 //
 INTEGER B = TRUE
 //
 INTEGER downB = TRUE
 //
 INTEGER lineLengthI = 0
 //
 STRING s1[255] = ""
 STRING s2[255] = ""
 STRING s3[255] = ""
 //
 INTEGER I = 0
 //
 IF ( NOT ( IsBlockInCurrFile() ) ) Warn( "Please mark a block" ) B = FALSE RETURN( B ) ENDIF // return from the current procedure if no block is marked
 //
 Set( BREAK, ON )
 //
 PushPosition()
 PushBlock()
 //
 GotoBlockBegin()
 //
 WHILE ( ( IsCursorInBlock() ) AND ( downB ) )
  //
  // regular expression which checks if this is a Run Length Encoding (=RLE) line
  //
  IF ( NOT ( LFind( "^[ ]*\#", "cgx" ) ) ) AND ( NOT ( LFind( "^[ ]*x", "cgx" ) ) )
   //
   BegLine()
   //
   lineLengthI = CurrLineLen()
   //
   WHILE ( NOT ( Chr( CurrChar() ) == "!" ) ) AND ( NOT ( CurrCol() >= lineLengthI ) )
    //
    // skip spaces
    //
    WHILE ( Chr( CurrChar() ) == " " )
     //
     Right()
     //
    ENDWHILE
    //
    // get the integer number
    //
    s1 = ""
    //
    IF ( Chr( CurrChar() ) IN '0'..'9' )
     //
     REPEAT
      //
      s1 = Format( s1, Chr( CurrChar() ) )
      //
      Right()
      //
     UNTIL NOT ( Chr( CurrChar() ) IN '0'..'9' )
     //
    ENDIF
    //
    s2 = ""
    //
    CASE Chr( CurrChar() )
     //
     WHEN "b"
      //
      s2 = Format( s2, "." )
      //
     WHEN "o"
      //
      s2 = Format( s2, "O" )
     //
    ENDCASE
    //
    Right()
    //
    IF ( s1 == "" )
     //
     I = 1
     //
    ELSE
     //
     I = Val( s1 )
     //
    ENDIF
    //
    s3 = FNStringGetInStringS( I, s2 )
    //
    PushPosition()
    PushBlock()
    GotoBufferId( bufferI )
    EndLine()
    InsertText( s3, _INSERT_ )
    PopBlock()
    PopPosition()
    //
    IF ( Chr( CurrChar() ) == "$" )
     //
     PushPosition()
     PushBlock()
     GotoBufferId( bufferI )
     AddLine()
     BegLine()
     PopBlock()
     PopPosition()
     //
    ENDIF
    //
   ENDWHILE
   //
  ENDIF
  //
  downB = Down()
  //
 ENDWHILE
 //
 B = TRUE
 //
 PopPosition()
 PopBlock()
 //
 RETURN( B )
 //
END

// library: string: get: in: string <description>create concatenated duplicates of a certain string (STRING$ in BBCBASIC)</description> <version>1.0.0.0.7</version> <version control></version control> (filenamemacro=getstist.s) [<Program>] [<Research>] [kn, zoe, th, 20-05-1999 11:25:55]
STRING PROC FNStringGetInStringS( INTEGER maxI, STRING inS )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = "3" // change this
 // e.g.  STRING s2[255] = "a" // change this
 // e.g.  IF ( NOT ( Ask( "string: get: copy: create concatenated duplicates of a certain string: totalT = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.  IF ( NOT ( Ask( "string: get: copy: create concatenated duplicates of a certain string: string = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 // e.g.  Warn( FNStringGetInStringS( Val( s1 ), s2 ) ) // gives "aaa"
 // e.g.  Warn( FNStringGetInStringS( 15, "0" ) ) // gives "000000000000000"
 // e.g.  Warn( FNStringGetInStringS( 3, " " ) ) // gives "   "
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER minI = 1
 //
 INTEGER I = 0
 //
 STRING s[255] = ""
 //
 IF ( maxI <= 0 )
  //
  RETURN( "" )
  //
 ENDIF // minimum 1 character width block or more to insert
 //
 FOR I = minI TO maxI
  //
  s = Format( s, inS )
  //
 ENDFOR
 //
 RETURN( s )
 //
END
