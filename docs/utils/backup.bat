@echo off & cls & @echo. & @echo.

rem === архивирует весь каталог,
rem === или отдельные подкаталоги

rem каталоги для поиска 7-zip
set "ePATHS=C:\Program Files\7-Zip; C:\Program Files (x86)\7-Zip"


rem какие файлы или каталоги нужно исключить из бэкапа
set "eEXCLUDE1=ipch; .vs; *VC.db; *.VC.opendb; *.sdf; .svn" 
set "eEXCLUDE2=_backup; _build; _products; _cache; _stash" 
set "eEXCLUDE3=external; boost; googletest" 
set "eEXCLUDE=%eEXCLUDE1%; %eEXCLUDE2%; %eEXCLUDE3%" 
set "eEXCLUDE=_backup; 2021y-*"

rem каталог, где нужно расположить готовый архив (или архивы)
rem по умолчанию: %~dp0_backup
set "eDIR_DST="

rem каталог, который нужно заархивировать
rem по умолчанию: %~dp0
set "eDIR_SRC="

rem имя архива.
rem по умолчанию: совпадаем с именем архивируемого каталога
set "eNAME="


rem весь каталог архивируется в один файл.7z
rem этот стиль используется по умолчанию.
set "eSTYLE=all directory"
rem example:
rem   _backup
rem      `-- docs-2021y-06m-14d_16h-56minuts.7z
rem           |--- agreement
rem            `-- payment


