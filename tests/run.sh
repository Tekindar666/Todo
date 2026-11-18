#!/bin/bash
set -e

project_dir=$(cd "$(dirname "$0")/.." && pwd)

fixture() {
	test_dir=$(mktemp -d)
	trap 'rm -rf "$test_dir"' EXIT
	export HOME="$test_dir/home"
	workspace="$test_dir/project with spaces"
	todo_dir="$HOME/Documents/todo"
	mkdir -p "$workspace" "$todo_dir" "$test_dir/bin"
	cp "$project_dir/setup.sh" "$project_dir/todo.sh" "$workspace/"
	printf '#!/bin/sh\nprintf "26-11-18\\n"\n' > "$test_dir/bin/date"
	printf '#!/bin/sh\ntouch "$HOME/git-called"\nexit 1\n' > "$test_dir/bin/git"
	printf '#!/bin/sh\nexit 0\n' > "$test_dir/bin/nvim"
	chmod +x "$test_dir/bin/"*
	export PATH="$test_dir/bin:$PATH"
	cd "$test_dir"
}

expect_content() {
	printf '%s' "$2" | diff -u --label expected - "$1"
}

setup_installs_command() {
	bash "$workspace/setup.sh" > /dev/null
	[ -L "$HOME/.local/bin/todo" ]
	[ "$(readlink "$HOME/.local/bin/todo")" = "$workspace/todo.sh" ]
	[ -x "$HOME/.local/bin/todo" ]
	PATH="$HOME/.local/bin:$PATH" todo
	[ -f "$todo_dir/26-11-18.md" ]
}

setup_preserves_existing_command() {
	mkdir -p "$HOME/.local/bin"
	printf 'existing command\n' > "$HOME/.local/bin/todo"
	if bash "$workspace/setup.sh" > /dev/null 2>&1; then
		printf 'Expected setup to reject an existing command\n' >&2
		return 1
	fi
	expect_content "$HOME/.local/bin/todo" $'existing command\n'
}

todo_preserves_today() {
	printf '%s\n' '- [ ] existing task' > "$todo_dir/26-11-18.md"
	bash "$workspace/todo.sh"
	bash "$workspace/todo.sh"
	expect_content "$todo_dir/26-11-18.md" $'- [ ] existing task\n'
	[ ! -d "$todo_dir/26" ]
}

todo_carries_tasks_and_archives() {
	printf '%s\n' '- [ ] existing task' > "$todo_dir/26-11-18.md"
	printf '%s\n' '# Yesterday' '- [ ] unfinished' '- [x] finished' > "$todo_dir/26-11-17.md"
	bash "$workspace/todo.sh"
	[ ! -e "$todo_dir/26-11-17.md" ]
	expect_content "$todo_dir/26-11-18.md" $'- [ ] existing task\n- [ ] unfinished\n'
	expect_content "$todo_dir/26/11/17.md" $'# Yesterday\n- [x] finished\n'
	bash "$workspace/todo.sh"
	expect_content "$todo_dir/26-11-18.md" $'- [ ] existing task\n- [ ] unfinished\n'
}

todo_archives_without_unfinished_tasks() {
	printf '%s\n' '- [x] finished' > "$todo_dir/26-11-17.md"
	bash "$workspace/todo.sh"
	[ ! -e "$todo_dir/26-11-17.md" ]
	expect_content "$todo_dir/26/11/17.md" $'- [x] finished\n'
	expect_content "$todo_dir/26-11-18.md" ''
}

todo_stops_on_transfer_error() {
	printf '%s\n' '- [ ] unfinished' > "$todo_dir/26-11-17.md"
	printf '#!/bin/sh\nexit 2\n' > "$test_dir/bin/grep"
	chmod +x "$test_dir/bin/grep"
	if bash "$workspace/todo.sh" > /dev/null 2>&1; then
		printf 'Expected todo to stop on a grep error\n' >&2
		return 1
	fi
	expect_content "$todo_dir/26-11-17.md" $'- [ ] unfinished\n'
	expect_content "$todo_dir/26-11-18.md" ''
	[ ! -d "$todo_dir/26" ]
}

run_test() (
	printf 'Testing %s\n' "$1"
	fixture
	"$1"
	[ ! -e "$HOME/git-called" ]
	printf '\033[32mPASS: %s\033[0m\n' "$1"
)

for test in \
	setup_installs_command \
	setup_preserves_existing_command \
	todo_preserves_today \
	todo_carries_tasks_and_archives \
	todo_archives_without_unfinished_tasks \
	todo_stops_on_transfer_error; do
	run_test "$test"
done
