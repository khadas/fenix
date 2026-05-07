#!/bin/bash

# systemd 259 enables OSC 3008 shell context integration through
# /etc/profile.d/80-systemd-osc-context.sh. Serial consoles and Linux VTs do
# not understand those sequences and print them literally.

# Keep OSC context enabled for SSH and graphical terminals.
[ -n "${SSH_CONNECTION:-}" ] && return 0

case "${TERM:-}" in
dumb|linux|vt100|vt102|vt220)
	;;
*)
	return 0
	;;
esac

[ -n "${BASH_VERSION:-}" ] || return 0

# serial-getty uses TERM=dumb to suppress systemd OSC 3008 output before
# login. Restore a more capable terminal type for the interactive shell on
# supported serial consoles once the shell starts.
if [ "${TERM:-}" = "dumb" ]; then
	case "${TTY:-}" in
	/dev/ttyS0|ttyS0|/dev/ttyAML0|ttyAML0|/dev/ttyFIQ0|ttyFIQ0)
		export TERM=linux
		;;
	esac
fi

PS0=

if declare -p PROMPT_COMMAND >/dev/null 2>&1; then
	if declare -p PROMPT_COMMAND 2>/dev/null | grep -q '^declare \-a'; then
		prompt_commands=()
		for cmd in "${PROMPT_COMMAND[@]}"; do
			[ "$cmd" = "__systemd_osc_context_precmdline" ] && continue
			prompt_commands+=("$cmd")
		done
		PROMPT_COMMAND=("${prompt_commands[@]}")
	else
		PROMPT_COMMAND=${PROMPT_COMMAND//__systemd_osc_context_precmdline; /}
		PROMPT_COMMAND=${PROMPT_COMMAND//__systemd_osc_context_precmdline;/}
		PROMPT_COMMAND=${PROMPT_COMMAND//; __systemd_osc_context_precmdline/}
		PROMPT_COMMAND=${PROMPT_COMMAND//;__systemd_osc_context_precmdline/}
		PROMPT_COMMAND=${PROMPT_COMMAND//__systemd_osc_context_precmdline/}
	fi
fi
