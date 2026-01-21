# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

convert2ascii is a Ruby gem that converts images, videos, and webcam feeds to ASCII art displayed in the terminal. The project provides three main executables and corresponding Ruby classes.

## Prerequisites

- Ruby 3.1.0+
- ImageMagick (required for image processing via RMagick)
- ffmpeg (required for video/webcam processing)

## Common Commands

### Testing
```bash
rake test                    # Run all tests in test/ directory
ruby test/test_01_image2ascii.rb    # Run a single test file
```

### Building and Publishing
```bash
rake build                   # Build gem
gem build convert2ascii.gemspec    # Alternative build command
rake release                 # Release new version (requires proper credentials)
```

### Docker Development
```bash
rake build_docker           # Build Docker image (mark24code/convert2ascii:latest)
rake run_in_docker          # Run container with current directory mounted to /app
rake push_docker            # Push Docker image to registry
```

### Documentation
```bash
rake build_rdoc            # Generate RDoc documentation
```

### Testing Executables Locally
```bash
# Image conversion
ruby -Ilib exe/image2ascii -i <path/to/image>

# Video conversion
ruby -Ilib exe/video2ascii -i <path/to/video.mp4>

# Webcam feed (requires camera access)
ruby -Ilib exe/webcam2ascii
```

## Architecture

### Core Components

**Image Processing (Image2Ascii)**
- Located in `lib/convert2ascii/image2ascii.rb`
- Uses RMagick to process images pixel-by-pixel
- Converts pixel brightness to ASCII characters using a gradient string
- Supports two styles: "color" (ANSI colors) and "text" (plain ASCII)
- Handles quantum depth conversion for ImageMagick compatibility
- Corrects aspect ratio to account for terminal character dimensions (height is halved)

**Video Processing (Video2Ascii)**
- Located in `lib/convert2ascii/video2ascii.rb`
- Workflow:
  1. Extracts audio using ffmpeg
  2. Splits video into frames at specified intervals (default 0.04s)
  3. Converts each frame to ASCII using MultiTasker (parallel processing)
  4. Stores frames and metadata in `~/.convert2ascii/` temp directory
- Can save ASCII frames to a directory or play them directly in terminal
- Uses TerminalPlayer for synchronized audio/video playback

**Webcam Processing (Webcam2Ascii)**
- Located in `lib/convert2ascii/webcam2ascii.rb`
- Captures frames in real-time using platform-specific ffmpeg inputs:
  - macOS: AVFoundation (`-f avfoundation`)
  - Linux: video4linux2 (`-f v4l2`)
  - Windows: DirectShow (`-f dshow`)
- Uses tempfiles for frame capture to minimize disk I/O
- Maintains target FPS by calculating frame processing time and adjusting sleep duration

**Parallel Processing (MultiTasker)**
- Located in `lib/convert2ascii/multi-tasker.rb`
- Uses the `parallel` gem to distribute image conversion across CPU cores
- Automatically determines optimal process count (cpu_count - 2, minimum 1)
- Provides real-time progress tracking with completion percentage and elapsed time

**Terminal Control (Terminal & TerminalPlayer)**
- `terminal.rb`: Low-level terminal manipulation (cursor control, screen clearing)
- `terminal-player.rb`: Handles ASCII video playback with audio synchronization

### Key Design Patterns

**Multi-process Image Conversion**
- Video frames are converted in parallel using process-based parallelism
- Each process handles a subset of frames independently
- Results are collected and ordered by frame number before playback

**Temporary File Management**
- Videos use `~/.convert2ascii/` for intermediate storage
- Webcam captures use Ruby Tempfile for transient frame storage
- Cleanup happens in `ensure` blocks to prevent file leaks

**Aspect Ratio Correction**
- Terminal characters are roughly twice as tall as they are wide
- Images/frames are vertically scaled by 50% to maintain proper proportions

**Character Gradient Mapping**
- ASCII characters ordered by visual density: `.'^\"\,:;Il!i><~+_-?][}{1)(|\\/tfjrxnuvczXYUJCLQ0OZmwqpdbkhao*#MW&8%B@$`
- Pixel brightness (0-255) maps to character index proportionally

## Gem Dependencies

- `rmagick ~> 6.0.1` - ImageMagick bindings for image manipulation
- `rainbow ~> 3.1.1` - ANSI color support for terminal output
- `parallel ~> 1.26` - Multi-process parallelization for performance

## Module Structure

All classes are under the `Convert2Ascii` module:
- `Convert2Ascii::Image2Ascii`
- `Convert2Ascii::Video2Ascii`
- `Convert2Ascii::Webcam2Ascii`

Executables are in `exe/` directory and are thin wrappers around the library classes, handling CLI option parsing with `OptionParser`.

## Testing Conventions

Tests use Minitest and follow the naming pattern `test/test_0X_*.rb`. Each test file typically includes:
- Setup with test assets from `test/assets/`
- Tests for initialization parameters
- Tests for generation with different styles (color, text, color_block)
- Output verification by checking ascii_string length and printing results

## Common Workflows

**Adding a new feature to video processing:**
1. Modify `lib/convert2ascii/video2ascii.rb` for core logic
2. Update `exe/video2ascii` if CLI options are needed
3. Add test in `test/test_02_video2ascii.rb` or `test/test_03_video2ascii_play.rb`
4. Run `rake test` to verify

**Debugging performance issues:**
- Check `MultiTasker` thread count calculation in `multi-tasker.rb:15`
- Verify ffmpeg thread usage in `video2ascii.rb:149`
- Profile with increased logging (check Rainbow output statements)

**Platform compatibility:**
- Webcam device handling is platform-specific (see `webcam2ascii.rb:78-93`)
- Test on target platforms: macOS, Ubuntu, Docker (Windows not currently supported)
