# set-i3-workspace
Script to set, increment through, or wrap through i3 or sway workspaces given a string of arguments

# Requires:
    -i3 or sway (obviously)
    -jq
    -zenity (optional)

______________________________________________

As seen in the i3 config file use cases may include:

# Selecting a standard numeric workspace: (lame)
    bindsym $mod+Control+Escape       exec set-i3-workspace.sh 1
    bindsym $mod+Control+Shift+Escape exec set-i3-workspace.sh -c 1

# Using zenity to select a non numeric workspace: (kinda cool)
    bindsym $mod+Control+grave exec set-i3-workspace.sh "$(zenity --title='Workspace Selection' --entry --text='Please enter desired workspace.')"

# Looping through workspaces in numerical order: (pretty cool)
    bindsym $mod+Control+plus   exec set-i3-workspace.sh +1
    bindsym $mod+Control+minus  exec set-i3-workspace.sh -1

# Looping through workspaces 10 at a time: (pretty cool)
    bindsym $mod+Control+Up     exec set-i3-workspace.sh +10
  	bindsym $mod+Control+Down   exec set-i3-workspace.sh -10

# Using the left and right arrow keys to wrap through the 10's you are currently in: (really cool)
    bindsym $mod+Control+Right  exec set-i3-workspace.sh -w10 +1
  	bindsym $mod+Control+Left   exec set-i3-workspace.sh -w10 -1

# Using the numeric keys on you keyboard to select a workspace within the 10's you are currently in: (freeze your face off cool)
  	bindsym $mod+Control+3      exec set-i3-workspace.sh -w10 3
  	bindsym $mod+Control+7      exec set-i3-workspace.sh -w10 7

# Take that container with you: (ice!)
    bindsym $mod+Control+Shift+3      exec set-i3-workspace.sh -c -w10 3
  	bindsym $mod+Control+Shift+Right  exec set-i3-workspace.sh -c -w10 +1
    bindsym $mod+Control+Shift+plus   exec set-i3-workspace.sh -c +1
