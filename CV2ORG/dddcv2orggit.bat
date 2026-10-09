 @REM version: 1.0.0.0.0 [kn, ri, fr, 04-09-2026 21:30:21]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CV2ORG\
 git add cv2org.s
 git add cv2org.zip
 git add cv2org_readme.md
 git commit -m "Update cv2org directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CV2ORG
