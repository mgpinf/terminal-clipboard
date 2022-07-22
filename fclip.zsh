# check if $CLIP_FILE is defined
if [[ ! $+$CLIP_FILE ]]
then
  export CLIP_FILE="$HOME/.clip_dir/clip_file.txt"
fi

# check if $CLIP_FILE exists
if [[ ! -f $CLIP_FILE ]]
then
  echo "Clip file not found\nCreating it..."
  mkdir -p $HOME/.clip_dir
  touch $HOME/.clip_dir/clip_file.txt
fi


# -----------------------------------------------------------------------------------------------------
# FUNCTIONS
# -----------------------------------------------------------------------------------------------------

# function to specify action as "copy" and store contents' addresses in clip_file
function fcp() {
  [[ $# -eq 0 ]] && return
  items_list=$(printf '%s\n' $@)
  echo "cp\n$PWD\n$items_list" > $CLIP_FILE
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
  echo "mv\n$PWD\n$items_list" > $CLIP_FILE
}
# tab completion function for fmv
function _fmv() {
  local obj_list=$(fd --exact-depth=1 --hidden --exclude='.git*' --strip-cwd-prefix)
  [[ -z $obj_list ]] && return
  obj_list=(${(@f)obj_list})
  compadd $obj_list
}
compdef _fmv fmv


# function to paste clip_file contents
function fp() {
  if [[ ! -s $CLIP_FILE ]]; then
    echo 'Nothing to show'
    return
  fi
  local clip_file_details=(${(@f)$(cat $CLIP_FILE)})
  local clip_file_elements=(${clip_file_details:2})
  clip_file_elements=(${clip_file_elements[@]/#/$clip_file_details[2]/})
  if [[ $clip_file_details[1] = 'cp' ]]; then
    clip_file_details[1]+=' -r'
  else
    truncate -s 0 $CLIP_FILE
  fi
  eval $clip_file_details[1] $clip_file_elements .
}
# tab completion function for fp
function _fp() {
  return
}
compdef _fp fp


# function to display clip file
function fls() {
  if [[ ! -s $CLIP_FILE ]]; then
    echo 'Nothing to show'
    return
  fi
  local clip_file_details=("${(@f)$(cat $CLIP_FILE)}")
  printf "Operation\n----------------\n%s\n\nSource Directory\n----------------\n%s\n\nItems\n----------------\n" ${clip_file_details:0:2}
  printf "%s\n" ${clip_file_details:2}
}
# tab completion function for fls
function _fls() {
  return
}
compdef _fls fls


# function to clear clip file
function fclear() {
  if [[ ! -s $CLIP_FILE ]]; then
    echo 'Clip file already empty'
    return
  fi
  truncate --size 0 $CLIP_FILE
  echo 'Clip file cleared'
}
# tab completion function for fclear
function _fclear() {
  return
}
compdef _fclear fclear
