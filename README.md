# Un microprocesseur et son assembleur

Ce dépôt contient un simulateur de netlist, un microprocesseur (écrit en netlist) et son assembleur, et enfin, le programme d'une horloge, exécuté sur le microprocesseur.

Ce projet a été réalisé par [Lucas Willems](http://www.lucaswillems.com), Josselin Giet et Elie Studnia pour le cours "[Système digital : de l'algorithme au circuit](http://perso.telecom-paristech.fr/~guilley/ENS/program_2016_2017.html)" donné par Sylvain Guilley pour la L3 d'informatique de l'ENS Ulm.

Ce dépôt contient aussi :
- un rapport sur le microprocesseur et son assembleur
- le diaporama de la soutenance

## Structure du projet

Le projet (dans le dossier `Code`) contient un `Makefile` permettant d'exécuter les 5 commandes :
- `make assembly` : pour compiler l'assembleur
- `make micro` : pour compiler le microprocesseur (avec la netlist ordonnée)
- `make simulator` : pour compiler simulateur
- `make` : pour exécuter les 3 commandes précédentes
- `make minijazz` : pour compiler MiniJazz
- `make clock` : pour compiler le fichier source de l'horloge et le simuler sur le microprocesseur

Et 5 dossiers :
- `minijazz` contenant une version modifiée de MiniJazz
- `assembly` contenant le compilateur de notre code assembleur vers le code machine
- `micro` contenant le circuit électrique du microprocesseur
- `simulator` contenant le simulateur de netlist
- `clock` contenant les fichiers propres à l'horloge

## Assembleur

Pour compiler un fichier assembleur en code machine, il faut exécuter le fichier `assembly/assembly.byte` avec le paramètre suivant :

- `(filename)` : définit le nom du fichier contenant la netlist.

Voici un exemple d'utilisation depuis l'origine du projet :

```bash
> ./assembly.byte tests/clock-without-mod.s
```

## Microprocesseur

Le dossier `micro` contient le circuit du microprocesseur `main.net`.

## Simulateur

### Utilisation

Pour utiliser le simulateur de netlist, il faut exécuter le fichier `simulator/simulator.byte` avec les paramètres suivants :

- `(filename)` : définit le nom du fichier contenant la netlist.
- (Optionnel) `-n (number_steps)` : définit le nombre d'étapes de la simulation. Par défaut, `number_steps = -1`.
- (Optionnel) `-print` : définit si seul le résultat du scheduling doit être affiché.
- (Optionnel) `-rom (rom_filename)` : définit le nom du fichier contenant la ROM. Par défaut, `rom_filename = ""` et aucune ROM n'est chargée.
- (Optionnel) `-ram (ram_filename)` : définit le nom du fichier contenant la RAM. Par défaut, `ram_filename = ""` et aucune RAM n'est chargée.

Voici un exemple d'utilisation depuis l'origine du projet :

```
./simulator.byte micro/main.net -n 1 -rom tests/clock-without-mod.byte
```

### Conventions

Le simulateur de netlist a été réalisé avec les conventions suivantes :

- Le fil d'index 0 d'une nappe de fils correspond au bit de poids faible
- La RAM est de taille variable : à chaque fois que le programme rencontre une instance de RAM, si la taille de cette RAM est supérieure à celle déjà en mémoire, alors la RAM en mémoire est étendu avec des bouléens à `false`

## L'horloge

Le dossier `clock` contient les fichiers propres à l'horloge c'est à dire son code assembleur, son binaire et son afficheur. Pour utiliser l'afficheur de l'horloge, il faut utiliser la commande suivante en étant placé à la racine du projet :

```
python3 micro/main.py
```

Par défaut, l'horloge fonctionne en mode `glock`. Pour activer le mode `synchrone`, il rajoute l'option `s` :

```
python3 micro/main.py -s
```