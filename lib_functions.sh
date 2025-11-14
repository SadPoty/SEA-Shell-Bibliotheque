#!/bin/bash

pagination() {
    local page="$1"
    local nb=10
    local start=$(expr \( $page - 1 \) \* $nb + 1 )
    local end=$(expr $page \* $nb )

    sed -n "${start},${end}p" livres.txt
}

increment() {
    local id=$( head -1 test.txt | cut -d'|' -f1 )
    local newid=$(expr \( $id \- 1 \) )
    
    
}
