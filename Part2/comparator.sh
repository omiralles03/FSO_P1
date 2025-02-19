#!/bin/bash

# -------------------------------------
# PART 2: Ampliació de funcionalitats
# -------------------------------------

# TODO: 
#   1. Comparacio recursiva
#   2. Comparacio avancada de fitxers
#   3. Ignorar certs fitxers
#   4. Comprovacio de permisos
#   5. Registre en un fitxer

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

# Llistar contingut dels directoris
# FLAGS:
#   -1: Suppress lines unique to file1.
#   -2: Suppress lines unique to file2.
#   -3: Suppress lines common to both files.
#   find -type f: nomes fitxers
#   
echo "Fitxers només a $DIR1:"
comm -23 <(find "$DIR1" -type f -printf "%P\n" | sort) <(find "$DIR2" -type f -printf "%P\n" | sort)
echo "Fitxers només a $DIR2:"
comm -13 <(find "$DIR1" -type f -printf "%P\n" | sort) <(find "$DIR2" -type f -printf "%P\n" | sort)

# Nomes mostra els fitxers amb el mateix nom
# i diferent contingut de DIR
for file in $(ls "$DIR1"); do
    if [ -f "$DIR2/$file" ]; then
        if ! diff -q "$DIR1/$file" "$DIR2/$file" >/dev/null; then
            echo "Fitxer diferent: $file"
        fi
    fi
done
echo -e "\n"
