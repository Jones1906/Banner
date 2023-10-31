#!/bin/bash
# Author: Jeffin Tom
# Student ID: 041094535

# Function to print the help screen
print_help() {
    echo "Options:"
    echo "  -w NUM     Set the width of the banner (default: terminal width)"
    echo "  -p NUM     Set the number of spaces to pad above and below the text (default: 1)"
    echo "  -c [CHAR]  Set the border character (default: *)"
    echo "  -n         Only echo the centered text without printing a banner"
    echo "Created by: Jeffin Tom"
}

# Function to print the top line with options
top_line() {
    local width="$1"
    echo -n "+"
    for ((i = 0; i < width - 2; i++)); do
        echo -n "-"
    done
    echo "+"
}

# Function to print the empty line with options
empty_line() {
    local width="$1"
    echo -n "|"
    for ((i = 0; i < width - 2; i++)); do
        echo -n " "
    done
    echo "|"
}

# Function to print the banner with options
print_banner() {
    local length="$1"
    local width="$2"
    local text="$3"

    # Calculate the number of padding spaces on each side
    local padding=$(( (width - ${#text}) / 2 ))

    # Print the top solid line
    top_line "$width"

    # Print the empty lines with side columns
    for ((i = 0; i < (length - 2); i++)); do
        empty_line "$width"
    done

    # Print the line with centered text
    echo -n "|"
    for ((i = 0; i < padding - 1; i++)); do
        echo -n " "
    done
    echo -n "$text"

    # Adjust padding for odd-length strings
    if (( ${#text} % 2 != 0 )); then
        padding=$(( padding - 1 ))
    fi

    for ((i = 0; i < padding - 1; i++)); do
        echo -n " "
    done
    echo "|"

    # Print the empty lines with side columns in reverse order
    for ((i = (length - 3); i >= 0; i--)); do
        empty_line "$width"
    done

    # Print the bottom solid line
    top_line "$width"
}
# Check if the argument is --help
if [[ "$1" == "--help" ]]; then
    print_help
    exit 0
fi

# Parse the command line arguments using getopts
while getopts ":w:p:c:n" opt; do
    case $opt in
        w)
            width=$OPTARG
            ;;
        p)
            padding=$OPTARG
            ;;
        c)
            border_char=$OPTARG
            ;;
        n)
            only_text=true
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            echo "Try 'banner --help' for more information."
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument."
            exit 1
            ;;
    esac
done
# Shift the command line arguments
shift $((OPTIND - 1))

# Check if the string argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: banner [OPTION]... STRING"
    echo "Try 'banner --help' for more information."
    exit 1
fi

# Get the terminal width if width is not provided
width=${width:-$(tput cols)}
# Set default values if options are not provided
padding=${padding:-1}
border_char=${border_char:-"*"}

# Print the banner or only the centered text
if [[ "$only_text" == true ]]; then
    echo 
    echo -e "\t\t\t\t\t\t\t\t\t""$1"
    echo
else
    print_banner "$padding" "$width" "$1"
fi
