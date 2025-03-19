#!/bin/bash -e

# basic email template that setup headers and add footer
# sendEmail SUBJECT BODY [CUSTOM_MAILX_ARGS...]
sendEmail() {
    local subject="$1"
    local body="$2"
    shift 2

    local content="$body$footer"
    echo -e "$content" | qprint --encode | mailx \
        -s "$subject" \
        -a "List-Unsubscribe: <mailto:$nl+unsubscribe@club1.fr>" \
        -a 'Content-Transfer-Encoding: quoted-printable' \
        -a 'Content-Type: text/plain; charset=UTF-8' \
        -a "In-Reply-To: $emailMessageId" \
        "$@" \
        -r "$displayName <$nl@club1.fr>" \
        -- "$emailFrom"
}


# If the email address is aleary listed, we stop here and send an email
checkAlreadySubscribed () {
    if test $exist != 0
    then
        sendEmail \
            "Votre email est déjà inscrit à $extendedTitle" \
            "Pour vous désinscrire, vous pouvez envoyer un email à : $nl+unsubscribe@club1.fr"
        exit
    fi
}

# generate an identifier like `<NLNAME-XXXXX@club1.fr>` thanks to a hash based on the `.secret` config file
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

    sendEmail \
        "Inscription à $extendedTitle" \
        "Veuillez repondre a cet email pour confirmer que vous souhaitez recevoir $extendedTitle.\
        \nVous recevrez un email de confirmation. (n'oubliez pas vérifier vos courriers indésirables !)" \
        -a "Message-Id: $(confirmID)" -a "Reply-to: $nl+confirm@club1.fr"
}

unsubscribe () {
    # If it exist, we delete it. Otherwise we send an email indicating the mistake
    if test $exist = 1
    then
        tmpemails=$(sed "/^$emailFrom\$/d" "$emails")
        echo "$tmpemails" > "$emails"
        sendEmail \
            "Vous avez bien été retiré de $extendedTitle" \
            "Votre email <$emailFrom> a bien été retiré des abonnements à $extendedTitle.\
            \n\nPour vous réinscrire, il vous suffit d'envoyer un email à <$nl+subscribe@club1.fr> à tout moment."
    else
        sendEmail \
            "Votre email n'est pas inscrit à $extendedTitle" \
            "On ne peut donc pas le retirer. Si le problème persiste, veuillez contacter <postmaster@club1.fr>"
    fi
}

confirm () {
    checkAlreadySubscribed

    # get the In-Reply-To header
    emailInReplyTo=$(echo "$mail" | grep -Eoi -m 1 "^In-Reply-To: .*" | grep -Eo "<.*>")

    # comparaison  against the localy generated ID
    if test $emailInReplyTo = $(confirmID)
    then
        echo "$emailFrom" >> "$emails"
        sendEmail \
            "Confirmation d'inscription à $extendedTitle" \
            "C'est bon!\nVotre email <$emailFrom> a bien été ajouté. \
            \nPour vous désinscrire, vous pouvez envoyer un email a : <$nl+unsubscribe@club1.fr>"
    else
        sendEmail \
            "Erreur lors de la confirmation d'inscription à $extendedTitle" \
            "L'adresse de provenance : <$emailFrom> ne correspond pas."
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

# look for first line containing `From: ` and store it in var
from=$(echo "$mail" | grep -Ei -m 1 "^From: ")
emailFrom=$(echo "$from" | grep -E -m 1 -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b")

# get the message ID thanks to the associated mail header
emailMessageId=$(echo "$mail" | grep -Eoi -m 1 "^Message-Id: .*" | grep -Eo "<.*>")

# path to file containing subscribed emails
emails="$configPath/emails"

# check if the from address is listed in the subscribed emails file.
# `0` is stored if not listed. `1` is stored if listed.
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

# lauch matching sub-command
case $subcmd in
    'subscribe') subscribe;;
    'unsubscribe') unsubscribe;;
    'confirm') confirm;;
    *) echo 'this sub-command does not exist'
    exit 2;;
esac
