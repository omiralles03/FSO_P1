#!/bin/bash
# Joc de proves
#   - Crear directoris
#   - Fitxers unics, iguals i diferents
#   - Subdirectoris amb fitxers unics, iguals i diferents

echo "*/---------------------------------\*"
echo "          JOC DE PROVES PART 2       "
echo "*\---------------------------------/*"

# Esborrar directoris anteriors
if [ -d dir1 ]; then
    rm -r dir1
fi
if [ -d dir2 ]; then
    rm -r dir2
fi
echo -e "\nDirectoris eliminats"
echo $(ls -d */)

# Crear directoris de proves
mkdir dir1 && mkdir dir2
echo -e " \nDirectoris dir1 dir2 creats:"
echo $(ls -d */)

# -------------------
# Fitxers
# -------------------
echo -e "\nCreant fitxers de proves..."
# Unics
echo "Only in dir1" > dir1/file1.txt
echo "Only in dir2" > dir2/file2.txt
echo "Log for dir1" > dir1/log1.log
echo "Log for dir2" > dir2/log2.log
echo "Backup for dir1" > dir1/backup1.bak
echo "Temp for dir2" > dir2/temporal2.tmp
echo "Vim config" > dir1/vim.conf
echo "Lua content" > dir2/init.lua

# Iguals
echo "Equal file" > dir1/equal.txt
echo "Equal file" > dir2/equal.txt

# Diferents
echo "Different in dir1" > dir1/diff.txt
echo "Different in dir2" > dir2/diff.txt

echo "Fitxers creats."
# -------------------
# Subdirectoris
# -------------------
echo -e "\nCreant subdirectoris de proves..."

mkdir dir1/subdir
mkdir dir2/subdir

# Fitxers unics en dir1/subdir
echo "Unique in subdir1" > dir1/subdir/sub1.txt
echo "Unique in subdir2" > dir2/subdir/sub2.txt

# Fitxers iguals en els dos subdirs
echo "Equal in subdir" > dir1/subdir/sub_equal.txt
echo "Equal in subdir" > dir2/subdir/sub_equal.txt

# Fitxers diferents
echo "Line 1" > dir1/subdir/sub_diff.txt
echo "Line 1" >> dir2/subdir/sub_diff.txt
echo "Line 2 - canvi" >> dir1/subdir/sub_diff.txt

echo "Line 1" > dir2/subdir/sub_diff.txt
echo "Line 1" >> dir2/subdir/sub_diff.txt
echo "Line 2 - modified" >> dir2/subdir/sub_diff.txt

echo "Subdirectoris i subfitxers creats."

# -------------------
# Fitxers amb moltes linies per comparar
# -------------------
echo -e "\nCreant fitxers per comparar..."

for i in {1..1000}; do
    echo "Line $i content" >> dir1/long.txt
    echo "Line $i content" >> dir2/long.txt
done
for i in {1..10}; do
    j=$((1+RANDOM%1000))
    sed -i "$j s/.*/Line $j modified/" dir1/long.txt
done
echo "Fitxers per comparar creats."
# -------------------
# Fitxers amb diferents permisos
# -------------------
echo -e "\nCreant fitxers amb diferents permisos..."

echo "Different permissions 1" > dir1/perm.py
echo "Different permissions 2" > dir2/perm.py
chmod 777 dir1/perm.py
chmod 755 dir2/perm.py
echo "Different permissions 1" > dir1/perm2.js
echo "Different permissions 2" > dir2/perm2.js
chmod 644 dir1/perm2.js
chmod 654 dir2/perm2.js
echo "Different permissions 1" > dir1/perm3.osr
echo "Different permissions 2" > dir2/perm3.osr
chmod 777 dir1/perm3.osr
chmod 733 dir2/perm3.osr

echo "Fitxers amb diferents permisos creats."
# -------------------
# Fitxers amb diferents extensions
# -------------------
echo -e "\nCreant fitxers amb diferents extensions..."

echo "Shell script" > dir1/shell.sh
echo "Shell script" > dir2/shell.sh
echo "Copy script" > dir1/copy.bak
echo "Copy script" > dir2/copy.bak
echo "Temporal file1" > dir1/temp.tmp
echo "Temporal file2" > dir2/temp.tmp
echo "{ 'version' : '1.0.0' }" > dir1/package.json
echo "{ 'version' : '1.3.1' }" > dir2/package.json
echo "apiKey: '1234567890'
secretKey: '123123123'" > dir1/.env
echo "apiKey: '0987654321'
secretKey: '123123123'" > dir2/.env

# -------------------
# Fitxers amb whitespaces
# -------------------
echo "Fire ball" > dir1/fireball.astro
echo "" >> dir1/fireball.astro
echo "Banana" >> dir1/fireball.astro

echo "Fireball" > dir2/fireball.astro
echo "" >> dir2/fireball.astro
echo "Banana" >> dir2/fireball.astro

echo "Fitxers amb diferents extensions creats."

