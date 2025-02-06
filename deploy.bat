echo Copy files
xcopy /E /I /Y "build\web\*" "..\proj_njp\web" >nul

cd /d "..\proj_njp\web" 

echo Pushing changes...
git add .
git commit -m "application new build"
git push --force

echo Done.
