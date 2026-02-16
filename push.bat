@echo off
echo Pushing to GitHub...
cd /d "%~dp0"
git add .
git commit -m "Update"
git push origin main
echo Done!
pause
