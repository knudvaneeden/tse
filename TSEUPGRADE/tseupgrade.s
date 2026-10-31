// TSEUPGRADE version 1.0.0.0.53
// Created: 2026-10-31 18:43:55
// Settings menus follow the supplied latex.s Options/Configure pattern.
// No external menu helper macros are required.
STRING configIniS[255] = ""
STRING cfgUnattendedS[255] = "false"
INTEGER configDirtyI = FALSE, configDoneI = FALSE, launchRequestedI = FALSE, cancelRequestedI = FALSE
STRING cfgOldVersionS[255] = ""
STRING cfgNewVersionS[255] = ""
STRING cfgOldDirectoryS[255] = ""
STRING cfgNewDirectoryS[255] = ""
STRING cfgArchiveFileS[255] = ""
STRING cfgDownloadUrlS[255] = ""
STRING cfgInstallerExeS[255] = ""
STRING cfgUiFileS[255] = ""
STRING cfgUiDestinationS[255] = ""
STRING cfgCfgFileS[255] = ""
STRING cfgCfgDestinationS[255] = ""
STRING cfgCustomMacroDirectoryS[255] = ""
STRING cfgCuamarkFileS[255] = ""
STRING cfgWorkingDirectoryS[255] = ""
STRING cfgStartupMacroS[255] = ""
STRING cfgTsePathS[255] = ""
STRING cfgKbdPathS[255] = ""
STRING cfgEditorExeS[255] = ""
STRING cfgCompilerExeS[255] = ""
STRING cfgPreparationCompilerExeS[255] = ""
STRING cfgPowershellExeS[255] = ""
STRING cfgCfgDataFileS[255] = ""
STRING cfgOldCompileDataS[255] = ""
STRING cfgNewCompileDataS[255] = ""
STRING cfgSilentS[255] = ""
STRING cfgCopydisplayS[255] = ""
STRING cfgCopyetaS[255] = ""
STRING cfgCompileetaS[255] = ""
STRING cfgExportCfgS[255] = ""
STRING cfgMergeCompileDataS[255] = ""
STRING cfgPreparationWaitSecondsS[255] = ""
STRING cfgGeneratedMacroLaunchDelaySecondsS[255] = ""
STRING cfgLogFileS[255] = ""

STRING PROC ConfigPreview(STRING valueS)
 IF valueS == ""
  RETURN("<blank>")
 ENDIF
 IF Length(valueS) > 38
  RETURN("..." + RightStr(valueS, 35))
 ENDIF
 RETURN(valueS)
END

PROC EditConfigText(VAR STRING valueS, STRING promptS)
 STRING editedS[255] = valueS
 IF Ask(promptS, editedS)
  IF editedS <> valueS
   valueS = editedS
   configDirtyI = TRUE
  ENDIF
 ENDIF
END

PROC ToggleConfigBool(VAR STRING valueS)
 IF Lower(valueS) == "true"
  valueS = "false"
 ELSE
  valueS = "true"
 ENDIF
 configDirtyI = TRUE
END

PROC EditConfigNumber(VAR STRING valueS, STRING promptS)
 STRING editedS[255] = valueS
 INTEGER validI, charI
 LOOP
  IF NOT Ask(promptS + " (0..300 seconds)", editedS)
   RETURN()
  ENDIF
  validI = Length(editedS) > 0 AND Length(editedS) <= 3
  FOR charI = 1 TO Length(editedS)
   IF NOT (Asc(editedS[charI]) IN 48..57)
    validI = FALSE
   ENDIF
  ENDFOR
  IF validI AND Val(editedS) <= 300
   IF editedS <> valueS
    valueS = editedS
    configDirtyI = TRUE
   ENDIF
   RETURN()
  ENDIF
  Warn("Enter a whole number from 0 through 300.")
 ENDLOOP
END

PROC EditCopyDisplay()
 STRING editedS[255] = cfgCopydisplayS
 LOOP
  IF NOT Ask("Copy display: all, summary or none", editedS)
   RETURN()
  ENDIF
  editedS = Lower(editedS)
  IF editedS IN "all", "summary", "none"
   IF editedS <> cfgCopydisplayS
    cfgCopydisplayS = editedS
    configDirtyI = TRUE
   ENDIF
   RETURN()
  ENDIF
  Warn("Enter all, summary or none.")
 ENDLOOP
END

