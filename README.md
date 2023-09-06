# CLUB1 Newsletter

A very simple newsletter for CLUB1 server

- subscribe and unsubscribe using emails
    - email confirmation at subscription
- store emails in a file, separated by new lines
- no web interface



## Setup

Clone this repo into `/var/tmp/nl/`

Create 3 files :

    emails              must be readable
    secret              must be readable
    signatures          must be readable and writable

Fill `secret` with a long sentence

Fill `signatures` with one sentence per line. On will be used randomly as a little message at the end of each subscription or unsubscription email.

Edit aliases [doc](https://club1.fr/docs/fr/outils/aliases.html#modifier-les-alias-de-reception)

    ln-subscribe:        | "/var/tmp/nl/nls.sh /var/tmp/nl"
    ln-confirm:          | "/var/tmp/nl/nlc.sh /var/tmp/nl"
    ln-unsubscribe:      | "/var/tmp/nl/nlu.sh /var/tmp/nl"



## Usage

### send newsletter

    newsletter.sh "content of the newsletter"

