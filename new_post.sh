#!/bin/sh

# Check if a title was provided
if [ $# -eq 0 ]; then
    echo "Usage: new \"[title]\""
    exit 1
fi

# Get the title from the command line argument
title="$1"

# Generate the current date in YYYY-MM-DD format
date=$(date +"%Y-%m-%d")

# Convert the title to lowercase and replace spaces with dashes
formatted_title=$(echo "$title" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

# Create the Hugo command
hugo_command="hugo new post/$date-$formatted_title/index.md"

echo "Executing: $hugo_command"

# Execute the Hugo command
$hugo_command