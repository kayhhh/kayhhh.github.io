#!/usr/bin/env nu

# Convert all images to WebP format.

def main [] {
    print "Converting and optimizing all images to WebP..."

    # Find all image files in the images directory recursively.
    let all_images = (glob images/**/* | where { |path| ($path | path type) == "file" })

    if ($all_images | is-empty) {
        print "No images found to process."
        return
    }

    print $"\nFound ($all_images | length) files to process.\n"

    for img in $all_images {
        let dir = ($img | path dirname)
        let basename = ($img | path parse | get stem)
        let ext = ($img | path parse | get extension)

        # Skip GIFs (preserve animation).
        if $ext == "gif" {
            print $"Skipping ($img) \(.gif\)"
            continue
        }

        # Skip if already webp, only resize if needed to avoid quality loss.
        if $ext == "webp" {
            # Only resize/optimize WebP images in gallery folder.
            if ($img | str contains "images/gallery/") {
                # Check if image width exceeds 1000px.
                let width_str = (magick identify -format '%w' $img)
                let width = ($width_str | into int)

                if $width > 1000 {
                    let temp = ($dir | path join $"($basename).tmp.webp")

                    print $"Resizing ($img) \(($width)px -> 1000px\)"
                    cwebp -resize 1000 0 $img -o $temp

                    if ($temp | path exists) {
                        mv -f $temp $img
                        print $"  ✓ Resized ($img)"
                    }
                } else {
                    print $"Skipping ($img) \(already ≤1000px wide\)"
                }
            } else {
                print $"Skipping ($img) \(WebP outside gallery folder\)"
            }
        } else {
            # Convert non-webp to webp.
            let output = ($dir | path join $"($basename).webp")

            print $"Converting ($img) -> ($output)"
            cwebp -q 85 -resize 1000 0 $img -o $output

            if ($output | path exists) {
                print $"  ✓ Created ($output)"
                rm $img
                print $"  ✓ Removed ($img)"
            }
        }
    }

    print "\nDone! All images converted and optimized."
}
