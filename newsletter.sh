# ENVOI UN EMAIL A TOUT LES EMAILS INSCRITS A LA NEWSLETTER

# on récupère le contenu du mail à envoyer via paramètre ou stdin
content=$(cat)

# on vérifie si le contenu n'est pas vide
if test -z "$content"
then
    echo "c'est vide !!!!"
    exit 1
fi

# COMPTEUR (WIP)
# $counter=4
#
# Ajoute le nombre de zéros necessaires devant le numéro de newsletters pour que cela prenne 3 caractères
# $counter=$(printf printf '%03d\n' $counter)

# on lit le fichier contenant les emails et pour chaque ligne on envoie un email à l'adresse correspondante
cat '/var/tmp/nl/emails' | while read addr
do
    echo "$content" | mailx -s "[CLUB1] Newsletter 'Newsletter CLUB1 <nouvelles@club1.fr>' -- "$addr"
done

