@echo off

set flashName=Flash CC 2015

:: Finds the parent directory of the current directory.
for %%a in ("..") do (
	set parent=%%~fa
)

set path=%path%;%parent%\_Tool
set flashDir=%LOCALAPPDATA%\Adobe\%flashName%

:: Check whether directory %flashDir% exists.
if not exist "%flashDir%" (
	echo No software installed [%flashName%]!
	goto :ERROR
)

:: Check the operating system language.
chcp | find "936" >nul || (
	echo The operating system language must be Chinese! && goto :ERROR
)

:: Call the 7z program to extract the file to the specified directory.
set cmdDir=%flashDir%\zh_CN\Configuration\Commands
7za x "%CD%\jsfl.7z" -o"%cmdDir%" -aoa >nul

:: If the exit code is not 0, output the exit code.
set error=%errorlevel%
if not %error% == 0 (
	echo Error, exit code is %error%.
	goto :ERROR
)

goto :END

:: If an error occurs, prompt and exit.
:ERROR
pause >nul
:END
exit