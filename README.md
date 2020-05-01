# hack_lyto_different_color_osx
Using OpenCV to hack game Lyto different color on OSX

# Build OpenCV on OSX
### Required
- CMake 2.8.8 or higher
- Xcode 10 or higher
- Python 2.7 or higher
### Building OpenCV from Source

    git clone https://github.com/opencv/opencv.git
    python opencv/platforms/ios/build_framework.py ios

  Copy opencv2.framework into hackcolor directory.

# Methodology

- Take a screenshot of the rect of screen.
- Detect the circles in the screenshot using Hough in OpenCV.
- Process circles:
  - Check radius
  - Find circle with different color
- Simulate mouse click on screen
- Similate the result on screen.