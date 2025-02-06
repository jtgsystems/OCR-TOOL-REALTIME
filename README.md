# 📝 OCR Drag-N-Drop Tool

> 🔍 Extract text from images with a simple drag and drop!

## ✨ Features

🎯 **Simple to Use**

- Just drag & drop images onto the window
- Process entire folders with one click
- Real-time text extraction

🚀 **Powerful Processing**

- Batch process multiple images
- Support for all common image formats
- Live progress tracking

💾 **Easy Export**

- Save extracted text to files
- Clean, formatted output
- Automatic file handling

## 🛠️ Setup

### Prerequisites

- ✅ Python 3.6+
- ✅ Tesseract OCR
- ✅ PySide6, OpenCV, pytesseract

### 📥 Installation

1. **Install Tesseract OCR**

   ```bash
   # Windows: Download from Tesseract GitHub
   # Linux
   sudo apt-get install tesseract-ocr
   # Mac
   brew install tesseract
   ```

2. **Set Up Project**

   ```bash
   # Clone repo
   git clone [repository-url]
   cd OCR-DRAG-N-Drop-Tool

   # Create virtual environment
   python -m venv venv
   source venv/bin/activate  # Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```

3. **Run Setup**

   ```bash
   # Windows
   Scripts/setup.bat
   # Unix
   bash Scripts/setup.sh
   ```

## 🚀 Usage

1. **Launch App**

   ```bash
   # Windows
   Scripts/launch.bat
   # Unix
   bash Scripts/launch.sh
   ```

2. **Extract Text**
   - 🖱️ Drag & drop images onto the window
   - 📁 Or click "Open Folder" to select multiple images
   - 👀 Watch text appear in real-time
   - 💾 Click "Save" to export results

## 📸 Supported Formats

- 🖼️ PNG, JPG/JPEG
- 🎨 BMP, GIF
- 📷 TIFF, WebP
- 🎯 PPM, PGM, PBM, PNM

## ⚡ Error Handling

The tool smartly handles:

- 🚫 Invalid files
- ⚠️ Unreadable images
- 🔍 OCR issues
- 💽 File system errors

## 🤝 Contributing

1. 🍴 Fork the repo
2. 🌿 Create your branch (`git checkout -b feature/Amazing`)
3. 💾 Commit changes (`git commit -m 'Add Amazing Feature'`)
4. 📤 Push to branch (`git push origin feature/Amazing`)
5. 🎯 Open a Pull Request

## 📄 License

MIT License - feel free to use and modify!

## 🙏 Acknowledgments

- 🔍 Tesseract OCR - text recognition
- 🎨 Qt/PySide6 - GUI framework
- 📸 OpenCV - image processing

---

Made with ❤️ for the OCR community
