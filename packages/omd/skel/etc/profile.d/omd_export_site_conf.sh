set -a
. "$OMD_ROOT/etc/omd/site.conf"
set +a

case "$-" in
*i*) # interactive
    _omd_prompt_command() {
      # if -a is already active do not inactivate it
      local defer="set +a"
      if [[ $- =~ a ]] ; then
	defer=":"
      fi

      set -a
      . "$OMD_ROOT/etc/omd/site.conf"
      eval "$defer"
    }

    case "$PROMPT_COMMAND" in
      *_omd_prompt_command*) ;;
      *) PROMPT_COMMAND="${PROMPT_COMMAND}${PROMPT_COMMAND:+;}_omd_prompt_command" ;;
    esac
;;
esac