PROC ReadConfigSettings()
 cfgUnattendedS = GetProfileStr("tseupgrade", "unattended", "false", configIniS)
 cfgOldVersionS = GetProfileStr("tseupgrade", "old_version", "", configIniS)
 cfgNewVersionS = GetProfileStr("tseupgrade", "new_version", "", configIniS)
 cfgOldDirectoryS = GetProfileStr("tseupgrade", "old_directory", "", configIniS)
 cfgNewDirectoryS = GetProfileStr("tseupgrade", "new_directory", "", configIniS)
 cfgArchiveFileS = GetProfileStr("tseupgrade", "archive_file", "", configIniS)
 cfgDownloadUrlS = GetProfileStr("tseupgrade", "download_url", "", configIniS)
 cfgInstallerExeS = GetProfileStr("tseupgrade", "installer_exe", "tse.exe", configIniS)
 cfgUiFileS = GetProfileStr("tseupgrade", "ui_file", "", configIniS)
 cfgUiDestinationS = GetProfileStr("tseupgrade", "ui_destination", "", configIniS)
 cfgCfgFileS = GetProfileStr("tseupgrade", "cfg_file", "", configIniS)
 cfgCfgDestinationS = GetProfileStr("tseupgrade", "cfg_destination", "", configIniS)
 cfgCustomMacroDirectoryS = GetProfileStr("tseupgrade", "custom_macro_directory", "", configIniS)
 cfgCuamarkFileS = GetProfileStr("tseupgrade", "cuamark_file", "", configIniS)
 cfgStartupMacroS = GetProfileStr("tseupgrade", "startup_macro", "knudstar", configIniS)
 cfgWorkingDirectoryS = GetProfileStr("tseupgrade", "working_directory", "", configIniS)
 cfgTsePathS = GetProfileStr("tseupgrade", "tse_path", "", configIniS)
 cfgKbdPathS = GetProfileStr("tseupgrade", "kbd_path", "", configIniS)
 cfgEditorExeS = GetProfileStr("tseupgrade", "editor_exe", "g32.exe", configIniS)
 cfgCompilerExeS = GetProfileStr("tseupgrade", "compiler_exe", "sc32.exe", configIniS)
 cfgPreparationCompilerExeS = GetProfileStr("tseupgrade", "preparation_compiler_exe", "", configIniS)
 cfgPowershellExeS = GetProfileStr("tseupgrade", "powershell_exe", "", configIniS)
 cfgCfgDataFileS = GetProfileStr("tseupgrade", "cfg_data_file", "tsecfg.dat", configIniS)
 cfgOldCompileDataS = GetProfileStr("tseupgrade", "old_compile_data", "", configIniS)
 cfgNewCompileDataS = GetProfileStr("tseupgrade", "new_compile_data", "compile.dat", configIniS)
 cfgSilentS = GetProfileStr("tseupgrade", "silent", "false", configIniS)
 cfgCopydisplayS = GetProfileStr("tseupgrade", "copydisplay", "none", configIniS)
 cfgCompileetaS = GetProfileStr("tseupgrade", "compileeta", "true", configIniS)
 cfgCopyetaS = GetProfileStr("tseupgrade", "copyeta", "true", configIniS)
 cfgExportCfgS = GetProfileStr("tseupgrade", "export_cfg", "true", configIniS)
 cfgMergeCompileDataS = GetProfileStr("tseupgrade", "merge_compile_data", "true", configIniS)
 cfgPreparationWaitSecondsS = GetProfileStr("tseupgrade", "preparation_wait_seconds", "5", configIniS)
 cfgGeneratedMacroLaunchDelaySecondsS = GetProfileStr("tseupgrade", "generated_macro_launch_delay_seconds", "5", configIniS)
 cfgLogFileS = GetProfileStr("tseupgrade", "log_file", "", configIniS)
 configDirtyI = FALSE
END

INTEGER PROC WriteOneSetting(STRING keyS, STRING valueS)
 WriteProfileStr("tseupgrade", keyS, valueS, configIniS)
 IF GetProfileStr("tseupgrade", keyS, "<write failed>", configIniS) <> valueS
  Warn("Could not verify setting: ", keyS, " in ", configIniS)
  RETURN(FALSE)
 ENDIF
 RETURN(TRUE)
END

