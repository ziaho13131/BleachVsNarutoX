@echo off

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Finds the parent directory of the current directory.
for %%a in ("..") do (
	set parent=%%~fa
)

set path=%path%;%CD%\_Tool

set name=FighterTester
set file_swf=%name%.swf
set file_xml=%name%-app.xml
set tmp_xml=%parent%\swf_output\%file_xml%
set out_swf=%parent%\swf_output\%file_swf%
set out_xml=%parent%\swf_output\META-INF\AIR\application.xml
set src_swf=%CD%\#%name%\bin-release-temp\%file_swf%
set src_xml=%CD%\#%name%\src\%file_xml%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if exist "%tmp_xml%" (
	echo Deleting file "%tmp_xml%" ...
	del "%tmp_xml%" /q
)
if exist "%out_swf%" (
	echo Deleting file "%out_swf%" ...
	del "%out_swf%" /q
)
if exist "%out_xml%" (
	echo Deleting file "%out_xml%" ...
	del "%out_xml%" /q
)

:: Check the source file_swf
if not exist "%src_swf%" (
	echo Source "%src_swf%" does not exist ...
	goto :ERROR
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Call the tool [ABCMerge] to optimize the file_swf.
echo Optimization in progress...
echo SOURCE: [%src_swf%]
echo OUTPUT: [%out_swf%]
ABCMerge "%src_swf%" >ABCMerge.log

set error=%errorlevel%
if not %error% == 0 (
	echo Error, exit code is %error%.
	goto :ERROR
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

move "%src_swf%" "%out_swf%" >nul
ren "%src_swf%.bak" %file_swf%

copy "%src_xml%" "%out_xml%" >nul

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

goto :END

:: If an error occurs, prompt and exit.
:ERROR
pause >nul
:END
exit

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::