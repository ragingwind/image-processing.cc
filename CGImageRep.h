/*
 * Copyright (c) 2010 devnight.net. All rights reserved.  Use of this
 * source code is governed by a MIT license that can be found at
 * http://devnight.net/LICENSE/MIT
 *
 * Image processing example for iOS
 * http://github.com/ragingwind/image-processing.cc
 *
 * @version 0.1
 * @author ragingwind@gmail.com
 *
 */

#import <Foundation/Foundation.h>
#import "CFDataRep.h"

//
// CGImageRep
//
@interface CGImageRep : NSObject {
@protected
	CGImageRef _imageRef;
	CFDataRep* _dataRep;
}

@property (nonatomic, readonly) size_t width;
@property (nonatomic, readonly) size_t height;
@property (nonatomic, readonly) CGImageAlphaInfo alphaInfo;
@property (nonatomic, readonly) size_t bitsPerPixel;
@property (nonatomic, readonly) size_t bytesPerRow;
@property (nonatomic, readonly) size_t bitsPerComponent;

@property (nonatomic, readonly) CFDataRep* CFDataRep;
@property (nonatomic, readonly) CGImageRef CGImage;

- (id)initWithCGImage:(CGImageRef)imageRef allocator:(CFAllocatorRef)allocator;
- (id)initWithCGImage:(CGImageRef)imageRef;

@end

//
// CGImageMutableRep
//
@interface CGImageMutableRep : CGImageRep {
}

@property (nonatomic, readonly) CFMutableDataRep* CFMutableDataRep;

- (id)initWithCGImage:(CGImageRef)imageRef allocator:(CFAllocatorRef)allocator;

@end

NSString* NSStringFromCGImageRep(CGImageRep* imageRep);