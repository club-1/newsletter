# ENVOI UN EMAIL A TOUT LES EMAILS INSCRITS A LA NEWSLETTER

# on récupère le contenu du mail à envoyer via paramètre ou stdin
content=$(cat)

# on vérifie si le contenu n'est pas vide
if test -z "$content"
then
    echo "c'est vide !!!!"
    exit 1
fi

# on réccupère l'argument 1 correspondant au numéro de la NL
counter=$1

# Ajoute le nombre de zéros necessaires devant le numéro de newsletters pour que cela prenne 3 caractères
counter=$(printf '%03d\n' $counter)
subject="[CLUB1] Newsletter $counter"

content="$content\n\nhttps://club1.fr\n\nPour vous desinscrire, vous pouvez envoyer un email a : nl-unsubscribe@club1.fr"

# for debbuging
# printf "contenu:\n$content\nsujet:\n$subject\n"

# on lit le fichier contenant les emails et pour chaque ligne on envoie un email à l'adresse correspondante
cat '/var/tmp/nl/emails' | while read addr
do
    printf "$content" | mailx -s "$subject" -r 'Newsletter CLUB1 <nouvelles@club1.fr>' -- "$addr"
done


