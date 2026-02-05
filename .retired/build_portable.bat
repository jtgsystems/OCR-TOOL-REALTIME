@echo off
echo Building portable OCR Tool...

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
pip install PySide6 opencv-python pytesseract pyinstaller

REM Create a directory for Tesseract
if not exist "portable_resources" (
    mkdir portable_resources
    mkdir portable_resources\Tesseract-OCR
)

REM Download Tesseract portable
echo Downloading Tesseract...
powershell -Command "& {Invoke-WebRequest -Uri 'https://digi.bib.uni-mannheim.de/tesseract/tesseract-ocr-w64-setup-5.3.1.20230401.exe' -OutFile 'tesseract_installer.exe'}"

REM Extract Tesseract (requires 7zip, will use portable version)
echo Downloading 7zip portable...
powershell -Command "& {Invoke-WebRequest -Uri 'https://www.7-zip.org/a/7zr.exe' -OutFile '7zr.exe'}"

echo Extracting Tesseract...
7zr.exe x tesseract_installer.exe -oportable_resources\Tesseract-OCR

REM Create spec file for PyInstaller
echo Creating PyInstaller spec file...
echo from PyInstaller.utils.hooks import collect_data_files, collect_submodules > ocr_tool.spec
echo datas = collect_data_files('cv2') + collect_data_files('pytesseract') >> ocr_tool.spec
echo datas += [('portable_resources/Tesseract-OCR', 'Tesseract-OCR')] >> ocr_tool.spec
echo hiddenimports = collect_submodules('PySide6') + collect_submodules('cv2') >> ocr_tool.spec
echo a = Analysis(['../Source/OCR-DRAG-N-Drop-Tool.py'], >> ocr_tool.spec
echo              datas=datas, >> ocr_tool.spec
echo              hiddenimports=hiddenimports, >> ocr_tool.spec
echo              hookspath=[], >> ocr_tool.spec
echo              runtime_hooks=[], >> ocr_tool.spec
echo              excludes=[], >> ocr_tool.spec
echo              noarchive=False) >> ocr_tool.spec
echo pyz = PYZ(a.pure, a.zipped_data) >> ocr_tool.spec
echo exe = EXE(pyz, >> ocr_tool.spec
echo           a.scripts, >> ocr_tool.spec
echo           a.binaries, >> ocr_tool.spec
echo           a.zipfiles, >> ocr_tool.spec
echo           a.datas, >> ocr_tool.spec
echo           name='OCR-Tool-Portable', >> ocr_tool.spec
echo           debug=False, >> ocr_tool.spec
echo           bootloader_ignore_signals=False, >> ocr_tool.spec
echo           strip=False, >> ocr_tool.spec
echo           upx=True, >> ocr_tool.spec
echo           upx_exclude=[], >> ocr_tool.spec
echo           runtime_tmpdir=None, >> ocr_tool.spec
echo           console=False, >> ocr_tool.spec
echo           disable_windowed_traceback=False, >> ocr_tool.spec
echo           target_arch=None, >> ocr_tool.spec
echo           codesign_identity=None, >> ocr_tool.spec
echo           entitlements_file=None) >> ocr_tool.spec

REM Build the executable
echo Building executable...
pyinstaller --clean ocr_tool.spec

REM Clean up
echo Cleaning up...
del tesseract_installer.exe
del 7zr.exe
del ocr_tool.spec

REM Create the final portable package
echo Creating portable package...
mkdir "OCR-Tool-Portable"
move "dist\OCR-Tool-Portable.exe" "OCR-Tool-Portable\"
xcopy /E /I "portable_resources\Tesseract-OCR" "OCR-Tool-Portable\Tesseract-OCR\"

echo Done! The portable executable is in the OCR-Tool-Portable folder.
pause
