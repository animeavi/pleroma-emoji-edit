#!/bin/bash

set -e

url_regex='^(https?|ftp|file)://'

function parse_args
{
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -e  | --emoji-path )
                emoji_path="$2"
                shift
                shift
                ;;
            -j  | --json-path )
                json_path="$2";
                shift
                shift
                ;;
            -n  | --emoji-name )
                emoji_name="$2";
                shift
                shift
                ;;
            -f  | --emoji-filename )
                emoji_filename="$2";
                shift
                shift
                ;;
            -r  | --remove-emoji )
                remove_emoji="yes";
                shift
                ;;
            -d  | --delete-file )
                delete_file="yes";
                shift
                ;;
            -u  | --pleroma-username )
                pleroma_username="$2";
                shift
                shift
                ;;
            -jj | --jj-bin )
                jj_bin="$2";
                shift
                shift
                ;;
            -h | --help )
                usage;
                exit 1
                ;;
            -* | --* )
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    # set defaults
    if [[ -z "$pleroma_username" ]]; then
        pleroma_username="pleroma";
    fi

    if [[ -z "$jj_bin" ]]; then
        jj_bin="jj";
    fi

    # argument validation
    if [[ -z "${json_path}" ]]; then
        echo "Error: You need to specify the pack.json file!"
        usage
        exit 1;
    fi

    if [[ -z "${emoji_path}" && -z "${remove_emoji}" ]]; then
        echo "Error: Not all required arguments were specified."
        usage
        exit 1;
    fi

    if [[ ! -z "${delete_file}" && -z "${remove-emoji}" ]]; then
        echo "Error: delete-file used without remove-emoji!"
        usage
        exit 1;
    fi

    json_dir=$(dirname "$json_path")
}

function usage
{
    echo "usage: pleroma-emoji-edit -e EMOJI_PATH -j JSON_PATH [-n EMOJI_NAME | -f EMOJI_FILE_NAME | -r | -d | -U pleroma | -jj jj | -h]"
    echo "   ";
    echo "  -e  | --emoji-path       : URL or local path of emoji.";
    echo "  -j  | --json-path        : Path for the json.pack file you want to edit.";
    echo "  -n  | --emoji-name       : Name of the emoji to be added or deleted.";
    echo "  -f  | --emoji-filename   : Time in seconds to end the clip instead of timecode.";
    echo "  -r  | --remove-emoji     : Remove emoji from pack.json.";
    echo "  -d  | --delete-file      : Also delete emoji when removing from pack.json.";
    echo "  -u  | --pleroma-username : Name of your pleroma user in the system [$pleroma_username].";
    echo "  -jj | --jj-bin           : Specify jj binary [$jj_bin].";
    echo "  -h  | --help             : Shows this message.";
}

function update_count
{
    emoji_count=$(jj -i $json_path files -n | wc -l | awk '{print $1-2}')
    jj -i $json_path -v "$emoji_count" "files_count" -p  -o $json_path
}


function run
{
    parse_args "$@"

    if [[ -z "${remove_emoji}" ]]; then
        # Grab filename and emoji name from filename if not specified
        if [[ -z "${emoji_filename}" ]]; then
            emoji_filename=$(basename "$emoji_path")
        fi

        if [[ -z "${emoji_name}" ]]; then
            emoji_name="${emoji_filename%.*}"
        fi

        if [[ $emoji_path =~ $url_regex ]]; then
            sudo -Hu "$pleroma_username" wget "$emoji_path" -O "$json_dir/$emoji_filename"
        else
            # sudo to make sure we can copy the file from anywhere
            sudo cp "$emoji_path" "$json_dir/$emoji_filename"
            sudo chown "$pleroma_username:$pleroma_username" "$json_dir/$emoji_filename"
        fi

        jj -i $json_path -v "$emoji_filename" "files.$emoji_name" -p -o $json_path
        update_count

        echo "Emoji added!"
        echo "Emoji name: $emoji_name"
        echo "Emoji source: $emoji_path"
        echo "Emoji path: $json_dir/$emoji_filename"
        exit 0
    else
        removed_emoji_file=$(jj -i "$json_path" -O "files.$emoji_name")

        if [[ -z "${removed_emoji_file}" ]]; then
            echo "Emoji '$emoji_name' not found, not removing!"
            exit 1
        fi

        jj -i $json_path -D "files.$emoji_name" -p -o $json_path
        update_count
        echo "Emoji removed!"
        echo "Emoji name: $emoji_name"
        echo "Emoji path: $json_dir/$removed_emoji_file"

        if [[ ! -z "${delete_file}" ]]; then
            rm -rf "$json_dir/$removed_emoji_file"
            echo "Emoji file deleted from file system!"
        fi

        exit 0
    fi
}

run "$@";
