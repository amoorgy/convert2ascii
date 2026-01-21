require_relative "../lib/convert2ascii/webcam2ascii"
require "minitest/autorun"

class TestWebcam2Ascii < Minitest::Test
  def test_webcam2ascii_initialization
    webcam = Convert2Ascii::Webcam2Ascii.new(
      device: "0",
      fps: 10,
      width: 80,
      style: "color",
      color_block: false
    )

    assert_equal "0", webcam.device
    assert_equal 10, webcam.fps
    assert_equal 80, webcam.width
    assert_equal "color", webcam.style
    assert_equal false, webcam.color_block
  end

  def test_default_values
    webcam = Convert2Ascii::Webcam2Ascii.new

    assert_equal "0", webcam.device
    assert_equal 10, webcam.fps
    assert webcam.width > 0  # Should be set to console width
  end

  def test_get_ffmpeg_device_input_macos
    webcam = Convert2Ascii::Webcam2Ascii.new(device: "0")

    # Test the private method through send
    device_input = webcam.send(:get_ffmpeg_device_input)

    if RUBY_PLATFORM =~ /darwin/
      assert_includes device_input, "-f avfoundation"
    end
  end
end
