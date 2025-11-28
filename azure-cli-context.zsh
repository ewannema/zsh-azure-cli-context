#!/usr/bin/env zsh

#------------------------------------------------------------------------------
# Global configuration variables
#------------------------------------------------------------------------------
: "${ZSH_AZCTX_CONTEXTS_DIR:="${HOME}/.azure-contexts"}"

#------------------------------------------------------------------------------
# Add completions to fpath
#------------------------------------------------------------------------------
if [[ -d "${0:A:h}/completions" ]]; then
  fpath=("${0:A:h}/completions" $fpath)
fi

#------------------------------------------------------------------------------
# Internal global variables
#------------------------------------------------------------------------------
typeset -g REPLY
typeset -g -a reply
typeset -g ZSH_AZCTX_PREV_CONTEXT

#------------------------------------------------------------------------------
# Public interface
#------------------------------------------------------------------------------

azctx() {
  # Lazy initialization - create contexts directory on first use
  if [[ ! -d $ZSH_AZCTX_CONTEXTS_DIR ]] && ! mkdir -p -- "$ZSH_AZCTX_CONTEXTS_DIR"; then
    print >&2 "ERROR: Could not create contexts dir: $ZSH_AZCTX_CONTEXTS_DIR"
    return 1
  fi

  if (( $# == 0 )); then
    _azctx_usage
    return 1
  fi

  local command=$1
  shift

  case "${command}" in
    current)
      _r_get_active_context
      local active_context=$REPLY

      if [[ -n $active_context ]]; then
        print "$active_context"
      fi
      ;;
    help)
      _azctx_usage
      return 0
      ;;
    list)
      _r_get_contexts
      local -a contexts=("${reply[@]}")

      _r_get_active_context
      local active_context=$REPLY

      print "Active context: ${active_context:-<none>}"
      printf '%s\n' "${contexts[@]}"
      ;;
    new)
      if (( $# != 1 )); then
        _azctx_usage
        return 1
      fi

      local context=$1

      # Validate context name
      if ! _validate_context_name "$context"; then
        return 1
      fi

      if _context_exists "$context"; then
        print >&2 "ERROR: context '$context' already exists"
        return 1
      fi

      if mkdir -p -- "${ZSH_AZCTX_CONTEXTS_DIR}/${context}"; then
        print "Created context: $context"
      else
        print >&2 "ERROR: Could not create context $context"
        return 1
      fi
      ;;
    reset)
      _r_get_active_context
      local active_context=$REPLY

      if [[ -n $active_context ]]; then
        unset AZURE_CONFIG_DIR
      fi

      unset ZSH_AZCTX_PREV_CONTEXT

      print "Reset active context"
      ;;
    rm)
      if (( $# != 1 )); then
        _azctx_usage
        return 1
      fi

      local context=$1
      if ! _context_exists "$context"; then
        print >&2 "ERROR: context '$context' does not exist"
        return 1
      fi

      _r_get_active_context
      local active_context=$REPLY

      if [[ "$context" == "$active_context" ]]; then
        print >&2 "ERROR: can not remove active context '$context'"
        return 1
      fi

      if ! rm -rf -- "${ZSH_AZCTX_CONTEXTS_DIR:?}/$context"; then
        print >&2 "ERROR: Could not remove context $context"
        return 1
      fi

      print "Removed context: $context"
      ;;
    run)
      if (( $# < 2 )); then
        _azctx_usage
        return 1
      fi

      local context=$1
      shift

      if ! _context_exists "$context"; then
        print >&2 "ERROR: context '$context' does not exist"
        return 1
      fi

      AZURE_CONFIG_DIR="${ZSH_AZCTX_CONTEXTS_DIR}/${context}" "$@"
      ;;
    use)
      if (( $# != 1 )); then
        _azctx_usage
        return 1
      fi

      local context=$1

      # Handle '-' to switch to previous context
      if [[ "$context" == "-" ]]; then
        if [[ -z "$ZSH_AZCTX_PREV_CONTEXT" ]]; then
          print >&2 "ERROR: no previous context"
          return 1
        fi

        if ! _context_exists "$ZSH_AZCTX_PREV_CONTEXT"; then
          print >&2 "ERROR: previous context '$ZSH_AZCTX_PREV_CONTEXT' no longer exists"
          unset ZSH_AZCTX_PREV_CONTEXT
          return 1
        fi

        context=$ZSH_AZCTX_PREV_CONTEXT
      else
        if ! _context_exists "$context"; then
          print >&2 "ERROR: context '$context' does not exist"
          return 1
        fi
      fi

      # Save current context as previous before switching
      _r_get_active_context
      local current_context=$REPLY

      if [[ -n "$current_context" ]] && [[ "$current_context" != "$context" ]]; then
        ZSH_AZCTX_PREV_CONTEXT=$current_context
      fi

      export AZURE_CONFIG_DIR="${ZSH_AZCTX_CONTEXTS_DIR}/${context}"
      print "Switched to context: $context"
      ;;
    *)
      print >&2 "ERROR: Unknown command: ${command}"
      _azctx_usage
      return 2
      ;;
    esac
}

#------------------------------------------------------------------------------
# Private implementation
#------------------------------------------------------------------------------

_validate_context_name() {
  local context=$1

  # Empty name
  if [[ -z "$context" ]]; then
    print >&2 "ERROR: Context name cannot be empty"
    return 1
  fi

  # Dots (. or ..)
  if [[ "$context" == "." || "$context" == ".." ]]; then
    print >&2 "ERROR: Invalid context name '$context'"
    return 1
  fi

  # Contains slash
  if [[ "$context" == */* ]]; then
    print >&2 "ERROR: Context name cannot contain '/'"
    return 1
  fi

  # Starts with dash (causes issues with commands)
  if [[ "$context" == -* ]]; then
    print >&2 "ERROR: Context name cannot start with '-'"
    return 1
  fi

  return 0
}

_azctx_usage() {
  print >&2 "azctx <command>"
  print >&2 "azctx current - show the current active context"
  print >&2 "azctx help - show this help"
  print >&2 "azctx list - list available contexts"
  print >&2 "azctx new <context> - make a new context"
  print >&2 "azctx reset - reset context setting"
  print >&2 "azctx rm <context> - remove an existing context"
  print >&2 "azctx run <context> <command> - run a command in a context without switching"
  print >&2 "azctx use <context> - switch to a context"
  print >&2 "azctx use - - switch to previous context"
}

_r_get_contexts() {
  local -a contexts
  # get dirs and return the last component (tail)
  contexts=("$ZSH_AZCTX_CONTEXTS_DIR"/*(N/:t))

  # sort the contexts
  contexts=("${(on)contexts[@]}")

  reply=("${contexts[@]}")
}

_context_exists() {
  _r_get_contexts
  local -a contexts=("${reply[@]}")

  # non-zero index -> found
  (( ${contexts[(Ie)$1]} ))
}

_r_get_active_context() {
  # Azure config dir is not set
  if [[ -z "$AZURE_CONFIG_DIR" ]]; then
    REPLY=""
    return
  fi

  # Azure config dir is set, but is not one of our context directories
  if [[ $AZURE_CONFIG_DIR != $ZSH_AZCTX_CONTEXTS_DIR/* ]]; then
    REPLY=""
    return
  fi

  local context=${AZURE_CONFIG_DIR:t}

  # Configured context does not exist and is therefore not considered valid
  if ! _context_exists "$context"; then
    REPLY=""
    return
  fi

  REPLY=$context
  return
}
