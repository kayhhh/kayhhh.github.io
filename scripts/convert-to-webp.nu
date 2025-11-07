#!/usr/bin/env nu

# Convert all images to WebP format.

def main [] {
    print "Converting all images to WebP..."

    # Find all images in the images directory recursively.
    let images = (glob images/**/*.{jpg,jpeg,png,JPG,JPEG,PNG})

    if ($images | is-empty) {
        print "No images found to convert."
        return
    }

    print $"\nFound ($images | length) images to convert.\n"

    for img in $images {
        let dir = ($img | path dirname)
        let basename = ($img | path parse | get stem)
        let output = ($dir | path join $"($basename).webp")

        print $"Converting ($img) -> ($output)"
        cwebp -q 85 $img -o $output

        if ($output | path exists) {
            print $"  ✓ Created ($output)"
            rm $img
            print $"  ✓ Removed ($img)"
        }
    }

    print "\nDone! All images converted to WebP."
}
