:--------------- START SCRIPT DUMP ------------
@echo off
setlocal enabledelayedexpansion

setlocal DISABLEDELAYEDEXPANSION
: protect from exclamation marks in args
SET _RU=%JS7_VAR_RU%
SET _RP=%JS7_VAR_RP%
SET _CMD=%JS7_VAR_CMD%
SET _ARGS=%JS7_VAR_ARGS%
SET INTERACTIVE=%JS7_VAR_INTERACTIVE%

setlocal enabledelayedexpansion

echo #
echo "%DATE% %TIME% -- Starting ssh command file on  %COMPUTERNAME% / %_CMD% / %_ARGS% "

rem DEFINE a unique ID in PP, sha will contains date time and random number
SET _RND=%RANDOM%
for /f "tokens=1 delims= " %%a in ('set ^|busybox sha3sum') do set "PP=%%~a"

set _FNAME=Jlog_%PP%.txt
set JOB_LOGFILE_NAME=%~dp0%Jlog_!PP!.txt

set AA=%_ARGS:\=/%
SET CC=%_CMD:\=/%
SET LL=%JOB_LOGFILE_NAME:\=/%

echo !JOB_LOGFILE_NAME! > !JOB_LOGFILE_NAME!
icacls !JOB_LOGFILE_NAME! /grant Users:F

echo ORDER_ARGS=%AA%
echo ORDER_CMD=%CC%
echo LOG=%LL%

if [%INTERACTIVE%] == [YES] (
	start {CMD} -s {JOB_LOGFILE_NAME} {ARG}
) else (
	{CMD} -s {JOB_LOGFILE_NAME} {ARG}
)



