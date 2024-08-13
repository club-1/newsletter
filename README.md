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

A folder called `newsletter` in user home must contain those files:

    emails              must be readable and writable
    .secret             must be readable
    ambiant-lines       must be readable
    signature           must be readable
    title               must be readable

`emails` will be filled with each email that subscribed to the newsletter.

Fill `.secret` with a long sentence.

Fill `ambiant-lines` with one sentence per line. On will be used randomly as a little message at the end of each automatic emails.

Fill `signature` with text that need to appear at the end of each email. This will be placed after a `-- ` signature separator.

Fill `title` with the name of the newsletter.

User home directory must contain 3 files:

    .forward+subscribe        | "/var/tmp/nl/nl.sh subscribe"
    .forward+confirm          | "/var/tmp/nl/nl.sh confirm"
    .forward+unsubscribe      | "/var/tmp/nl/nl.sh unsubscribe"

For `nl.sh`, first argument is newsletter data path (list of emails, signatures, secret).

## Usage

### send newsletter

```sh
./newsletter.sh SUBJECT NL_FILE
```

Where

- `SUBJECT` subject of the letter
- `NL_FILE` is the file containing the newsletter text

This will send a newsletter to every mail addresses listed in the `emails` file. The __From address__  will be `USER@club1.fr`.
