# check if fd exists
if (( ! $+commands[fd] ))
then
  echo "fd not installed"
  return
fi

# check if fzf exists
if (( ! $+commands[fzf] ))
then
  echo "fzf not installed"
  return
fi

# check if $CLIP_FILE is defined
if [[ ! $+$BIN ]]
then
  export BIN='/usr/bin'
fi

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

# function to specify action as "copy" and store contents' addresses in clip_file
function fcp() {
  [[ -z $($BIN/ls --almost-all) ]] && return
  local obj_list=$(fd --exact-depth=1 --hidden --exclude='.git*' --strip-cwd-prefix --color=always | fzf --multi --layout=reverse --ansi)
  [[ -z $obj_list ]] && return
  echo "cp -r\n$PWD\n$obj_list" > $CLIP_FILE
}

# function to specify action as "move" and store contents' addresses in clip_file
function fmv() {
  [[ -z $($BIN/ls --almost-all) ]] && return
  local obj_list=$(fd --exact-depth=1 --hidden --exclude='.git*' --strip-cwd-prefix --color=always | fzf --multi --layout=reverse --ansi)
  [[ -z $obj_list ]] && return
  echo "mv\n$PWD\n$obj_list" > $CLIP_FILE
}

# function to paste clip_file contents
function fp() {
  [[ -s $CLIP_FILE ]] || { echo 'Nothing to paste'; return }
  local clip_file_details=("${(@f)$(cat $CLIP_FILE)}")
  local clip_file_elements=(${clip_file_details:2})
  clip_file_elements=("${clip_file_elements[@]/#/$clip_file_details[2]/}")
  eval $clip_file_details[1] $clip_file_elements .
  [[ $clip_file_details[1] = 'mv' ]] && truncate -s 0 $CLIP_FILE
}

# function to display clip file
function fls() {
  [[ -s $CLIP_FILE ]] || { echo 'Nothing to show'; return }
  local clip_file_details=("${(@f)$(cat $CLIP_FILE)}")
  printf "Operation\n----------------\n%s\n\nSource Directory\n----------------\n%s\n\nItems\n----------------\n" ${clip_file_details:0:2}
  printf "%s\n" ${clip_file_details:2}
}

# function to clear clip file
function fclear() {
  [[ -s $CLIP_FILE ]] || { echo 'Clip file already empty'; return }
  truncate -s 0 $CLIP_FILE
  echo 'Clip file cleared'
}
