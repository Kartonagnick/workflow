@echo off & cls & @echo. & @echo.

@echo [START] please wait...
set "eDEBUG=ON"
call "%~dp0git-date.bat" > "%~dp0log.txt" 2>&1
@echo [DONE]
rem ============================================================================
rem ============================================================================
