@echo off & cls & @echo. & @echo.

set "PATH_GIT1=c:\Program Files\Git\bin"
set "PATH_GIT2=C:\Program Files\SmartGit\git\bin"
set "PATH=%PATH_GIT1%;%PATH_GIT2%;%PATH%"
set "token=..."

rem ============================================================================
rem ============================================================================

rem without tokens (access by password)
::git clone --recursive https://github.com/Kartonagnick/workflow.git

rem ============================================================================
rem ============================================================================

rem with token:
rem https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token

git clone --recursive "https://%token%@github.com/Kartonagnick/workflow.git"

rem ============================================================================
rem ============================================================================











