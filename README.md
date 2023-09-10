# CLUB1 Newsletter

A very simple newsletter for CLUB1 server

- subscribe and unsubscribe using emails
    - email confirmation at subscription
- store emails in a file, separated by new lines
- no web interface

## todo

- [x] use argument for newsletter prefix
- [x] ask for subscription after unsubscription
- [ ] add list unsubscribe header
- [ ] wrap text message to 72 chars
    - [ ] content type: format = fload (to allow client to display it nicely)


## Setup

Clone this repo into `/var/tmp/nl/`

Create 3 files :

    emails              must be readable
    secret              must be readable
    signatures          must be readable and writable

Fill `secret` with a long sentence

Fill `signatures` with one sentence per line. On will be used randomly as a little message at the end of each subscription or unsubscription email.

Edit aliases [doc](https://club1.fr/docs/fr/outils/aliases.html#modifier-les-alias-de-reception)

    nl-subscribe:        | "/var/tmp/nl/nls.sh /var/tmp/nl nl"
    nl-confirm:          | "/var/tmp/nl/nlc.sh /var/tmp/nl nl"
    nl-unsubscribe:      | "/var/tmp/nl/nlu.sh /var/tmp/nl nl"

For `nls.sh`, `nlc.sh` and `nlu.sh`, first argument is newsletter data path (list of emails, signatures, secret). Second argument is the newsletter prefix. Which is `nl` in the above example. This as to be in sync with the aliases.


## Usage

### send newsletter

```sh
./newsletter.sh DATA_PATH PREFIX NL_FILE NL_NUMBER
```

Where

- `DATA_PATH` is the path of the newsletter datas (list of emails) without trailing slash
- `PREFIX` is the newsletter prefix. It should be the same as for sbscription management commands.
- `NL_FILE` is the file containing the newsletter text
- `NL_NUMBER` is the newsletter number (no need to add leading zeros)
