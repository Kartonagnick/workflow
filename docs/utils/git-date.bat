@echo off & cls & @echo. & @echo.
call :checkParent
if errorlevel 1 (exit /b 1)

rem ============================================================================
rem ============================================================================

:main
    setlocal

    rem set "eDEBUG=ON"

    @echo [GIT-DATE] run...

    rem cd "%~dp0workflow"

    call :updLastCommit "2021-06-18 00:00:00"
        if errorlevel 1 (goto :failed)
    
    rem call :updAnyCommit "2021-06-16 15:30:26" "1457bdfcf672dd4f48828a533d8d6e24fa2a2400"
        if errorlevel 1 (goto :failed)

:success
    @echo [GIT-DATE] completed successfully
exit /b 0

:failed
    @echo [GIT-DATE] finished with erros
exit /b 1

rem ============================================================================
rem ============================================================================

:updLastCommit
    set "new_date=%~1"

    if not defined new_date (
        commit --amend --no-edit --date=now
        exit /b
    )

    set "GIT_COMMITTER_DATE=%new_date%"
    git commit --amend --no-edit --date="%new_date%"
exit /b

:updAnyCommit
    set "new_date=%~1"
    set "com_hash=%~2"

    git rev-parse -q --verify "%com_hash%"
    if errorlevel 1 (
        @echo [ERROR] hash not found: %com_hash%
        exit /b
    )

    git add -A
    git commit -m "auto-fixed"
    git filter-branch -f --env-filter ^
        "if [ $GIT_COMMIT = %com_hash% ]; then export GIT_AUTHOR_DATE='%new_date%'; export GIT_COMMITTER_DATE=$GIT_AUTHOR_DATE; fi"
exit /b

:updAuthor
    git commit --amend --author="New Author <new@email.com>" -m "new comment"
exit /b

rem ============================================================================
rem ============================================================================

:normalize
    set "%~1=%~dpfn2"
exit /b

rem ============================================================================
rem ============================================================================

:findGit
    set "PATH_GIT1=C:\Program Files\Git\bin"
    set "PATH_GIT2=C:\Program Files\SmartGit\git\bin"
    set "PATH=%PATH_GIT1%;%PATH_GIT2%;%PATH%"
    where git.exe >nul 2>nul
    if errorlevel 1 (@echo [ERROR] git.exe not found)
exit /b

:checkParent
    if errorlevel 1 (
        @echo [ERROR] was broken at launch
        exit /b 1
    )
    call :findGit
exit /b

rem ============================================================================
rem ============================================================================
