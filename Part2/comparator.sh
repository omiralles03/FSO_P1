#!/bin/bash

# -------------------------------------
# PART 2: Ampliació de funcionalitats
# -------------------------------------

# TODO: 
#   1. Comparacio recursiva
#   2. Comparacio avancada de fitxers
#   3. Ignorar certs fitxers
#   4. Comprovacio de permisos
#   5. Registre en un fitxers

DEBUG=false

# Comprovar si es passen 2 params i existeixen
if [ "$#" -ne 2 ]; then
    echo "Ús: $0 <directori1> <directori2>" >&2
    exit 1
fi
DIR1=$1
DIR2=$2
if [ ! -d "$DIR1" ] || [ ! -d "$DIR2" ]; then
    echo "Un o ambdós directoris no existeixen." >&2
    exit 1
fi

# 1. Recursive comparison
# FLAGS:
#   -1: Suppress lines unique to file1.
#   -2: Suppress lines unique to file2.
#   -3: Suppress lines common to both files.
echo -e "Fitxers només a $DIR1:\n"
comm -23 <(find "$DIR1" -type f -printf "%P\n" | sort) <(find "$DIR2" -type f -printf "%P\n" | sort) | sed "s|^|   > |"

echo -e "\nFitxers només a $DIR2:\n"
comm -13 <(find "$DIR1" -type f -printf "%P\n" | sort) <(find "$DIR2" -type f -printf "%P\n" | sort) | sed "s|^|   > |"

# 2. Advanced comparison
advanced_comparison() {
    local file1="$1"
    local file2="$2"

    echo -e "$file1 <--> $file2\n"

    # Get the diff between the two files
        # -B: Ignore blank lines
        # -w: Ignore white space when comparing lines
        # -u: Unified output format
    local diffed=$(diff -B -w -u "$file1" "$file2")

    # Get non-empty lines in each file
        # -c: Count the number of lines
        # -v: Invert the sense of comparisons (only selects lines that are different)
        # -e: Regular expression (start of line, any number of spaces, end of line)
    local total1=$(grep -cve '^[[:space:]]*$' "$file1")
    local total2=$(grep -cve '^[[:space:]]*$' "$file2")
    local total_lines=$(( total1 > total2 ? total1 : total2 ))

    # Count lines that are different
        # Get all lines that start with + or - (added or removed lines)
        # Remove lines that start with --- or +++ (file names)
    local diff_lines=$(echo "$diffed" | grep -E '^[+-]' | grep -vE '^(---|\+\+\+)' | wc -l)
    diff_lines=$(( (diff_lines % 2) > 0 ? diff_lines / 2 + 1 : diff_lines / 2 ))

    # Return the absolute name of files with over 90% similarity
    local similarity

    if [ "$total_lines" -gt 0 ]; then
        similarity=$((100 - (diff_lines * 100 / total_lines))) 
    else
        similarity=100 # For empty files
    fi

    echo -e "Els fitxers tenen un $similarity% de similitud.\n"
    if [ "$similarity" -ge 90 ]; then
        # Print the absolute path of the files
        echo "   > $(realpath -e "$file1")"
        echo "   > $(realpath -e "$file2")"
        echo -e "\nDiferencies:\n"
        echo "$diffed"
    fi

    if $DEBUG; then
        echo -e "\nDEBUG INFO:"
        echo "Total lines in $file1: $total1"
        echo "Total lines in $file2: $total2"
        echo "Total lines compared: $total_lines"
        echo "Different lines: $diff_lines"
        echo "Similitud: $similarity%"
    fi
}

# Iterate over all files in DIR1 and compare them with DIR2
echo -e "\nComparacio avancada de fitxers:\n"
find "$DIR1" -type f -printf "%P\n" | while IFS= read -r relpath; do
    if [ -f "$DIR2/$relpath" ]; then
        if ! diff -q "$DIR1/$relpath" "$DIR2/$relpath" >/dev/null; then
            if $DEBUG; then 
                advanced_comparison "d1/countries.txt" "d2/countries.txt" 
            else
                advanced_comparison "$DIR1/$relpath" "$DIR2/$relpath"
            fi
        fi
    fi
done
