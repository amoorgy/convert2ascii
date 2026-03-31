# Ruby Setup Guide (For Beginners)

Welcome! If it's your first time using Ruby on macOS, you might have run into some strange errors like `Could not find 'bundler'` or `cannot load such file`. 

This document explains **why** those errors happen and **how** we solved them.

## The Problem: Two Versions of Ruby

1. **System Ruby**: Apple includes a version of Ruby by default on macOS (usually an older version like 2.6). This system Ruby is meant for internal macOS scripts, not for your development projects. If you try to install project dependencies directly into System Ruby, macOS often blocks it for security reasons, or you get missing tool errors.
2. **Project Ruby**: Modern Ruby projects (like this one) use newer features and require a newer version of Ruby (like 3.3.6). We manage this new version using a tool called **`rbenv`**, which lets you install and switch between multiple Ruby versions without messing with macOS system files.

When you open a new terminal, macOS defaults back to **System Ruby**. Because System Ruby doesn't know about the `convert2ascii` project dependencies, commands like `bundle install` or `ruby exe/webcam2ascii` will suddenly fail.

## The Solution: Our Run Script

To save you from typing the same commands every time you open a terminal, I've created a simple wrapper script: **`./run-webcam.sh`**.

Here is what it does behind the scenes:

1. **`export PATH=...` and `eval "$(rbenv init - bash)"`**
   This commands the terminal: *"Stop using Apple's default Ruby, and start using the Ruby installed by `rbenv` just for this session."* 
   
2. **`bundle install`**
   Bundler is Ruby's package manager (like `npm` for Node or `pip` for Python). This command looks at the `Gemfile` to see what external code libraries (Gems) this project needs (like `rainbow` to colorize output) and installs them.

3. **`bundle exec ruby -Ilib exe/webcam2ascii`**
   This finally starts the webcam script. The `bundle exec` prefix ensures the script strictly uses the correct library versions installed in step 2.

## How to use it

From now on, you never have to remember Ruby commands! Just run the script. 

**Basic Run:**
```bash
./run-webcam.sh
```

**Run with higher frames (e.g., 30 FPS):**
```bash
./run-webcam.sh -f 30
```

**Run with a wider display for better resolution (e.g., 120 width):**
```bash
./run-webcam.sh -w 120
```

## Making it Permanent

If you plan on doing more Ruby development, you can tell your terminal to automatically load `rbenv` every time you open a new tab.

Run these 3 commands once in your terminal:
```bash
echo 'export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init - bash)"' >> ~/.bashrc
source ~/.bashrc
```

Once you do that, you won't even need the `./run-webcam.sh` wrapper anymore; you can just run `bundle exec ruby -Ilib exe/webcam2ascii` directly!