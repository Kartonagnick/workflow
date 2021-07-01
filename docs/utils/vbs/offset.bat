@echo off & cls & @echo. & @echo.

@echo [BEGIN]

set command=cscript.exe /nologo ^
    "%~dp0offset.vbs"           ^
    "2021y-06m-30d 00:00:00"    ^
    "2021y-06m-30d 00:00:10"    ^
    "10"

for /f "usebackq tokens=*" %%a in (`%command%`) do (
    @echo [vbs] %%~a
)

@echo [DONE]
