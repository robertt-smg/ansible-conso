@echo off
setlocal enabledelayedexpansion

set "INPUT=userlist.csv"
set "OUTPUT=output.csv"
set "TEMPFILE=sid.tmp"
set "VBSCRIPT=getsid.vbs"

rem VBScript zum Ermitteln der SID schreiben
>"%VBSCRIPT%" echo Set objArgs = WScript.Arguments
>>"%VBSCRIPT%" echo strUser = objArgs(0)
>>"%VBSCRIPT%" echo Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
>>"%VBSCRIPT%" echo Set colItems = objWMIService.ExecQuery("Select * from Win32_UserAccount where Name='" ^& strUser ^& "'")
>>"%VBSCRIPT%" echo For Each objItem in colItems
>>"%VBSCRIPT%" echo     WScript.Echo objItem.SID
>>"%VBSCRIPT%" echo Next

echo Username,SID,MD5> "%OUTPUT%"

for /f "usebackq delims=" %%U in ("%INPUT%") do (
    set "USER=%%U"
    set "SID="

    for /f "delims=" %%S in ('cscript //nologo "%VBSCRIPT%" %%U') do (
        set "SID=%%S"
    )

    if defined SID (
        echo !SID!> "%TEMPFILE%"

        set "HASH="
        for /f "skip=1 tokens=1" %%H in ('certutil -hashfile "%TEMPFILE%" MD5') do (
            if not defined HASH set "HASH=%%H"
        )

        echo %%U,!SID!,!HASH!>> "%OUTPUT%"
    ) else (
        echo %%U,SID not found,>> "%OUTPUT%"
    )
)

del "%TEMPFILE%" >nul 2>&1
del "%VBSCRIPT%" >nul 2>&1
echo Fertig! Ergebnisse in %OUTPUT%
