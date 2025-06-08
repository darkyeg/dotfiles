#! /usr/bin/env bash

swww-daemon &

swww img ~/dotfiles/wallpapers/guts.png

nm-applet --indicator &

env GTK_THEME=Adapta waybar &

dunst 
