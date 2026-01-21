# Webcam ASCII Conversion Guide

## Quick Start

```bash
# Basic usage (uses default webcam, 10 FPS)
webcam2ascii

# Stop with Ctrl+C
```

## Installation

```bash
gem install convert2ascii
```

### Prerequisites
- Ruby 3.1+
- FFmpeg (for webcam capture)
- ImageMagick (for image processing)

#### Install FFmpeg

**macOS**:
```bash
brew install ffmpeg
```

**Ubuntu/Debian**:
```bash
sudo apt-get install ffmpeg
```

**Windows**:
Download from https://ffmpeg.org/download.html

## Usage Examples

### Command Line

```bash
# Default settings (device 0, 10 FPS, color mode)
webcam2ascii

# Higher frame rate for smoother video
webcam2ascii -f 20

# Custom width (narrower for faster processing)
webcam2ascii -w 60

# Text-only mode (no colors)
webcam2ascii -s text

# Color block mode (solid colored blocks)
webcam2ascii -b

# Combine options
webcam2ascii -f 15 -w 80 -s color -b
```

### Ruby API

```ruby
require 'convert2ascii/webcam2ascii'

# Basic usage
webcam = Convert2Ascii::Webcam2Ascii.new
webcam.start

# Custom configuration
webcam = Convert2Ascii::Webcam2Ascii.new(
  device: "0",        # Webcam device number
  fps: 15,            # Target frames per second
  width: 100,         # Display width in characters
  style: "color",     # "color" or "text"
  color_block: true   # Use colored blocks instead of characters
)
webcam.start

# The start method blocks until interrupted (Ctrl+C)
```

## Configuration Options

| Option | CLI Flag | Default | Description |
|--------|----------|---------|-------------|
| Device | `-d`, `--device` | `"0"` | Webcam device identifier |
| FPS | `-f`, `--fps` | `10` | Target frames per second |
| Width | `-w`, `--width` | Terminal width | Display width in characters |
| Style | `-s`, `--style` | `"color"` | "color" or "text" |
| Color Block | `-b`, `--block` | `false` | Use solid color blocks |

## Platform-Specific Notes

### macOS
- Uses AVFoundation for webcam access
- You may need to grant camera permissions when first running
- Device "0" is typically the built-in FaceTime camera
- Device "1" is usually an external USB webcam

**List available cameras**:
```bash
ffmpeg -f avfoundation -list_devices true -i ""
```

### Linux
- Uses Video4Linux2 (v4l2)
- Device "0" corresponds to `/dev/video0`
- Device "1" corresponds to `/dev/video1`

**List available cameras**:
```bash
v4l2-ctl --list-devices
# or
ls -l /dev/video*
```

### Windows
- Uses DirectShow (dshow)
- Device names may be different (e.g., "Integrated Camera")

**List available cameras**:
```bash
ffmpeg -list_devices true -f dshow -i dummy
```

## Performance Tips

1. **Lower FPS for better stability**: Start with default 10 FPS
   ```bash
   webcam2ascii -f 10
   ```

2. **Reduce width for faster processing**: Smaller width = faster conversion
   ```bash
   webcam2ascii -w 60
   ```

3. **Use text mode for minimal CPU**: No color processing
   ```bash
   webcam2ascii -s text
   ```

4. **Maximize your terminal window**: Larger display looks better

5. **Good lighting helps**: Better lit scenes convert more clearly

## Troubleshooting

### "Camera not found" or "Device not available"

**Check camera access**:
```bash
# macOS - list cameras
ffmpeg -f avfoundation -list_devices true -i ""

# Linux - check video devices
ls -l /dev/video*
```

**Try different device numbers**:
```bash
webcam2ascii -d 1    # Try device 1
webcam2ascii -d 2    # Try device 2
```

### "Permission denied" (macOS)

Grant camera permissions:
1. System Preferences → Security & Privacy → Camera
2. Allow terminal/Ruby to access camera

### "FFmpeg not found"

Install FFmpeg:
```bash
# macOS
brew install ffmpeg

# Ubuntu/Debian
sudo apt-get install ffmpeg
```

### Low frame rate / stuttering

- Reduce FPS: `webcam2ascii -f 5`
- Reduce width: `webcam2ascii -w 40`
- Close other applications
- Use text mode: `webcam2ascii -s text`

### Display looks garbled

- Ensure terminal supports ANSI colors
- Try text mode: `webcam2ascii -s text`
- Maximize terminal window
- Use a monospace font

## Examples

### Retro Matrix Effect
```bash
webcam2ascii -f 20 -s text -w 100
```

### Smooth Color Display
```bash
webcam2ascii -f 20 -w 120 -s color
```

### Color Mosaic
```bash
webcam2ascii -b -w 80
```

### Low Resource Mode
```bash
webcam2ascii -f 5 -w 40 -s text
```

## How It Works

1. **Capture**: FFmpeg captures a single frame from webcam
2. **Convert**: Frame is saved as temporary JPEG
3. **Transform**: Image2Ascii converts JPEG to ASCII using existing algorithm
4. **Display**: ASCII frame is printed to terminal
5. **Repeat**: Loop continues with configurable delay between frames

The "delay" approach (vs. true streaming) provides:
- Lower CPU usage
- Better frame quality
- More predictable performance
- Simpler implementation

## Comparison with Video2Ascii

| Feature | Webcam2Ascii | Video2Ascii |
|---------|--------------|-------------|
| Input | Live webcam | Video file |
| Audio | ❌ No | ✅ Yes |
| Recording | ❌ No | ✅ Yes (save frames) |
| Playback | Real-time only | Can replay saved frames |
| Loop | N/A | ✅ Yes |
| Use case | Live preview | Process recorded videos |

## Contributing

Found a bug or want to improve webcam support?
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

See CHANGES.md for implementation details.

## License

MIT License - See LICENSE.txt
