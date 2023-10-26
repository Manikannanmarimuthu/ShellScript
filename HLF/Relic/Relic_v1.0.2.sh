#!/bin/bash

# Define a function to insert a command after a specific word in a file
insert_command_after_word() {
    local search_word
    local insert_command
    local input_file
    local insert_empty_line
    local line_number

    # Prompt the user for input
    read -p "Enter the word to search for: " search_word
    read -p "Enter the command to insert: " insert_command
    read -p "Enter the input file name: " input_file
    read -p "Do you want to insert an empty line before the command? (yes/no): " insert_empty_line

    # Find the line number of the search word
    local word_line_number=$(grep -n "$search_word" "$input_file" | cut -d':' -f1)

    if [ -z "$word_line_number" ]; then
        echo "Word '$search_word' not found in the file."
    else
        # Increase the line number by 1
        ((word_line_number++))

        # Check if the user wants to insert an empty line
        if [ "$insert_empty_line" == "yes" ]; then
            # Insert an empty line at the specified line number
            sed -i "${word_line_number}a\\" "$input_file"
            ((word_line_number++))
        fi

        # Insert the command at the increased line number directly into the source file
        sed -i "${word_line_number}i$insert_command" "$input_file"
    fi
}

# Call the function
insert_command_after_word
