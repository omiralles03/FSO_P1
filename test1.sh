#!/bin/bash
# Joc de proves
#   - Crear directoris
#   - Fitxers unics, iguals i diferents
#   - Subdirectoris amb fitxers unics, iguals i diferents

echo "*/---------------------------------\*"
echo "   Joc de proves per comparator.sh   "
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

# Unics
echo "Only in dir1" > dir1/file1.txt
echo "Only in dir2" > dir2/file2.txt

# Iguals
echo "Equal file" > dir1/equal.txt
echo "Equal file" > dir2/equal.txt

# Diferents
echo "Different in dir1" > dir1/diff.txt
echo "Different in dir2" > dir2/diff.txt

# -------------------
# Subdirectoris
# -------------------
mkdir dir1/subdir
mkdir dir2/subdir

# Fitxers unics en dir1/subdir
echo "Unique in subdir1" > dir1/subdir/subfile1.txt
echo "Unique in subdir2" > dir1/subdir/subfile2.txt

# Fitxers iguals en els dos subdirs
echo "Equal in subdir" > dir1/subdir/subfile3.txt
echo "Equal in subdir" > dir2/subdir/subfile3.txt

# Fitxers diferents en dir1/subdir
echo "Different1 in subdir1" > dir1/subdir/subfile4.txt
echo "Different2 in subdir1" > dir1/subdir/subfile4.txt

# Fitxer unic en dir2/sudir
echo "Only in subdir2" > dir2/subdir/subfile5.txt


# Executar comparator.sh
echo -e "\nExecucio comparator.sh\n"

./comparator.sh dir1 dir2

# Esborrar directoris de proves
# echo -e "\nEsborrar directoris de proves"
# rm -r dir1 && rm -r dir2
# echo $(ls -d */)

echo "*/---------------------------------\*"
echo "        Joc de proves finalitzat     "
echo "*\---------------------------------/*"
