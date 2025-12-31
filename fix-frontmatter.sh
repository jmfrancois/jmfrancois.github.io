#!/bin/bash

# Script to fix frontmatter in blog posts for Astro

cd /Users/jeanmichel.francois/github/jmfrancois/jmfrancois.github.io-astro/src/content/posts

for file in *.md *.markdown; do
    if [ -f "$file" ]; then
        # Extract filename without extension
        filename="${file%.*}"
        
        # Extract date from filename (format: YYYY-MM-DD)
        if [[ $filename =~ ^([0-9]{4}-[0-9]{2}-[0-9]{2}) ]]; then
            date="${BASH_REMATCH[1]}"
            
            # Use awk to process the file
            awk -v date="$date" '
            BEGIN { in_frontmatter=0; frontmatter_done=0; }
            /^---$/ { 
                if (!frontmatter_done) {
                    if (in_frontmatter == 0) {
                        print "---"
                        in_frontmatter = 1
                    } else {
                        print "date: " date
                        print "---"
                        frontmatter_done = 1
                    }
                } else {
                    print
                }
                next
            }
            in_frontmatter == 1 {
                if ($1 == "categories:") {
                    # Convert single string to array
                    if (NF == 2 && $2 !~ /^\[/) {
                        print "categories: [\"" $2 "\"]"
                    } else {
                        print
                    }
                } else if ($1 == "tags:") {
                    # Convert tags to array format
                    if (NF > 1 && $2 !~ /^\[/) {
                        printf "tags: ["
                        for (i=2; i<=NF; i++) {
                            if (i > 2) printf ", "
                            printf "\"" $i "\""
                        }
                        print "]"
                    } else {
                        print
                    }
                } else if ($1 == "date:") {
                    # Skip existing date, we'll add it at the end
                    next
                } else {
                    print
                }
                next
            }
            { print }
            ' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
        fi
    fi
done
