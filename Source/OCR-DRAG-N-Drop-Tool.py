import os
import platform
import sys

import cv2  # pylint: disable=no-member
import pytesseract  # pylint: disable=import-error
from PySide6.QtCore import QRunnable  # pylint: disable=import-error
from PySide6.QtCore import QObject, Qt, QThreadPool, Signal
from PySide6.QtGui import QFont  # pylint: disable=import-error
from PySide6.QtWidgets import QApplication  # pylint: disable=import-error
from PySide6.QtWidgets import (
    QFileDialog,
    QHBoxLayout,
    QLabel,
    QMainWindow,
    QMessageBox,
    QProgressBar,
    QPushButton,
    QTextEdit,
    QVBoxLayout,
    QWidget,
)

# Try to find Tesseract executable
tesseract_path = None
tessdata_path = None
if platform.system() == "Windows":
    # Check default installation paths
    possible_paths = [
        r"C:\Program Files\Tesseract-OCR\tesseract.exe",
        r"C:\Program Files (x86)\Tesseract-OCR\tesseract.exe",
    ]
    for path in possible_paths:
        if os.path.exists(path):
            tesseract_path = path
            tessdata_path = os.path.join(os.path.dirname(path), "tessdata")
            break
else:
    # For other systems, rely on PATH or environment variables
    tesseract_path = "tesseract"  # Assumes it's in PATH

if tesseract_path:
    pytesseract.pytesseract.tesseract_cmd = tesseract_path
    # Set the TESSDATA_PREFIX environment variable
    if tessdata_path and os.path.exists(tessdata_path):
        os.environ["TESSDATA_PREFIX"] = tessdata_path


class WorkerSignals(QObject):
    """
    Defines the signals available from a running worker thread.
    """

    finished = Signal()
    result = Signal(str)
    progress = Signal(int)
    error = Signal(str)  # Signal for error messages


class ImageProcessor(QRunnable):
    """
    Processes a single image file to extract text using Tesseract OCR.
    """

    def __init__(self, file, config=None):
        """
        Initializes the ImageProcessor with the file path.
        """
        super().__init__()
        self.file = file
        self.config = config
        self.signals = WorkerSignals()

    def preprocess_image(self, image):
        """
        Basic preprocessing focused on clarity and contrast.
        """
        # Convert to grayscale
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

        # Simple thresholding
        _, binary = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)

        return binary

    def run(self):
        """
        Runs the image processing task in a separate thread.
        """
        try:
            # Load the image using OpenCV
            image = cv2.imread(self.file)
            if image is None:
                msg = f"Could not open or read the image: {self.file}"
                raise ValueError(msg)

            # Preprocess the image
            processed_image = self.preprocess_image(image)

            # Perform OCR using pytesseract with configuration
            extracted_text = pytesseract.image_to_string(
                processed_image, config=self.config
            )

            # Clean up the extracted text
            extracted_text = extracted_text.strip()
            if not extracted_text:
                msg = "No text was found in the image"
                self.signals.error.emit(msg)
                return

            # Emit the extracted text as a result
            self.signals.result.emit(extracted_text)
            self.signals.finished.emit()

        except Exception as e:
            # Handle any exceptions during image processing
            msg = f"Error processing {self.file}: {str(e)}"
            self.signals.error.emit(msg)


