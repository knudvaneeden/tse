 @REM version: 1.0.0.0.0 [kn, ri, sa, 26-09-2026 13:19:00]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\OS2CMD\
 git add hstart05.zip
 git add os2cmd.ini
 git add os2cmd.s
 git add os2cmd.zip
 git add os2cmd1.0.0.0.1.zip
 git add os2cmd_readme.md
 git commit -m "Update os2cmd directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/OS2CMD
