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
#import "CGImageRep.h"

typedef enum _UIColorDegrees {
	kUIColorDegreesMaster = -1,
	kUIColorDegreesRed = 0,
	kUIColorDegreesYellow = 60,
	kUIColorDegreesGreen = 120,
	kUIColorDegreesCyan = 180,
	kUIColorDegreesBlue = 240,
	kUIColorDegreesMagenta = 300
} UIColorDegrees;

@interface UIImage (Processing)

+ (UIImage*)imageWithCGImageRep:(CGImageRep*)rep;

/**
 * Pixel-based RGB Conversion
 */
- (UIImage*)greyImage;
- (UIImage*)brightImage:(CGFloat)val;
- (UIImage*)contrastImage:(CGFloat)level contrast:(CGFloat)contrast;

/**
 * Colour Space Conversion
 */
- (UIImage*)hueImage:(UIColorDegrees)colorDegree hue:(CGFloat)hue 
		  saturation:(CGFloat)saturation luminance:(CGFloat)luminance;

/**
 * Spatial Filterings, Convolution operator
 */

// Sharpens
- (UIImage*)sharpen:(CGFloat)sigma;
- (UIImage*)moreSharpen:(CGFloat)sigma;
- (UIImage*)subtleSharpen;

// Blurs
- (UIImage*)blur:(CGFloat)sigma;
- (UIImage*)photoshopBlur;
- (UIImage*)boxBlur:(CGFloat)sigma;
- (UIImage*)gaussianBlur:(CGFloat)sigma;

@end

NSString* NSStringFromKernel(CGFloat* kernel, size_t width, size_t height);


