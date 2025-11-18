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

emprunter_livre() {
    # emprunter_livre <id> <emprunteur> <fichier_livres> <fichier_emprunt>

    if [ "$#" -ne 4 ]; then
        echo "Erreur : 4 arguments requis. Usage : emprunter_livre <id> <emprunteur> <fichier_livres> <fichier_emprunt>"
        return 1
    fi

    local id="$1"
    local emprunteur="$2"
    local fichier_livres="$3"
    local fichier_emprunt="$4"

    for file in "$fichier_livres" "$fichier_emprunt"; do
        if [ ! -f "$file" ]; then
            echo "File $file does not exist"
            return 1
        fi
    done

    local ligne=$(grep -w "$id" "$fichier_livres")
    if [ -z "$ligne" ]; then
        echo "Erreur : aucun livre trouvé avec l'id '$id'."
        return 1
    fi

    local dispo
    dispo=$(echo "$ligne" | cut -d '|' -f6)
    if [ "$dispo" != "disponible" ]; then
        echo "Livre déjà emprunté"
        return 1
    fi

    local date_emprunt date_retour
    date_emprunt=$(date +'%d/%m/%Y')
    date_retour=$(date -d "+7 days" +'%d/%m/%Y')

    local emprunt="$id|$emprunteur|$date_emprunt|$date_retour"

    mettreAJourDisponibilite "$id" "$fichier_livres"
    echo "$emprunt" >> "$fichier_emprunt"
}

retour_livre() {
    # retour_livre <id> <fichier_livres> <fichier_emprunt>

    if [ "$#" -ne 3 ]; then
        echo "Erreur : 3 arguments requis. Usage : emprunter <id> <fichier_livres> <fichier_emprunt>"
        return 1
    fi

    local id="$1"
    local fichier_livres="$2"
    local fichier_emprunt="$3"

    for file in "$fichier_livres" "$fichier_emprunt"; do
        if [ ! -f "$file" ]; then
            echo "File $file does not exist"
            return 1
        fi
    done

    local ligne_livre=$(grep -w "$id" "$fichier_livres")
    local ligne_emprunt=$(grep -w "$id" "$fichier_emprunt")

    if [ -z "$ligne_livre" ] || [ -z "$ligne_emprunt" ]; then
        echo "Erreur : aucun livre trouvé avec l'id '$id'."
        return 1
    fi

    mettreAJourDisponibilite "$id" "$fichier_livres"
    sed -i "/^${id}/d" "$fichier_emprunt"
}

liste_emprunts() {
    # liste_emprunts <fichier_livres>

    local fichier="$1"
    if [ ! -f "$fichier" ]; then
        echo "Le fichier $fichier n'existe pas."
        return 1
    fi

    grep -i '|indisponible$' "$fichier" | cut -d '|' -f 2
}

filtrer_genre() {
    local genre="$1"
    local fichier="data/livres.txt"

    if [ -z "$genre" ]; then
        echo "Veuillez entrer un genre."
        return 1
    fi

    grep -i -E "^[0-9]+\|[^|]*\|[^|]*\|[^|]*\|${genre}\|" "$fichier"
}

filtrer_annee() {
    local annee_min="$1"
    local annee_max="$2"
    local fichier="data/livres.txt"

    if [ -z "$annee_min" ] || [ -z "$annee_max" ]; then
        echo "Veuillez entrer une plage d'années : min max"
        return 1
    fi

    awk -F'|' -v min="$annee_min" -v max="$annee_max" '{
        if ($4 >= min && $4 <= max) print $0
    }' "$fichier"
}

recherche_avancee() {
    local titre="$1"
    local auteur="$2"
    local annee_min="$3"
    local annee_max="$4"
    local genre="$5"
    local fichier="data/livres.txt"

    awk -F'|' -v t="$titre" -v a="$auteur" -v min="$annee_min" -v max="$annee_max" -v g="$genre" '
    BEGIN {
        IGNORECASE=1
    }
    {
        if ((t == "" || $2 ~ t) &&
            (a == "" || $3 ~ a) &&
            (min == "" || $4 >= min) &&
            (max == "" || $4 <= max) &&
            (g == "" || $5 ~ g))
        {
            print $0
        }
    }' "$fichier"
}