# -------------------
# Fitxers d'un directory a ignorar
# -------------------
echo -e "\nCreant fitxers d'un subdirectori a ignorar..."

mkdir dir1/ignore && mkdir dir2/ignore
echo "margin: 4px;
padding: 2px 4px;
border: none;
color: white;" > dir1/ignore/styles.css
echo "margin: 0px;
padding: 2px 4px;
border: bold;
color: red;" > dir2/ignore/styles.css

echo "Fitxers d'un subdirectori a ignorar creats."
# -------------------
# Executar comparator.sh
# -------------------
echo -e "\nExecutant comparator.sh amb diferents opcions..."
while true; do
    echo ""
    echo "-------------------------------------"
    echo "-------------------------------------"
    echo "Selecciona el cas de prova:"
    echo "    [0] Sense parametres" 
    echo "    [1] Amb parametres incorrectes (directori inexistent)"
    echo "    [2] Amb parametres correctes (dir1 i dir2)"
    echo "    [3] Amb flag -c (mostrant comparacio de linies)"
    echo "    [4] Amb flag -w (ignorant whitespaces)"
    echo "    [5] Amb flag -s (calculant similaritat)"
    echo "    [6] Amb flag -f (ignorant .bak i .txt)"
    echo "    [7] Amb flag -d (ignorant dirX/ignore)"
    echo "    [8] Amb flag -p (mostrant permisos)"
    echo "    [9] Amb flag -o (guardant sortida a register.log)"
    echo "    [A] Amb tots els flags (-c, -w, -s, -f, -d, -p, -o)"
    echo "    [X] Sortir"
    echo "-------------------------------------"
    echo "-------------------------------------"
    echo ""

    read -p "Tria una opcio [0-9]: " option

    case $option in
        0)
            echo -e "\nSense parametres"
            echo "./comparator.sh"
            ./comparator.sh
            ;;
        1)
            echo -e "\nAmb parametres incorrectes"
            echo "./comparator.sh dir1 inexistent"
            ./comparator.sh dir1 inexistent
            ;;
        2)
            echo -e "\nAmb parametres correctes"
            echo "./comparator.sh dir1 dir2"
            ./comparator.sh dir1 dir2
            ;;
        3)
            echo -e "\nAmb flag -c (mostrant comparacio de linies)"
            echo "./comparator.sh -c dir1 dir2"
            ./comparator.sh -c dir1 dir2
            ;;
        4)
            echo -e "\nAmb flag -w (ignorant whitespaces)"
            echo -e "\nIgnorant tots els fitxers menys el de prova de whitespaces"
            echo "./comparator.sh -w -c -f .txt,.log,.bak,.tmp,.conf,.lua,.py,.osr,.js,.sh,.json,.env,.css dir1 dir2"
            ./comparator.sh -w -c -f .txt,.log,.bak,.tmp,.conf,.lua,.py,.osr,.js,.sh,.json,.env,.css dir1 dir2
            echo -e "\nSense flag -w (comparant whitespaces)"
            echo "./comparator.sh -c -f .txt,.log,.bak,.tmp,.conf,.lua,.py,.osr,.js,.sh,.json,.env,.css dir1 dir2"
            ./comparator.sh -c -f .txt,.log,.bak,.tmp,.conf,.lua,.py,.osr,.js,.sh,.json,.env,.css dir1 dir2
            ;;
        5)
            echo -e "\nAmb flag -s (calculant similaritat)"
            echo "./comparator.sh -s dir1 dir2"
            ./comparator.sh -s dir1 dir2
            ;;
        6)
            echo -e "\nAmb flag -f (ignorant .bak i .txt)"
            echo "./comparator.sh -f .bak,.txt dir1 dir2"
            ./comparator.sh -f .bak,.txt dir1 dir2
            ;;
        7)
            echo -e "\nAmb flag -d (ignorant dirX/ignore)"
            echo "./comparator.sh -d ignore dir1 dir2"
            ./comparator.sh -d ignore dir1 dir2
            ;;
        8)
            echo -e "\nAmb flag -p (mostrant permisos)"
            echo "./comparator.sh -p dir1 dir2"
            ./comparator.sh -p dir1 dir2
            ;;
        9)
            echo -e "\nAmb flag -o (guardant sortida a register.log)"
            echo "./comparator.sh -o register.log dir1 dir2"
            ./comparator.sh -o register.log dir1 dir2
            ;;
        A)
            echo -e "\nAmb tots els flags (-c, -w, -s, -f, -d, -p, -o)"
            echo "./comparator.sh -c -w -s -f .bak,.txt -d ignore -p -o output.log dir1 dir2"
            ./comparator.sh -c -f .bak,.txt -d ignore -p -o output.log dir1 dir2
            ;;
        X)
            break
            ;;
        *)
            echo "Opcio incorrecta, torna a provar"
            ;;
    esac
done

echo "*/---------------------------------\*"
echo "        JOC DE PROVES FINALITZAT     "
echo "*\---------------------------------/*"
