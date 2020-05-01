//
//  OpenCVWrapper.m
//  hackcolor
//
//  Created by Sam on 4/29/20.
//  Copyright © 2020 Sam. All rights reserved.
//

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"
#import <opencv2/opencv.hpp>
#import <opencv2/imgproc.hpp>
#pragma clang diagnostic pop

#import <Cocoa/Cocoa.h>
#import "OpenCVWrapper.h"


/// Converts an NSImage to Mat.
static void NSImageToMat(NSImage *image, cv::Mat &mat) {
    
    // Create a pixel buffer.
    NSBitmapImageRep *bitmapImageRep = [NSBitmapImageRep imageRepWithData:image.TIFFRepresentation];
    NSInteger width = bitmapImageRep.pixelsWide;
    NSInteger height = bitmapImageRep.pixelsHigh;
    CGImageRef imageRef = bitmapImageRep.CGImage;
    cv::Mat mat8uc4 = cv::Mat((int)height, (int)width, CV_8UC4);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef contextRef = CGBitmapContextCreate(mat8uc4.data, mat8uc4.cols, mat8uc4.rows, 8, mat8uc4.step, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    // Draw all pixels to the buffer.
    cv::Mat mat8uc3 = cv::Mat((int)width, (int)height, CV_8UC3);
    cv::cvtColor(mat8uc4, mat8uc3, cv::COLOR_RGBA2BGR);
    
    mat = mat8uc3;
}

/// Converts a Mat to NSImage.
static NSImage *MatToNSImage(cv::Mat &mat) {
    
    // Create a pixel buffer.
    assert(mat.elemSize() == 1 || mat.elemSize() == 3);
    cv::Mat matrgb;
    if (mat.elemSize() == 1) {
        cv::cvtColor(mat, matrgb, cv::COLOR_GRAY2RGB);
    } else if (mat.elemSize() == 3) {
        cv::cvtColor(mat, matrgb, cv::COLOR_BGR2RGB);
    }
    
    // Change a image format.
    NSData *data = [NSData dataWithBytes:matrgb.data length:(matrgb.elemSize() * matrgb.total())];
    CGColorSpaceRef colorSpace;
    if (matrgb.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGImageRef imageRef = CGImageCreate(matrgb.cols, matrgb.rows, 8, 8 * matrgb.elemSize(), matrgb.step.p[0], colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault);
    NSBitmapImageRep *bitmapImageRep = [[NSBitmapImageRep alloc] initWithCGImage:imageRef];
    NSImage *image = [NSImage new];
    [image addRepresentation:bitmapImageRep];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return image;
}

/// Get color at pixel
static cv::Vec3b GetColorFromMat(cv::Mat mat, cv::Vec3i c) {
    // circle center
    cv::Point center = cv::Point(c[0], c[1]);
    // get pixel
    cv::Vec3b &color = mat.at<cv::Vec3b>(center.y+10,center.x+10);
    return color;
}

@implementation OpenCVWrapper

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

@end
