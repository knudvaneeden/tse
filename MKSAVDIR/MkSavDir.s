/*
   Macro          MkSavDir
   Author         Carlo.Hogeveen@xs4all.nl
   Date           24 jun 2007
   Compatibility  TSE Pro 2.5e upwards
   Version        1.0.0

   When you save a file with a non-existing directory in its path,
   this macro makes TSE offer to create that directory.

   Installation.
      Copy this file to TSE's "mac" directory, compile it,
      and execute it at least once to permanently enable/disable it.
*/




// The following determines the editor version at compile-time.
// Note: TSE Pro versions older than 2.5 don't understand compilation
//       directives (e.g. the "#ifdef"), giving a desired compiler error,
//       which should act as a clue to the user that this macro is not
//       compatible with TSE Pro versions older than 2.5.
#ifdef EDITOR_VERSION
   // From TSE Pro 3.0 upwards the built-in constant EDITOR_VERSION exists.
#else
   #ifdef WIN32
      // From TSE Pro 2.6 upwards the built-in constant WIN32 exists.
      #define EDITOR_VERSION 0x2800
      // TSE Pro < 2.5e and TSE Pro 2.6 are not supported by this macro.
      // Note: TSE 2.5e (the Dos version of TSE) has existed so long, that
      //       almost every Dos user has upgraded to it, so supporting older
      //       versions is no longer worth the effort. Due to a bug in
      //       TSE 2.5c (and presumably older TSE 2.5 versions (which is one
      //       of the reasons for not supporting them), the line below is
      //       syntax-checked despite the lack of WIN32 in those versions,
      //       and generates a desired compiler error, which should act as a
      //       clue to the user that this macro is not compatible with TSE
      //       2.5 thru 2.5c.
      // Note: TSE 2.6 was an intermediate 32-bits version from which anyone
      //       could freely upgrade to TSE 2.8. The parameter constant
      //       _MFSKIP_ exists since TSE 2.8, so the line below will
      //       correctly generate a desired compiler error for TSE 2.6,
      //       giving a clue to the user that this macro is not compatible
      //       with TSE 2.6.
      #define TSE_UNSUPPORTED_TEST _MFSKIP_
   #else
      // Since all other TSE versions were excluded, this must be TSE 2.5e.
      #define EDITOR_VERSION 0x2500
   #endif
#endif

string macroname [255] = ""
integer autoload_id = 0
integer mkdir_mode = 0

#if EDITOR_VERSION < 0x3000
   menu MsgBoxEx_menu()
      title = "Create directory?"
      history
      "&Yes"
      "&No"
      "N&ever"
      "&Allways"
   end
#endif

proc on_file_save()
   integer dir_no = 0
   string dir [255] = ""
   string parent_dir [255] = ""
   if  (Lower(SubStr(CurrFilename(), 1, 1)) in "a".."z")
   and        SubStr(CurrFilename(), 2, 1)  == ":"
      for dir_no = 1 to (NumTokens(CurrFilename(), "\") - 1)
         if dir_no == 1
            dir = GetToken(CurrFilename(), "\", 1)
         else
            if dir_no == 2
               parent_dir = dir + "\"
            else
               parent_dir = dir
            endif
            dir = dir + "\" + GetToken(CurrFilename(), "\", dir_no)
            if not FileExists(dir)
            and (   dir_no == 2
                 or FileExists(parent_dir))
               if mkdir_mode < 3
                  #if EDITOR_VERSION < 0x3000
                     Message("Create directory " + dir + " ?")
                     if Query(X1) < 4
                        Set(X1, 4)
                     endif
                     MsgBoxEx_menu()
                     mkdir_mode = MenuOption()
                  #else
                     mkdir_mode = MsgBoxEx("Saving " + CurrFilename(),
                                           "Create directory " + dir + " ?",
                                           "&Yes;  &No;  N&ever;  &Allways")
                  #endif
               endif
               if mkdir_mode in 1, 4
                  #if EDITOR_VERSION > 0x4000
                     MkDir(dir)
                  #else
                     Dos("mkdir " + dir, _DONT_PROMPT_|_DONT_CLEAR_)
                  #endif
               endif
            endif
         endif
      endfor
   endif
end

proc idle()
   mkdir_mode = 0
end

string proc is_autoloaded()
   string result [3] = "No"
   integer org_id = GetBufferId()
   PushBlock()
   if not autoload_id
      autoload_id = CreateTempBuffer()
   endif
   if autoload_id
      GotoBufferId(autoload_id)
      EmptyBuffer()
      InsertFile(LoadDir() + "TseLoad.dat", _DONT_PROMPT_)
      UnMarkBlock()
      if  CurrLineLen() > 1
      and lFind(macroname, "giw")
         result = "Yes"
      endif
   endif
   PopBlock()
   GotoBufferId(org_id)
   return(result)
end

proc toggle_autoloaded()
   if is_autoloaded() == "Yes"
      DelAutoLoadMacro(macroname)
   else
      AddAutoLoadMacro(macroname)
   endif
end

proc WhenLoaded()
   macroname = SplitPath(CurrFilename(), _NAME_)
   Hook(_ON_FILE_SAVE_, on_file_save)
   Hook(_IDLE_, idle)
end

menu configuration_menu()
   title = "MkSavDir Configuration"
   "&Offer to create non-existing directories when saving   "
      [is_autoloaded():3],
      toggle_autoloaded(),
      dontclose,
      "Should the editor offer to create non-existing directories when saving files"
end

proc configure()
   repeat
      configuration_menu()
   until MenuOption() == 0
   if Query(Beep)
      Alarm()
   endif
   Message(Format("...":-255:" "))
   Delay(9)
   if is_autoloaded() <> "Yes"
      Message("MkSavDir is disabled")
      PurgeMacro(macroname)
   else
      Message("MkSavDir is enabled")
   endif
   Delay(54)
end

proc Main()
   configure()
end

