@echo off
cd /d "%~dp0"

echo Building app...
flutter build web || exit /b

echo Copying new build...
xcopy /E /I /Y "build\web\*" "..\proj_njp\web" >nul

cd /d "..\proj_njp\web" || exit /b

echo Pushing changes...
git add . 
git commit -m "application new build"
git push

echo Done.
pause
