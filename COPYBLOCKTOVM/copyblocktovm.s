// COPYBLOCKTOVM - package version 1.0.0.0.1
// Updated: 2026-10-28 22:08:15
// See copyblocktovm_readme.md for installation and help.

STRING gDistribution[255] = "Ubuntu"
STRING gSilent[20] = "false"

// Read the INI beside the compiled macro without changing the working directory.
PROC ReadSettings()
 INTEGER originalId = GetBufferId()
 INTEGER tempId = 0
 INTEGER equalsAt = 0
 INTEGER moreLines = TRUE
 STRING iniPath[255] = ""
 STRING lineText[255] = ""
 STRING keyText[255] = ""
 STRING valueText[255] = ""

 gDistribution = "Ubuntu"
 gSilent = "false"
 iniPath = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_) + "copyblocktovm.ini"
 IF FileExists(iniPath)
  // INI loading must not disturb the user's marked block.
  PushBlock()
  tempId = CreateTempBuffer()
  IF tempId
   IF InsertFile(iniPath)
    BegFile()
    WHILE moreLines
     lineText = Trim(GetText(1, 255))
     IF ( NOT (SubStr(lineText, 1, 1) == ";") ) AND
        ( NOT (SubStr(lineText, 1, 1) == "#") )
      equalsAt = Pos("=", lineText)
      IF equalsAt > 0
       keyText = Lower(Trim(SubStr(lineText, 1, equalsAt - 1)))
       valueText = Trim(SubStr(lineText, equalsAt + 1, 255))
       CASE keyText
        WHEN "silent"
         gSilent = Lower(valueText)
        WHEN "linuxdistribution"
         gDistribution = valueText
       ENDCASE
      ENDIF
     ENDIF
     moreLines = Down()
    ENDWHILE
   ENDIF
   AbandonFile()
  ENDIF
  GotoBufferId(originalId)
  PopBlock()
 ENDIF
END

INTEGER PROC FNBlockCopyToVirtualMachineVirtualBoxViaPowershellB(STRING linuxDistributionS)
 INTEGER B = FALSE
 STRING commandText[255] = ""
 IF ( NOT ( IsBlockInCurrFile() ) ) Warn( "Please mark a block" ) B = FALSE RETURN( B ) ENDIF // return from the current procedure if no block is marked
 IF ( NOT ( CopyToWinClip() ) )
  Warn("The marked block could not be copied to the Windows clipboard.")
  RETURN(FALSE)
 ENDIF
 commandText = Format("& 'C:\Program Files\Oracle\VirtualBox\VBoxManage.exe' controlvm 'Linux ",
                      linuxDistributionS, "' keyboardputstring (Get-Clipboard -Raw)")
 Dos(Format("powershell -NoProfile -Command ", QuotePath(commandText)))
 // TRUE means the command was launched; inspect PowerShell for VM errors.
 RETURN(TRUE)
END

PROC Main()
 INTEGER historyId = GetFreeHistory("copyblocktovm:distribution")
 STRING distribution[255] = ""
 ReadSettings()
 distribution = gDistribution
 IF ( NOT (gSilent == "true") )
  Warn("COPYBLOCKTOVM 1.0.0.0.1: Copies the marked block to a running VirtualBox VM. ",
       "Focus the target input first. Choose Ubuntu, Debian or CentOS. ",
       "Set silent=true in copyblocktovm.ini to hide this message.")
 ENDIF
 IF ( NOT ( IsBlockInCurrFile() ) )
  Warn("Please mark a block before running COPYBLOCKTOVM.")
  RETURN()
 ENDIF
 IF ( NOT ( Ask("Copy block to distribution (Ubuntu / Debian / CentOS):", distribution, historyId) ) )
  RETURN()
 ENDIF
 distribution = Trim(distribution)
 CASE Lower(distribution)
  WHEN "ubuntu"
   distribution = "Ubuntu"
  WHEN "debian"
   distribution = "Debian"
  WHEN "centos"
   distribution = "CentOS"
  OTHERWISE
   Warn("Choose Ubuntu, Debian or CentOS. Check linuxdistribution in copyblocktovm.ini.")
   RETURN()
 ENDCASE
 IF FNBlockCopyToVirtualMachineVirtualBoxViaPowershellB(distribution)
  Message("COPYBLOCKTOVM: command launched. Check the target VM for the result.")
 ENDIF
END

<Ctrl F12> Main()
