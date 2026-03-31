#!/bin/bash

# Exit on any error
set -e

echo "Starting convert2ascii webcam..."

# 1. Activate rbenv if it exists, so we use the project's Ruby version (3.3.6)
# instead of the system's default Ruby (2.6.x on older macOS).
if command -v rbenv >/dev/null 2>&1; then
    export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init - bash)"
fi

# 2. Make sure dependencies are installed (this is fast if they already are)
bundle check >/dev/null 2>&1 || bundle install

# 3. Run the webcam tool with whatever arguments you passed
# e.g., ./run-webcam.sh -f 30 -w 100
bundle exec ruby -Ilib exe/webcam2ascii "$@"