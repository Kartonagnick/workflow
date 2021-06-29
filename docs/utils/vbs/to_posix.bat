@echo off & cls & @echo. & @echo.

@echo [BEGIN]

set command=cscript.exe /nologo "%~dp0to_posix.vbs" "2021y-06m-30d 12:30:21"
for /f "usebackq tokens=*" %%a in (`%command%`) do (
    @echo [vbs] %%~a
)

@echo [DONE]
