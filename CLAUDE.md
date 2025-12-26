# OCR Drag-N-Drop Tool - Claude Code Reference

## Project Overview

**OCR-TOOL-REALTIME** is a desktop application for extracting text from images using Optical Character Recognition (OCR). Built with Python and Qt, it provides a drag-and-drop interface for batch processing images with real-time text extraction.

### Purpose
- Simplify text extraction from images through an intuitive GUI
- Support batch processing of multiple images and folders
- Provide cross-platform support (Windows, Linux, macOS)
- Offer both portable and development deployment options

### Status
Work in Progress - Actively accepting contributions. Core functionality is stable.

### Key Features
- Drag-and-drop image processing
- Batch processing with progress tracking
- Real-time OCR text extraction
- Multi-threaded image processing
- Enhanced image preprocessing for accuracy
- Export results to text files
- Cross-platform support

---

## Directory Structure

```
OCR-TOOL-REALTIME/
├── Source/
│   └── OCR-DRAG-N-Drop-Tool.py    # Main application (484 lines)
├── Scripts/
│   ├── setup.sh                   # Linux/macOS setup script
│   ├── setup.bat                  # Windows setup script
│   ├── launch.sh                  # Linux/macOS launcher
│   ├── launch.bat                 # Windows launcher
│   ├── build_portable.bat         # Portable executable builder
│   └── add_tesseract_to_path.ps1  # Windows PATH configuration
├── README.md                      # User-facing documentation
├── LICENSE                        # MIT License
├── .gitignore                     # Git exclusions
└── banner.png                     # Repository banner image
```

### Key Files

#### Source/OCR-DRAG-N-Drop-Tool.py
Main application file containing:
- `MainWindow` class: Qt-based GUI with drag-and-drop
- `ImageProcessor` class: OCR worker threads
- `WorkerSignals` class: Thread communication signals
- Image preprocessing pipeline
- File handling and error management

#### Scripts/
- **setup.sh/bat**: Automated environment setup (venv, dependencies, Tesseract check)
- **launch.sh/bat**: Quick launchers for starting the app
- **build_portable.bat**: PyInstaller-based portable build system

---

## Technology Stack

### Core Dependencies

#### Python 3.6+
Primary programming language

#### GUI Framework
- **PySide6** (≥6.10.1): Qt6 bindings for Python
  - QMainWindow, QTextEdit, QLabel, QPushButton
  - QFileDialog, QProgressBar, QMessageBox
  - Drag-and-drop events (dragEnterEvent, dropEvent)

#### Image Processing
- **OpenCV (cv2)**: Image manipulation and preprocessing
  - Grayscale conversion
  - Median blur (noise reduction)
  - Adaptive thresholding
  - Morphological operations (closing gaps)

#### OCR Engine
- **Tesseract OCR**: Text recognition engine
  - **pytesseract**: Python wrapper for Tesseract
  - PSM 6 (single uniform text block)
  - OEM 3 (default engine mode)
  - 300 DPI processing
  - Character whitelisting for accuracy

#### Multithreading
- **QThreadPool**: Parallel image processing
- **QRunnable**: Worker thread implementation
- **Signal/Slot**: Thread-safe communication

### Build Tools
- **PyInstaller**: Portable executable creation
- **Virtual Environment**: Isolated dependency management

---

## Development Workflow

### Initial Setup

#### Linux/macOS
```bash
git clone https://github.com/jtgsystems/OCR-TOOL-REALTIME.git
cd OCR-TOOL-REALTIME
chmod +x Scripts/setup.sh
./Scripts/setup.sh
```

#### Windows
```cmd
git clone https://github.com/jtgsystems/OCR-TOOL-REALTIME.git
cd OCR-TOOL-REALTIME
Scripts\setup.bat
```

### Dependencies Installation
```bash
# Manual installation
python3 -m venv venv
source venv/bin/activate  # Linux/macOS
# venv\Scripts\activate.bat  # Windows

pip install --upgrade pip
pip install PySide6 opencv-python pytesseract
```

### Tesseract Installation

#### Linux (Ubuntu/Debian)
```bash
sudo apt-get install tesseract-ocr
```

#### macOS
```bash
brew install tesseract
```

#### Windows
- Download from GitHub: tesseract-ocr-w64-setup
- Install to: `C:\Program Files\Tesseract-OCR\`
- Or use portable version (placed next to executable)

### Running the Application

#### Quick Launch
```bash
# Linux/macOS
bash Scripts/launch.sh

