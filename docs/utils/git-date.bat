@echo off & cls & @echo. & @echo.
call :checkParent
if errorlevel 1 (exit /b 1)

rem ============================================================================
rem ============================================================================

:main
    setlocal

    @echo [GIT-DATE] run... v0.0.3 PRE
    set "eDIR_WORK=%~dp0..\..\workflow"
    rem set "eDEBUG=ON"

    call :prepare
        if errorlevel 1 (goto :failed) 

    call :viewDebug

    rem call :viewBranch 
        if errorlevel 1 (goto :failed)

    call :updBranch "2021-07-01 14:30:00" "2021-07-01 14:50:00"
        if errorlevel 1 (goto :failed)

    rem call :updLastCommit "2021-06-30 00:05:00"
        if errorlevel 1 (goto :failed)

    rem call :updCommit "2021-07-01 12:35:00" "794331fdf457cf63a2bf494cf0ec93c290bb3221"
        if errorlevel 1 (goto :failed)
 
    rem deprecated   
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

rem ============================================================================
rem ============================================================================

:viewDebug
    if not defined eDEBUG (
        @echo BRANCH: %eGIT_LAST_BRANCH%
        exit /b
    )
    @echo [eGIT_VERSION] ............. %eGIT_VERSION%
    @echo [eGIT_LAST_FULL_COMMIT] .... %eGIT_LAST_FULL_COMMIT%
    @echo [eGIT_LAST_SHORT_COMMIT] ... %eGIT_LAST_SHORT_COMMIT%
    @echo [eGIT_LAST_BRANCH] ......... %eGIT_LAST_BRANCH%
    @echo [eGIT_LAST_COMMENT] ........ %eGIT_LAST_COMMENT%
    @echo.
exit /b

rem ============================================================================
rem ============================================================================

:prepare
    set "eMODE_SILENT="
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

:viewTitle
    if not defined index   (goto :viewTitleS)
    if not defined eETALON (goto :viewTitleS)
    set /a "cur=index+1"
    @echo [%cur%/%eETALON%]------------------------------------[%new_date%][%id_commit%]
    exit /b
:viewTitleS
    @echo ------------------------------------[%new_date%][%id_commit%]
exit /b

:updCommit
    set "new_date=%~1"
    set "id_commit=%~2"
    call :viewTitle

    set "eTMP_BRANCH=temp-rebasing-branch"
    set "GIT_COMMITTER_DATE=%new_date%" 
    set "GIT_AUTHOR_DATE=%new_date%"

    set arguments=--committer-date-is-author-date ^
        "%id_commit%" --onto "%eTMP_BRANCH%"

    if defined eDEBUG (
        set silent=
    ) else (
        set silent=1^>nul
    )

    git checkout -b "%eTMP_BRANCH%" "%id_commit%"      %silent%
    git commit --amend --no-edit --date "%new_date%"   %silent%
    git checkout "%eGIT_LAST_BRANCH%"                  %silent%
    git rebase --autostash  %arguments%                %silent%
    git branch -d "%eTMP_BRANCH%"                      %silent%
    @echo --- & @echo.
exit /b

rem ============================================================================
rem ============================================================================

:addCommit
    if "%~1" == "-" (exit /b)
    if defined eMODE_SILENT (goto :addCommitNext)
    @echo [%~2][%~3]
:addCommitNext
    set "commits[%count%]=%~2"
    set /a "count=count+1"
exit /b

:addStamp
    if defined eMODE_SILENT (goto :addStampNext)
    @echo [vbs] %~1
:addStampNext
    set "stamps[%count%]=%~1"
    set /a "count=count+1"
exit /b

:viewBranch
    set "count=0"
    for /f "tokens=1,2,*" %%a in ('git cherry -v master') do (
        call :addCommit "%%~a" "%%~b" "%%~c"
    )
    if not defined eMODE_SILENT (@echo.)
exit /b

:updBranch
    set "beg_date=%~1"
    set "end_date=%~2"
    @echo started...
    @echo from: %beg_date%
    @echo  to : %end_date%

    if not defined eDEBUG (set "eMODE_SILENT=ON")

    call :viewBranch
    set "eETALON=%count%"

    set command=cscript.exe /nologo ^
        "%~dp0vbs\offset.vbs"       ^
        "%beg_date%"                ^
        "%end_date%"                ^
        "%count%"

    set "count=0"
    for /f "usebackq tokens=*" %%a in (`%command%`) do (
        call :addStamp "%%~a"
    )
    @echo number of commits: %count%
    @echo.


    if not defined eDEBUG (set "eMODE_SILENT=ON")
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
    rem @echo [%index%][%commit%] - [%stamp%]
    rem @echo.
    call :updCommit "%stamp%" "%commit%"
    if errorlevel 1 (exit /b 1)

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
