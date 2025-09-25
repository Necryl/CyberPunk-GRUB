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

    info=$(magick identify -format '%[type] %[bit-depth]' "$file")
    image_type=$(echo "$info" | awk '{print $1}')
    bit_depth=$(echo "$info" | awk '{print $2}')

    needs_conversion=false
    
    if [ "$image_type" == "Palette" ]; then
        echo "  > Indexed PNG found. Will convert to TrueColor."
        needs_conversion=true
    else
        echo "  > Image is already in TrueColor format. OK."
    fi

    if [ "$bit_depth" != "8" ] && [ "$bit_depth" != "16" ]; then
        echo "  > Bit depth is $bit_depth. Will convert to 8-bit."
        needs_conversion=true
    else
        echo "  > Bit depth is $bit_depth. OK."
    fi

    if [ "$needs_conversion" == "true" ]; then
        echo "  > Converting image..."
        temp_file=$(mktemp --suffix=.png)
        
        # Define the PNG color type to force TrueColor (6 = RGBA) and set depth to 8
        if magick "$file" -define png:color-type=6 -depth 8 "$temp_file"; then
            echo "  > Conversion successful. Replacing original file."
            mv "$temp_file" "$file"
        else
            echo "  > Conversion failed. Original file is untouched."
            rm -f "$temp_file"
        fi
    else
        echo "  > No conversion needed."
    fi
    echo

done < <(find . -type f -name "*.png")

if [ "$found_png" == "false" ]; then
    echo "No PNG files found in the current directory or its subdirectories."
fi

echo "Script finished."
