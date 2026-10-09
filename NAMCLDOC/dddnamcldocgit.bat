 @REM version: 1.0.0.0.0 [kn, ri, we, 23-09-2026 21:39:25]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\NAMCLDOC\
 git add namcldoc.ini
 git add namcldoc.zip
 git add namcldoc1.0.0.0.0.zip
 git add namcldoc_readme.md
 git commit -m "Update namcldoc directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/NAMCLDOC
