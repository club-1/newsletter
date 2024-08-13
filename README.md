# CLUB1 Newsletter

A very simple newsletter for CLUB1 server

- subscribe and unsubscribe using emails
    - email confirmation at subscription
- store emails in a file, separated by new lines
- a signature is picked out randomly from your selection to add some human vibe to automatic emails
- no web interface

## todo

- [x] ask for subscription after unsubscription
- [x] add list unsubscribe header
- [x] quoted printable


## Setup

Clone this repo into `/var/tmp/nl/`

Create 3 files :

    emails              must be readable and writable
    .secret             must be readable
    signature           must be readable
    ambiant-lines       must be readable

Fill `.secret` with a long sentence.

Fill `ambiant-lines` with one sentence per line. On will be used randomly as a little message at the end of each automatic emails.

Fill `signature` with text that need to appear at the end of each email. This will be placed after a `-- ` signature separator.

Edit aliases [doc](https://club1.fr/docs/fr/outils/aliases.html#modifier-les-alias-de-reception)

    USER+subscribe:        | "/var/tmp/nl/nl.sh subscribe /var/tmp/nl"
    USER+confirm:          | "/var/tmp/nl/nl.sh confirm /var/tmp/nl"
    USER+unsubscribe:      | "/var/tmp/nl/nl.sh unsubscribe /var/tmp/nl"

For `nl.sh`, first argument is newsletter data path (list of emails, signatures, secret).

## Usage

### send newsletter

```sh
./newsletter.sh DATA_PATH SUBJECT NL_FILE
```

Where

- `DATA_PATH` is the path of the newsletter datas (list of emails) without trailing slash
- `SUBJECT` subject of the letter
- `NL_FILE` is the file containing the newsletter text

This will send a newsletter to every mail addresses listed in the `emails` file. The __From address__  will be `USER@club1.fr`.
