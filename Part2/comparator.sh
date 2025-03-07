#!/bin/bash

# -------------------------------------
# PART 2: Ampliació de funcionalitats
# -------------------------------------

# Color values
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'

# Underlined color values
URED='\033[4;31m'
UGREEN='\033[4;32m'
UBLUE='\033[4;34m'
UMAGENTA='\033[4;35m'
UCYAN='\033[4;36m'
UYELLOW='\033[4;33m'

# No color
NC='\033[0m'

# Custom icons with colors
INFO="${BLUE}ⓘ ${NC}"         # Displays results
ARROW="${CYAN}➜ ${NC}"        # Entry of a directory
IDK="${YELLOW}≈ ${UYELLOW}"   # Indicates similarity
NOTE="${MAGENTA}➥${NC}"       # Entry of a list
CMP="${NC}<==>${NC}"          # Comparison
WARN="${RED}✗ ${URED}"        # Failure / Warning
OK="${GREEN}✓ ${UGREEN}"      # Success 

# Default values
show_compare=false
ignore_whites=false
sim=false
ignore_file=""
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
            # Disable colors to avoid file having color codes
            RED="" GREEN="" BLUE="" MAGENTA="" CYAN="" YELLOW="" NC=""
            URED="" UGREEN="" UBLUE="" UMAGENTA="" UCYAN="" UYELLOW=""
            INFO="ⓘ " ARROW="➜ " IDK="≈ " NOTE="➥" CMP="<==>" WARN="✗ " OK="✓ "
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

echo -e "${BLUE}-------------------------------------"
echo -e "      RESULTATS DE LA COMPARACIO     "
echo -e "-------------------------------------${NC}"
echo ""
# 1. Recursive comparison
# FLAGS:
#   -1: Suppress lines unique to file1.
#   -2: Suppress lines unique to file2.
#   -3: Suppress lines common to both files.
echo -e "Fitxers només a ${CYAN}$DIR1${NC}:\n"
comm -23 <(find "$DIR1" -type f -printf "%P\n" | sort) <(find "$DIR2" -type f -printf "%P\n" | sort) | sed "s|^|\t`printf "${ARROW}"`|"
echo -e "\nFitxers només a ${CYAN}$DIR2${NC}:\n"
comm -13 <(find "$DIR1" -type f -printf "%P\n" | sort) <(find "$DIR2" -type f -printf "%P\n" | sort) | sed "s|^|\t `printf "${ARROW}"`|"

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
        echo -e "\n${INFO}Linies diferents:\n" | sed "s|^|\t|"
        echo "$diffed" | sed "s|^|\t\t|"
        echo ""
    fi

    # Return the absolute path if the similarity is greater than 90%
    if $sim; then
        local similarity=$(calculate_similarity "$file1" "$file2")
        echo -e "${INFO}Els fitxers tenen un ${MAGENTA}$similarity%${NC} de similitud\n" | sed "s|^|\t|"
        if [ "$similarity" -ge 90 ]; then
            # Print the absolute path of the files
            echo -e "${ARROW}${BLUE} $(realpath -e "$file1")${NC}" | sed "s|^|\t\t|"
            echo -e "${ARROW}${BLUE} $(realpath -e "$file2")${NC}\n" | sed "s|^|\t\t|"
        fi
    fi

    # Print the result
    if [ -z "$diffed" ]; then
        echo -e "${OK}Els fitxers son iguals${NC}" | sed "s|^|\t|"
    else
        if $sim && [[ "$similarity" -ge 90 ]]; then 
            echo -e "${IDK}Els fitxers son molt semblants${NC}" | sed "s|^|\t|"
        else
            echo -e "${WARN}Els fitxers son diferents${NC}" | sed "s|^|\t|"
        fi
    fi
}

perms_comparison() {
    local file1="$1"
    local file2="$2"

    # Check the permissions of the files
    local perms1=$(stat -c "%a" "$file1")
    local perms2=$(stat -c "%a" "$file2")
    echo ""
    if [ "$perms1" != "$perms2" ]; then
        echo -e "${WARN}Els permisos son diferents${NC}\n" | sed "s|^|\t|"
        echo -e "${ARROW} "$file1"" | sed "s|^|\t\t|"
        echo -e "${INFO}${YELLOW} $(stat -c "%A" "$file1") ($perms1)${NC}" | sed "s|^|\t\t\t|"
        echo -e "${ARROW} "$file2"" | sed "s|^|\t\t|"
        echo -e "${INFO}${YELLOW} $(stat -c "%A" "$file2") ($perms2)${NC}" | sed "s|^|\t\t\t|"
    else
        echo -e "${OK}Els permisos son iguals${NC}\n" | sed "s|^|\t|"
        echo -e "${ARROW} "$file1"" | sed "s|^|\t\t|"
        echo -e "${INFO}${YELLOW} $(stat -c "%A" "$file1") ($perms1)${NC}" | sed "s|^|\t\t\t|"
        echo ""
    fi
}

# 3. Ignore certain files

# Convert the comma-separated string into an array
if [ -n "$ignore_file" ]; then
    IFS=',' read -r -a extensions <<< "$ignore_file"
    echo -e "\nComparacio avancada de fitxers ignorant (${YELLOW}${extensions[@]}${NC}):\n"
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
            echo -e " ${NOTE} Comparant: ${CYAN}$DIR1/$relpath ${CMP} ${CYAN}$DIR2/$relpath${NC}\n"
            if ! diff -q "$DIR1/$relpath" "$DIR2/$relpath" >/dev/null; then
                advanced_comparison "$DIR1/$relpath" "$DIR2/$relpath"
            else
                echo -e "${OK}Els fitxers son iguals${NC}" | sed "s|^|\t|"
            fi

            # Check the permissions of the files
            if $check_perms; then
                perms_comparison "$DIR1/$relpath" "$DIR2/$relpath"
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
