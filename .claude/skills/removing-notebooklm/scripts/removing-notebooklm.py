#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "Pillow>=10.0.0",
#     "pymupdf>=1.24.0",
#     "opencv-python>=4.8.0",
#     "numpy",
# ]
# ///
"""
Remove NotebookLM watermark from PDFs (presentations) and images (infographics).
Uses OpenCV inpainting to seamlessly reconstruct the background.
"""

import sys
import argparse
from pathlib import Path
from PIL import Image
import numpy as np
import cv2
import io


# NotebookLM watermark exact measurements (at 2x scale for quality)
WATERMARK_WIDTH = 194   # pixels at 2x scale
WATERMARK_HEIGHT = 28   # pixels at 2x scale

# Margins for PDF (presentations)
PDF_MARGIN_RIGHT = 18   # pixels from right edge at 2x scale
PDF_MARGIN_BOTTOM = 16  # pixels from bottom edge at 2x scale

# Margins for images (infographics) - slightly different position
IMAGE_MARGIN_RIGHT = 9    # 9px more to the right than PDF
IMAGE_MARGIN_BOTTOM = 10  # 6px more down than PDF

# Inpainting parameters
INPAINT_RADIUS = 3  # Small radius for crisp edges
INPAINT_METHOD = cv2.INPAINT_TELEA  # Fast, good for small regions

# Supported file extensions
PDF_EXTENSIONS = {'.pdf'}
IMAGE_EXTENSIONS = {'.png', '.jpg', '.jpeg'}


def remove_watermark_from_image(img, margin_right, margin_bottom):
    """
    Remove watermark from a single image using OpenCV inpainting.
    Returns the processed image.
    """
    # Convert PIL Image to NumPy array (RGB)
    img_array = np.array(img)
    height, width = img_array.shape[:2]

    # Calculate watermark rectangle position
    x1 = width - margin_right - WATERMARK_WIDTH
    y1 = height - margin_bottom - WATERMARK_HEIGHT
    x2 = width - margin_right
    y2 = height - margin_bottom

    # Create binary mask (white = area to inpaint)
    mask = np.zeros((height, width), dtype=np.uint8)
    mask[y1:y2, x1:x2] = 255

    # Convert RGB to BGR for OpenCV
    img_bgr = cv2.cvtColor(img_array, cv2.COLOR_RGB2BGR)

    # Apply inpainting
    result_bgr = cv2.inpaint(img_bgr, mask, INPAINT_RADIUS, INPAINT_METHOD)

    # Convert back to RGB
    result_rgb = cv2.cvtColor(result_bgr, cv2.COLOR_BGR2RGB)

    # Convert back to PIL Image
    return Image.fromarray(result_rgb)


def process_pdf(input_path: Path, output_path: Path):
    """Process a PDF file (presentation with multiple slides)."""
    try:
        import fitz  # PyMuPDF
    except ImportError:
        print("Error: PyMuPDF not installed. Run: pip install pymupdf")
        sys.exit(1)

    print(f"Processing PDF: {input_path.name}")

    doc = fitz.open(str(input_path))
    total_pages = len(doc)
    print(f"Pages: {total_pages}")

    # Render at 2x scale for quality
    mat = fitz.Matrix(2, 2)
    processed_images = []

    for page_num in range(total_pages):
        page = doc[page_num]
        pix = page.get_pixmap(matrix=mat)
        img = Image.open(io.BytesIO(pix.tobytes("png")))

        # Remove watermark using inpainting
        img = remove_watermark_from_image(img, PDF_MARGIN_RIGHT, PDF_MARGIN_BOTTOM)

        processed_images.append(img)
        print(f"  Page {page_num + 1}/{total_pages}")

    doc.close()

    # Save as PDF
    first_img = processed_images[0].convert('RGB')
    other_imgs = [img.convert('RGB') for img in processed_images[1:]]

    first_img.save(
        str(output_path),
        "PDF",
        resolution=144.0,
        save_all=True,
        append_images=other_imgs
    )

    print(f"Saved: {output_path}")
    return str(output_path)


def process_image(input_path: Path, output_path: Path):
    """Process a single image file (infographic)."""
    print(f"Processing image: {input_path.name}")

    img = Image.open(str(input_path))

    # Ensure RGB mode for OpenCV compatibility
    if img.mode != 'RGB':
        img = img.convert('RGB')

    # Remove watermark using inpainting
    img = remove_watermark_from_image(img, IMAGE_MARGIN_RIGHT, IMAGE_MARGIN_BOTTOM)

    # Save in same format
    img.save(str(output_path))

    print(f"Saved: {output_path}")
    return str(output_path)


def remove_watermark(input_file: str, output_file: str = None):
    """
    Remove NotebookLM watermark from file.
    Automatically detects if PDF or image and processes accordingly.
    """
    input_path = Path(input_file)

    if not input_path.exists():
        print(f"Error: File not found: {input_file}")
        sys.exit(1)

    suffix = input_path.suffix.lower()

    # Determine output path
    if output_file:
        output_path = Path(output_file)
    else:
        output_path = input_path.parent / f"{input_path.stem}_clean{suffix}"

    # Process based on file type
    if suffix in PDF_EXTENSIONS:
        return process_pdf(input_path, output_path)
    elif suffix in IMAGE_EXTENSIONS:
        return process_image(input_path, output_path)
    else:
        print(f"Error: Unsupported file type: {suffix}")
        print(f"Supported: PDF, PNG, JPG")
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description='Remove NotebookLM watermark from PDFs and images'
    )
    parser.add_argument('input_file', help='Input file (PDF, PNG, or JPG)')
    parser.add_argument('--output', help='Output file (optional)')

    args = parser.parse_args()
    remove_watermark(args.input_file, args.output)


if __name__ == '__main__':
    main()
