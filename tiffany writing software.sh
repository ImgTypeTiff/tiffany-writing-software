#!/bin/sh
printf '\033c\033]0;%s\a' tiffany writing software
base_path="$(dirname "$(realpath "$0")")"
"$base_path/tiffany writing software.x86_64" "$@"
