@echo off

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Set console title.
title Bleach vs. Naruto Kizuna - Console

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Check the operating system language.
chcp | find "936" >nul || (
	echo The operating system language must be Chinese! && goto :ERROR
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Finds the parent directory of the current directory.
for %%a in ("..") do (
	set parent=%%~fa
)

:: Invoke the [python] command to start the program.
set toolPath=%CD%\_Tool
set path=%path%;%toolPath%\Python34
set dbgmain=%toolPath%\dbgmain.py
set adlExe=%toolPath%\adl.exe
set gameData=%parent%\swf_output

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

python -B %dbgmain% %adlExe% %gameData%

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

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::