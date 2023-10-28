#!/bin/sh -e

# si l'adresse existe deja, on arrête la et on renvoie un email expliquant ca
checkAlreadySubscribed () {
    if test $exist != 0
    then
        corp="votre email est deja inscrit a la newsletter CLUB1\
        \nPour vous desinscrire, vous pouvez envoyer un email a : $nl-unsubscribe@club1.fr"
        printf "$corp$signature" | mailx -s "votre email est deja inscrit a la newsletter CLUB1" -a "$headerInReplyTo" -r "Newsletter CLUB1 <$nl-subscribe@club1.fr>" -- "$emailFrom"
        exit
    fi
}

# génère une adresse email pointant vers le script de confirmation avec le hash basé sur le secret du serveur
confirmAdress () {
    secret=$(cat "$path/secret")
    hash=$(echo -n "$emailFrom$secret" | sha256sum | cut -b 1-10)
    echo "$nl-confirm+${hash}@club1.fr"
}

subscribe () {
    checkAlreadySubscribed

    confirmAdress=$(confirmAdress)
    corp="Veuillez repondre a ce mail pour confirmer que vous souhaitez recevoir la newsletter CLUB1\
    \nOu envoyer un email a l'adresse : $confirmAdress\
    \nVous recevrez un email de confirmation"
    printf "$corp$signature" | mailx -s "inscription a la newsletter CLUB1" -a "Reply-to: $confirmAdress" -a "$headerInReplyTo" -r "Newsletter CLUB1 <$nl-subscribe@club1.fr>" -- "$emailFrom"
}

unsubscribe () {
    # Si elle existe, on la supprime. Sinon on envoie un email indiquant qu'elle n'y était pas
    if test $exist = 1
    then
        tmpemails=$(sed "/^$emailFrom\$/d" "$emails")
        echo "$tmpemails" > "$emails"
        content="Votre email $emailFrom a bien ete retire de la newsletter CLUB1\
        \n\nPour vous re-inscrire, il vous suffit d'envoyer un email a $nl-subscribe@club1.fr a tout moment.$signature"
        printf "$content"  | mailx -s "Vous avez bien ete retire de la newsletter CLUB1" -a "$headerInReplyTo" -r "Newsletter CLUB1 <$nl-unsubscribe@club1.fr>" -- "$emailFrom"
    else
        echo "Votre email $emailFrom n'est pas incrit a la newsletter CLUB1 $signature" | mailx -s "Votre email n est pas inscrit a la newsletter CLUB1" -a "$headerInReplyTo" -r "Newsletter CLUB1 <$nl-unsubscribe@club1.fr>" -- "$emailFrom"
    fi
}

confirm () {
    checkAlreadySubscribed

    # cherche la première ligne qui contient `To: ` et la stocke dans une variable
    to=$(echo "$mail" | grep -Ei -m 1 "To: ")

    # dans cette ligne, récuppère ce qui ressemble à une adresse Email et stocke dans une variable
    emailTo=$(echo "$to" | grep -E -m 1 -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b")

    if test $emailTo = $(confirmAdress)
    then
        echo "$emailFrom" >> "$emails"
        corp="C'est bon!\nVotre email $emailFrom a bien ete ajoute a notre newsletter.\
        \nPour vous desinscrire, vous pouvez envoyer un email a : $nl-unsubscribe@club1.fr"
        echo "$corp$signature" | mailx -s "Confirmation d'inscription" -a "$headerInReplyTo" -r "Newsletter CLUB1 <$nl-confirm@club1.fr>" -- "$emailFrom"
    else
        printf "Erreur\nAdresse de provenance : $emailFrom ne correspond pas.$signature" | mailx -s "Erreur lors de la confirmation" -a "$headerInReplyTo" -r "Newsletter CLUB1 <$nl-confirm@club1.fr>" -- "$emailFrom"
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

# check if email have Autosubmitted Header, if so, abort mission and prevent daemon to send any error email to avoid infinite bouncing
autoSubmitted=$(echo "$mail" | grep -cEi -m 1 "^Auto-Submitted:" || test $? = 1)

if test $autoSubmitted = 1
then
    exit 0
fi

# cherche la première ligne qui contient `From: ` et la stocke dans une variable
from=$(echo "$mail" | grep -Ei -m 1 "^From: ")
emailFrom=$(echo "$from" | grep -E -m 1 -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b")

# on réccupère le message ID via le Header correspondant
emailMessageId=$(echo "$mail" | grep -Eoi -m 1 "^Message-ID: .*" | grep -Eo "<.*>")
headerInReplyTo="In-Reply-To: $emailMessageId"

# chemin du fichier contenant les emails
emails="$path/emails"

# indique si l'adresse email reçue existe déjà dans le fichiers des adresses
exist=$(grep -c -x -m 1 "$emailFrom" "$emails" || test $? = 1)

# charge une signature depuis le fichier
signature=$(shuf -n 1 "$path/signatures")
signature="\n\n$signature\n\nhttps://club1.fr"

# lance la sous commande correspondante
case $subcmd in
    'subscribe') subscribe;;
    'unsubscribe') unsubscribe;;
    'confirm') confirm;;
    *) echo 'this sub-command does not exist'
    exit 2;;
esac
