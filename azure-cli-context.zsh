#!/usr/bin/env zsh

#------------------------------------------------------------------------------
# Global configuration variables
#------------------------------------------------------------------------------
: ${ZSH_AZCTX_CONTEXTS_DIR="${HOME}/.azure-contexts"}

#------------------------------------------------------------------------------
# Internal global variables
#------------------------------------------------------------------------------
typeset -g _rval
typeset -g -a _rval_a

#------------------------------------------------------------------------------
# Set up
#------------------------------------------------------------------------------
[[ -d ${ZSH_AZCTX_CONTEXTS_DIR} ]] || mkdir -p ${ZSH_AZCTX_CONTEXTS_DIR}

#------------------------------------------------------------------------------
# Public interface
#------------------------------------------------------------------------------

azctx() {
  if (( $# == 0 )); then
    _azctx_usage
    return 1
  fi

  typeset command=$1
  shift

  case "${command}" in
    help)
      _azctx_usage
      return 0
      ;;
    list)
      _r_get_contexts
      typeset -a contexts=(${_rval_a})

      _r_get_active_context
      typeset active_context=$_rval

      echo "Active context: $active_context"
      printf '%s\n' "${contexts[@]}"
      ;;
    new)
      if (( $# != 1 )); then
        _azctx_usage
        return 1
      fi

      typeset context=$1

      if _context_exists $context; then
        print >&2 "ERROR: context '$context' already exists"
        return 1
      fi

      mkdir -p ${ZSH_AZCTX_CONTEXTS_DIR}/${context}

      if [[ $? == 0 ]]; then
        print "Created context: $context"
      else
        print >&2 "ERROR: Could not create context $context"
      fi
      ;;
    reset)
      _r_get_active_context
      typeset active_context=$_rval

      if [[ -n $active_context ]]; then
        unset AZURE_CONFIG_DIR
      fi
      ;;
    rm)
      if (( $# != 1 )); then
        _azctx_usage
        return 1
      fi

      typeset context=$1
      if ! _context_exists $context; then
        print >&2 "ERROR: context '$context' does not exist"
        return 1
      fi

      _r_get_active_context
      typeset active_context=$_rval

      if [[ "$context" == "$active_context" ]]; then
        print >&2 "ERROR: can not remove active context '$context'"
        return 1
      fi

      rm -rf ${ZSH_AZCTX_CONTEXTS_DIR}/${context}

      if [[ $? == 0 ]]; then
        print "Removed context: $context"
      else
        print >&2 "ERROR: Could not remove context $context"
      fi
      ;;
    run)
      if (( $# < 2 )); then
        _azctx_usage
        return 1
      fi

      typeset context=$1
      shift

      if ! _context_exists $context; then
        print >&2 "ERROR: context '$context' does not exist"
        return 1
      fi

      AZURE_CONFIG_DIR=${ZSH_AZCTX_CONTEXTS_DIR}/${context} $@
      ;;
    use)
      if (( $# != 1 )); then
        _azctx_usage
        return 1
      fi

      typeset context=$1

      if ! _context_exists $context; then
        print >&2 "ERROR: context '$context' does not exist"
        return 1
      fi

      export AZURE_CONFIG_DIR=${ZSH_AZCTX_CONTEXTS_DIR}/${context}
      ;;
    *)
      print >&2 "ERROR: Unknown command: ${command}\n"
      _azctx_usage
      return 2
      ;;
    esac
}

#------------------------------------------------------------------------------
# Private implementation
#------------------------------------------------------------------------------

_azctx_usage() {
    print >&2 "azctx <command>"
    print >&2 "azctx help - show this help"
    print >&2 "azctx list - list available contexts"
    print >&2 "azctx new <context> - make a new context"
    print >&2 "azctx reset - reset context setting"
    print >&2 "azctx rm <context> - remove an existing context"
    print >&2 "azctx run <context> <command> - run a command in a context without switching"
    print >&2 "azctx use <context> - switch to a context"
}

_r_get_contexts() {
  typeset -a contexts=("${(@f)$(find "${ZSH_AZCTX_CONTEXTS_DIR}" -type d -mindepth 1 -maxdepth 1 -exec basename {} \; | sort )}")

  _rval_a=($contexts)
  return
}

_context_exists() {
  _r_get_contexts
  typeset -a contexts=($_rval_a)

  if [[ ${contexts[(ie)$1]} -le ${#contexts} ]]; then
    return 0
  else
    return 1
  fi
}

_r_get_active_context() {
  # Azure config dir is not set
  if [[ -z "$AZURE_CONFIG_DIR" ]]; then
    _rval=""
    return
  fi

  # Azure config dir is set, but is not one of our context directories
  if [[ "$AZURE_CONFIG_DIR" != "$ZSH_AZCTX_CONTEXTS_DIR"* ]]; then
    _rval=""
    return
  fi

  typeset context=$(basename $AZURE_CONFIG_DIR)

  # Configured context does not exist and is therefore not considered valid
  if ! _context_exists $context; then
    _rval=""
    return
  fi

  _rval=$context
  return
}
