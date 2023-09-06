# INSCRIPTION A LA NEWSLETTER


# stocke stdin (standard input) dans une variable
mail=$(cat)

# réccupère le chemin indiquant l'emplacement des fichiers
path=$1

# cherche la première ligne qui contient `From: ` et la stocke dans une variable
from=$(echo "$mail" | grep -E -m 1 "From: ")


# dans cette ligne, récuppère ce qui ressemble à une adresse Email et stocke dans une variable
emailFrom=$(echo "$from" | grep -E -m 1 -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b")


# lit le fichier contenant les adresses email
emails=$(cat "$path/emails")

# indique si l'adresse email reçue existe déjà dans le fichiers des adresses
exist=$(echo "$emails" | grep -c -m 1 "$emailFrom")


# charge un mot doux depuis le fichier
signature=$(shuf -n 1 "$path/signatures")
signature="\n\n$signature\n\nhttps://club1.fr"

# Si elle n'existe pas déjà, on l'ajoute. Sinon on envoie un email indiquant qu'elle y est déjà
if test $exist = 1
then
    sed -i "/$emailFrom/d" "$path/emails"
    echo "Votre email $emailFrom a bien ete retire de la newsletter CLUB1 $signature" | mailx -s "Vous avez bien ete retire de la newsletter CLUB1" -r "Newsletter CLUB1 <nl-unsubscribe@club1.fr>" -- "$emailFrom"
else
    echo "Votre email $emailFrom n'est pas incrit a la newsletter CLUB1 $signature" | mailx -s "Votre email n est pas inscrit a la newsletter CLUB1" -r "Newsletter CLUB1 <nl-unsubscribe@club1.fr>" -- "$emailFrom"
fi










# echo "$mail" | grep -E -m 1 "From: " | grep -E -m 1 -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b" >> ~/scripts/emails



# echo "$mail" | grep -E -m 1 "From: " >> ~/scripts/subscribe

# echo "$mail" | grep -E -m 1 -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b" >> ~/scripts/subscribe

