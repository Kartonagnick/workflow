@echo off & cls & @echo. & @echo.
call :checkParent
if errorlevel 1 (exit /b 1)

rem ============================================================================
rem ============================================================================

:main
    setlocal

    @echo [GIT-DATE] run...
    set "eDIR_WORK=%~dp0..\..\workflow"
    rem set "eDEBUG=ON"

    call :prepare
        if errorlevel 1 (goto :failed) 

    if defined eDEBUG (
        call :viewDebug
    ) else (
        @echo BRANCH: %eGIT_LAST_BRANCH%
    )

    call :viewBranch 
        if errorlevel 1 (goto :failed)

    rem call :updDateBranch "2021-06-29 19:00:00" "2021-06-29 19:40:00"
        if errorlevel 1 (goto :failed)

    rem call :updLastCommit "2021-06-30 00:05:00"
        if errorlevel 1 (goto :failed)
    
    rem call :updAnyCommit "2021-06-29 00:25:00" "763b5bf983cde5add0e7957bb567ac20754fa4ce"
        if errorlevel 1 (goto :failed)

:success
    @echo [GIT-DATE] completed successfully
    popd
exit /b 0

:failed
    @echo [GIT-DATE] finished with erros
    if defined eDIR_WORK (popd)
exit /b 1

:viewDebug
    if not defined eDEBUG (exit /b)
    @echo [eGIT_VERSION] ............. %eGIT_VERSION%
    @echo [eGIT_LAST_FULL_COMMIT] .... %eGIT_LAST_FULL_COMMIT%
    @echo [eGIT_LAST_SHORT_COMMIT] ... %eGIT_LAST_SHORT_COMMIT%
    @echo [eGIT_LAST_BRANCH] ......... %eGIT_LAST_BRANCH%
    @echo [eGIT_LAST_COMMENT] ........ %eGIT_LAST_COMMENT%
    @echo.
exit /b

:prepare
    set "FILTER_BRANCH_SQUELCH_WARNING=1"
    if not exist "%eDIR_WORK%\.git" (
        @echo [ERROR] .git not found
        @echo [ERROR] check: eDIR_WORK
        @echo [ERROR] eDIR_WORK: %eDIR_WORK%
        set "eDIR_WORK="
        exit /b 1
    )
    pushd "%eDIR_WORK%" 
    if errorlevel 1 (
        @echo [ERROR] can not access do directory
        @echo [ERROR] check: eDIR_WORK
        @echo [ERROR] eDIR_WORK: %eDIR_WORK%
        set "eDIR_WORK="
        exit /b 1
    )

    for /f "tokens=3" %%a in ('git --version') do (
        set "eGIT_VERSION=%%a"
    )

    set "eGIT_LAST_FULL_COMMIT="
    for /f %%a in ('git log -1 --pretty^=format:"%%H"') do (
        set "eGIT_LAST_FULL_COMMIT=%%a"
    )

    set "eGIT_LAST_SHORT_COMMIT="
    for /f %%a in ('git log -1 --pretty^=format:"%%h"') do (
        set "eGIT_LAST_SHORT_COMMIT=%%a"
    )

    rem git branch
    rem git branch --show-current
    set "eGIT_LAST_BRANCH="
    for /f "delims=* tokens=*" %%a in ('git branch --contains %eGIT_LAST_FULL_COMMIT%') do (
        call :trim eGIT_LAST_BRANCH %%~a
    )

    set "eGIT_LAST_COMMENT="
    for /f "delims=* tokens=*" %%a in ('git log --format^="%%s" -n 1 %eGIT_LAST_FULL_COMMIT%') do (
        call :trim eGIT_LAST_COMMENT %%~a
    )
exit /b

rem ============================================================================
rem ============================================================================

rem :setRange
rem     if not defined end (
rem         set "end=%~1"
rem     ) else (
rem         set "beg=%~1"
rem     )
rem exit /b

