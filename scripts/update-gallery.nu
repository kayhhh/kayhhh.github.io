#!/usr/bin/env nu

# Update gallery.html with color-sorted images from images/gallery/

# Convert RGB (0-255) to HSL and return as record.
def rgb_to_hsl [r: int, g: int, b: int] {
    let r_norm = $r / 255.0
    let g_norm = $g / 255.0
    let b_norm = $b / 255.0

    let max = ([$r_norm $g_norm $b_norm] | math max)
    let min = ([$r_norm $g_norm $b_norm] | math min)
    let delta = $max - $min

    # Lightness.
    let lightness = ($max + $min) / 2.0

    # Saturation.
    let saturation = if $delta == 0 {
        0.0
    } else {
        $delta / (1.0 - (((2.0 * $lightness) - 1.0) | math abs))
    }

    # Hue.
    let hue = if $delta == 0 {
        0.0
    } else if $max == $r_norm {
        ((($g_norm - $b_norm) / $delta) mod 6) * 60.0
    } else if $max == $g_norm {
        ((($b_norm - $r_norm) / $delta) + 2) * 60.0
    } else {
        ((($r_norm - $g_norm) / $delta) + 4) * 60.0
    }

    {
        hue: $hue,
        saturation: $saturation,
        lightness: $lightness
    }
}

def main [] {
    print "Analyzing gallery images and sorting by color..."

    # Get all images in gallery directory
    let images = (ls images/gallery/*.webp
        | where type == file
        | get name
        | each { |file|
            print $"Analyzing ($file)..."

            # Extract dominant color using ImageMagick
            let rgb_str = (magick $file -scale 1x1! -format '%[fx:int(mean.r*255)],%[fx:int(mean.g*255)],%[fx:int(mean.b*255)]' info:-)
            let rgb = ($rgb_str | split row ',' | each { |x| $x | into int })

            let r = ($rgb | get 0)
            let g = ($rgb | get 1)
            let b = ($rgb | get 2)
            let hsl = (rgb_to_hsl $r $g $b)

            # Rotate hue so desert colors (tan/yellow ~45°) map to 0°.
            let hue = (($hsl.hue - 45.0 + 360.0) mod 360.0)

            print $"  RGB: ($r), ($g), ($b) -> Hue: ($hue | math round -p 1), Sat: ($hsl.saturation | math round -p 2), Light: ($hsl.lightness | math round -p 2)"

            {
                file: $file,
                hue: $hue
            }
        }
        | sort-by hue
    )

    print "\nGenerating gallery.html..."

    # Generate HTML
    let image_tags = ($images
        | enumerate
        | each { |item|
            let basename = ($item.item.file | path basename)
            let loading = if $item.index < 2 { "" } else { " loading=\"lazy\"" }
            $"      <img width=\"100%\" src=\"/($item.item.file)\" alt=\"($basename)\"($loading) />"
        }
        | str join "\n")

    let html = $"---
---
<!DOCTYPE html>
<html lang=\"en\">

<head>
  <meta charset=\"UTF-8\">
  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
  <title>kayh.dev</title>
  <link rel=\"stylesheet\" href=\"/style.css\">
</head>

<body>
  <div id=\"root\">
    {% include navbar.html %}

    <main>
($image_tags)
    </main>
  </div>
</body>

</html>
"

    # Write to gallery.html
    $html | save -f gallery.html

    print $"\nDone! Updated gallery.html with ($images | length) images sorted by color."
}
