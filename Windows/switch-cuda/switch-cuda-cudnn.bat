@echo off

REM Check for administrative privileges
NET SESSION >nul 2>&1
if %errorLevel% NEQ 0 (
    echo This script must be run with administrative privileges.
    exit /B 1
)

REM Function to list available CUDA versions
FOR /F "tokens=*" %%G IN ('dir /b /ad "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA"') DO (
    echo %%G
)

echo Available CUDA Versions:
set /P selectedCudaVersion="Enter the desired CUDA version from the list above: "

REM Function to list available cuDNN versions
FOR /F "tokens=*" %%G IN ('dir /b /ad "C:\cudnn"') DO (
    echo %%G
)

echo Available cuDNN Versions:
set /P selectedCudnnVersion="Enter the desired cuDNN version from the list above: "

REM Set the CUDA_PATH and CUDNN_PATH environment variables
set cudaPath=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\%selectedCudaVersion%
set cudnnPath=C:\cudnn\%selectedCudnnVersion%

setx CUDA_PATH "%cudaPath%"
setx CUDNN_PATH "%cudnnPath%"

REM Update the PATH environment variable
FOR /F "tokens=*" %%G IN ('echo %PATH%') DO (
    set "oldPath=%%G"
)

set "newPath="

FOR %%G IN ("%oldPath:;=";"%") DO (
    IF "%%~G" NEQ "" (
        echo.%%G | findstr /I /C:"NVIDIA GPU Computing Toolkit\CUDA" 1>nul || echo.%%G | findstr /I /C:"cudnn" 1>nul || (
            IF NOT DEFINED newPath (
                set "newPath=%%~G"
            ) ELSE (
                set "newPath=!newPath!;%%~G"
            )
        )
    )
)

set "newPath=!newPath!;%cudaPath%\bin;%cudaPath%\libnvvp;%cudnnPath%\bin"

setx PATH "!newPath!"

echo Successfully switched to CUDA version %selectedCudaVersion% and cuDNN version %selectedCudnnVersion%
