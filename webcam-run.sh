#!/bin/bash
# Wrapper script to run webcam2ascii with the correct Ruby version

eval "$(rbenv init - bash)"
ruby exe/webcam2ascii "$@"
