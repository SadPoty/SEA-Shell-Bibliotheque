#!/bin/bash

pagination() {
    local page="$1"
    local nb=10
    local start=$(expr \( $page - 1 \) \* $nb + 1 )
    local end=$(expr $page \* $nb )

    sed -n "${start},${end}p" livres.txt
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
