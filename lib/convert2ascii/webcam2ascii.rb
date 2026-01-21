require "io/console"
require "rainbow"
require "tempfile"
require_relative "./image2ascii"
require_relative "./terminal"
require_relative "./check_package"
require_relative "./version"

module Convert2Ascii
  class Webcam2AsciiError < StandardError
  end

  class Webcam2Ascii
    DEFAULT_FPS = 10
    DEFAULT_DEVICE = "0"  # default webcam device

    attr_accessor :width, :fps, :device, :style, :color_block

    def initialize(**args)
      @device = args[:device] || DEFAULT_DEVICE
      @fps = args[:fps] || DEFAULT_FPS
      @frame_delay = 1.0 / @fps

      # image2ascii attrs
      @width = args[:width] || (IO.console&.winsize&.[](1) || 80)
      @style = args[:style] || Image2Ascii::STYLE_ENUM::Color
      @color = args[:color] || Image2Ascii::COLOR_ENUM::Full
      @color_block = args[:color_block] || false

      @running = false
      @first_frame = true

      check_packages
    end

    def start
      begin
        @running = true
        init_terminal
        capture_and_display
      rescue Interrupt
        puts Rainbow("\n[info] Webcam capture stopped by user").yellow
      rescue => error
        puts Rainbow("\n[Error] #{error.message}").red
        puts error.backtrace if ENV['DEBUG']
      ensure
        cleanup
      end
    end

    def stop
      @running = false
    end

    private

    def check_packages
      CheckImageMagick.new.check
      CheckFFmpeg.new.check
    end

    def init_terminal
      Terminal.open_buffer
      Terminal.hide_cursor
      Terminal.clear_screen
      puts Rainbow("[info] Starting webcam capture... Press Ctrl+C to stop").green
      sleep 1
      Terminal.clear_screen
    end

    def cleanup
      Terminal.close_buffer
      Terminal.clear_screen
      Terminal.show_cursor
      puts Rainbow("\n[info] Cleaned up terminal").green
    end

    def get_ffmpeg_device_input
      # Platform-specific device input for ffmpeg
      case RUBY_PLATFORM
      when /darwin/
        # macOS uses AVFoundation - add framerate and proper quoting
        "-f avfoundation -framerate 30 -i \"#{@device}\""
      when /linux/
        # Linux uses video4linux2
        "-f v4l2 -i /dev/video#{@device}"
      when /mswin|mingw/
        # Windows uses dshow
        "-f dshow -i video=\"Integrated Camera\""
      else
        raise Webcam2AsciiError, "Unsupported platform: #{RUBY_PLATFORM}"
      end
    end

    def capture_and_display
      # Use a temporary file for frame capture
      Tempfile.create(['webcam_frame', '.jpg']) do |tempfile|
        frame_path = tempfile.path

        device_input = get_ffmpeg_device_input

        while @running
          frame_start_time = Time.now

          # Capture single frame from webcam
          cmd = "ffmpeg #{device_input} -frames:v 1 -update 1 #{frame_path} -y 2>&1"

          success = system(cmd)

          if success && File.exist?(frame_path) && File.size(frame_path) > 0
            begin
              # Convert frame to ASCII
              ascii_string = convert_frame_to_ascii(frame_path)

              # Display in terminal
              display_frame(ascii_string)

            rescue => error
              puts Rainbow("[Error] Frame conversion failed: #{error.message}").red if ENV['DEBUG']
            end
          else
            error_msg = if !success
              "[Error] FFmpeg failed to capture frame. Check camera permissions and device number."
            elsif !File.exist?(frame_path)
              "[Error] Frame file was not created"
            else
              "[Error] Frame file is empty"
            end

            puts Rainbow(error_msg).red
            puts Rainbow("[Tip] Try: ffmpeg -f avfoundation -list_devices true -i \"\"").yellow
            sleep 1  # Give user time to see error before next attempt
          end

          # Calculate delay to maintain target FPS
          frame_time = Time.now - frame_start_time
          sleep_time = [@frame_delay - frame_time, 0].max
          sleep(sleep_time) if sleep_time > 0
        end
      end
    end

    def convert_frame_to_ascii(image_path)
      config = {
        width: @width,
        style: @style,
        color: @color,
        color_block: @color_block,
      }
      Image2Ascii.new(uri: image_path).generate(**config).ascii_string
    end

    def display_frame(ascii_string)
      if !@first_frame
        # Move cursor back to top of screen
        rows, _ = Terminal.winsize
        print "\033[#{rows}A"
      end

      Terminal.clear_screen
      print ascii_string
      @first_frame = false
    end

    def get_backspace_adjust
      rows, _ = Terminal.winsize
      "\033[#{rows}A"
    end
  end
end
