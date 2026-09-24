// NEWCOLOR informational companion macro, version 1.0.0.0.0.
// The original package contains color templates, not an executable macro.

proc Main()
    string silentS[16] = GetProfileStr("newcolor", "silent", "false", ".\\newcolor.ini")

    if Lower(silentS) <> "true"
        Warn("NEWCOLOR 1.0.0.0.0 (GPT-6): This archive contains color templates for the TSE Colors macro. See newcolor_readme.md to install a template. Running this companion does not install or activate colors.")
    endif
end
