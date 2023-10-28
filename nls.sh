#!/bin/sh -e
# INSCRIPTION A LA NEWSLETTER


# stocke stdin (standard input) dans une variable
mail=$(cat)

# réccupère le chemin indiquant l'emplacement des fichiers
path=$1

nl="$2"

# cherche la première ligne qui contient `From: ` et la stocke dans une variable
from=$(echo "$mail" | grep -Ei -m 1 "^From: ")


# dans cette ligne, récuppère ce qui ressemble à une adresse Email et stocke dans une variable
emailFrom=$(echo "$from" | grep -E -m 1 -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b")


# chemin du fichier contenant les emails
emails="$path/emails"

# indique si l'adresse email reçue existe déjà dans le fichiers des adresses
exist=$(grep -c -x -m 1 "$emailFrom" "$emails" || test $? = 1)

. "$path/pick_signature.sh"

# Si elle n'existe pas déjà, on l'ajoute. Sinon on envoie un email indiquant qu'elle y est déjà
if test $exist = 0
then
    secret=$(cat "$path/secret")
    hash=$(echo -n "$emailFrom$secret" | sha256sum | cut -b 1-10)
    confirmAdress="$nl-confirm+${hash}@club1.fr"
    corp="Veuillez repondre a ce mail pour confirmer que vous souhaitez recevoir la newsletter CLUB1\
    \nOu envoyer un email a l'adresse : $confirmAdress\
    \nVous recevrez un email de confirmation"
    printf "$corp$signature" | mailx -s "inscription a la newsletter CLUB1" -a "Reply-to: $confirmAdress" -r "Newsletter CLUB1 <$nl-subscribe@club1.fr>" -- "$emailFrom"
else
    corp="votre email est deja inscrit a la newsletter CLUB1\
    \nPour vous desinscrire, vous pouvez envoyer un email a : $nl-unsubscribe@club1.fr"
    printf "$corp$signature" | mailx -s "votre email est deja inscrit a la newsletter CLUB1" -r "Newsletter CLUB1 <$nl-subscribe@club1.fr>" -- "$emailFrom"
fi
