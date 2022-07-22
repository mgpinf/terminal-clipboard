# NOTE: we use $ before the subshell if we want to store the result for future use
# else just using subshell without '$' symbol is enough


# check if $CLIP_FILE is exported
# if not source it to zsh config file
if [[ -z $CLIP_FILE ]]; then
  echo 'export CLIP_FILE=/tmp/clip_file' > $HOME/.zshenv
  export CLIP_FILE=/tmp/clip_file
fi

# -----------------------------------------------------------------------------------------------------
# ASSIST FUNCTIONS
# -----------------------------------------------------------------------------------------------------
# function to refresh clipboard with check
function refresh_clipboard_with_check() {
  # NOTE: named pipes never get overwritten, so remove them if they exist, and create them again
  # we do this in order to prevent appending
  [[ -p $CLIP_FILE ]] && rm $CLIP_FILE
  mkfifo $CLIP_FILE
}


# function to refresh clipboard without check
function refresh_clipboard_without_check() {
  # NOTE: named pipes never get overwritten, so remove them if they exist, and create them again
  # we do this in order to prevent appending
  rm $CLIP_FILE
  mkfifo $CLIP_FILE
}


# function to clear clipboard
function clear_clipboard() {
  rm $CLIP_FILE
}
# -----------------------------------------------------------------------------------------------------


# -----------------------------------------------------------------------------------------------------
# DIRECT FUNCTIONS
# -----------------------------------------------------------------------------------------------------
# function to specify action as "copy" and store contents' addresses in clip_file
function fcp() {
  [[ $# -eq 0 ]] && return
  items_list=$(printf '%s\n' $@)
  refresh_clipboard_with_check
  # convert statement to subshell in order to prevent echoing of background output
  ( echo "cp\n$PWD\n$items_list" > $CLIP_FILE & )
}
# tab completion function for fcp
function _fcp() {
  local obj_list=$(fd --exact-depth=1 --hidden --exclude='.git*' --strip-cwd-prefix)
  [[ -z $obj_list ]] && return
  obj_list=(${(@f)obj_list})
  compadd $obj_list
}
compdef _fcp fcp


# function to specify action as "move" and store contents' addresses in clip_file
function fmv() {
  [[ $# -eq 0 ]] && return
  items_list=$(printf '%s\n' $@)
  refresh_clipboard_with_check
  # convert statement to subshell in order to prevent echoing of background output
  ( echo "mv\n$PWD\n$items_list" > $CLIP_FILE & )
}
# tab completion function for fmv
function _fmv() {
  local obj_list=$(fd --exact-depth=1 --hidden --exclude='.git*' --strip-cwd-prefix)
  [[ -z $obj_list ]] && return
  obj_list=(${(@f)obj_list})
  compadd $obj_list
}
compdef _fmv fmv


# NOTE: for copy operation, we store previously contents in clipboard, since their location remains the same
# NOTE: for move operation, we don't store previously contents in clipboard, since their location has changed

# function to paste clip_file contents
function fp() {
  if [[ ! -p $CLIP_FILE ]]; then
    echo 'Nothing to show'
    return
  fi
  local clip_file_details=$(cat $CLIP_FILE)
  local clip_file_details_array=(${(@f)clip_file_details})
  local clip_file_elements=(${clip_file_details_array:2})
  clip_file_elements=(${clip_file_elements[@]/#/$clip_file_details_array[2]/})
  if [[ $clip_file_details_array[1] = 'cp' ]]; then
    cp --recursive $clip_file_elements[@] .
    refresh_clipboard_without_check
    # convert statement to subshell in order to prevent echoing of background output
    ( echo $clip_file_details > $CLIP_FILE & )
  else
    mv $clip_file_elements[@] .
    clear_clipboard
  fi
}
# tab completion function for fp
function _fp() {
  return
}
compdef _fp fp


# function to display clip file
function fls() {
  if [[ ! -p $CLIP_FILE ]]; then
    echo 'Nothing to show'
    return
  fi
  local clip_file_details=$(cat $CLIP_FILE)
  refresh_clipboard_without_check
  local clip_file_details_array=("${(@f)clip_file_details}")
  printf 'Operation\n----------------\n%s\n\nSource Directory\n----------------\n%s\n\nItems\n----------------\n' ${clip_file_details_array:0:2}
  printf '%s\n' ${clip_file_details_array:2}
  ( echo $clip_file_details > $CLIP_FILE & )
}
# tab completion function for fls
function _fls() {
  return
}
compdef _fls fls


# function to clear clip file
function fclear() {
  if [[ ! -p $CLIP_FILE ]]; then
    echo 'Nothing in clipboard'
    return
  fi
  clear_clipboard
  echo 'Clipboard cleared'
}
# tab completion function for fclear
function _fclear() {
  return
}
compdef _fclear fclear
# -----------------------------------------------------------------------------------------------------
