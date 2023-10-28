#!/bin/sh -e
# INSCRIPTION A LA NEWSLETTER


# stocke stdin (standard input) dans une variable
mail=$(cat)

# réccupère le chemin indiquant l'emplacement des fichiers
path=$1

nl="$2"

# cherche la première ligne qui contient `From: ` et la stocke dans une variable
from=$(echo "$mail" | grep -Ei -m 1 "From: ")


# dans cette ligne, récuppère ce qui ressemble à une adresse Email et stocke dans une variable
emailFrom=$(echo "$from" | grep -E -m 1 -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b")


# chemin du fichier contenant les emails
emails="$path/emails"

# indique si l'adresse email reçue existe déjà dans le fichiers des adresses
exist=$(grep -c -x -m 1 "$emailFrom" "$emails" || test $? = 1)

. "$path/pick_signature.sh"

# Si elle n'existe pas déjà, on la supprime. Sinon on envoie un email indiquant qu'elle y est déjà
if test $exist = 1
then
    tmpemails=$(sed "/^$emailFrom\$/d" "$emails")
    echo "$tmpemails" > "$emails"
    content="Votre email $emailFrom a bien ete retire de la newsletter CLUB1\
    \n\nPour vous re-inscrire, il vous suffit d'envoyer un email a $nl-subscribe@club1.fr a tout moment.$signature"
    printf "$content"  | mailx -s "Vous avez bien ete retire de la newsletter CLUB1" -r "Newsletter CLUB1 <$nl-unsubscribe@club1.fr>" -- "$emailFrom"
else
    echo "Votre email $emailFrom n'est pas incrit a la newsletter CLUB1 $signature" | mailx -s "Votre email n est pas inscrit a la newsletter CLUB1" -r "Newsletter CLUB1 <$nl-unsubscribe@club1.fr>" -- "$emailFrom"
fi










# echo "$mail" | grep -E -m 1 "From: " | grep -E -m 1 -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b" >> ~/scripts/emails



# echo "$mail" | grep -E -m 1 "From: " >> ~/scripts/subscribe

# echo "$mail" | grep -E -m 1 -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b" >> ~/scripts/subscribe

