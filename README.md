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
Three fields are allowed: `title`, `displayName` and `fromUsername`.

```json
{
  "title": "news from alien kitchen",
  "displayName": "Mysterious alien",
  "fromUsername": "myst-alien"
}
```

Where `title` is the official name of the newsletter. It will be used during sign up phase. `displayName` is the email associated display name in the `From` field. And `fromUsername` is the text before `@club1.fr` in the `From` field.

    From: DISPLAY_NAME <FROM_USERNAME@club1.fr>

### Forwarding

User home directory must contain 3 files:

    FILE                      CONTENT
    .forward+subscribe        | "SCRIPT_PATH subscribe"
    .forward+confirm          | "SCRIPT_PATH confirm"
    .forward+unsubscribe      | "SCRIPT_PATH unsubscribe"

Where `SCRIPT_PATH` is the full absolute path to the `nl` script. For example: `/usr/local/sbin/nl`.

#### Override config path

The `nl` can take an optionnal argument that is used to override config path.

    nl [-c CONFIG_PATH] SUB_COMMAND

`CONFIG_PATH` is a path to the config folder. That must contain all config files as described in [setup](#user-setup).



## Usage

### send newsletter

```sh
./newsletter [-c CONFIG_PATH] SUBJECT [CONTENT_FILE]
```

Where:

- `CONFIG_PATH` is the folder containing the config (default is `~/.config/newsletter`)
- `SUBJECT` is the subject of the letter
- `CONTENT_FILE` is the file containing the newsletter text. An alternative method is to transmit the content through STDIN using a pipe.

This will send a newsletter to every mail addresses listed in the `emails` file in config folder.
The default __From address__  will use your club1 username like this `USER@club1.fr`, but can be overidden using the settings file.
If you define a `displayName` in `settings.json`, it will be displayed in the like this:

    DISPLAY_NAME <USER@club1.fr>

If a `title` is set in `settings.json` it will be used as a prefix in each newsletter subjects under square brackets (even during subscription and unsubscription).
