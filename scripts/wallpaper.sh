#!/bin/bash

# --- CONFIG ---
DIR=$HOME/Pictures/Wallpapers
FPS=60
STEPS=90
TYPE="wave"
RESIZE_TYPE="stretch"
DURATION=2
WIDTH=40
HEIGHT=30
SWWW_PARAMS="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION --resize $RESIZE_TYPE"
SWWW_PARAMS_GIF="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION"


# 1. Get the list of pictures
# Added -i to grep for case-insensitivity just in case!
# 1. Get the list of pictures


PICS=($(ls "${DIR}" | grep -Ei "\.jpg$|\.jpeg$|\.png$|\.gif$" | grep -Ev "mobile|android"))

#Debugging line
#PICS=($(ls "${DIR}" | grep -Ei "\.gif$" | grep -Ev "mobile|android"))

# Pick the actual file
RANDOM_PIC=${PICS[ $RANDOM % ${#PICS[@]} ]}

# Clean the name of the random pick (remove extension) for the menu
CLEAN_RANDOM=$(echo "$RANDOM_PIC" | sed -E 's/\.(jpg|jpeg|png|gif)$//i')

# The text that will appear in Wofi
RANDOM_PIC_NAME="Shuffle: $CLEAN_RANDOM (${#PICS[@]} images)"
# Menu Function
menu() {
    echo "$RANDOM_PIC_NAME"
    # Adds an option to set a random wallpaper as Wofi background
    echo "Random Wofi Backgound"
    # Just list the names without extensions
    printf "%s\n" "${PICS[@]}" | sed -E 's/\.(jpg|jpeg|png|gif)$//i'
}

# --- WOFI CONFIG ---
# (Keep your existing wofi_command block here)
wofi_command="wofi --show dmenu \
            --prompt Search \
            --conf $HOME/.config/wofi/config --style $HOME/.config/wofi/style.css \
            --width=$WIDTH% --height=$HEIGHT% \
            --cache-file=/dev/null \
            --hide-scroll --no-actions \
            --matching=fuzzy"

swww query || swww-daemon

main() {
    choice=$(menu | ${wofi_command})

    if [[ -z $choice ]]; then return; fi

    # Case: Random
    if [ "$choice" = "$RANDOM_PIC_NAME" ]; then
	if [[ $RANDOM_PIC  == *.gif ]]; then
            swww img "${DIR}/${RANDOM_PIC}" $SWWW_PARAMS_GIF && wallust run "${DIR}/${RANDOM_PIC}" && hyprctl reload
            return
        fi
        swww img "${DIR}/${RANDOM_PIC}" $SWWW_PARAMS && wallust run "${DIR}/${RANDOM_PIC}" && hyprctl reload
        return
    fi
    # Adds a file name "background.png" to the Wofi config folder for Wofi backgrounds.
    #To Use the background in Wofi, set the "background" parameter in the Wofi style.css to:
    # background: url($HOME/.config/wofi/background.png);
    if [ "$choice" = "Random Wofi Backgound" ]; then
        cp ${DIR}/${RANDOM_PIC} $HOME/.config/wofi/background.png
        return
    fi
    
    # Case: Specific Picture
    # Since we have no index, we search the array for a filename that matches the choice
    for pic in "${PICS[@]}"; do
        # If the filename (without extension) matches what you clicked
        if [[ "$pic" == "$choice"* ]]; then
        if [[ $pic == *.gif ]]; then
            swww img "${DIR}/${pic}" $SWWW_PARAMS_GIF && wallust run "${DIR}/${pic}" && hyprctl reload
            return
        fi
            swww img "${DIR}/$pic" $SWWW_PARAMS && wallust run "${DIR}/$pic" && hyprctl reload
            break
        fi
    done
}

if pidof wofi >/dev/null; then
    killall wofi
else
    main
fi
