Using OpenCV to hack game Lyto different color on OSX.

Demo with 193 level

[![WI162qIHEGA](http://img.youtube.com/vi/WI162qIHEGA/0.jpg)](http://www.youtube.com/watch?v=WI162qIHEGA)

## Build OpenCV on OSX

#### Required
- CMake 2.8.8 or higher
- Xcode 10 or higher
- Python 2.7 or higher
- 
#### Building OpenCV from Source

    git clone https://github.com/opencv/opencv.git
    python opencv/platforms/ios/build_framework.py ios

  Copy opencv2.framework into hackcolor directory.

## Methodology

- Take a screenshot of the rect of screen.
- Detect the circles in the screenshot using Hough in OpenCV.
- Process circles:
  - Check radius
  - Find circle with different color
- Simulate mouse click on screen
- Similate the result on screen.

Using function HoughCircles in openCV to detect array circles from image
```
+ (NSDictionary *)hack:(NSImage *)image {
    cv::Mat src;
    NSImageToMat(image, src);
    
    cv::Mat gray;
    cv::cvtColor(src, gray, cv::COLOR_BGR2GRAY);
    cv::medianBlur(gray, gray, 5);
    std::vector<cv::Vec3f> circles;
    HoughCircles(gray, circles, cv::HOUGH_GRADIENT, 1,
                 src.rows/16,
                 100, 70, 10, 300
                 );
    
    cv::Point tempPoint;
    NSMutableArray *arrPoints = [[NSMutableArray alloc] init];
    
    if(circles.size() > 3) {
        
        std::vector<cv::Vec3b> vColors;

        int tempRadius = circles[0][2];
        for( size_t i = 0; i < circles.size(); i++ )
        {
            cv::Vec3i c = circles[i];
            int radius = c[2];
            //NSLog(@"%ld %d %d", i, tempRadius, radius);
            
            if(std::abs(tempRadius - radius) < 5){
                vColors.push_back(GetColorFromMat(src, c));
                cv::Point center = cv::Point(c[0], c[1]);
                cv::circle( src, center, radius-2, cv::Scalar(255,0,255), 2, cv::LINE_AA);
            }
        }
        for( size_t i = 0; i < vColors.size(); i++ ) {
            cv::Vec3b color1 = vColors[i];
            bool flag = true;
            for( size_t j = 0; j < vColors.size(); j++ ) {
                cv::Vec3b color2 = vColors[j];
                if(i!=j && color1[0]==color2[0] && color1[1]==color2[1] && color1[2]==color2[2]) {
                    flag = false;
                }
            }
            if(flag){
                cv::Vec3i c = circles[i];
                tempPoint = cv::Point(c[0], c[1]);
                cv::circle( src, tempPoint, 10, cv::Scalar(255,0,255), 4, cv::LINE_8);
                NSLog(@"%ld R: %d G:%d B:%d", i, color1[0], color1[1], color1[2]);
                [arrPoints addObject: @{ @"x": [NSNumber numberWithInt:tempPoint.x],
                                         @"y": [NSNumber numberWithInt:tempPoint.y]}];
            }
        }
        if(arrPoints.count>1){
            NSLog(@"xx: %ld", arrPoints.count);
        }
    }
   
    return @{
        @"image": MatToNSImage(src),
        @"points": arrPoints,
    };
}
```
