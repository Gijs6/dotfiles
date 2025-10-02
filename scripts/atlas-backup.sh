#!/bin/zsh

ts=$(date +"%Y-%m-%d_%H-%M-%S")
dest="$HOME/atlas-backups/$ts"

mkdir -p "$dest"
rsync -ciavuP nov:/volume1/docker/atlas/ "$dest"
