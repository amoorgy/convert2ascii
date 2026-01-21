# Convert2Ascii

Convert Image/Video to ASCII art.


## Intro

convert2ascii provides three executable commands：

* image2ascii: transform picture to ascii art and display in terminal.
* video2ascii: transform video to ascii art, you can save or play it in terminal.
* webcam2ascii: transform webcam feed to ascii art in real-time in terminal.

It also provides classes as a gem:

* Convert2Ascii::Image2Ascii
* Convert2Ascii::Video2Ascii
* Convert2Ascii::Webcam2Ascii

you can use it in your code and make your own ascii art !


## Test pass

* MacOS 15.2 ✅
* Ubuntu 24.04 ✅
* Windows 11  ❌
* Docker ✅

## Example

* Black Myth: Wukong

![example](./example/wukong.jpg)

* The Matrix: Neo

![neo](./example/neo.gif)

## Prerequisites

* Ruby 3+
* ImageMagick ([Download here](https://imagemagick.org/script/download.php))
* ffmpeg ([Download here](https://www.ffmpeg.org/))

# How to use

## Try in Docker

`$ docker run -it -v $(pwd):/app  mark24code/convert2ascii bash -c "cd /app && exec bash"`

>  `$(pwd)` can be changed to your local path. Here, use your working path.

```bash
# image
image2ascii -i </path/to/image>

# video
video2ascii -i </path/to/video.mp4>

# webcam (real-time)
webcam2ascii
```


## Install

`$ gem install convert2ascii`


## Executable commands

### image2ascii

Convert an image to ascii art.

```bash
image2ascii -h
Usage: image2ascii [options]
        --version                    version
    -i, --image=URI                  image uri (required)
    -w, --width=WIDTH                image width (integer)
    -s, --style=STYLE                ascii style: 'color'/'text'
    -b, --block                      ascii color style use BLOCK or not true/false
```

### video2ascii

Convert a video to ascii art.

```bash
Usage: video2ascii [options]

* By default, it will generate and play without saving.
* The -p option will just play the ascii frames within the directory, and ignore -i, -o other options. --loop will play loop
* -i,-o will just generate and output frames and ignore others options
        --version                    version
    -i, --input=URI                  video uri (required)
    -w, --width=WIDTH                video width (integer)
    -s, --style=STYLE                ascii style: ['color'| 'text']
    -b, --block                      ascii color style use BLOCK or not [ true | false ]
    -o, --ouput=OUTPUT               save ascii frames to the output directory
    -p, --play_dir=PLAY_DIRNAME      input the ascii frames directory to play
        --loop
```

### webcam2ascii

Convert webcam feed to ascii art in real-time.

```bash
Usage: webcam2ascii [options]
        --version                    version
    -d, --device=DEVICE              webcam device (default: 0)
    -f, --fps=FPS                    frames per second (default: 10)
    -w, --width=WIDTH                display width (integer)
    -s, --style=STYLE                ascii style: ['color'| 'text']
    -b, --block                      ascii color style use BLOCK or not [ true | false ]
```

Examples:
```bash
# Use default webcam with 10 FPS
webcam2ascii

# Use custom FPS and width
webcam2ascii -f 15 -w 80

# Use text style instead of color
webcam2ascii -s text

# Use color blocks
webcam2ascii -b
```


## As a Gem

### Convert2Ascii::Image2Ascii


```ruby
require 'convert2ascii/image2ascii'

# generate image
uri = "path/to/image"
ascii = Convert2Ascii::Image2Ascii.new(uri:, width: 50)

# generate image
ascii.generate
# display in your terminal
ascii.tty_print


# also chain call
ascii.generate.tty_print

```


### Convert2Ascii::Video2Ascii

```ruby
require 'convert2ascii/video2ascii'

# generate video
uri = "path/to/video.mp4"
ascii = Convert2Ascii::Video2Ascii.new(uri:, width: 50)
# generate video
ascii.generate
# save frames
ascii.save(output_path)

# play in terminal
ascii.play


# chain call
ascii.generate.play

```

### Convert2Ascii::Webcam2Ascii

```ruby
require 'convert2ascii/webcam2ascii'

# capture from webcam
webcam = Convert2Ascii::Webcam2Ascii.new(
  device: "0",     # webcam device (default: "0")
  fps: 10,         # frames per second (default: 10)
  width: 80,       # display width
  style: "color",  # "color" or "text"
  color_block: false
)

# start capturing and displaying (press Ctrl+C to stop)
webcam.start

```


## Inspired by

* [michaelkofron/image2ascii](https://github.com/michaelkofron/image2ascii)
* [andrewcohen/video_to_ascii](https://github.com/andrewcohen/video_to_ascii)
