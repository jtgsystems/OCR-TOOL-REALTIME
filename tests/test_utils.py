"""Tests for utility functions."""

from pathlib import Path

# Import the module - adjust based on actual module structure
import sys

sys.path.insert(0, str(Path(__file__).parent.parent / "Source"))

# This would normally import from the module
# For now, we'll test the functions directly when module is refactored


def test_get_base_path() -> None:
    """Test that get_base_path returns a valid Path object."""
    # This will be implemented when we can import the function
    # from ocr_tool import get_base_path
    # assert isinstance(get_base_path(), Path)
    pass


def test_supported_extensions() -> None:
    """Test that supported image extensions are defined correctly."""
    # This will be implemented when we can import the constant
    # from ocr_tool import SUPPORTED_IMAGE_EXTENSIONS
    # assert ".png" in SUPPORTED_IMAGE_EXTENSIONS
    # assert ".jpg" in SUPPORTED_IMAGE_EXTENSIONS
    pass
