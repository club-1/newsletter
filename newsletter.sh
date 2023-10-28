#!/bin/bash -e
# ENVOI UN EMAIL A TOUT LES EMAILS INSCRITS A LA NEWSLETTER

# on récupère le chemin où se trouvent les données
path="$1"

# on récupère le contenu du mail à envoyer via paramètre
content=$(cat "$3")

nl="$2"

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


# on réccupère l'argument 1 correspondant au numéro de la NL
counter=$4

# Ajoute le nombre de zéros necessaires devant le numéro de newsletters pour que cela prenne 3 caractères
counter=$(printf '%03d\n' $counter)
subject="[CLUB1] Newsletter $counter"

sig="\n-- \nCLUB1 - https://club1.fr\
    \n\nPour vous desinscrire, vous pouvez envoyer un email a : $nl-unsubscribe@club1.fr\
    \n\nArchive des newsletters disponible sur le site : https://club1.fr/newsletters"

printf 'sending'

echo "$uniqueEmails" | while read addr
do
    (echo "$content"; echo -e $sig) | qprint --encode | mailx \
        -s "$subject" \
        -a "List-Unsubscribe: <mailto:$nl-unsubscribe@club1.fr>" \
        -a "Content-Transfer-Encoding: quoted-printable" \
        -r "Newsletter CLUB1 <$nl@club1.fr>" \
        -- "$addr"
    printf '.'
    sleep 0.2
done
echo 'done !'
