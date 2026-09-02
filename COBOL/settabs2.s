/*
   Set tabs depending on whether this is a Cobol program or a Cobol copy,
   and for Cobol programs depending on the Cobol division.

   This macro is called by the macros Tab2 and BakSpac2.
*/


string data_division_tabs      [255] = "1 7 8 12 15 18 21 24 27 30 33 36 39 42 45 48 51 54 57 60 63 66 69 73 80"
string procedure_division_tabs [255] = "1 7 8 12 16 42 45 48 51 54 57 60 63 66 69 73 80"
string general_tabs            [255] = "1 7 8 12 15 18 21 24 27 30 33 36 39 42 45 48 51 54 57 60 63 66 69 73 80"


#define space 32

integer org_tabtype      = 0
integer org_tabwidth     = 0
string  org_vartabs [32] = ""

string coboltabs [255] = ""


// Copied from tabul21:
integer t_unit, t_bit
string vtab[32], s_unit[1]


proc save_org_tabs()
   org_tabtype    = query(tabtype)
   org_tabwidth   = query(tabwidth)
   org_vartabs    = query(vartabs)
end


proc restore_org_tabs()
   set(tabtype,  org_tabtype)
   set(tabwidth, org_tabwidth)
   set(vartabs,  org_vartabs)
end


proc overrule_coboltabs_with_smarttabs()
   integer empty_line      = true
   integer nww_counter     = 0
   integer end_counter     = 0
   integer last_smarttab   = 0
   integer cobol_counter   = 0
   integer back_lines       = 0
   string  smarttabs [255] = ""
   string  coboltab    [3] = ""

   PushPosition()

   while  empty_line
      and Up()

      EndLine()
      if CurrCol() <> 1
         empty_line = FALSE
      endif
   endwhile

   EndLine()
   end_counter = CurrCol()

   BegLine()
   smarttabs = "1"
   for nww_counter = 2 to end_counter
      if  CurrChar(nww_counter)     >  space
      and CurrChar(nww_counter - 1) <= space
         smarttabs = smarttabs + " " + Str(nww_counter)
      endif
   endfor

   end_counter = Val(GetToken(smarttabs, " ", 2)) - 1

   while  end_counter > 1
      and back_lines  < 250  // This limit improves performace for big sources.
      and Up()

      if PosFirstNonWhite() <= end_counter
         for nww_counter = end_counter downto 2
            if  CurrChar(nww_counter)     >  space
            and CurrChar(nww_counter - 1) <= space
               smarttabs = "1 " +  Str(nww_counter) + SubStr(smarttabs, 2, 254)
            endif
         endfor
         end_counter = Val(GetToken(smarttabs, " ", 2)) - 1
      endif

      back_lines = back_lines + 1
   endwhile

   PopPosition()

   last_smarttab = Val(GetToken(smarttabs, " ", NumTokens(smarttabs, " ")))

   repeat
      cobol_counter = cobol_counter + 1
      coboltab = GetToken(coboltabs, " ", cobol_counter)
   until coboltab == ""
      or Val(coboltab) > last_smarttab

   if coboltab == ""
      coboltabs = smarttabs
   else
      coboltabs = smarttabs
                + DelStr(coboltabs, 1, Pos(coboltab, coboltabs) - 2)
   endif
end


// Two proc's copied from tabul21:

// Bit manipulation routines:

string proc GetValue(integer colu)
    t_unit=(colu/8)+1             //Get vartab string element
    t_bit=(colu mod 8)            //Get bit of vartab string element
    vtab=Query(VarTabs)
    return(vtab[t_unit])
end

proc SetTab(integer colu)
    s_unit = GetValue(colu)
    s_unit = Chr(Asc(s_unit)|(1 shl t_bit))
    vtab=SubStr(vtab,1,t_unit-1)+s_unit+SubStr(vtab,t_unit+1,32)
    Set(VarTabs,vtab)
end


proc setvartabs()
   integer num_coboltabs = NumTokens(coboltabs, " ")
   integer tab = 0

   Set(VarTabs, TabSet(""))

   for tab = 1 to num_coboltabs
      settab(Val(GetToken(coboltabs, " ", tab)))
   endfor
end


proc settabs()

   string cobol_yn [1] = iif ((CurrExt() in ".cbl", ".cob"), "Y", "N")

   if cobol_yn == "N"
      if Lower(SubStr(SplitPath(CurrFilename(), _NAME_), 1, 3)) == "cpy"
         cobol_yn = "Y"
      endif
   endif

   if cobol_yn == "Y"
      PushPosition()
      Set(TabType, _VARIABLE_)
      if lFind("^...... #data #division", "ix")
         coboltabs = data_division_tabs
      else
         if lFind("^...... #procedure #division", "ix")
         or lFind(" (;)", "ig")                                  // In a copy.
            coboltabs = procedure_division_tabs
         else
            coboltabs = general_tabs
         endif
      endif
      PopPosition()

      if org_tabtype == _SMART_
         overrule_coboltabs_with_smarttabs()
      endif

      setvartabs()
   endif
end


proc Main()
   string parameter [6] = Lower(GetToken(Query(MacroCmdLine), " ", 1))

   case parameter
      when "set"
         save_org_tabs()
         settabs()
      when "reset"
         restore_org_tabs()
      otherwise
         Warn("Macro SETTABS received unknown parameter: ", parameter)
   endcase
end


