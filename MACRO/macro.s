/*
    macro.s

    Small information launcher for the historical MACRO package.

    Package version : 1.0.0.0.1
    Date/time       : 2026-09-20 21:44 CEST
    LLM             : GPT-5.6 Sol
*/

PROC Main()
    Warn("MACRO package - version 1.0.0.0.1" + Chr(13);
         Chr(13);
         "This package contains a historical TSE Macro Editor/helper." + Chr(13);
         "It assists with writing and working with TSE SAL macros." + Chr(13);
         Chr(13);
         "Press OK for more information." + Chr(13))

    Warn("Main features:" + Chr(13);
         "- SAL command, syntax, query and setting reference information." + Chr(13);
         "- Macro editing help and parameter prompts." + Chr(13);
         "- Compile and execute macro functions." + Chr(13);
         "- Editing shortcuts and a macro command menu." + Chr(13))

    Warn("Important files:" + Chr(13);
         "MACRO.MAC - original compiled macro" + Chr(13);
         "MACRO.DAT - SAL command/syntax information" + Chr(13);
         "MACRO.QRY - TSE query information" + Chr(13);
         "MACRO.SET - TSE setting information" + Chr(13);
         Chr(13);
         "See macro_readme.md for installation and usage details." + Chr(13))
END
