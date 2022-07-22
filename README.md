# fclip
### CLI form of GUI file manager's copy, cut and paste operations  

### GUI Clipboard emulation in command line


__Approach__:
* Select a group of items for copying or moving
* We select that group of items in a particular directory
* So, we take note of the directory where we selected items for copying/moving
* We also take note of the selected items
* Operation could be either copy (or) move, hence take note of teh operation as well
* While pasting, if there are items in the clipboard, they would get pasted, otherwise not
* So, we need to check if there are items selected for copying (or) moving
* So for the above reasons, we need to keep the list of items persistent, since we could select them for copy/move at some instant of time and paste them in another directory at some other instant of time, which could be a lot later than the timestamp at which the items had been selected
* So we write the above 3 details (operation, source directory, list of items) to a file, and then refer the file for pasting
* The file used for the above purpose is known as the clip file
* But reading from and writing to file then mostly involves a disk operation which we obviously want to avoid, else it defeats the whole purpose of copying to buffer
* So rather than using a file, we use named pipes (which are used for communication between 2 processes)
* Named pipes are much faster since the interprocess communication happens in the memory itself


__Prerequisites__:
* [fd](https://github.com/sharkdp/fd) (better version of find)


__Commands__:
```
git clone https://github.com/Manish0925/fclip
echo "source $PWD/fclip/fclip.zsh" > $HOME/.zshrc
```
