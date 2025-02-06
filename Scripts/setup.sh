#!/bin/bash

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3 and try again."
    exit 1
fi

# Check if pip is installed
if ! command -v pip3 &> /dev/null; then
    echo "❌ pip3 is not installed. Please install pip3 and try again."
    exit 1
fi

# Check if Tesseract is installed
if ! command -v tesseract &> /dev/null; then
    echo "❌ Tesseract is not installed. Please install Tesseract OCR and try again."
    echo "📝 Installation instructions:"
    echo "  Ubuntu/Debian: sudo apt-get install tesseract-ocr"
    echo "  MacOS: brew install tesseract"
    exit 1
fi

echo "🔍 Creating virtual environment..."
python3 -m venv venv

echo "🔄 Activating virtual environment..."
source venv/bin/activate

echo "📦 Installing dependencies..."
pip install -r requirements.txt

echo "✅ Setup complete! You can now run the application using:"
echo "   bash Scripts/launch.sh"
