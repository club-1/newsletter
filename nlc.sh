# stocke stdin (standard input) dans une variable

# stocke stdin (standard input) dans une variable
mail=$(cat)

# réccupère le chemin indiquant l'emplacement des fichiers
path=$1

# cherche la première ligne qui contient `From: ` et la stocke dans une variable
from=$(echo "$mail" | grep -E -m 1 "^From: ")


# dans cette ligne, récuppère ce qui ressemble à une adresse Email et stocke dans une variable
emailFrom=$(echo "$from" | grep -E -m 1 -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b")

# indique si l'adresse email reçue existe déjà dans le fichiers des adresses
exist=$(echo "$emails" | grep -c -m 1 "$emailFrom")

# si l'adresse existe deja, on arrête la et on renvoie un email expliquant ca
if test $exist > 0
then
    corp="votre email est deja inscrit a la newsletter CLUB1\
    \nPour vous desinscrire, vous pouvez envoyer un email a : nl-unsubscribe@club1.fr"
    printf "$corp$signature" | mailx -s "votre email est deja inscrit a la newsletter CLUB1" -r "Newsletter CLUB1 <nl-subscribe@club1.fr>" -- "$emailFrom"
    exit
fi


# cherche la première ligne qui contient `To: ` et la stocke dans une variable
to=$(echo "$mail" | grep -E -m 1 "To: ")


# dans cette ligne, récuppère ce qui ressemble à une adresse Email et stocke dans une variable
emailTo=$(echo "$to" | grep -E -m 1 -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b")

secret=$(cat "$path/secret")
hash=$(echo -n "$emailFrom$secret" | sha256sum | cut -b 1-10)
emailToLocal="nl-confirm+${hash}@club1.fr"


# charge un mot doux depuis le fichier
signature=$(shuf -n 1 "$path/signatures")
signature="\n\n$signature\n\nhttps://club1.fr"

if test $emailTo = $emailToLocal
then
    echo "$emailFrom" >> "$path/emails"
    corp="C'est bon!\nVotre email $emailFrom a bien ete ajoute a notre newsletter.\
    \nPour vous desinscrire, vous pouvez envoyer un email a : nl-unsubscribe@club1.fr"
    echo "$corp$signature" | mailx -s "Confirmation d'inscription" -r "Newsletter CLUB1 <nl-confirm@club1.fr>" -- "$emailFrom"
else
    printf "Erreur\nAdresse de provenance : $emailFrom ne correspond pas.$signature" | mailx -s "no" -r "Newsletter CLUB1 <nl-confirm@club1.fr>" -- "$emailFrom"
fi


