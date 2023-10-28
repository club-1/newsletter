#!/bin/sh -e

subscribe () {
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
}

unsubscribe () {
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
}

confirm () {
    # si l'adresse existe deja, on arrête la et on renvoie un email expliquant ca
    if test $exist != 0
    then
        corp="votre email est deja inscrit a la newsletter CLUB1\
        \nPour vous desinscrire, vous pouvez envoyer un email a : $nl-unsubscribe@club1.fr"
        printf "$corp$signature" | mailx -s "votre email est deja inscrit a la newsletter CLUB1" -r "Newsletter CLUB1 <$nl-subscribe@club1.fr>" -- "$emailFrom"
        exit
    fi

    # cherche la première ligne qui contient `To: ` et la stocke dans une variable
    to=$(echo "$mail" | grep -Ei -m 1 "To: ")

    # dans cette ligne, récuppère ce qui ressemble à une adresse Email et stocke dans une variable
    emailTo=$(echo "$to" | grep -E -m 1 -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b")

    secret=$(cat "$path/secret")
    hash=$(echo -n "$emailFrom$secret" | sha256sum | cut -b 1-10)
    emailToLocal="$nl-confirm+${hash}@club1.fr"

    if test $emailTo = $emailToLocal
    then
        echo "$emailFrom" >> "$emails"
        corp="C'est bon!\nVotre email $emailFrom a bien ete ajoute a notre newsletter.\
        \nPour vous desinscrire, vous pouvez envoyer un email a : $nl-unsubscribe@club1.fr"
        echo "$corp$signature" | mailx -s "Confirmation d'inscription" -r "Newsletter CLUB1 <$nl-confirm@club1.fr>" -- "$emailFrom"
    else
        printf "Erreur\nAdresse de provenance : $emailFrom ne correspond pas.$signature" | mailx -s "no" -r "Newsletter CLUB1 <$nl-confirm@club1.fr>" -- "$emailFrom"
    fi
}

# stocke stdin (standard input) dans une variable
mail=$(cat)

# on associe le premier argument à la sous commande
subcmd=$1

# réccupère le chemin indiquant l'emplacement des fichiers
path=$2

# réccupère le préfix
nl="$3"

# cherche la première ligne qui contient `From: ` et la stocke dans une variable
from=$(echo "$mail" | grep -Ei -m 1 "^From: ")

# dans cette ligne, récuppère ce qui ressemble à une adresse Email et stocke dans une variable
emailFrom=$(echo "$from" | grep -E -m 1 -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b")

# chemin du fichier contenant les emails
emails="$path/emails"

# indique si l'adresse email reçue existe déjà dans le fichiers des adresses
exist=$(grep -c -x -m 1 "$emailFrom" "$emails" || test $? = 1)

# charge une signature depuis le fichier
signature=$(shuf -n 1 "$path/signatures")
signature="\n\n$signature\n\nhttps://club1.fr"


case $subcmd in
    'subscribe') subscribe;;
    'unsubscribe') unsubscribe;;
    'confirm') confirm;;
    *) echo 'this sub-command does not exist'
    exit 2;;
esac
