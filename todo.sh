#!/bin/bash

cd "$HOME/Documents/todo" || exit 1

today=$(date +%y-%m-%d)
touch "$today.md" || exit 1

for file in [0-9][0-9]-[0-9][0-9]-[0-9][0-9].md; do
	[ -f "$file" ] || continue
	# don't save today's todo list
	[ "$file" = "$today.md" ] && continue
	date_part=${file%.md}
	yy=${date_part%%-*}
	rest=${date_part#*-}
	mm=${rest%%-*}
	dd=${rest#*-}

	grep '^- \[ \]' "$file" >>"$today.md"
	status=$?

	case "$status" in
		0)
			sed -i '/^- \[ \]/d' "$file" || exit 1
			;;
		1)
			;;
		*)
			printf 'Could not transfer tasks from %s\n' "$file" >&2
			exit 1
			;;
	esac

	mkdir -p "$yy/$mm" || exit 1
	mv -i "$file" "$yy/$mm/$dd.md" || exit 1
done

nvim "$today.md"
