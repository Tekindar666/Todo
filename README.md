# Todo scripts

A small Bash command for daily Markdown todo lists. Scripts and tests live here;
personal todo records belong in a separate private repository at `~/Documents/todo`.

## Setup

Requires Bash, GNU sed (Linux), and Neovim.

Clone this repository somewhere other than `~/Documents/todo`, for example
`~/Documents/todo-scripts`. Create the records directory or clone your private
records repository there:

```sh
mkdir -p "$HOME/Documents/todo"
cd "$HOME/Documents/todo-scripts"
./setup.sh
```

Setup links `~/.local/bin/todo` to `todo.sh`. It prints instructions if you need
to add `~/.local/bin` to your PATH, and refuses to overwrite an existing command.
Keep the scripts directory in place so the link continues working.

## Usage

Run from any directory:

```sh
todo
```

The command creates today's `yy-mm-dd.md` file without clearing existing content,
carries unchecked tasks (`- [ ]`) from other dated files into today's file, and
archives those other files under `yy/mm/dd.md`. It then opens today's file in Neovim.
Future-dated files are also archived, so only use current or past dates.

The command does not run Git. Commit and push your records separately from
`~/Documents/todo`, using a private remote.

## Tests

```sh
bash tests/run.sh
```

Tests use temporary directories and fake external commands. They do not modify
real todo records, open Neovim, or create commits. No test framework is required.
