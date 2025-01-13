# CLUB1 Newsletter

A very simple newsletter for CLUB1 server

- subscribe and unsubscribe using emails
    - email confirmation at subscription
- store emails in a file, separated by new lines
- no web interface

## todo

- [x] ask for subscription after unsubscription
- [x] add list unsubscribe header
- [x] quoted printable


## Setup

The configuration is stored under this folder:

    ~/.config/newsletter/

    emails              must be readable and writable
    .secret             must be readable
    signature           must be readable
    settings.json       must be readable

`emails` will be filled with each email that subscribed to the newsletter.

Fill `.secret` with a long sentence.

Fill `signature` with text that need to appear at the end of each email. This will be placed after a `-- ` signature separator.

Settings is a JSON file that contain some metada about the newsletter.
Two fields are allowed: `title` and `displayName`.

```json
{
  "title": "news from the kitchen",
  "displayName": "Mysterious alien"
}
```

User home directory must contain 3 files:

    FILE                      CONTENT
    .forward+subscribe        | "/var/tmp/nl/nl.sh subscribe"
    .forward+confirm          | "/var/tmp/nl/nl.sh confirm"
    .forward+unsubscribe      | "/var/tmp/nl/nl.sh unsubscribe"

## Usage

### send newsletter

```sh
./newsletter.sh SUBJECT NL_FILE
```

Where

- `SUBJECT` subject of the letter
- `NL_FILE` is the file containing the newsletter text

This will send a newsletter to every mail addresses listed in the `emails` file.
The __From address__  will be `USER@club1.fr`.
If you define a `displayName` in `settings.json`, it will be displayed in the __from__ like this:

    DISPLAY_NAME <USER@club1.fr>

If a `title` is set in `settings.json` it will be used as a prefix in each newsletter subjects (even during subscription and unsubscription).
