#!/bin/sh -e

# si l'adresse existe deja, on arrête la et on renvoie un email expliquant ca
checkAlreadySubscribed () {
    if test $exist != 0
    then
        body="votre email est deja inscrit à $extendedTitle.\
        \nPour vous desinscrire, vous pouvez envoyer un email a : $nl+unsubscribe@club1.fr"
        printf "$body$footer" | mailx -s "votre email est deja inscrit à $extendedTitle" -a "$headerInReplyTo" -r "$displayName <$nl+subscribe@club1.fr>" -- "$emailFrom"
        exit
    fi
}

# génère un identifiant de la forme `<NLNAME-XXXXX@club1.fr>` avec le hash basé sur le secret du serveur
confirmID () {
    if test ! -s "$configPath/.secret"
    then
        head -c 30 /dev/urandom | base64 > "$configPath/.secret"
        touch "$configPath/.secret"
        chmod 600 "$configPath/.secret"
    fi
    secret=$(cat "$configPath/.secret")
    hash=$(echo -n "$emailFrom$secret" | sha256sum | cut -b 1-16)
    echo "<$nl-${hash}@club1.fr>"
}

subscribe () {
    checkAlreadySubscribed

    headerMessageID="Message-ID: $(confirmID)"
    body="Veuillez repondre a ce mail pour confirmer que vous souhaitez recevoir $extendedTitle.\
    \nVous recevrez un email de confirmation."
    printf "$body$footer" | mailx -s "inscription à $extendedTitle" -a "Reply-to: $nl+confirm@club1.fr" -a "$headerInReplyTo" -a "$headerMessageID" -r "$displayName <$nl+subscribe@club1.fr>" -- "$emailFrom"
}

unsubscribe () {
    # Si elle existe, on la supprime. Sinon on envoie un email indiquant qu'elle n'y était pas
    if test $exist = 1
    then
        tmpemails=$(sed "/^$emailFrom\$/d" "$emails")
        echo "$tmpemails" > "$emails"
        body="Votre email $emailFrom a bien ete retire des abonnements à $extendedTitle.\
        \n\nPour vous re-inscrire, il vous suffit d'envoyer un email a $nl+subscribe@club1.fr a tout moment."
        printf "$body$footer"  | mailx -s "Vous avez bien ete retire de $extendedTitle" -a "$headerInReplyTo" -r "$displayName <$nl+unsubscribe@club1.fr>" -- "$emailFrom"
    else
        echo "Votre email $emailFrom n'est pas incrit à $extendedTitle.$footer" | mailx -s "Votre email n'est pas inscrit à $extendedTitle" -a "$headerInReplyTo" -r "$displayName <$nl+unsubscribe@club1.fr>" -- "$emailFrom"
    fi
}

confirm () {
    checkAlreadySubscribed

    # on réccupère le header In-Reply-To
    emailInReplyTo=$(echo "$mail" | grep -Eoi -m 1 "^In-Reply-To: .*" | grep -Eo "<.*>")

    if test $emailInReplyTo = $(confirmID)
    then
        echo "$emailFrom" >> "$emails"
        body="C'est bon!\nVotre email $emailFrom a bien ete ajoute.\
        \nPour vous desinscrire, vous pouvez envoyer un email a : $nl+unsubscribe@club1.fr"
        echo "$body$footer" | mailx -s "Confirmation d'inscription à $extendedTitle" -a "$headerInReplyTo" -r "$displayName <$nl+confirm@club1.fr>" -- "$emailFrom"
    else
        printf "Erreur\nAdresse de provenance : $emailFrom ne correspond pas.$footer" | mailx -s "Erreur lors de la confirmation d'inscription à $extendedTitle" -a "$headerInReplyTo" -r "$displayName <$nl+confirm@club1.fr>" -- "$emailFrom"
    fi
}

# Default config path location
configPath="$HOME/.config/newsletter"
# store stdin (standard input)
mail=$(cat)

while getopts 'c:' opt
do
    case $opt in
        c)
            # overide config path
            configPath="$OPTARG"
        ;;
    esac
done
shift "$(($OPTIND -1))"

# if the config folder does not exist, abort here
if test ! -d "$configPath"
then
    echo "config path '$configPath' is not a valid folder."
    exit 2
fi

# associate first arg with sub-command
subcmd=$1

# email name is username
nl="$USER"

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
emails="$configPath/emails"

# indique si l'adresse email reçue existe déjà dans le fichiers des adresses
exist=$(grep -c -x -m 1 "$emailFrom" "$emails" || test $? = 1)

# read the title of the newsletter and the from display name
settingsFile="$configPath/settings.json"
title=$(cat "$settingsFile" | jq -r '.title // ""')
displayName=$(cat "$settingsFile" | jq -r '.displayName // ""')

# define extended title: how the newsletter is called in the email
if test -n "$title"
then
    extendedTitle="la newsletter [$title]"
else
    extendedTitle="la newsletter de $USER"
fi

# load a signature from the corresponding file
signatureFile="$configPath/signature.txt"
if test -f "$signatureFile"
then
    signature=$(cat "$signatureFile")
    footer="\n-- \n$signature"
else
    footer=''
fi

# lance la sous commande correspondante
case $subcmd in
    'subscribe') subscribe;;
    'unsubscribe') unsubscribe;;
    'confirm') confirm;;
    *) echo 'this sub-command does not exist'
    exit 2;;
esac
