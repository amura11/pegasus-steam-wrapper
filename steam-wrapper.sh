#!/bin/bash

parent_process=$(ps -o comm= $(ps -o ppid= $PPID))

# Check if the caller is systemd, this is likely Pegasus calling it via flatpak-spawn
if [[ $parent_process == "systemd" ]]; then
  # Get the first argument
  first_arg="$1"

  # Check if the first argument has the format "steam://rungameid/1234567"
  if [[ "$first_arg" =~ ^steam://rungameid/([0-9]+)$ ]]; then
    
    # Extract the numbers from the first argument
    game_id="${BASH_REMATCH[1]}"

    # Launch the game with the specified ID
    /usr/games/steam -silent "$@" 2>&1 | tee >(
      while read line; do
        if [[ $line == *"Game process removed: AppID $game_id"* ]]; then
          sleep 10; steam -shutdown; break
        fi
      done
      )
  fi
else
  # If the calling process is not systemd, or the first argument does not match the expected format,
  # execute the original steam command with the provided arguments
  /usr/games/steam "$@"
fi