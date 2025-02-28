# Pràctica 1: FSO

## Objectiu
- Aprendre a utilitzar la Bash per gestionar i comparar continguts de fitxers i directoris.
- Modificar un script existent per ampliar funcionalitats.
- Familiaritzar-se amb eines i ordres de Bash com ls, diff, find, comm i stat.

## Enunciat
Un administrador de sistemes necessita gestionar grans quantitats de fitxers.

Una tasca habitual és comparar directoris per detectar fitxers nous, eliminats o modificats. 

Per facilitar aquesta tasca, hauràs de treballar amb un script que ja fa part de la feina i modificar-lo per millorar les seves funcionalitats.

Usant les comandes explicades en els laboratoris, implementeu les següents tasques:

---

# Part 1: Execució de l'script inicial
Se t'ha proporcionat un script bàsic que compara dos directoris. Aquest script:
- Llista els fitxers presents en un directori però no en l'altre.
- Detecta fitxers amb el mateix nom que tenen contingut diferent.

## Tasques inicials
Descarrega i analitza l'script proporcionat.

- [x] Revisa el codi per entendre com funciona.
- [x] Afegeix comentaris al codi per descriure cada part.
- [x] Executa l'script amb dos directoris d'exemple.

Per tal de facilitar el joc de proves en els laboratoris, feu un script que crei el joc de proves inicial que consistirà en:

- Crea dos directoris amb:
  - [x] Alguns fitxers iguals.
  - [x] Alguns fitxers diferents.
  - [x] Algun subdirectori.
  - [x] Afegeix fitxers en el subdirectori, tan iguals com diferents
- [x] Observa la sortida per comprovar què fa l'script.

> [!NOTE]
> Nota: per tal de crear el contingut dels fitxers, podem usar comandes linux amb redireccions de sortida.

---

# Part 2: Ampliació de funcionalitats
Hauràs de modificar l'script inicial per afegir les següents funcionalitats:

## 1. Comparació recursiva
- [x] L'script ha de buscar també en els subdirectoris dels directoris donats per paràmetre.

> [!TIP]
Utilitza `find` per obtenir la llista de fitxers amb rutes completes.

## 2. Comparació avançada de fitxers
- [x] Mostra el contingut de les línies diferents entre dos fitxers amb el mateix nom.

- [x] Ignora les línies o caràcters en blanc.

- [x] Afegeix una funció que retorni el nom absolut dels fitxers on el contingut tingui una similitud del 90%. Realitza aquesta cerca entre tots els fitxers dels dos directoris.

> [!TIP]
> Pots utilitzar la comanda `diff`

- [ ] Afegeix paràmetres per línia de comandes per configurar aquests criteris.

- [ ] Afegeix la comanda `getopts`, ja que tindrem diverses opcions possibles.

## 3. Ignorar certs fitxers
Afegeix opcions per ignorar en la comparativa fitxers basant-te en diferents criteris:

- - [ ] Ignora els fitxers amb unes extensions concretes introduïdes per paràmetre i separades per `,` (per exemple,`.tmp`,`.bak`).
- - [ ] Ignora tota la branca d'un subdirectori concret introduit per paràmetre.
- - [ ] Afegeix els paràmetres per línia de comandes per configurar aquests criteris.

## 4. Comprovació de permisos
- [ ] L'script ha de verificar si els permisos dels fitxers són iguals entre els fitxers amb el mateix nom i mostrar-ne els detalls si són diferents.

- [ ] Afegeix paràmetres per línia de comandes per configurar aquests criteris.

## 5. Registre en un fitxer
- [ ] Escriu els resultats de l’script en un fitxer de registre en lloc de mostrar-los per pantalla.
- [ ] Afegeix l'opció `-o <nom_fitxer>` per especificar el fitxer de sortida

---

# Lliurament
- L'script modificat, amb comentaris necessaris per entendre el codi.
- Fitxer `.tgz` que inclogui els dos directoris on s'han realitzat les proves.
- Una documentació en pdf que inclogui:
  - El codi complet de l'script amb les funcionalitats afegides.
  - El joc de proves realitzat.
  - Instruccions per executar l'script. Fent èmfasis en les diferents opcions dissenyades.
- El resultat del teu joc de proves executat
- Resultat del teu joc de proves executat

---

# Qualificacions

---