# Windows
Scripts\launch.bat
```

#### Manual Launch
```bash
source venv/bin/activate
python Source/OCR-DRAG-N-Drop-Tool.py
```

### Building Portable Version (Windows)
```cmd
Scripts\build_portable.bat
```

This script:
1. Creates virtual environment
2. Installs dependencies + PyInstaller
3. Downloads Tesseract portable version
4. Creates PyInstaller spec file
5. Builds executable with bundled Tesseract
6. Packages into `OCR-Tool-Portable/` folder

---

## Configuration and Setup

### Tesseract Path Detection

The application automatically detects Tesseract in this order:

1. **Portable Path** (Windows): `[executable_dir]/Tesseract-OCR/tesseract.exe`
2. **Default Installations** (Windows):
   - `C:\Program Files\Tesseract-OCR\tesseract.exe`
   - `C:\Program Files (x86)\Tesseract-OCR\tesseract.exe`
3. **System PATH** (Linux/macOS): `tesseract` command

### Environment Variables
- `TESSDATA_PREFIX`: Automatically set to Tesseract's tessdata directory
- Used for language data files

### Virtual Environment
- **Location**: `venv/` (created in project root)
- **Activation**: Required before running application manually
- **Dependencies**: Isolated from system Python

### Supported Image Formats
```python
SUPPORTED_IMAGE_EXTENSIONS = (
    ".png", ".jpg", ".jpeg", ".bmp", ".gif",
    ".tiff", ".webp", ".ppm", ".pgm", ".pbm", ".pnm"
)
```

---

## Application Architecture

### Main Window (MainWindow Class)

#### UI Components
- **QLabel**: Drag-and-drop instructions / status messages
- **QTextEdit**: Display extracted text (read-only)
- **QPushButton**: "Open Folder", "Save", "Clear" buttons
- **QProgressBar**: Visual progress tracking

#### Event Handlers
- `dragEnterEvent()`: Accept dropped files
- `dropEvent()`: Process dropped files/folders
- `select_folder()`: Open folder dialog

#### File Processing Flow
```
User Action (drag/drop or folder)
    ↓
count_image_files() → Calculate total files
    ↓
process_files() → Reset state, validate files
    ↓
process_folder() / process_image() → Spawn workers
    ↓
ImageProcessor threads → Extract text
    ↓
handle_result() → Collect results
    ↓
update_text_edit() → Display combined text
```

### Image Processor (ImageProcessor Class)

#### Preprocessing Pipeline
```
Original Image (cv2.imread)
    ↓
Convert to Grayscale (cv2.cvtColor)
    ↓
Median Blur - 3x3 kernel (cv2.medianBlur)
    ↓
Adaptive Thresholding (cv2.adaptiveThreshold)
    ↓
Morphological Closing - 2x2 kernel (cv2.morphologyEx)
    ↓
