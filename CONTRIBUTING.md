# Contributing to OCR Drag-N-Drop Tool

Thank you for your interest in contributing to the OCR Drag-N-Drop Tool! This document provides guidelines and instructions for contributing to the project.

## Development Setup

### Prerequisites

- Python 3.8 or higher
- Tesseract OCR installed
- Git for version control

### Setting Up Your Development Environment

1. **Fork and Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/OCR-TOOL-REALTIME.git
   cd OCR-TOOL-REALTIME
   ```

2. **Create a Virtual Environment**
   ```bash
   python -m venv venv

   # On Windows
   venv\Scripts\activate

   # On Unix or MacOS
   source venv/bin/activate
   ```

3. **Install Dependencies**
   ```bash
   pip install -r requirements-dev.txt
   ```

4. **Install Tesseract OCR**
   - **Windows**: Download from [Tesseract GitHub](https://github.com/UB-Mannheim/tesseract/wiki)
   - **Linux**: `sudo apt-get install tesseract-ocr`
   - **macOS**: `brew install tesseract`

## Code Quality Standards

### Linting and Formatting

We use `ruff` for both linting and formatting:

```bash
# Check for linting issues
ruff check Source/

# Auto-fix issues
ruff check --fix Source/

# Format code
ruff format Source/
```

### Type Checking

We use `mypy` for static type checking:

```bash
mypy Source/
```

### Running Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=Source --cov-report=html

# Run specific test file
pytest tests/test_main_window.py

# Run with verbose output
pytest -v
```

## Coding Standards

### Python Code Style

- Follow PEP 8 guidelines
- Use type hints for all functions and methods
- Write comprehensive docstrings (Google style)
- Keep functions focused and single-purpose
- Maximum line length: 88 characters

### Example Function with Type Hints and Docstring

```python
def process_image(file_path: str, config: Optional[str] = None) -> str:
    """Process an image file and extract text using OCR.

    Args:
        file_path: Path to the image file to process.
        config: Optional Tesseract configuration string.

    Returns:
        Extracted text from the image.

    Raises:
        FileNotFoundError: If the image file doesn't exist.
        ValueError: If the file is not a valid image.
    """
    # Implementation here
    pass
```

### Naming Conventions

- Classes: `PascalCase` (e.g., `ImageProcessor`, `MainWindow`)
- Functions/Methods: `snake_case` (e.g., `process_image`, `get_base_path`)
- Constants: `UPPER_SNAKE_CASE` (e.g., `SUPPORTED_IMAGE_EXTENSIONS`)
- Private methods: `_leading_underscore` (e.g., `_update_progress`)

## Making Changes

### Branching Strategy

1. Create a new branch for your feature or bugfix:
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bugfix-name
   ```

2. Make your changes and commit them with clear messages:
   ```bash
   git add .
   git commit -m "Add: Description of your changes"
   ```

### Commit Message Guidelines

Use clear, descriptive commit messages:

- **Add**: New feature or functionality
- **Fix**: Bug fix
- **Update**: Improvements to existing features
- **Refactor**: Code restructuring without changing functionality
- **Docs**: Documentation changes
- **Test**: Adding or updating tests
- **Style**: Code formatting changes

Examples:
- `Add: Support for TIFF image format`
- `Fix: Progress bar not updating correctly`
- `Update: Improve OCR accuracy with better preprocessing`
- `Test: Add unit tests for ImageProcessor class`

## Pull Request Process

1. **Update Tests**: Ensure all tests pass and add new tests for your changes
2. **Update Documentation**: Update README.md or other docs if needed
3. **Run Quality Checks**:
   ```bash
   ruff check Source/
   ruff format Source/
   mypy Source/
   pytest
   ```
4. **Create Pull Request**: Provide a clear description of your changes
5. **Code Review**: Address any feedback from maintainers

## Testing Guidelines

### Writing Tests

- Write tests for all new features
- Ensure edge cases are covered
- Use meaningful test names that describe what they test
- Use fixtures for common test setup
- Mock external dependencies (like Tesseract OCR)

### Test Structure

```python
class TestFeatureName:
    """Tests for FeatureName class or module."""

    def test_specific_behavior(self) -> None:
        """Test that specific behavior works correctly."""
        # Arrange
        setup_test_data()

        # Act
        result = perform_action()

        # Assert
        assert result == expected_value
```

## Areas for Contribution

We welcome contributions in these areas:

### Features
- Additional language support for OCR
- Enhanced image preprocessing options
- Batch processing improvements
- Custom OCR configuration UI
- Export to multiple formats (PDF, Word, etc.)

### Bug Fixes
- Report bugs via GitHub Issues
- Include reproduction steps
- Provide system information

### Documentation
- Improve README
- Add code examples
- Create tutorials
- Fix typos

### Testing
- Increase test coverage
- Add integration tests
- Performance benchmarks

## Getting Help

- **Issues**: Check existing issues or create a new one
- **Discussions**: Use GitHub Discussions for questions
- **Email**: Contact maintainers for sensitive issues

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on the code, not the person
- Help others learn and grow

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to the OCR Drag-N-Drop Tool! 🎉
