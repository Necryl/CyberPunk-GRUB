#!/bin/bash

# Check for ImageMagick
if ! command -v magick &> /dev/null; then
    echo "Error: ImageMagick 'magick' command not found."
    echo "Please install ImageMagick and try again."
    exit 1
fi

found_png=false

while IFS= read -r file; do
    found_png=true
    echo "Processing file: $file"

    # Create a temporary file for the conversion
    temp_file=$(mktemp --suffix=.png)

    # Unconditionally convert the PNG to a GRUB-compatible format:
    # - png:color-type=6: Forces RGBA (TrueColor with Alpha) to ensure transparency is handled.
    # - png:filter=0:     Disables all PNG filters for maximum compatibility with simple decoders.
    # - depth 8:          Sets the bit depth to 8 bits per channel.
    if magick "$file" -define png:color-type=6 -define png:filter=0 -depth 8 "$temp_file"; then
        echo "  > Conversion successful. Replacing original file."
        mv "$temp_file" "$file"
    else
        echo "  > Conversion failed for '$file'. Original file is untouched."
        rm -f "$temp_file"
    fi
    echo

done < <(find . -type f -name "*.png")

if [ "$found_png" == "false" ]; then
    echo "No PNG files found in the current directory or its subdirectories."
fi

echo "Script finished."
