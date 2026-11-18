#!/bin/bash
set -e

script_dir=$(cd "$(dirname "$0")" && pwd)

chmod +x "$script_dir/todo.sh"
mkdir -p "$HOME/.local/bin"
ln -s "$script_dir/todo.sh" "$HOME/.local/bin/todo"

printf 'Installed todo at %s/.local/bin/todo\n' "$HOME"

case ":$PATH:" in
	*:"$HOME/.local/bin":*) ;;
	*) printf 'Add this to your shell config: export PATH="$HOME/.local/bin:$PATH"\n' ;;
esac
