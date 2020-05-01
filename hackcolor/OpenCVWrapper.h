//
//  OpenCVWrapper.h
//  hackcolor
//
//  Created by Sam on 4/29/20.
//  Copyright © 2020 Sam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject

+ (NSDictionary *)hack:(NSImage *)image;

@end

NS_ASSUME_NONNULL_END
