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
SET NOWAIT=%JS7_VAR_NOWAIT%

if [%INTERACTIVE%] == [YES] (
	SET XML_TEMPLATE=INT_XML
) else (
	SET XML_TEMPLATE=XML
)
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

if not exist %CC% goto :eof
	
	set XML_FILE=%TEMP%\tmp_%PP%.xml
	echo XML_FILE=%XML_FILE%

	set TASK_NAME=JobSched_Immediate_Task_%PP%
	busybox grep "^:%XML_TEMPLATE%" %0 |busybox sed -b -e "s^:%XML_TEMPLATE%^^g" -e "s^{CMD}^%CC%^g" -e "s^{ARG}^%AA%^g"  -e "s^{_RU}^%_RU%^g" -e "s^{JOB_LOGFILE_NAME}^%LL%^g" > %XML_FILE%
	rem type %XML_FILE%
setlocal DISABLEDELAYEDEXPANSION
rem protect from exclamation marks in args
	echo "Create scheduler task %TASK_NAME% ..."

	if [%INTERACTIVE%] == [YES] (
		schtasks.exe /Create /XML %XML_FILE% /tn "%TASK_NAME%" /HRESULT
	) else (
		schtasks.exe /Create /XML %XML_FILE% /tn "%TASK_NAME%" /RU %_RU% /RP %_RP% /HRESULT
	)
	
setlocal enabledelayedexpansion
	echo "Run scheduler task %TASK_NAME% ..."
	schtasks /run /i /tn "%TASK_NAME%"
	echo "Wait for scheduler task %TASK_NAME% ..."
	schtasks /query /tn "%TASK_NAME%" /fo list | find "Status:"
	IF ERRORLEVEL 1 goto :eof2
:loop
	echo "%TASK_NAME%" is running %DATE% %TIME%
	if [%NOWAIT%] == [YES] (
		echo "%TASK_NAME%" we are not waiting for exit ...
	) else (
		for /f "tokens=2 delims=: " %%f in ('schtasks /query /tn "%TASK_NAME%" /fo list ^| find "Status:"' ) do (
			if "%%f"=="Running" (
				busybox sleep 10
				goto loop
			)
		)
		for /f "delims=" %%x in (!JOB_LOGFILE_NAME!) do set JOB_LOGFILE=%%x
		echo JOB Done: Final Log !JOB_LOGFILE!
		busybox cat !JOB_LOGFILE!
		
		schtasks /query /tn "%TASK_NAME%" /fo list /v
		SCHTASKS /Delete /tn "%TASK_NAME%" /f
	)
	del /q %XML_FILE%
	echo "%TASK_NAME%" finished Another job: "%CC%" "%AA%" well done ...
    exit 0

rem ###################################    
:eof2
	echo ERROR: Running Sched Task faild - not Status found for "%TASK_NAME%" ...
	echo Sorry, that I failed you :-( ...
    exit 2

rem ###################################    
:eof
	echo ERROR: CMD Script "%CC%" not found ...
	echo Sorry, that I failed you :-( ...
    exit 1

rem ###################################    
rem XML Task Scheduler template

:XML<?xml version="1.0" encoding="UTF-16"?>
:XML<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
:XML  <RegistrationInfo />
:XML  <Principals />
:XML  <Settings>
:XML    <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
:XML    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
:XML    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
:XML    <IdleSettings>
:XML      <StopOnIdleEnd>true</StopOnIdleEnd>
:XML      <RestartOnIdle>false</RestartOnIdle>
:XML    </IdleSettings>
:XML  </Settings>
:XML  <Triggers />
:XML  <Actions Context="Author">
:XML    <Exec>
:XML      <Command>{CMD}</Command>
:XML      <Arguments>-s {JOB_LOGFILE_NAME} {ARG}</Arguments>
:XML    </Exec>
:XML  </Actions>
:XML</Task>
:--------------- RUN INTERACTIVE ------------
:INT_XML<?xml version="1.0" encoding="UTF-16"?>
:INT_XML<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
:INT_XML  <RegistrationInfo />
:INT_XML  <Principals>
:INT_XML    <Principal id="Author">
:INT_XML      <LogonType>InteractiveToken</LogonType>
:INT_XML      <RunLevel>LeastPrivilege</RunLevel>
:INT_XML      <UserId>{_RU}</UserId>
:INT_XML    </Principal>
:INT_XML  </Principals>
:INT_XML  <Settings>
:INT_XML    <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
:INT_XML    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
:INT_XML    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
:INT_XML    <IdleSettings>
:INT_XML      <StopOnIdleEnd>true</StopOnIdleEnd>
:INT_XML      <RestartOnIdle>false</RestartOnIdle>
:INT_XML    </IdleSettings>
:INT_XML  </Settings>
:INT_XML  <Triggers />
:INT_XML  <Actions Context="Author">
:INT_XML    <Exec>
:INT_XML      <Command>{CMD}</Command>
:INT_XML      <Arguments>{ARG} -s {JOB_LOGFILE_NAME}</Arguments>
:INT_XML    </Exec>
:INT_XML  </Actions>
:INT_XML</Task>

:--------------- END SCRIPT DUMP ------------