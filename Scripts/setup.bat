@echo off
echo Installing dependencies for Advanced OCR Image Processing Tool...

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Python is not installed. Please install Python 3.7 or higher and run this script again.
    pause
    exit /b 1
)

REM Create a virtual environment
python -m venv venv
call venv\Scripts\activate

REM Upgrade pip
python -m pip install --upgrade pip

REM Install required packages
pip install PySide6 pytesseract Pillow opencv-python easyocr

REM Install Tesseract OCR
echo Installing Tesseract OCR...
winget install --id UB-Mannheim.TesseractOCR

REM Download and install additional Tesseract language data
echo Downloading additional Tesseract language data...
mkdir "%ProgramFiles%\Tesseract-OCR\tessdata"
curl -L "https://github.com/tesseract-ocr/tessdata_best/raw/main/eng.traineddata" -o "%ProgramFiles%\Tesseract-OCR\tessdata\eng.traineddata"
curl -L "https://github.com/tesseract-ocr/tessdata_best/raw/main/osd.traineddata" -o "%ProgramFiles%\Tesseract-OCR\tessdata\osd.traineddata"

echo Dependencies installed successfully!
echo To run the Advanced OCR Image Processing Tool, activate the virtual environment and run the Python script:
echo venv\Scripts\activate
echo python image_processing_tool.py

pause