OCR Extraction (pytesseract.image_to_string)
```

#### Tesseract Configuration
```bash
--psm 6          # Page segmentation mode: uniform text block
--oem 3          # OCR Engine Mode: default
-l eng           # English language
--dpi 300        # High-resolution processing
-c tessedit_char_whitelist=... # Allowed characters
-c preserve_interword_spaces=1 # Keep spacing
-c load_system_dawg=1          # Dictionary correction
-c load_freq_dawg=1            # Language model
```

### Worker Signals (WorkerSignals Class)
- `finished`: Processing complete
- `result(str)`: Extracted text ready
- `progress(int)`: Progress update
- `error(str)`: Error message

### Threading Model
- **QThreadPool**: Manages worker threads
- **Parallel Processing**: Multiple images processed simultaneously
- **Thread-Safe Signals**: Qt signal/slot mechanism for UI updates

---

## Performance Considerations

### Optimization Strategies

#### Image Preprocessing
- **Median blur**: Reduces noise without blurring edges
- **Adaptive thresholding**: Handles varying lighting conditions
- **Morphological closing**: Connects broken characters
- **Grayscale conversion**: Reduces processing overhead

#### Multi-threading
- **QThreadPool**: Automatic thread management
- **Parallel image processing**: Faster batch operations
- **Non-blocking UI**: Remains responsive during processing

#### Memory Management
- **Per-image processing**: No full-batch memory load
- **Progress tracking**: Incremental file counting
- **Text accumulation**: Append-only result collection

### Performance Metrics
- **Processing Speed**: Depends on image complexity and Tesseract performance
- **Thread Pool**: Uses system's available CPU cores
- **Memory Usage**: Scales with number of concurrent images

### Bottlenecks
- **Tesseract OCR**: CPU-intensive text recognition
- **Large images**: Higher resolution = longer processing
- **Character whitelisting**: May slow down for complex patterns

---

## Testing Approach

### Manual Testing Areas

#### File Handling
- Single image drag-and-drop
- Multiple images drag-and-drop
- Folder selection and recursive processing
- Invalid file types rejection
- Missing file error handling

#### OCR Accuracy
- Clear printed text
- Handwritten text (limited support)
- Low-quality scans
- Skewed images
- Multiple languages (currently English only)

#### UI Responsiveness
- Progress bar updates
- Status message changes
- Save functionality
- Clear button behavior

#### Cross-platform Testing
- Windows: Tesseract path detection
- Linux: System Tesseract integration
- macOS: Homebrew Tesseract compatibility

### Future Testing Improvements
- Automated unit tests with pytest
- Image preprocessing validation
- OCR accuracy benchmarks
- Performance regression tests
- CI/CD pipeline integration

---

## Known Issues and Troubleshooting

### Common Issues

#### "Tesseract OCR is not found"
**Cause**: Tesseract not installed or not in PATH

**Solution**:
- **Linux/macOS**: Install via package manager
- **Windows**: Install to default location or use portable version
- Verify installation: `tesseract --version`

#### "Could not open or read the image"
**Cause**: Corrupt file, unsupported format, or file permissions

**Solution**:
- Verify file format is in supported list
- Check file permissions
- Test with known-good image

#### "No text was found in the image"
**Cause**: Image quality, no text, or OCR configuration mismatch

**Solution**:
- Improve image quality (resolution, contrast)
- Ensure text is readable
- Check language settings (currently English only)

#### Empty or garbled text output
**Cause**: Poor image quality, complex fonts, or preprocessing issues

**Solution**:
- Use higher resolution images (300 DPI recommended)
- Preprocess images externally (increase contrast, remove noise)
- Adjust Tesseract configuration if needed

### Debugging

#### Enable Console Output (Windows Portable)
Edit `build_portable.bat`:
```python
console=True,  # Change from False
```

#### Check Tesseract Path
Add debug print in `OCR-DRAG-N-Drop-Tool.py`:
```python
print(f"Tesseract path: {tesseract_path}")
print(f"TESSDATA_PREFIX: {os.environ.get('TESSDATA_PREFIX')}")
```

#### Verify Virtual Environment
```bash
which python  # Linux/macOS
where python  # Windows
# Should point to venv/bin/python or venv\Scripts\python.exe
```

---

## Next Steps and Roadmap

### Planned Features

#### OCR Enhancements
- [ ] Multiple language support (via Tesseract language packs)
- [ ] Custom OCR configuration UI
- [ ] Image rotation/deskewing
- [ ] Text region detection (auto-crop)

#### UI/UX Improvements
- [ ] Preview pane for images
- [ ] Individual image results view
- [ ] Copy to clipboard button
- [ ] Dark mode theme
- [ ] Drag-and-drop reordering

#### Processing Features
- [ ] PDF support (extract images from PDFs)
- [ ] Batch export (individual files per image)
- [ ] CSV/JSON export formats
- [ ] OCR confidence scoring
- [ ] Text formatting preservation

#### Performance
- [ ] GPU acceleration (if available)
- [ ] Configurable thread pool size
- [ ] Image caching for re-processing
- [ ] Progress estimation (ETA)

#### Error Handling
- [ ] Detailed error logs
- [ ] Automatic retry on failure
- [ ] Skipped file reporting
- [ ] Recovery from crashes

### Contributing Areas

#### Code Quality
- Add type hints (PEP 484)
- Implement unit tests (pytest)
- Code coverage reporting
- Linting with ruff/pylint

#### Documentation
- API documentation (docstrings)
- Architecture diagrams
- Video tutorials
- Contribution guidelines

#### Build System
- Linux portable build (AppImage)
- macOS app bundle (.app)
- Automated GitHub releases
- Version numbering system

#### Platform Support
- ARM architecture support
- Mobile version (Android/iOS)
- Web version (WASM/PyScript)

---

## Development Guidelines

### Code Style
- **Formatting**: Follow PEP 8
- **Docstrings**: Google-style docstrings
- **Comments**: Explain "why", not "what"
- **Line length**: 88 characters (Black formatter default)

### Git Workflow
1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open Pull Request

### Commit Messages
Use conventional commits format:
```
✨ feat: Add multi-language support
🔧 fix: Resolve Tesseract path detection on Windows
📚 docs: Update installation instructions
🎨 style: Format code with Black
♻️ refactor: Simplify image preprocessing pipeline
```

### Testing Before PR
- [ ] Test on target platform(s)
- [ ] Verify no new linting errors
- [ ] Update documentation if needed
- [ ] Test with various image types
- [ ] Check performance impact

---

## Project Metadata

**Repository**: https://github.com/jtgsystems/OCR-TOOL-REALTIME
**License**: MIT License
**Python Version**: 3.6+
**Maintained By**: JTG Systems (https://www.jtgsystems.com)

### Recent Commits
- Add banner to README
- Refactor image extension handling
- Enhance preprocessing and Tesseract configuration
- Update README for WIP status
- Add portable build script
- Improve setup scripts

---

## Additional Resources

### Tesseract Documentation
- GitHub: https://github.com/tesseract-ocr/tesseract
- Documentation: https://tesseract-ocr.github.io/

### PySide6 Documentation
- Official Docs: https://doc.qt.io/qtforpython/
- API Reference: https://doc.qt.io/qtforpython/api.html

### OpenCV Documentation
- Official Docs: https://docs.opencv.org/
- Python Tutorials: https://docs.opencv.org/master/d6/d00/tutorial_py_root.html

### PyInstaller
- Documentation: https://pyinstaller.org/en/stable/

---

*Last Updated: 2025-10-26*
*Project Status: Work in Progress*
*Contributions Welcome!*

## Framework Versions

- No major frameworks detected in this project
- This may be a utility script, documentation project, or uses custom dependencies

