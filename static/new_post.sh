#!/bin/bash

# Check if a title is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: ./new_post.sh \"Post Title\""
  exit 1
fi

# Get the current date and format it for the post
DATE=$(date +"%Y-%m-%d")
TIME=$(date +"%H:%M:%S")
TITLE=$1

# Convert the title to lowercase, replace spaces with hyphens, and remove special characters
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g' | sed 's/[^a-zA-Z0-9-]//g')

# Set the filename based on the date and title slug
FILENAME="_posts/${DATE}-${SLUG}.md"

# Create the post content with YAML front matter
cat <<EOL > $FILENAME
---
layout: post
title: "$TITLE"
date: ${DATE} ${TIME}
---

EOL

echo "New post created: $FILENAME"
