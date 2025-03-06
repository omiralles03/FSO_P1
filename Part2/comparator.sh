#!/bin/bash

# -------------------------------------
# PART 2: Ampliació de funcionalitats
# -------------------------------------

# Default values
show_compare=false
ignore_whites=false
sim=false
extensions=()
#ignore_file=""
ignore_dir=""
check_perms=false
output_file=""
editor="cat"

# Parse getopt arguments
while getopts "cwsf:d:po:" opt; do 
    case "$opt" in 
        c)
            show_compare=true
            ;;
        w)
            ignore_whites=true
            ;;
        s)
            sim=true
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
            # Redirect output to the specified file
            output_file="$OPTARG"
            exec > "$output_file" 2>&1
            ;;
        *)
            echo "Invalid option: -${OPTARG}" >&2 
            exit 1 
            ;;
    esac
done
shift $((OPTIND-1)) # Remove opts args to access positional args

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

echo "-------------------------------------"
echo "      RESULTATS DE LA COMPARACIO     "
echo "-------------------------------------"
echo ""
# 1. Recursive comparison
# FLAGS:
#   -1: Suppress lines unique to file1.
#   -2: Suppress lines unique to file2.
#   -3: Suppress lines common to both files.
echo -e "Fitxers només a $DIR1:\n"
comm -23 <(find "$DIR1" -type f -printf "%P\n" | sort) <(find "$DIR2" -type f -printf "%P\n" | sort) | sed "s|^|\t> |"

echo -e "\nFitxers només a $DIR2:\n"
comm -13 <(find "$DIR1" -type f -printf "%P\n" | sort) <(find "$DIR2" -type f -printf "%P\n" | sort) | sed "s|^|\t> |"

# 2.3 Calculate similarity
calculate_similarity() {
    local file1="$1"
    local file2="$2"

    # Save the content of the files
    local content1=$(<"$file1")
    local content2=$(<"$file2")

    # Remove whitespaces if the flag is set
    if $ignore_whites; then
        content1=$(echo "$content1" | tr -d '[:space:]')
        content2=$(echo "$content2" | tr -d '[:space:]')
    fi
    
    # Total number of characters in each file
    local chars1=${#content1}
    local chars2=${#content2}
    local total_chars=$((chars1 > chars2 ? chars1 : chars2))
    
    # Number of matching characters
    local match_chars=0 
    for ((i = 0; i < total_chars; i++)); do
        chars1=${content1:$i:1}
        chars2=${content2:$i:1}
        if [ "$chars1" == "$chars2" ]; then
            ((match_chars++))
        fi
    done
    
    # Calculate the similarity
    local similarity=0
    if ((total_chars > 0)); then
        similarity=$((match_chars * 100 / total_chars))
    fi 
    echo "$similarity"
}

# 2. Advanced comparison
advanced_comparison() {
    local file1="$1"
    local file2="$2"

    # Get the total number of lines in each file
    if $ignore_whites; then
        local diffed=$(diff -B -w -u0 "$file1" "$file2" | grep -v '^@@')
    else
        local diffed=$(diff -u0 "$file1" "$file2" | grep -v '^@@')
    fi
    
    # If flag is set and files are not the same, show the differences
    if $show_compare && [[ -n "$diffed" ]]; then
        echo -e "\nLinies diferents:\n" | sed "s|^|\t|"
        echo "$diffed" | sed "s|^|\t\t|"
        echo ""
    fi

    # Return the absolute path if the similarity is greater than 90%
    if $sim; then
        local similarity=$(calculate_similarity "$file1" "$file2")
        echo -e ": Els fitxers tenen un $similarity% de similitud.\n" | sed "s|^|\t\t|"
        if [ "$similarity" -ge 90 ]; then
            # Print the absolute path of the files
            echo "> $(realpath -e "$file1")" | sed "s|^|\t\t|"
            echo "> $(realpath -e "$file2")" | sed "s|^|\t\t|"
        fi
    fi

    # Print the result
    if [ -z "$diffed" ]; then
        echo "* Els fitxers $relpath son iguals." | sed "s|^|\t|"
    else
        echo "! Els fitxers $relpath son diferents." | sed "s|^|\t|"
    fi
}

perms_comparison() {
    local file1="$1"
    local file2="$2"

    # Check the permissions of the files
    local perms1=$(stat -c "%a" "$file1")
    local perms2=$(stat -c "%a" "$file2")
    if [ "$perms1" != "$perms2" ]; then
        echo -e "! Els permisos son diferents:\n" | sed "s|^|\t|"
        echo "> "$file1" : $perms1 = $(stat -c "%A" "$file1")" | sed "s|^|\t\t|"
        echo "> "$file2" : $perms2 = $(stat -c "%A" "$file2")" | sed "s|^|\t\t|"
    else
        echo -e "* Els permisos son iguals:\n" | sed "s|^|\t|"
        echo "> "$file1" : $perms1 = $(stat -c "%A" "$file1")" | sed "s|^|\t\t|"
        echo ""
    fi
}

# 3. Ignore certain files

# Convert the comma-separated string into an array
if [ -n "$ignore_file" ]; then
    IFS=',' read -r -a extensions <<< "$ignore_file"
    echo -e "\nComparacio avancada de fitxers ignorant (${extensions[@]}):\n"
else
    echo -e "\nComparacio avancada de fitxers:\n"
fi

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
            echo -e " || Comparant: $DIR1/$relpath <--> $DIR2/$relpath\n"
            if ! diff -q "$DIR1/$relpath" "$DIR2/$relpath" >/dev/null; then
                advanced_comparison "$DIR1/$relpath" "$DIR2/$relpath"
            else
                echo "* Els fitxers $relpath son iguals." | sed "s|^|\t|"
            fi
        fi

        if $check_perms; then
            perms_comparison "$DIR1/$relpath" "$DIR2/$relpath"
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
