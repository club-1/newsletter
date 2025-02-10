# CLUB1 Newsletter

A very simple newsletter for CLUB1 server members.
This was first only used for the club official newsletter and later extended as a service for members.

The design strategy of this piece of code is to take advantage of Postfix `.forward` files combined with recipient delimiter. 

**Features:**

- subscribe and unsubscribe using emails
    - email confirmation at subscription
- store subscribers email addresses in a file, separated by new lines
- no web interface


## User setup



### Configuration folder

The configuration is stored under this folder:

    ~/.config/newsletter/

    emails              must be readable and writable
    .secret             must be readable
    signature.txt       must be readable
    settings.json       must be readable

`emails` will be filled with each email that subscribed to the newsletter.

Fill `.secret` with a long sentence.

Fill `signature.txt` with text that need to appear at the end of each email. This will be placed after a `-- ` signature separator.

Settings is a JSON file that contain some metada about the newsletter.
Two fields are allowed: `title` and `displayName`.

```json
{
  "title": "news from the kitchen",
  "displayName": "Mysterious alien"
}
```

### Forwarding

User home directory must contain 3 files:

    FILE                      CONTENT
    .forward+subscribe        | "SCRIPT_PATH subscribe"
    .forward+confirm          | "SCRIPT_PATH confirm"
    .forward+unsubscribe      | "SCRIPT_PATH unsubscribe"

Where `SCRIPT_PATH` is the full absolute path to the `nl.sh` script. For example: `/usr/local/sbin/nl.sh`.

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



## Advanced setup

This advanced setup is mosty designed for the purpose of a newsletter not related to an user on the server.

### Optionnal arguments

The `nl.sh` can take two additionnal optionnal argument that are used to override config path and email prefix.

    nl.sh SUB_COMMAND [CONFIG_PATH] [PREFIX]

- `CONFIG_PATH` is a path to the config folder. That must contain all config files as described in [setup](#user-setup).
- `PREFIX` is the string that will be used in the email address like this: `PREFIX+subscribe@club1.fr`


## todo

- [x] ask for subscription after unsubscription
- [x] add list unsubscribe header
- [x] quoted printable
