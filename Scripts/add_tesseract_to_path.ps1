# add_tesseract_to_path.ps1

# Define the path to the Tesseract-OCR executable
$tesseractPath = "C:\Program Files\Tesseract-OCR"

# Check if the Tesseract-OCR directory exists
if (Test-Path $tesseractPath) {
  # Add the path to the system's PATH environment variable
  [System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";" + $tesseractPath, [System.EnvironmentVariableTarget]::Machine)

  # Verify the installation
  $output = & tesseract --version
  if ($output -match "tesseract") {
    Write-Output "Tesseract-OCR has been successfully added to the PATH."
  }
  else {
    Write-Output "Failed to verify Tesseract-OCR installation."
  }
}
else {
  Write-Output "Tesseract-OCR directory not found at $tesseractPath. Please ensure Tesseract-OCR is installed correctly."
}
