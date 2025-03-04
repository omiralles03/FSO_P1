#!/bin/bash

# -------------------------------------
# PART 2: Ampliació de funcionalitats
# -------------------------------------

# Default values
DEBUG=false
show_compare=false
ignore_file=""
ignore_dir=""
check_perms=false
output_file=""
editor="cat"
# Parse getopt arguments
while getopts "cf:d:po:" opt; do 
    case "$opt" in 
        c)
            show_compare=true
            ;;
        f)
            ignore_file="$OPTARG"
            ;;
        d)
            ignore_dir="$OPTARG"
            ;;
        p)
            check_perms=true
            ;;
        o)
            output_file="$OPTARG"
            ;;
        *)
            echo "Invalid option: -${OPTARG}" >&2 
            exit 1 
            ;;
    esac
done
shift $((OPTIND-1)) # Remove opts args to access positional args

# Redirect output to a file
if [ -n "$output_file" ]; then
    exec > "$output_file" 2>&1
fi

# Comprovar si es passen 2 params i existeixen
if [ "$#" -ne 2 ]; then
    echo "Ús: $0 [-f extensio1,extensio2,...] [-d subdirectori] <directori1> <directori2>" >&2
        
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

    echo -e "      : Els fitxers tenen un $similarity% de similitud.\n"
    if [ "$similarity" -ge 90 ]; then
        # Print the absolute path of the files
        echo "      > $(realpath -e "$file1")"
        echo "      > $(realpath -e "$file2")"
    fi

    if $show_compare; then
        echo -e "\n   Linies diferents:\n"
        echo "$diffed"
    fi
    # Check the permissions of the files
    if $check_perms; then
        local perms1=$(stat -c "%a" "$file1")
        local perms2=$(stat -c "%a" "$file2")
        if [ "$perms1" != "$perms2" ]; then
            echo -e "\n      - Els permisos son diferents:"
            echo "         > $(realpath -e "$file1")"
            echo "            : $perms1 = $(stat -c "%A" "$file1")"
            echo "         > $(realpath -e "$file2"): $perms2"
            echo "            : $perms2 = $(stat -c "%A" "$file2")"
        else
            echo -e "\n      - Els permisos son iguals:"
            echo "         > $perms1 = $(stat -c "%A" "$file1")"
        fi
    fi

    if $DEBUG; then
        echo -e "\nDEBUG INFO:"
        echo "Total lines in $file1: $total1"
        echo "Total lines in $file2: $total2"
        echo "Total lines compared: $total_lines"
        echo "Different lines: $diff_lines"
        echo "Similitud: $similarity%"
        echo "Permisos de $file1: $perms1"
        echo "Permisos de $file2: $perms2"
    fi
}

echo -e "\nComparacio avancada de fitxers ignorant {$ignore_file}\n"

# 3. Ignore certain files
# Convert the file extension string into an array
if [ -n "$ignore_file" ]; then 
    IFS=',' read -r -a extensions <<< "$ignore_file"
fi
isCompared=false
# Apply filters to the files
find "$DIR1" -type f -printf "%P\n" | while IFS= read -r relpath; do
    if [ -f "$DIR2/$relpath" ]; then
        skip=false

        # Check if the subdirectory is in the ignore list
        if [ -n "$ignore_dir" ]; then
            if [[ "$relpath" == "$ignore_dir"* ]]; then
                skip=true
            fi
        fi

        # Check if the file extension is in the ignore list
        if [ -n "$ignore_file" ]; then
            for ext in "${extensions[@]}"; do
                if [[ "$relpath" == *"$ext" ]]; then
                    skip=true
                    break
                fi
            done
        fi
        # Compare the files if they are not skipped
        if ! $skip; then 
            echo ""
            echo -e "   Comparant: $DIR1/$relpath <--> $DIR2/$relpath\n"
            if ! diff -q "$DIR1/$relpath" "$DIR2/$relpath" >/dev/null; then
                advanced_comparison "$DIR1/$relpath" "$DIR2/$relpath"
                if $DEBUG; then 
                    echo "skip: $skip" 
                    echo "compared: $isCompared"
                fi
                isCompared=true
            else
                echo "      ! Els fitxers $relpath són iguals."
            fi
        fi
    fi
done


# Open output file
# dev/tty is used to read input from the terminal
if [ -n "$output_file" ]; then
    echo "Resultats guardats a $output_file" > /dev/tty
    echo "Vols veure els resultats? (y/n)" > /dev/tty
    read -r res < /dev/tty
    if [ "$res" == "y" ]; then
        echo "Com el vols veure?"> /dev/tty
        echo "vim[1], neovim[2], nano[3], cat[4]: " > /dev/tty
        read -r option < /dev/tty
        case $option in
            1) editor="vim";;
            2) editor="nvim";;
            3) editor="nano";;
            4) editor="cat";;
            *) echo "Opció no vàlida. S'obrirà amb cat." > /dev/tty;;
        esac
        echo "Obrint amb $editor..." > /dev/tty
        $editor $output_file > /dev/tty
    fi
fi
