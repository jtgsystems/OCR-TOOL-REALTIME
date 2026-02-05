@echo off
echo Setting up OCR Tool environment...

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Python is not installed! Please install Python 3.x and try again.
    pause
    exit /b 1
)

REM Create virtual environment if it doesn't exist
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
)

REM Activate virtual environment
call venv\Scripts\activate.bat

REM Install required packages
echo Installing required packages...
python -m pip install --upgrade pip
pip install PySide6 opencv-python pytesseract

REM Check if Tesseract is installed and add to PATH
echo Checking Tesseract installation...
powershell -ExecutionPolicy Bypass -File "%~dp0add_tesseract_to_path.ps1"

REM Launch the application
echo Starting the application...
python ..\Source\OCR-DRAG-N-Drop-Tool.py

REM Keep the window open if there's an error
if %errorlevel% neq 0 (
    echo An error occurred while running the application.
    pause
)

REM Deactivate virtual environment
deactivate
