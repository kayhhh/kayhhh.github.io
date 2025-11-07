# Gallery Scripts

Automated scripts for managing the image gallery with color-based sorting.

## Prerequisites

Enter the development shell first:

```bash
nix develop
```

This provides:

- `imagemagick` - For image analysis and color extraction
- `libwebp` - For WebP conversion (`cwebp` command)
- `jekyll` - For building the site

## Scripts

### `convert-to-webp.nu`

Converts all gallery images to WebP format for better compression.

**Usage:**

```bash
nu scripts/convert-to-webp.nu
```

**What it does:**

1. Identifies format of files without extensions
1. Renames them with proper extensions (.jpg, .png)
1. Converts all images to WebP at quality 85
1. Removes original files after successful conversion

**Result:** ~30% smaller file sizes while maintaining quality.

### `update-gallery.nu`

Updates `gallery.html` with all images from `images/gallery/`, sorted by color.

**Usage:**

```bash
nu scripts/update-gallery.nu
```

**What it does:**

1. Scans `images/gallery/` for all `.webp` images
1. Extracts dominant color from each image using ImageMagick
1. Converts RGB to HSL and calculates hue (0-360 degrees)
1. Sorts images by hue (creates color gradient effect)
1. Generates new `gallery.html` with sorted images in single-column layout

**Result:** Gallery displays images in color order (red → orange → yellow → green → cyan → blue → purple).

## Workflow

When adding new images to the gallery:

1. Place images in `images/gallery/`
1. Convert to WebP: `nu scripts/convert-to-webp.nu`
1. Update gallery: `nu scripts/update-gallery.nu`
1. Commit changes

## Current Gallery Stats

- Total images: 12
- Total size: 3.7MB (down from 3.8MB original)
- Format: WebP at quality 85
- Layout: Single-column, full-width, stacked
- Sort order: By hue (color wheel gradient)
