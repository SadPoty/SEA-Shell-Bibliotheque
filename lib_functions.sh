#!/bin/bash

pagination() {
    local page="$1"
    local file="$2"

    local nb=10
    local start=$(expr \( $page - 1 \) \* $nb + 1 )
    local end=$(expr $page \* $nb )

    sed -n "${start},${end}p" "$file"
}

supprimer_livre() {
	local id="$1"
	local fichier="data/livres.txt"

	if ! grep -q "$id|" "$fichier"; then
		echo "Il n'y a pas de livre a l'ID $id."
		return
	fi

	grep -v "^$id|" "$fichier" > "${fichier}.tmp" && mv "${fichier}.tmp" "$fichier"

    for current_id in $(cut -d'|' -f1 "$fichier" | sort -n); do
        if [ "$current_id" -gt "$id" ]
        then
            decrement "$fichier" "$current_id"
        fi
    done
	echo "Le livre a été supprimer"
}

increment() {
    local file="$1"
    local id="$2"
    local newid=$(expr $id + 1)

    sed -i "0,/^${id}|/s//${newid}|/" "$file"
}



decrement() {
    local file="$1"
    local id="$2"
    local newid=$(expr $id - 1)

    sed -i "0,/^${id}|/s//${newid}|/" "$file"
}

recherche_titre() {
    local titre="$1"
    local fichier="data/livres.txt"

    if [ -z "$titre" ]; then
        echo "Veuillez entrer un titre."
        return 1
    fi
    grep -i -E "^[0-9]+\|[^|]*${titre}[^|]*\|" "$fichier"
}

recherche_auteur() {
    local auteur="$1"
    local fichier="data/livres.txt"

    if [ -z "$auteur" ]; then
        echo "Veuillez entrer un auteur."
        return 1
    fi

    # colonne auteur = champ 3
    grep -i -E "^[0-9]+\|[^|]*\|[^|]*${auteur}[^|]*\|" "$fichier"
}

ajouter_livre() {
    local fichier="data/livres.txt"

    if [ ! -s "$fichier" ]; then
        newid=1
    else
        newid=$(cut -d'|' -f1 "$fichier" | sort -n | tail -1)
        newid=$((newid + 1))
    fi

    read -p "Titre du livre : " titre
    read -p "Auteur : " auteur
    read -p "Année : " annee
    read -p "Type : " type_liv 
    read -p "Etat de l'emprunt : " etat_emprunt

    echo "${newid}|${titre}|${auteur}|${annee}|${type_liv}|${etat_emprunt}" >> "$fichier"

    echo "Livre ajouté avec succès : ID = $newid"
}

modifier_livre() {
    # modifier_livre <id> <champ> <nouvelle_valeur> <fichier>
    # <id> L'id du livre à changer
    # <champ> {Titre, Auteur, Annee, Genre}
    # <nouvelle_valeur> La nouvelle valeur pour le champ
    # <fichier> Le fichier contenant les livres

    if [ "$#" -ne 4 ]; then
        echo "Erreur : 4 arguments requis. Usage : modifier_livre <id> <champ> <nouvelle_valeur> <fichier>"
        return 1
    fi

    local id="$1"
    local modifier="$2"
    local new="$3"
    local file="$4"

    if [ ! -f "$file" ]; then
        echo "Erreur : le fichier '$file' n'existe pas."
        return 1
    fi

    local ligne=$(grep -w "$id" "$file")

    if [ -z "$ligne" ]; then
        echo "Erreur : aucun livre trouvé avec l'id '$id'."
        return 1
    fi

    case "$modifier" in
        "Titre")
            local Titre=$(echo "$ligne" | cut -d '|' -f2)
            sed -i "0,/${Titre}|/s#${Titre}|#${new}|#" "$file"
            ;;
        "Auteur")
            local Auteur=$(echo "$ligne" | cut -d '|' -f3)
            sed -i "0,/${Auteur}|/s#${Auteur}|#${new}|#" "$file"
            ;;
        "Annee")
            local Annee=$(echo "$ligne" | cut -d '|' -f4)
            sed -i "0,/${Annee}|/s#${Annee}|#${new}|#" "$file"
            ;;
        "Genre")
            local Genre=$(echo "$ligne" | cut -d '|' -f5)
            sed -i "0,/${Genre}|/s#${Genre}|#${new}|#" "$file"
            ;;
        *)
            echo "Erreur : deuxième argument invalide. Choisir parmi {Titre, Auteur, Annee, Genre}"
            return 1
            ;;
    esac
}

mettreAJourDisponibilite() {
    if [ "$#" -ne 2 ]; then
        echo "Erreur : 2 arguments requis. Usage : mettreAJourDisponibilite <id> <fichier>"
        return 1
    fi

    local id="$1"
    local file="$2"

    if [ ! -f "$file" ]; then
        echo "Erreur : le fichier '$file' n'existe pas."
        return 1
    fi

    # Vérifier si l'id existe
    local ligne=$(grep -w "$id" "$file")
    if [ -z "$ligne" ]; then
        echo "Erreur : aucun livre trouvé avec l'id '$id'."
        return 1
    fi

    # Changer la disponibilité
    local dispo=$(echo "$ligne" | cut -d '|' -f6)
    if [ "$dispo" = "disponible" ]; then
        sed -i "/^$id|/s/disponible$/indisponible/" "$file"
    elif [ "$dispo" = "indisponible" ]; then
        sed -i "/^$id|/s/indisponible$/disponible/" "$file"
    else
        echo "Erreur : valeur de disponibilité inconnue '$dispo'"
        return 1
    fi
}
