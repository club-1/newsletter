#!/bin/bash -e
# ENVOI UN EMAIL A TOUT LES EMAILS INSCRITS A LA NEWSLETTER

# on récupère le chemin où se trouvent les données
path="$1"

# on récupère le contenu du mail à envoyer via paramètre
content=$(cat "$2")

nl="$USER"

# on vérifie si le contenu n'est pas vide
if test -z "$content"
then
    echo "file $2 is empty"
    exit 1
fi

# on réccupère la liste des emails et on vire les doublons grâce à -u (unique)
uniqueEmails=$(sort -u "$path/emails")

# on compte le nombre d'emails
count=$(echo "$uniqueEmails" | wc -l)

# Estimate sending time, here for 0.2 sec per email
time=$(($count / 5))

echo ''
echo '========================== newsletter content =========================='
echo "$content"
echo '========================================================================'
echo ''
echo "Do you really want to send this to $count email addresses ? (estimated sending time is $time seconds) y/[n]"

# on lit la réponse de l'utilisateurice
read consent

# si ce n'est pas oui, il n'y a pas de consentement et dans ce cas on n'envoie pas de newsletter
if test "$consent" != 'y'
then
    echo "sending aborted"
    exit 2
fi

title=$(cat "$path/title")
signature=$(cat "$path/signature")

footer="\n-- \n$signature\
    \n\nPour vous desinscrire, vous pouvez envoyer un email a : $nl+unsubscribe@club1.fr"

printf 'sending'

echo "$uniqueEmails" | while read addr
do
    (echo "$content"; echo -e $footer) | qprint --encode | mailx \
        -s "$title" \
        -a "List-Unsubscribe: <mailto:$nl+unsubscribe@club1.fr>" \
        -a "Content-Transfer-Encoding: quoted-printable" \
        -r "$title <$nl@club1.fr>" \
        -- "$addr"
    printf '.'
    sleep 0.2
done
echo 'done !'
