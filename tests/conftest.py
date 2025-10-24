"""Pytest configuration and shared fixtures."""

import sys
from pathlib import Path

import pytest

# Add Source directory to path for imports
source_dir = Path(__file__).parent.parent / "Source"
sys.path.insert(0, str(source_dir))


@pytest.fixture
def sample_image_path(tmp_path: Path) -> Path:
    """Create a sample image file for testing.

    Args:
        tmp_path: Pytest temporary directory fixture.

    Returns:
        Path to the created test image.
    """
    import cv2
    import numpy as np

    # Create a simple test image with text
    img = np.ones((100, 300, 3), dtype=np.uint8) * 255
    cv2.putText(
        img, "Test Image", (10, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 0), 2
    )

    image_path = tmp_path / "test_image.png"
    cv2.imwrite(str(image_path), img)

    return image_path


@pytest.fixture
def sample_folder_with_images(tmp_path: Path) -> Path:
    """Create a folder with multiple test images.

    Args:
        tmp_path: Pytest temporary directory fixture.

    Returns:
        Path to the folder containing test images.
    """
    import cv2
    import numpy as np

    folder = tmp_path / "test_folder"
    folder.mkdir()

    # Create multiple test images
    for i in range(3):
        img = np.ones((100, 300, 3), dtype=np.uint8) * 255
        cv2.putText(
            img, f"Image {i}", (10, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 0), 2
        )
        image_path = folder / f"test_image_{i}.png"
        cv2.imwrite(str(image_path), img)

    return folder
