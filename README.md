# pleroma-emoji-edit
Add or remove emojis from Pleroma emoji packs (maybe more in the future!)

## Requirements
- awk
- basename (GNU Coreutils)
- jj (https://github.com/tidwall/jj)
- wget

## Usage
```
pleroma-emoji-edit -e EMOJI_PATH -j JSON_PATH [-n EMOJI_NAME | -f EMOJI_FILE_NAME | -r | -d | -U pleroma | -jj jj | -h]

  -e  | --emoji-path       : URL or local path of emoji.
  -j  | --json-path        : Path for the json.pack file you want to edit.
  -n  | --emoji-name       : Name of the emoji to be added or deleted.
  -f  | --emoji-filename   : Time in seconds to end the clip instead of timecode.
  -r  | --remove-emoji     : Remove emoji from pack.json.
  -d  | --delete-file      : Also delete emoji when removing from pack.json.
  -u  | --pleroma-username : Name of your pleroma user in the system [pleroma].
  -jj | --jj-bin           : Specify jj binary [jj].
  -h  | --help             : Shows this message.
```
