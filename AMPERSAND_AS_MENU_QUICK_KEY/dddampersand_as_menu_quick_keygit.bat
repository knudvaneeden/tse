@REM version: 1.0.0.0.0 [kn, ri, mo, 24-08-2026 13:30:03]

@echo off
g:
cd /d g:\versioncontrol\git\ddd01\AMPERSAND_AS_MENU_QUICK_KEY\
git add ampersand_as_menu_quick_key.s
git add ampersand_as_menu_quick_key_readme.md
git add ampersand_as_menu_quick_key_test.s
git commit -m "Update ampersand_as_menu_quick_key directory files"
git push origin HEAD:TRUNK
start https://github.com/knudvaneeden/tse/tree/TRUNK/AMPERSAND_AS_MENU_QUICK_KEY