class MainWindow(QMainWindow):
    """
    Main window of the image processing tool.
    """

    def __init__(self):
        """
        Initializes the main window and sets up the UI.
        """
        super().__init__()

        # Check if Tesseract is available
        if not tesseract_path or not os.path.exists(tesseract_path):
            QMessageBox.critical(
                None,
                "Error",
                "Tesseract OCR is not installed or not found. Please install Tesseract OCR and try again.",
            )
            sys.exit(1)

        self.setWindowTitle("Image Processing Tool")
        self.setGeometry(100, 100, 800, 600)
        self.setAcceptDrops(True)

        # Set up the UI components
        self.text_edit = QTextEdit()
        self.text_edit.setFont(QFont("Arial", 12))
        self.text_edit.setReadOnly(True)

        self.label = QLabel("Drag and drop image files or use Open Folder")
        self.label.setAlignment(Qt.AlignCenter)
        self.label.setFont(QFont("Arial", 16))
        self.label.setStyleSheet(
            "color: #333; background-color: #f0f0f0; padding: 20px;\n"
            "border-radius: 10px;"
        )

        # Create button layout with three buttons
        button_layout = QHBoxLayout()

        self.folder_button = QPushButton("Open Folder")
        self.folder_button.clicked.connect(self.select_folder)
        self.folder_button.setStyleSheet(
            "background-color: #2196F3; color: white; padding: 8px;\n"
            "border-radius: 5px;"
        )
        button_layout.addWidget(self.folder_button)

        self.save_button = QPushButton("Save")
        self.save_button.clicked.connect(self.save_text)
        self.save_button.setStyleSheet(
            "background-color: #4CAF50; color: white; padding: 8px;\n"
            "border-radius: 5px;"
        )
        button_layout.addWidget(self.save_button)

        self.clear_button = QPushButton("Clear")
        self.clear_button.clicked.connect(self.clear_text)
        self.clear_button.setStyleSheet(
            "background-color: #f44336; color: white; padding: 8px;\n"
            "border-radius: 5px;"
        )
        button_layout.addWidget(self.clear_button)

        self.progress_bar = QProgressBar()
        self.progress_bar.setRange(0, 100)
        self.progress_bar.setValue(0)
        style = (
            "QProgressBar {border: 2px solid grey; "
            "border-radius: 5px; text-align: center;}\n"
            "QProgressBar::chunk {background-color: #4CAF50; "
            "width: 10px; margin: 0.5px;}"
        )
        self.progress_bar.setStyleSheet(style)

        layout = QVBoxLayout()
        layout.addWidget(self.label)
        layout.addWidget(self.text_edit)
        layout.addLayout(button_layout)
        layout.addWidget(self.progress_bar)

        container = QWidget()
        container.setLayout(layout)
        self.setCentralWidget(container)

        # Set the window style
        self.setStyleSheet(
            """
            QMainWindow {
                background-color: #f5f5f5;
            }
            QTextEdit {
                background-color: white;
                border: 1px solid #ddd;
                border-radius: 5px;
            }
            """
        )

        self.extracted_texts = []
        self.threadpool = QThreadPool()
        self.total_files = 0
        self.processed_files = 0

    def select_folder(self):
        """
        Opens a folder selection dialog and processes all images in the selected folder.
        """
        folder_dialog = QFileDialog()
        folder_path = folder_dialog.getExistingDirectory(
            self, "Select Folder", "", QFileDialog.ShowDirsOnly
        )
        if folder_path:
            self.process_files([folder_path])

    def dragEnterEvent(self, event):
        """
        Handles drag enter events for accepting dropped files.
        """
        if event.mimeData().hasUrls():
            event.acceptProposedAction()

    def dropEvent(self, event):
        """
        Handles drop events for processing dropped files.
        """
        urls = event.mimeData().urls()
        files = [url.toLocalFile() for url in urls if url.isLocalFile()]
        self.process_files(files)

    def count_image_files(self, path):
        """
        Recursively counts image files in a path (file or directory).
        Returns the total count of supported image files.
        """
        supported_extensions = (
            ".png",
            ".jpg",
            ".jpeg",
            ".bmp",
            ".gif",
            ".tiff",
            ".webp",
            ".ppm",
            ".pgm",
            ".pbm",
            ".pnm",
        )

        if os.path.isfile(path):
            return 1 if path.lower().endswith(supported_extensions) else 0

        count = 0
        for root, _, files in os.walk(path):
            for file in files:
                if file.lower().endswith(supported_extensions):
                    count += 1
        return count

    def process_files(self, files):
        """
        Processes a list of image files or folders.
        """
        # Reset state
        self.processed_files = 0
        self.progress_bar.setValue(0)
        self.extracted_texts = []
        self.text_edit.clear()

        # Count total files including those in folders
        self.total_files = sum(self.count_image_files(file) for file in files)

        if self.total_files == 0:
            QMessageBox.warning(
                self,
                "No Images Found",
                "No supported image files were found.\nSupported formats: "
                "PNG, JPG, JPEG, BMP, GIF, TIFF, WebP, PPM, PGM, PBM, PNM",
            )
            return

        # Process each file or folder
        try:
            for file in files:
                if os.path.isdir(file):
                    self.process_folder(file)
                elif os.path.isfile(file):
                    if file.lower().endswith(
                        (
                            ".png",
                            ".jpg",
                            ".jpeg",
                            ".bmp",
                            ".gif",
                            ".tiff",
                            ".webp",
                            ".ppm",
                            ".pgm",
                            ".pbm",
                            ".pnm",
                        )
                    ):
                        self.process_image(file)
        except Exception as e:
            QMessageBox.critical(
                self, "Error", f"An error occurred while processing files: {str(e)}"
            )

    def process_folder(self, folder):
        """
        Recursively processes all image files within a folder.
        Includes error handling and progress updates.
        """
        try:
            for root, _, files in os.walk(folder):
                for file in files:
                    try:
                        if file.lower().endswith(
                            (
                                ".png",
                                ".jpg",
                                ".jpeg",
                                ".bmp",
                                ".gif",
                                ".tiff",
                                ".webp",
                                ".ppm",
                                ".pgm",
                                ".pbm",
                                ".pnm",
                            )
                        ):
                            file_path = os.path.join(root, file)
                            self.label.setText(f"Processing: {file}")
                            self.process_image(file_path)
                    except Exception as e:
                        self.text_edit.append(f"Error processing {file}: {str(e)}\n")
        except Exception as e:
            QMessageBox.warning(
                self, "Folder Error", f"Error accessing folder {folder}: {str(e)}"
            )

    def process_image(self, file):
        """
        Processes a single image file by creating a worker thread.
        Includes enhanced error checking and OCR configuration.
        """
        try:
            if not os.path.exists(file):
                raise FileNotFoundError(f"Image file not found: {file}")

            if not os.path.isfile(file):
                raise ValueError(f"Not a valid file: {file}")

            # Configure Tesseract OCR with robust settings
            config = (
                # Page segmentation mode 3: Fully automatic page segmentation
                "--psm 3 "
                # OCR Engine Mode 3: Default
                "--oem 3 "
                # Enable English language
                "-l eng "
                # Additional parameters for better accuracy
                "--dpi 300"
            )

            worker = ImageProcessor(file, config=config)
            worker.signals.result.connect(self.handle_result)
            worker.signals.finished.connect(self.handle_finished)
            worker.signals.error.connect(self.handle_error)

            self.threadpool.start(worker)

        except Exception as e:
            self.text_edit.append(f"Error setting up OCR for {file}: {str(e)}\n")
            self.processed_files += 1
            progress = int((self.processed_files / self.total_files) * 100)
            self.progress_bar.setValue(progress)

    def handle_result(self, extracted_text):
        """
        Handles the extracted text result from a worker thread.
        """
        self.extracted_texts.append(extracted_text)
        self.update_text_edit()

    def handle_finished(self):
        """
        Handles the finished signal from a worker thread.
        """
        self.processed_files += 1
        progress = int((self.processed_files / self.total_files) * 100)
        self.progress_bar.setValue(progress)
        msg = f"Processed {self.processed_files} of {self.total_files} files"
        self.label.setText(msg)

    def handle_error(self, error_message):
        """
        Handles error signals from worker threads and displays error messages.
        """
        # Display the error message in the text edit
        self.text_edit.append(f"Error: {error_message}")
        self.processed_files += 1
        progress = int((self.processed_files / self.total_files) * 100)
        self.progress_bar.setValue(progress)
        msg = f"Processed {self.processed_files} of {self.total_files} files"
        self.label.setText(msg)

    def update_text_edit(self):
        """
        Updates the text edit with the extracted text from all processed images.
        Uses a line separator between extractions.
        """
        separator = f"\n{'_' * 50}\n\n"
        description = []
        for text in self.extracted_texts:
            description.append(f"\n{text}\n{separator}")

        self.text_edit.setPlainText("".join(description))

    def save_text(self):
        """
        Saves the extracted text to a text file.
        """
        if not self.extracted_texts:
            QMessageBox.warning(
                self,
                "No Text to Save",
                "There is no extracted text to save. "
                "Please process some images first.",
            )
            return

        file_dialog = QFileDialog()
        file_path, _ = file_dialog.getSaveFileName(
            self, "Save Text", "", "Text Files (*.txt)"
        )
        if file_path:
            try:
                separator = f"\n{'_' * 50}\n\n"
                with open(file_path, "w", encoding="utf-8") as file:
                    for text in self.extracted_texts:
                        file.write(f"\n{text}\n{separator}")
                QMessageBox.information(self, "Success", "Text saved successfully!")
            except Exception as e:
                QMessageBox.critical(self, "Error", f"Failed to save text: {str(e)}")

    def clear_text(self):
        """
        Clears the text edit and resets the progress bar.
        """
        self.extracted_texts = []
        self.text_edit.clear()
        self.label.setText("Drag and drop image files or use Open Folder")
        self.progress_bar.setValue(0)
        self.total_files = 0
        self.processed_files = 0


if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec())