rem по отдельности архивирует все подкаталоги
set "eSTYLE=sub-directories (everyone-stamp)"
rem example:
rem   _backup
rem     |--- agreement-2021y-06m-14d_16h-55min.7z
rem      `-- payment-2021y-06m-14d_16h-55min.7z


rem по отдельности архивирует все подкаталоги
rem и размещает их в каталоге, имя которого содержит дату архивации
set "eSTYLE=sub-directories (for-all-stamp)"
rem example:
rem   _backup
rem      `-- 2021y-06m-14d_16h-55min
rem           |--- agreement.7z
rem            `-- payment.7z

rem ============================================================================

set "eSTYLE=all directory"
rem set "eSTYLE=sub-directories (everyone-stamp)"
rem set "eSTYLE=sub-directories (for-all-stamp)"

rem ============================================================================
rem ============================================================================

:main
  setlocal
  call :prepare
  if errorlevel 1 (
      @echo [ERROR] initialization failed
      goto failed
  )
  @echo [START] ... v0.0.1

  if not defined eSTYLE (
      call :backupDirectory 
      goto :check
  )
  if "%eSTYLE%" == "all directory" (
      call :backupDirectory 
      goto :check
  )
  call :backupDirectories

:check
  if errorlevel 1 (goto failed)

:success
    @echo [BACKUP] completed successfully
exit /b 0

:failed
    @echo [BACKUP] finished with erros
exit /b 1

rem ============================================================================
rem ============================================================================

:prepare
    call :find7z
    if errorlevel 1 (exit /b 1)

    call :makeExcludeList
    if errorlevel 1 (exit /b 1)

    if not defined eDIR_SRC (set "eDIR_SRC=%~dp0")
    if not defined eDIR_DST (set "eDIR_DST=%~dp0_backup")

    call :normalizePath eDIR_SRC "%eDIR_SRC%"
    call :normalizePath eDIR_DST "%eDIR_DST%"

    if not defined eNAME (
        for %%a in ("%eDIR_SRC%\.") do (
            set "eNAME=%%~na%%~xa"
        )
    )

    call :dateTime eTIMESTAMP
    if errorlevel 1 (exit /b 1)
exit /b

:backupDirectory
    rem @echo [backupDirectory] ...
    set "archive=%eNAME%-%eTIMESTAMP%.7z"
    call :backup "%eDIR_SRC%"  "%eDIR_DST%"  "%archive%"
exit /b

:enumerateExcludes
    set "enumerator=%eEXCLUDE%"
:loopEnumerateExcludes
    for /F "tokens=1* delims=;" %%a in ("%enumerator%") do (
        set "enumerator=%%b"
        call :processExclude "%%a"
        if errorlevel 1 (exit /b 1) 
    )
    if defined enumerator (goto :loopEnumerateExcludes)
exit /b 0

:processExclude
    call :trim mask_exclude %~1
    for /f "delims=" %%a in ('@echo %dir_check% ^| findstr /rc:"%mask_exclude%"') do (
        @echo   [skip] %dir_check% VS %mask_exclude% 
        exit /b 1
    )
    rem @echo   [ OK ] %dir_check% VS %mask_exclude% 
exit /b 0

:checkDirectory
    set "dir_check=%~1"
    call :enumerateExcludes 
    if not errorlevel 1 (set "eDIRS=%~1;%eDIRS%")
exit /b 0


:enumerateDirectories
    set "enumerator=%eDIRS%"
:loopEnumerateDirectories
    for /F "tokens=1* delims=;" %%a in ("%enumerator%") do (
        set "enumerator=%%b"
        call :processDirectory "%%a"
        if errorlevel 1 (exit /b 1) 
    )
    if defined enumerator (goto :loopEnumerateDirectories)
exit /b 0

:backupDirectories
    setlocal
        if "%eSTYLE%" == "sub-directories (for-all-stamp)" (
            set "eDIR_DST=%eDIR_DST%\%eTIMESTAMP%"    
        )
     
        @echo [make list of directories] ...
        set "eDIRS="
        for /D %%a  in ("%eDIR_SRC%\*") do (
            call :checkDirectory "%%~na%%~xa"
        )
        rem @echo [dirs] %eDIRS%
        call :enumerateDirectories
    endlocal
exit /b

:processDirectory
    rem @echo [process] %~1
    if "%eSTYLE%" == "sub-directories (everyone-stamp)" (
        call :backup "%~dpn1" "%eDIR_DST%" "%~n1%~x1-%eTIMESTAMP%"
    )
    if "%eSTYLE%" == "sub-directories (for-all-stamp)" (
        call :backup "%~dpn1" "%eDIR_DST%" "%~n1%~x1"
    )
exit /b

rem ============================================================================
rem ============================================================================

:backup
    set "DIR_SRC=%~1"
    set "DIR_DST=%~2"
    set "archive=%~3"
    @echo [backup] %~n1
    @echo   [DIR-SRC] %DIR_SRC%
    @echo   [DIR-DST] %DIR_DST%
    @echo   [ARCHIVE] %archive%
rem @echo   [EXCLUDE] %excludeList%

    7z.exe a -y -t7z -ssw -mx9        ^
        "-mmt=%NUMBER_OF_PROCESSORS%" ^
        %excludeList%                 ^
        "%DIR_DST%\%archive%"         ^
        "%DIR_SRC%"          >nul 2>nul  
exit /b 

rem ============================================================================
rem ============================================================================

:dateTime
    rem %~1 variable name 

    setlocal
    for /f %%a in ('WMIC OS GET LocalDateTime ^| find "."') do (
        set "DTS=%%~a"  
    )

    if errorlevel 1 (
        @echo [ERROR] 'WMIC' finished with error 
        exit /b 1
    )

    set "YY=%DTS:~0,4%"
    set "MM=%DTS:~4,2%"
    set "DD=%DTS:~6,2%"

    set "HH=%DTS:~8,2%"
    set "MIN=%DTS:~10,2%"
    set "SS=%DTS:~12,2%"
    rem set "MS=%DTS:~15,3%"

    set "curDate=%YY%y-%MM%m-%DD%d"
    set "curTime=%HH%h-%MIN%min"
    set "curDateTime=%curDate%_%curTime%"

    endlocal & set "%~1=%curDateTime%"
exit /b 

rem ============================================================================
rem ============================================================================

:makeExcludeList
    set "excludeMasks=%eEXCLUDE%"
    set "excludeList="
:loopMakeExcludeList
    for /f "tokens=1* delims=; " %%g in ("%excludeMasks%") do (
        set "excludeMasks=%%~h"
        set "excludeList=%excludeList% -xr!%%g"
    )
    if defined excludeMasks goto :loopMakeExcludeList
exit /b

rem ============================================================================
rem ============================================================================

:find7z
    set "PATH=%ePATHS%;%PATH%"
    where 7z.exe >nul 2>nul
    if errorlevel 1 (@echo [ERROR] 7z.exe not found)
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

:normalizePath
    call :normalizePathImpl "%~1" "?:\%~2\."
exit /b

:normalizePathImpl
    setlocal
    set "RETVAL=%~f2"
    endlocal & set "%~1=%RETVAL:?:\=%" 
exit /b

rem ============================================================================
rem ============================================================================