INTEGER PROC SaveConfigSettings()
 INTEGER okI = TRUE
 IF NOT WriteOneSetting("unattended", cfgUnattendedS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("old_version", cfgOldVersionS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("new_version", cfgNewVersionS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("old_directory", cfgOldDirectoryS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("new_directory", cfgNewDirectoryS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("archive_file", cfgArchiveFileS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("download_url", cfgDownloadUrlS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("installer_exe", cfgInstallerExeS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("ui_file", cfgUiFileS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("ui_destination", cfgUiDestinationS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("cfg_file", cfgCfgFileS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("cfg_destination", cfgCfgDestinationS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("custom_macro_directory", cfgCustomMacroDirectoryS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("cuamark_file", cfgCuamarkFileS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("startup_macro", cfgStartupMacroS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("working_directory", cfgWorkingDirectoryS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("tse_path", cfgTsePathS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("kbd_path", cfgKbdPathS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("editor_exe", cfgEditorExeS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("compiler_exe", cfgCompilerExeS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("preparation_compiler_exe", cfgPreparationCompilerExeS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("powershell_exe", cfgPowershellExeS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("cfg_data_file", cfgCfgDataFileS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("old_compile_data", cfgOldCompileDataS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("new_compile_data", cfgNewCompileDataS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("silent", cfgSilentS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("copydisplay", cfgCopydisplayS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("compileeta", cfgCompileetaS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("copyeta", cfgCopyetaS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("export_cfg", cfgExportCfgS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("merge_compile_data", cfgMergeCompileDataS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("preparation_wait_seconds", cfgPreparationWaitSecondsS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("generated_macro_launch_delay_seconds", cfgGeneratedMacroLaunchDelaySecondsS)
  okI = FALSE
 ENDIF
 IF NOT WriteOneSetting("log_file", cfgLogFileS)
  okI = FALSE
 ENDIF
 IF okI
  configDirtyI = FALSE
  Message("Saved upgrade settings: ", configIniS)
 ENDIF
 RETURN(okI)
END

PROC SaveAndReturnConfig()
 IF SaveConfigSettings()
  configDoneI = TRUE
 ENDIF
END

PROC DiscardConfig()
 ReadConfigSettings()
 configDoneI = TRUE
END

MENU ConfigInstallationMenu()
 Title = "TSEUPGRADE - Installation"
 Width = 70
 History
 "Old version                 " [ConfigPreview(cfgOldVersionS):38], EditConfigText(cfgOldVersionS, "Old version"), _MF_Dont_Close_
 "New version                 " [ConfigPreview(cfgNewVersionS):38], EditConfigText(cfgNewVersionS, "New version"), _MF_Dont_Close_
 "Old installation directory  " [ConfigPreview(cfgOldDirectoryS):38], EditConfigText(cfgOldDirectoryS, "Old installation directory"), _MF_Dont_Close_
 "NEW installation directory  " [ConfigPreview(cfgNewDirectoryS):38], EditConfigText(cfgNewDirectoryS, "NEW installation directory"), _MF_Dont_Close_
 "Installer ZIP filename      " [ConfigPreview(cfgArchiveFileS):38], EditConfigText(cfgArchiveFileS, "Installer ZIP filename"), _MF_Dont_Close_
 "Download URL                " [ConfigPreview(cfgDownloadUrlS):38], EditConfigText(cfgDownloadUrlS, "Download URL"), _MF_Dont_Close_
 "Installer executable        " [ConfigPreview(cfgInstallerExeS):38], EditConfigText(cfgInstallerExeS, "Installer executable"), _MF_Dont_Close_
END

MENU ConfigPersonalMenu()
 Title = "TSEUPGRADE - Personal"
 Width = 70
 History
 "Old UI source               " [ConfigPreview(cfgUiFileS):38], EditConfigText(cfgUiFileS, "Old UI source"), _MF_Dont_Close_
 "NEW UI destination          " [ConfigPreview(cfgUiDestinationS):38], EditConfigText(cfgUiDestinationS, "NEW UI destination"), _MF_Dont_Close_
 "Old CFG source              " [ConfigPreview(cfgCfgFileS):38], EditConfigText(cfgCfgFileS, "Old CFG source"), _MF_Dont_Close_
 "NEW CFG destination         " [ConfigPreview(cfgCfgDestinationS):38], EditConfigText(cfgCfgDestinationS, "NEW CFG destination"), _MF_Dont_Close_
 "Personal macro directory    " [ConfigPreview(cfgCustomMacroDirectoryS):38], EditConfigText(cfgCustomMacroDirectoryS, "Personal macro directory"), _MF_Dont_Close_
 "Cuamark source              " [ConfigPreview(cfgCuamarkFileS):38], EditConfigText(cfgCuamarkFileS, "Cuamark source"), _MF_Dont_Close_
 "Personal startup macro      " [ConfigPreview(cfgStartupMacroS):38], EditConfigText(cfgStartupMacroS, "Personal startup macro (-e)"), _MF_Dont_Close_
 "Startup working directory   " [ConfigPreview(cfgWorkingDirectoryS):38], EditConfigText(cfgWorkingDirectoryS, "Startup working directory"), _MF_Dont_Close_
 "New TSEPath                 " [ConfigPreview(cfgTsePathS):38], EditConfigText(cfgTsePathS, "New TSEPath"), _MF_Dont_Close_
 "New KbdPath                 " [ConfigPreview(cfgKbdPathS):38], EditConfigText(cfgKbdPathS, "New KbdPath"), _MF_Dont_Close_
END

MENU ConfigExecutablesMenu()
 Title = "TSEUPGRADE - Executables"
 Width = 70
 History
 "Editor executable           " [ConfigPreview(cfgEditorExeS):38], EditConfigText(cfgEditorExeS, "Editor executable"), _MF_Dont_Close_
 "Compiler executable         " [ConfigPreview(cfgCompilerExeS):38], EditConfigText(cfgCompilerExeS, "Compiler executable"), _MF_Dont_Close_
 "Preparation compiler        " [ConfigPreview(cfgPreparationCompilerExeS):38], EditConfigText(cfgPreparationCompilerExeS, "Preparation compiler"), _MF_Dont_Close_
 "PowerShell executable       " [ConfigPreview(cfgPowershellExeS):38], EditConfigText(cfgPowershellExeS, "PowerShell executable"), _MF_Dont_Close_
 "Settings DAT filename       " [ConfigPreview(cfgCfgDataFileS):38], EditConfigText(cfgCfgDataFileS, "Settings DAT filename"), _MF_Dont_Close_
 "Old compiler DAT source     " [ConfigPreview(cfgOldCompileDataS):38], EditConfigText(cfgOldCompileDataS, "Old compiler DAT source"), _MF_Dont_Close_
 "NEW compiler DAT filename   " [ConfigPreview(cfgNewCompileDataS):38], EditConfigText(cfgNewCompileDataS, "NEW compiler DAT filename"), _MF_Dont_Close_
END

MENU ConfigBehaviorMenu()
 Title = "TSEUPGRADE - Behavior"
 Width = 70
 History
 "Unattended upgrade steps   " [ConfigPreview(cfgUnattendedS):38], ToggleConfigBool(cfgUnattendedS), _MF_Dont_Close_
 "Hide introductory message   " [ConfigPreview(cfgSilentS):38], ToggleConfigBool(cfgSilentS), _MF_Dont_Close_
 "Copy display mode           " [ConfigPreview(cfgCopydisplayS):38], EditCopyDisplay(), _MF_Dont_Close_
 "Show compile time estimate  " [ConfigPreview(cfgCompileetaS):38], ToggleConfigBool(cfgCompileetaS), _MF_Dont_Close_
 "Show copy time estimate     " [ConfigPreview(cfgCopyetaS):38], ToggleConfigBool(cfgCopyetaS), _MF_Dont_Close_
 "Export NEW CFG              " [ConfigPreview(cfgExportCfgS):38], ToggleConfigBool(cfgExportCfgS), _MF_Dont_Close_
 "Merge compiler data         " [ConfigPreview(cfgMergeCompileDataS):38], ToggleConfigBool(cfgMergeCompileDataS), _MF_Dont_Close_
 "Confirmation wait seconds   " [ConfigPreview(cfgPreparationWaitSecondsS):38], EditConfigNumber(cfgPreparationWaitSecondsS, "Confirmation wait seconds"), _MF_Dont_Close_
 "Helper launch delay seconds " [ConfigPreview(cfgGeneratedMacroLaunchDelaySecondsS):38], EditConfigNumber(cfgGeneratedMacroLaunchDelaySecondsS, "Helper launch delay seconds"), _MF_Dont_Close_
 "Log filename (blank=auto)   " [ConfigPreview(cfgLogFileS):38], EditConfigText(cfgLogFileS, "Log filename (blank=auto)"), _MF_Dont_Close_
END

// Built-in help: no external viewer or readme file is required.
PROC HelpOverview()
 Warn("TSEUPGRADE: getting started", Chr(13),
      "1. Keep the package files together and compile tseupgrade.s.", Chr(13),
      "2. Open Settings, review paths, then Save and return.", Chr(13),
      "3. Run upgrade; inspect validation and console messages.", Chr(13),
      "The OLD installation is kept. Back up personal files first.")
END

PROC HelpDirectories()
 Warn("Directories and personal files", Chr(13),
      "old_directory: existing installation; new_directory: separate target.", Chr(13),
      "custom_macro_directory: source tree copied into NEW/custom_macros.", Chr(13),
      "working_directory: personal UI/CFG output base and optional TSE startup setting.", Chr(13),
      "Final g32.exe launch starts from NEW/custom_macros.")
END

PROC HelpConfirmation()
 Warn("Confirmations and unattended mode", Chr(13),
      "At [Y/n], Enter or y means Yes; n skips that optional step.", Chr(13),
      "Copying personal files and compiling them each have a separate prompt.", Chr(13),
      "unattended=true automatically answers Yes and skips this menu.", Chr(13),
      "tse.exe still needs user interaction. silent=true hides only the introduction.")
END

PROC HelpValidation()
 Warn("Initial INI validation", Chr(13),
      "Run upgrade first lists detected INI problems together.", Chr(13),
      "ERROR blocks upgrade actions; WARNING marks optional/conditional issues.", Chr(13),
      "Unknown/duplicate keys warn; the last duplicate value wins.", Chr(13),
      "See *.validation.log. Generated files are checked again when used.")
END

PROC HelpCompilation()
 Warn("Compilation and time estimates", Chr(13),
      "SC32 compiles .s and .si wildcard batches recursively.", Chr(13),
      "Batch errors are reported; later batches continue.", Chr(13),
      "compileeta=true shows rough estimates from previous successful runs.", Chr(13),
      "Without history, remaining time is estimated after a successful batch.", Chr(13),
      "Keep tseupgrade_compile_history.tsv for future estimates.")
END

PROC HelpInstaller()
 Warn("Installer and configuration backup", Chr(13),
      "Answer No to running tse.exe if NEW was already installed.", Chr(13),
      "Missing tsecfg.dat skips preparation; installation continues.", Chr(13),
      "If present, its original backup is restored after tse.exe exits.", Chr(13),
      "The installer DAT is preserved too. Later settings steps may change settings.")
END

PROC HelpStartup()
 Warn("Final startup and logs", Chr(13),
      "startup_macro=knudstar runs knudstar.mac with -e; blank disables it.", Chr(13),
      "Any generated settings macro runs before the personal startup macro.", Chr(13),
      "Review *.log and *.sc32.tsv for results and compiler timings.", Chr(13),
      "tseupgrade help opens this help even in unattended mode.", Chr(13),
      "The package readme has full details and validation-only instructions.")
END

PROC CloseUpgradeHelp()
 RETURN()
END

MENU UpgradeHelpMenu()
 Title = "TSEUPGRADE help - 1.0.0.0.53"
 Width = 62
 History
 "&Getting started", HelpOverview(), _MF_Dont_Close_
 "&Directories and personal files", HelpDirectories(), _MF_Dont_Close_
 "&Confirmations and unattended mode", HelpConfirmation(), _MF_Dont_Close_
 "&Validation and INI problems", HelpValidation(), _MF_Dont_Close_
 "&Compilation and time estimates", HelpCompilation(), _MF_Dont_Close_
 "&Installer and configuration backup", HelpInstaller(), _MF_Dont_Close_
 "&Startup macro and logs", HelpStartup(), _MF_Dont_Close_
 "", , _MF_Divide_
 "&Return", CloseUpgradeHelp()
END

PROC ShowUpgradeHelp()
 UpgradeHelpMenu()
END

KEYDEF UpgradeHelpKeys
 <CtrlAltShift F1> ShowUpgradeHelp()
END

MENU ConfigSettingsMenu()
 Title = "TSEUPGRADE settings"
 Width = 70
 History
 "&Installation and versions", ConfigInstallationMenu(), _MF_Dont_Close_
 "&Personal paths and destinations", ConfigPersonalMenu(), _MF_Dont_Close_
 "&Executables and data files", ConfigExecutablesMenu(), _MF_Dont_Close_
 "&Behavior, logging and waits", ConfigBehaviorMenu(), _MF_Dont_Close_
 "&Help <CtrlAltShift F1>", ShowUpgradeHelp(), _MF_Dont_Close_
 "", , _MF_Divide_
 "&Save settings", SaveConfigSettings(), _MF_Dont_Close_
 "Save and &return", SaveAndReturnConfig()
 "&Discard changes and return", DiscardConfig()
END

PROC ConfigureUpgrade()
 ReadConfigSettings()
 configDoneI = FALSE
 WHILE NOT configDoneI
  IF NOT ConfigSettingsMenu()
   IF configDirtyI
    Warn("Unsaved edits. Choose Save and return, or Discard changes and return.")
   ELSE
    configDoneI = TRUE
   ENDIF
  ENDIF
 ENDWHILE
END

PROC RequestUpgrade()
 launchRequestedI = TRUE
END

PROC CancelUpgradeMenu()
 cancelRequestedI = TRUE
END

MENU UpgradeStartupMenu()
 Title = "TSEUPGRADE 1.0.0.0.53"
 Width = 52
 History
 "&R: Run upgrade", RequestUpgrade()
 "", , _MF_Divide_
 "&S: Settings - edit tseupgrade.ini", ConfigureUpgrade()
 "", , _MF_Divide_
 "&H: Help <CtrlAltShift F1>", ShowUpgradeHelp(), _MF_Dont_Close_
 "", , _MF_Divide_
 "&C: Cancel", CancelUpgradeMenu()
END

PROC RunUpgrade()
 STRING macroDirectoryS[255] = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_)
 STRING iniFilenameS[255] = macroDirectoryS + "tseupgrade.ini"
 STRING helperFilenameS[255] = macroDirectoryS + "tseupgrade.ps1"
 STRING powershellFilenameS[255] = ""
 STRING commandLineS[255] = ""
 IF NOT FileExists(iniFilenameS)
  Warn("Missing configuration: ", iniFilenameS)
  RETURN()
 ENDIF
 IF NOT FileExists(helperFilenameS)
  Warn("Missing helper: ", helperFilenameS)
  RETURN()
 ENDIF
 powershellFilenameS = GetProfileStr("tseupgrade", "powershell_exe", "", iniFilenameS)
 IF powershellFilenameS == ""
  powershellFilenameS = GetEnvStr("SystemRoot") + "\System32\WindowsPowerShell\v1.0\powershell.exe"
 ENDIF
 IF NOT FileExists(powershellFilenameS)
  Warn("PowerShell not found. Set powershell_exe in tseupgrade.ini.")
  RETURN()
 ENDIF
 // SAL command strings are limited to 255 characters. Reject truncation.
 IF Length(powershellFilenameS) + Length(helperFilenameS) + 72 > 255
  Warn("Package path too long. Move this package to a shorter path.")
  RETURN()
 ENDIF
 commandLineS = QuotePath(powershellFilenameS) + " -NoProfile -ExecutionPolicy Bypass -File " + QuotePath(helperFilenameS)
 Dos(commandLineS, _DONT_PROMPT_)
END


PROC RunUpgradeMain()
 STRING actionS[255] = Lower(Trim(Query(MacroCmdLine)))
 IF actionS == "help" OR actionS == "/?"
  ShowUpgradeHelp()
  RETURN()
 ENDIF
 configIniS = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_) + "tseupgrade.ini"
 IF NOT FileExists(configIniS)
  Warn("Missing configuration: ", configIniS)
  RETURN()
 ENDIF
 launchRequestedI = FALSE
 cancelRequestedI = FALSE
 IF Lower(GetProfileStr("tseupgrade", "silent", "false", configIniS)) <> "true" AND
    Lower(GetProfileStr("tseupgrade", "unattended", "false", configIniS)) <> "true"
  Warn("TSEUPGRADE 1.0.0.0.53: Upgrade into a separate directory.",
       " Review tseupgrade.ini first. Answer the steps in the console.",
       " The old installation is kept. See tseupgrade_readme.md.")
 ENDIF
 CASE actionS
  WHEN "settings"
   ConfigureUpgrade()
   RETURN()
  WHEN "run"
   RunUpgrade()
   RETURN()
  WHEN ""
   IF Lower(GetProfileStr("tseupgrade", "unattended", "false", configIniS)) == "true"
    RunUpgrade()
    RETURN()
   ENDIF
   WHILE UpgradeStartupMenu()
    IF launchRequestedI OR cancelRequestedI
     BREAK
    ENDIF
   ENDWHILE
  OTHERWISE
   Warn("Use tseupgrade, tseupgrade settings, tseupgrade run, or tseupgrade help.")
   RETURN()
 ENDCASE
 IF launchRequestedI
  RunUpgrade()
 ENDIF
END


PROC Main()
 Enable(UpgradeHelpKeys)
 RunUpgradeMain()
 Disable(UpgradeHelpKeys)
END
