// VIEWREGULAREXPRESSIONSEARCHFOLDING 1.0.0.0.1
// Original creator: Zhong Zhao
// Updated 2026-09-28 10:43 CEST by OpenAI Codex (GPT-6)
PROC Main()
 STRING iniFilenameS[255] = ""
 STRING silentS[10] = ""

 iniFilenameS = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_) + "viewregularexpressionsearchfolding.ini"
 silentS = GetProfileStr("viewregularexpressionsearchfolding", "silent", "false", iniFilenameS)
 IF EquiStr(silentS, "true") == FALSE
  Warn("VIEWREGULAREXPRESSIONSEARCHFOLDING 1.0.0.0.1 uses a C/C++ regular expression to present a compressed view of selected lines. This can help locate declarations and other code structures. Set silent=true in viewregularexpressionsearchfolding.ini to hide this message.")
 ENDIF

 Find("^{{    }|\t[~iefswcr /:,# \t\[\\\{\}\x22]}?{{extern \x22C\x22}?{ @virtual}?_|~@[A-Za-z:]\w|[@+\-*/%^&|~!<>, \t:~]@([~;]*[~;,/'\x22]$}|{ @{class}|{typedef}|{inline}|{enum} }|{[ \t]#[~,+|&:<(!=/*\x22#\\\{?]#::[~% (;:+|-]#([~.;+|-]*[~;,\x22>+<|*:-]$}","ixav")
END
