#!/bin/bash

echo "Setting up OCR Tool environment..."

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "Python is not installed! Please install Python 3.x and try again."
    exit 1
fi

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install required packages
echo "Installing required packages..."
python3 -m pip install --upgrade pip
pip install PySide6 opencv-python pytesseract

# Check if Tesseract is installed
if ! command -v tesseract &> /dev/null; then
    echo "Tesseract OCR is not installed!"
    echo "For Ubuntu/Debian: sudo apt-get install tesseract-ocr"
    echo "For macOS: brew install tesseract"
    exit 1
fi

# Launch the application
echo "Starting the application..."
python3 ../Source/OCR-DRAG-N-Drop-Tool.py

# Deactivate virtual environment
deactivate
