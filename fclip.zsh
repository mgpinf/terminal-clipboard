# NOTE: -m flag passed to fzf to select multiple objects
# NOTE: --exact-depth 1 flag passed to fd in order to select elements only from the current directory
# NOTE: --type d flag passed to specify directory
# NOTE: --type d flag passed to specify file
# NOTE: clip_file (file containing the addresses of contents on which the operation mentioned in the first line is going to be performed)

function fclip() {
	if [ $# -gt 1 ]
	then
		echo "Invalid argument count. Use --help flag for help"
		return
	fi
	if  [ $# -eq 0 ] || [ $1 = "--help" ]
	then
		echo "fclip - cli emulation of graphical copy, move and paste items across directories by copying to clipboard"
		echo "Usage: fclip [OPTION]"
		echo "--help    Show help"
		return
	fi
	if [ $1 != "cp" ] && [ $1 != "mv" ] && [ $1 != "p" ] && [ $1 != "ls" ] && [ $1 != "clear" ]
	then
		echo "Invalid argument. Use --help flag for help"
		return
	fi
	if (( ! $+commands[fd] ))
	then
		echo "fd not installed"
		return
	fi
	if (( ! $+commands[fzf] ))
	then
		echo "fzf not installed"
		return
	fi
	local clip_file=~/.clip_dir/.clip_file.txt
	if [ ! -f $clip_file ]
	then
		echo "Clip file not found\nCreating it..."
		mkdir ~/.clip_dir
		touch $clip_file
		echo "Clip file created\nPerform operation again"
		return
	fi
	if [ $1 = "cp" ]
	then
		local obj_list=$(fd --exact-depth=1 --hidden --strip-cwd-prefix)
		# if atleast one element is present in the given directory
		if [ ${#obj_list[@]} -ne 0 ]
		then
			obj_list=$(echo $obj_list | fzf -m)
			# if atelast one element is selected from the list
			if [ ${#obj_list[@]} -ne 0 ]
			then
				echo "cp\n$PWD\n$obj_list" > $clip_file
			fi
		fi
	elif [ $1 = "mv" ]
	then
		local obj_list=$(fd --exact-depth=1 --hidden --strip-cwd-prefix)
		# if atleast one element is present in the given directory
		if [ ${#obj_list[@]} -ne 0 ]
		then
			obj_list=$(echo $obj_list | fzf -m)
			# if atelast one element is selected from the list
			if [ ${#obj_list[@]} -ne 0 ]
			then
				echo "mv\n$PWD\n$obj_list" > $clip_file
			fi
		fi
	elif [ $1 = "p" ]
	then
		# if clip file is empty, nothing to be done
		if [ $(wc -c $clip_file | awk '{print $1}') -eq 0 ]
		then
			echo "Nothing to paste"
			return
		fi
		# making note of operations
		local command=$(head -n 2 $clip_file)
		local clip_file_ops=("${(@f)$(echo $command)}")
		# operation to be performed (copy or move)
		local op=$clip_file_ops[1]
		# directory in which the operation is going to be performed on the below-mentioned elements
		local op_dir=$clip_file_ops[2]
		# elements in the above-mentioned directory on which the operation is going to be performed
		local clip_file_elements=("${(@f)$(tail -n +3 $clip_file)}")
		# recursive flag (applies only to copy operation)
		local r_flag
		if [ $op = "cp" ]
		then
			# recursive flag set since items always copied in a recursive manner since the element could be either a file or a directory (directories need to be copied recursively)
			r_flag="-r"
		else
			# recursive flag not set since it doesn't apply to move operation
			r_flag=""
		fi
		for element in $clip_file_elements
		do
			eval '$op $r_flag "$op_dir/$element" .'
		done
		# clears the clip file since the object is no longer stored in the original location after the move operation (not the case with copy)
		if [ $r_flag = ""]
		then
			truncate -s 0 $clip_file
		fi
	elif [ $1 = "ls" ]
	then
		# if clip file is empty, return since nothing to be shown
		if [ $(wc -c $clip_file | awk '{print $1}') -eq 0 ]
		then
			echo "Nothing to show"
			return
		fi
		local command=$(head -n 2 $clip_file)
		local clip_file_ops=("${(@f)$(echo $command)}")
		# operation to be performed (copy or move)
		local op=$clip_file_ops[1]
		# directory in which the operation is going to be performed on the below-mentioned elements
		local op_dir=$clip_file_ops[2]
		local clip_file_elements=("${(@f)$(tail -n +3 $clip_file)}")
		echo "Operation\n----------------\n$op\n"
		echo "Source Directory\n----------------\n$op_dir\n" 
		echo "Items\n----------------"
		local clip_file_element
		for clip_file_element in $clip_file_elements
		do
			echo "$clip_file_element"
		done
	elif [ $1 = "clear" ]
	then
		truncate -s 0 $clip_file
		echo "Clip file cleared"
	fi
}

# function to generate tab completions
function _fclip() {
	local -a commands=(
		"cp:select items to be copied"
	    "mv:select items to be moved"
		"p:paste items selected for copying/moving (if selected)"
		"ls:list items to be copied/moved (if selected)"
		"clear:clear selected list of items (if selected)"
		"--help:show help"
	)
	_describe -t commands "commands" commands
}

# defining completion function for the main function
compdef _fclip fclip

# defining aliases for above function with specific parameters
alias fcp="fclip cp"
alias fmv="fclip mv"
alias fp="fclip p"
alias fls="fclip ls"
alias fclear="fclip clear"