:addCommit
    set "commits[%count%]=%~1"
    set /a "count=count+1"
exit /b

:addStamp
    set "stamps[%count%]=%~1"
    set /a "count=count+1"
exit /b

:setBegEnd
    if "%~1" == "-" (exit /b)

    @echo [%~2][%~3]    

    if not defined beg (
        set "beg=%~2"
    ) else (
        set "end=%~2"
    )
exit /b

:viewBranch
    set "beg="
    set "end="

    for /f "tokens=1,2,*" %%a in ('git cherry -v master') do (
        call :setBegEnd "%%~a" "%%~b" "%%~c"
        rem @echo [%%a][%%b][%%c]
    )

rem    for /f %%a in ('git rev-list --simplify-by-decoration -2 HEAD') do (
rem        call :setRange %%a
rem    )

    @echo   [BEG] %beg%
    @echo   [END] %end%
    @echo.

    set "count=0"
    for /f "tokens=1,2,3,*" %%a in ('git log --reverse --date^=format:"%%Y-%%m-%%d %%H:%%M:%%S" --format^="%%ad %%H %%s" %beg%~..%end%') do (
        @echo [%%~a][%%~b][%%~c][%%~d]
        call :addCommit "%%~c"
    )
    @echo   [CNT] %count%
exit /b

:updDateBranch
    set "beg_date=%~1"
    set "end_date=%~2"
    @echo [updDateBranch] started...
    @echo [updDateBranch] from: %beg_date%
    @echo [updDateBranch]  to : %end_date%

    call :viewBranch
    set "eETALON=%count%"

    set command=cscript.exe /nologo ^
        "%~dp0vbs\offset.vbs"       ^
        "%beg_date%"                ^
        "%end_date%"                ^
        "%count%"

    set "count=0"
    for /f "usebackq tokens=*" %%a in (`%command%`) do (
        @echo [vbs] %%~a
        call :addStamp "%%~a"
    )
    @echo   [CNT] %count%

    set "index=0"
:loop
    call :runCommit
    if errorlevel 1 (@echo [ERROR] & exit /b 1)
    if not "%eETALON%" == "%count%" (exit /b)
    set /a "index=index+1"
    if %index% equ %count% (exit /b)
    goto :loop
exit /b

rem ============================================================================
rem ============================================================================

:runCommit
    call set "commit=%%commits[%index%]%%"
    call set "stamp=%%stamps[%index%]%%"
    @echo [%index%][%commit%] - [%stamp%]
    git filter-branch -f --env-filter "if [ $GIT_COMMIT = %commit% ]; then export GIT_AUTHOR_DATE='%stamp%'; export GIT_COMMITTER_DATE=$GIT_AUTHOR_DATE; fi"
    call :viewBranch

    if not "%eETALON%" == "%count%" (
        @echo [EXTREME STOP] value of count was changed
        @echo [EXTREME STOP] operation aborted
    )
exit /b

rem ============================================================================
rem ============================================================================

:updLastCommit
    set "new_date=%~1"

    if not defined new_date (
        commit --amend --no-edit --date=now
        exit /b
    )

    set "GIT_COMMITTER_DATE=%new_date%"
    set "GIT_AUTHOR_DATE=%new_date%"
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

:updAuthorLastCommit
    git commit --amend --author="New Author <new@email.com>" -m "new comment"
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


rem ============================================================================
rem ============================================================================

:normalize
    set "%~1=%~dpfn2"
exit /b

rem ============================================================================
rem ============================================================================

:trim
    for /F "tokens=1,*" %%a in ("%*") do (
        call set "%%a=%%b"
    )
exit /b

rem ============================================================================
rem ============================================================================

:checkParent
    if errorlevel 1 (
        @echo [ERROR] was broken at launch
        exit /b 1
    )
    call :findGit
exit /b

rem ============================================================================
rem ============================================================================
