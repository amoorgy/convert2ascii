# Changes Log - Webcam Support Feature

## Date: January 20, 2026

### Summary
Added real-time webcam to ASCII art conversion feature, allowing users to view their webcam feed as ASCII art in the terminal with configurable frame rates and display options.

---

## New Files Created

### 1. `lib/convert2ascii/webcam2ascii.rb`
**Purpose**: Core class for webcam capture and ASCII conversion

**Key Features**:
- Real-time webcam frame capture using FFmpeg
- Platform-specific device input support (macOS, Linux, Windows)
- Configurable FPS (frames per second) with default of 10
- Reuses existing `Image2Ascii` class for frame conversion
- Terminal display with proper screen refresh
- Graceful interrupt handling (Ctrl+C)
- Automatic frame delay calculation to maintain target FPS

**Architecture**:
- Uses temporary files for frame capture
- Captures single frames in a loop using FFmpeg
- Converts each frame using the existing ASCII conversion pipeline
- Displays frames with cursor positioning to avoid flicker

**Configuration Options**:
- `device`: Webcam device identifier (default: "0")
- `fps`: Target frames per second (default: 10)
- `width`: Display width in characters (default: terminal width)
- `style`: ASCII style - "color" or "text" (default: "color")
- `color`: Color mode - "full" or "greyscale" (default: "full")
- `color_block`: Use color blocks instead of characters (default: false)

### 2. `exe/webcam2ascii`
**Purpose**: Command-line executable for webcam ASCII conversion

**Command-Line Options**:
```bash
--version                  # Show version information
-d, --device=DEVICE       # Webcam device (default: 0)
-f, --fps=FPS            # Frames per second (default: 10)
-w, --width=WIDTH        # Display width (integer)
-s, --style=STYLE        # ASCII style: 'color' or 'text'
-b, --block              # Use color blocks
```

**Usage Examples**:
```bash
webcam2ascii                    # Default settings
webcam2ascii -f 15 -w 80        # Custom FPS and width
webcam2ascii -s text            # Text-only mode
webcam2ascii -b                 # Color block mode
```

### 3. `test/test_04_webcam2ascii.rb`
**Purpose**: Unit tests for Webcam2Ascii class

**Test Coverage**:
- Initialization with custom parameters
- Default value verification
- Platform-specific FFmpeg device input generation

---

## Modified Files

### 1. `lib/convert2ascii.rb`
**Changes**: Added require statement for webcam2ascii module
```ruby
require_relative './convert2ascii/webcam2ascii.rb'
```

### 2. `README.md`
**Changes**: Comprehensive documentation updates

**Sections Added**:
- Webcam2ascii command in intro section
- Webcam2Ascii class in gem classes list
- Docker example for webcam usage
- Complete webcam2ascii command-line documentation
- Usage examples for various configurations
- Ruby API documentation with code examples

**Example Documentation**:
```ruby
webcam = Convert2Ascii::Webcam2Ascii.new(
  device: "0",
  fps: 10,
  width: 80,
  style: "color",
  color_block: false
)
webcam.start
```

### 3. `convert2ascii.gemspec`
**Changes**: No direct changes needed - gemspec automatically includes executables from `exe/` directory via:
```ruby
spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
```

---

## Technical Implementation Details

### Webcam Capture Strategy
1. **Frame-by-frame capture**: Uses FFmpeg to capture single frames on-demand rather than continuous streaming
2. **Delay-based approach**: Implements configurable delays between frames (not truly "live" but near real-time)
3. **Platform compatibility**: Detects platform and uses appropriate FFmpeg input format:
   - macOS: AVFoundation (`-f avfoundation`)
   - Linux: Video4Linux2 (`-f v4l2`)
   - Windows: DirectShow (`-f dshow`)

### Code Reuse
- Leverages existing `Image2Ascii` class for all image-to-ASCII conversion logic
- Uses existing `Terminal` module for screen management
- Follows existing error handling patterns with `CheckImageMagick` and `CheckFFmpeg`

### Performance Considerations
- Default 10 FPS balances responsiveness with CPU usage
- Frame delay calculation ensures target FPS is maintained
- Temporary file cleanup handled automatically via `Tempfile`
- Single frame capture reduces memory footprint

### Terminal Display
- Uses cursor positioning to update frames in-place
- Clears screen between frames to prevent artifacts
- Properly handles terminal resize (inherits from existing Terminal module)
- Hides cursor during display for cleaner output

---

## Dependencies
No new dependencies required - uses existing gems:
- `rmagick` - Image processing
- `rainbow` - ANSI color support
- FFmpeg - External dependency for webcam capture (already required for video2ascii)
- ImageMagick - External dependency for image processing (already required)

---

## Usage Guide

### As Command-Line Tool
```bash
# Install the gem
gem install convert2ascii

# Basic usage
webcam2ascii

# With options
webcam2ascii -f 15 -w 100 -s color

# Stop with Ctrl+C
```

### As Ruby Library
```ruby
require 'convert2ascii/webcam2ascii'

webcam = Convert2Ascii::Webcam2Ascii.new(
  device: "0",
  fps: 15,
  width: 100,
  style: "color"
)

# Start capturing (blocks until Ctrl+C)
webcam.start
```

---

## Testing Notes

### Prerequisites for Testing
1. Webcam/camera device must be available
2. FFmpeg must be installed and accessible in PATH
3. ImageMagick must be installed
4. Camera permissions must be granted (especially on macOS)

### Manual Testing Steps
1. Run `ruby exe/webcam2ascii`
2. Verify webcam feed appears as ASCII art
3. Test Ctrl+C interrupt handling
4. Test different FPS settings
5. Test different style options (color vs text)
6. Test color block mode

### Unit Tests
Run with: `ruby test/test_04_webcam2ascii.rb`

---

## Known Limitations

1. **Not truly "live"**: Uses frame-by-frame capture with delays rather than continuous streaming
2. **Platform-specific**: Requires platform-specific FFmpeg device input formats
3. **No audio**: Webcam capture doesn't include audio (unlike video2ascii)
4. **Single device**: Only supports one webcam at a time
5. **Performance**: Lower FPS recommended for slower systems (default 10 FPS is conservative)

---

## Future Enhancements (Potential)

1. True streaming using FFmpeg pipe instead of frame-by-frame capture
2. Multi-camera support
3. Recording capability (save webcam ASCII to file)
4. Adjustable delay presets (low/medium/high latency modes)
5. Frame interpolation for smoother display
6. GPU acceleration for faster processing
7. Audio input support for webcam audio

---

## Compatibility

- **macOS**: ✅ Tested and working (AVFoundation)
- **Linux**: ⚠️ Should work with v4l2 (not tested)
- **Windows**: ⚠️ Should work with dshow (not tested)
- **Docker**: ⚠️ May require device passthrough configuration

---

## Breaking Changes
None - this is a purely additive feature that doesn't modify existing functionality.

---

## Migration Guide
No migration needed - existing code continues to work unchanged. The webcam feature is opt-in via the new `webcam2ascii` command or `Webcam2Ascii` class.
