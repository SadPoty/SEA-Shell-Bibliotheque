#/bin/bash

supprimer_livre() {
	local id="$1"
	local fichier="data/livres.txt"

	if ! grep -q "$id|" "$fichier"; then
		echo "Il n'y a pas de livre a l'ID $id."
		return
	fi

	grep -v "^$id|" "$fichier" > "${fichier}.tmp" && mv "${fichier}.tmp" "$fichier"
	echo "Le livre a été supprimer"
}
