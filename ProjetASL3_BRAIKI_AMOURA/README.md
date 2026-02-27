# TPC Syntactic Analyzer — `tpcas`

> Projet réalisé dans le cadre de la Licence 3 Informatique — Université Gustave Eiffel  
> Institut Gaspard Monge — Année universitaire 2025-2026

---

## Description

`tpcas` est un **analyseur syntaxique** pour le langage **TPC** (un sous-ensemble du C), développé en C avec **Flex** (analyse lexicale) et **Bison** (analyse syntaxique).

Le programme lit un fichier source `.tpc`, vérifie sa conformité grammaticale, puis construit et affiche un **Arbre Syntaxique Abstrait (ASA)**.

---

## Fonctionnalités

- Analyse lexicale complète (mots-clés, identifiants, littéraux, opérateurs)
- Analyse syntaxique avec grammaire stratifiée (priorités des opérateurs respectées)
- Construction d'un ASA avec gestion des valeurs (`int`, `char`, identifiants)
- Support des **structures** (`struct`), de l'accès aux champs (`a.b.c`), des fonctions et des blocs
- Localisation précise des erreurs (ligne **et** colonne)
- Affichage graphique de l'arbre avec l'option `--tree`
- Libération complète de la mémoire (aucune fuite)

---

## Structure du projet

```
Projet_TPC/
├── README.md
├── makefile
├── test.sh
├── assets/
│   ├── arbre_arithmetique.png
│   ├── arbre_while.png
│   ├── arbre_struct.png
│   ├── erreur_syntaxe.png
│   ├── compilation.png
│   └── tests.png
├── src/
│   ├── tpcas.l       # Analyseur lexical (Flex)
│   ├── tpcas.y       # Analyseur syntaxique (Bison)
│   ├── tree.h        # Définition de la structure de l'arbre
│   └── tree.c        # Implémentation de l'arbre (makeNode, printTree, deleteTree…)
├── test/
│   ├── good/         # Fichiers .tpc valides
│   └── syn-err/      # Fichiers .tpc avec erreurs syntaxiques
├── obj/              # Fichiers objets générés
└── bin/              # Binaire final
```

---

## Compilation

```bash
make
```

> Nécessite : `gcc`, `flex`, `bison`

Pour nettoyer les fichiers générés :

```bash
make clean
```

![Compilation](assets/compilation.png)

---

## Utilisation

```bash
# Analyser un fichier (retourne 0 si valide, 1 sinon)
./bin/tpcas < mon_fichier.tpc

# Afficher l'arbre syntaxique abstrait
./bin/tpcas --tree < mon_fichier.tpc

# Aide
./bin/tpcas --help
```

---

## Exemples

### Expression arithmétique — `x = 3 + 4`

![Arbre arithmétique](assets/arbre_arithmetique.png)

---

### Structure de contrôle — `while`

![Arbre while](assets/arbre_while.png)

---

### Support des structures — `struct Point`

![Arbre struct](assets/arbre_struct.png)

---

### Gestion des erreurs

En cas d'erreur syntaxique, `tpcas` indique précisément la ligne et la colonne :

![Erreur syntaxe](assets/erreur_syntaxe.png)

---

## Tests automatiques

```bash
bash test.sh
```

![Résultats des tests](assets/tests.png)

---

## Points techniques notables

- **Stratification de la grammaire** : 7 niveaux de non-terminaux (`Exp → TB → FB → M → E → T → F`) pour respecter les priorités et l'associativité des opérateurs.
- **Récursivité gauche sur les accès struct** : `Acces: IDENT | Acces '.' IDENT` pour traiter correctement `a.b.c`.
- **Localisation des erreurs** : macro `YY_USER_ACTION` + variable `current_column` pour reporter ligne et colonne précises.
- **`makeNodeVal`** : extension de `makeNode` avec duplication de la valeur textuelle via `strdup`, libérée proprement dans `deleteTree`.

---

## Technologies

![C](https://img.shields.io/badge/C-00599C?style=flat&logo=c&logoColor=white)
![Flex](https://img.shields.io/badge/Flex-Lexer-green?style=flat)
![Bison](https://img.shields.io/badge/Bison-Parser-orange?style=flat)
![Make](https://img.shields.io/badge/Makefile-build-lightgrey?style=flat)

---

## Auteurs

- **BRAIKI Koceila**
---

*Université Gustave Eiffel — Licence 3 Informatique — 2025-2026*
