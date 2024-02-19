@echo off

if not exist build mkdir build
if exist build\"%~1.exe" del build\"%~1.exe"

copy src\"%~1.asm" lib\ >nul
IF ERRORLEVEL 1 (
    echo Failed to copy %~1.asm to lib directory.
    goto cleanup_on_fail
)

pushd lib
IF ERRORLEVEL 1 (
    echo Failed to change directory to lib.
    goto cleanup_on_fail
)

echo( && echo ----------------ASSEMBLING---------------- && echo(
aml.exe /c /Zd /coff "%~1.asm"
IF ERRORLEVEL 1 (
    echo && echo Assembling %~1.asm failed.
    popd
    goto cleanup_on_fail
)

echo( && echo ----------------LINKING---------------- && echo(
alink.exe /SUBSYSTEM:CONSOLE "%~1.obj" /OUT:"..\build\%~1.exe"
IF ERRORLEVEL 1 (
    echo && echo Linking %~1.obj failed.
    popd
    goto cleanup_on_fail
)

popd

echo ----------------EXECUTING---------------- && echo(
build\"%~1.exe"
IF ERRORLEVEL 1 (
    echo && echo Executing %~1.exe failed.
    goto cleanup_on_fail
)

goto cleanup_on_success

:cleanup_on_success
    del lib\"%~1.asm"
    del lib\"%~1.obj"
    goto end

:cleanup_on_fail
    if exist lib\"%~1.asm" del lib\"%~1.asm"
    if exist lib\"%~1.obj" del lib\"%~1.obj"
    if exist build\"%~1.exe" del build\"%~1.exe"
    
:end
