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

#import "ColorConverter.h"
#import "CGImageRep.h"
#import "UIImage+Processing.h"

/**
 * Return kernel matrix string.
 */
NSString* NSStringFromKernel(CGFloat* kernel, size_t width, size_t height) {
	NSMutableString* matrix = [NSMutableString new];
	CGFloat sum = 0.f;
	for (UInt32 y = 0; y < height; ++y) {
		for (UInt32 x = 0; x < width; ++x) {
			CGFloat v = kernel[y * height + y];
			[matrix appendFormat:@"%.05f ", v];
			sum += v;			
		}
		[matrix appendFormat:@"\n"];
	}

	return [NSString stringWithFormat:@"Kernel data dump, size:%dx%d sum:%f\n%@"
			,width, height, sum, matrix];
}

#
#pragma mark UIImage (Processing)
#

@implementation UIImage (Processing)

/**
 * Make a image with CGImageCreate.
 */
+ (UIImage*)imageWithWidth:(size_t)width 
					height:(size_t)height
		  bitsPerComponent:(size_t)bitsPerComponent 
			  bitsPerPixel:(size_t)bitsPerPixel 
			   bytesPerRow:(size_t)bytesPerRow
					 space:(CGColorSpaceRef)space
				bitmapInfo:(CGBitmapInfo)bitmapInfo
				  provider:(CGDataProviderRef)provider
					intent:(CGColorRenderingIntent)intent {
	CGImageRef imageRef = CGImageCreate(width
										, height
										, bitsPerComponent
										, bitsPerPixel
										, bytesPerRow
										, space
										, bitmapInfo
										, provider
										, NULL
										, NO
										, intent);
	UIImage *newImage = [UIImage imageWithCGImage:imageRef];
	[newImage retain];
	CGImageRelease(imageRef);
	return newImage;
}

/**
 * Make a image with CGImageRep.
 */
+ (UIImage*)imageWithCGImageRep:(CGImageRep*)rep {
	return [self imageWithWidth:rep.width
						 height:rep.height
			   bitsPerComponent:rep.bitsPerComponent
				   bitsPerPixel:rep.bitsPerPixel
					bytesPerRow:rep.bytesPerRow
						  space:CGColorSpaceCreateDeviceRGB()
					 bitmapInfo:kCGImageAlphaNone
					   provider:rep.CFDataRep.CGDataProvider
						 intent:kCGRenderingIntentDefault];
}

/**
 * Change bright of the image.
 */
- (UIImage*)brightImage:(CGFloat)val {
	CGImageMutableRep* image = [[CGImageMutableRep alloc] initWithCGImage:[self CGImage]];
	size_t height = image.height;
	size_t width = image.width;
	UInt8* ptr = image.CFMutableDataRep.mutableBytes;
	
	UInt32 i = 0;
	for(UInt32 y = 0; y < height; y++) {
		for(UInt32 x = 0; x < width; x++, i++) {
			size_t index = (width * y + x) * 4; 
			ptr[i++] = CLAMP(ptr[index] * val, 0.f, 255.f);
			ptr[i++] = CLAMP(ptr[index + 1] * val, 0.f, 255.f);
			ptr[i++] = CLAMP(ptr[index + 2] * val, 0.f, 255.f);
		}
	}
	
	UIImage* newImage = [UIImage imageWithCGImageRep:image];
	[image release];
	return newImage;
}

/**
 * Make a grey image.
 */
- (UIImage*)greyImage {
	CGImageRep* image = [[CGImageRep alloc] initWithCGImage:[self CGImage]];
	size_t length = image.CFDataRep.length;
	CGImageAlphaInfo alpha = image.alphaInfo;
	const UInt8* src = image.CFDataRep.bytes;

	CFMutableDataRep* destDateRep = [[CFMutableDataRep alloc] 
							  initWithCapacity:length / (image.bitsPerPixel / 8)
							  allocator:kCFAllocatorDefault];
	UInt8* dest = destDateRep.mutableBytes;

	RGB rgb;
	if (image.bitsPerPixel == 16) {
		for (UInt32 i = 0, j = 0; i < length; ++i, ++j) {
			if (alpha == kCGImageAlphaNoneSkipFirst) {
				// alpha none skip first, 5-5-5 16-bit image, where the blue 
				// mask is 0x001f, the green mask is 0x03e0, and the red mask 
				// is 0x7c00
				rgb.b = src[i] & 0x1F;
				rgb.g = (((src[i++] & 0xE0) >> 5) & 0x07) 
									| ((src[i] & 0x03) << 3);
				rgb.r = (src[i] & 0x7C) >> 2;
			}
			else if (alpha = kCGImageAlphaNone 
					 || alpha == kCGImageAlphaNoneSkipLast) {
				// alpha none or skip last, 5-6-5 16-bit image, where the blue 
				// mask is 0x001f, the green mask is 0x07e0, and the red mask is 
				// 0xf800
				rgb.b = (src[i] & 0x3E) >> 1;
				rgb.g = (((src[i++] & 0xC0) >> 5) & 0x03) | ((src[i] & 0x07) << 2);
				rgb.r = (src[i] & 0xF8) >> 3;
				
			}
					
			YIQ yiq = {0.f, 0.f, 0.f};
			rgb2yiq(&rgb, &yiq);
			// grey color has a 5bit (max 31). 
			// scale up to change to 8bit after then scale down it.
			dest[j] = (UInt8) (yiq.y * 255) / 31;
		}
	}
	else if (image.bitsPerPixel == 32) {
		for(UInt32 i = 0, j = 0; i < length; i++, j++){
			rgb.b = src[i++];
			rgb.g = src[i++];
			rgb.r = src[i++];
			YIQ yiq = {0.f, 0.f, 0.f};
			rgb2yiq(&rgb, &yiq);
			dest[j] = yiq.y;
		}
	}
	else {
		NSLog(@"Doesn't supports other bpp yet.");
	}
	
	UIImage* newImage = [UIImage imageWithWidth:image.width
										 height:image.height
							   bitsPerComponent:8
								   bitsPerPixel:8
									bytesPerRow:image.width
										  space:CGColorSpaceCreateDeviceGray()
									 bitmapInfo:kCGImageAlphaNone
									   provider:destDateRep.CGDataProvider
										 intent:kCGRenderingIntentDefault];
	
	[destDateRep release];
	[image release];
	return newImage;
}

/**
 * Change HUE of the image.
 */
- (UIImage*)hueImage:(UIColorDegrees)colorDegree hue:(CGFloat)hue 
		  saturation:(CGFloat)saturation luminance:(CGFloat)luminance {
	CGImageMutableRep* image = [[CGImageMutableRep alloc] 
										initWithCGImage:[self CGImage]];
	size_t height = image.height;
	size_t width = image.width;
	UInt8* src = image.CFMutableDataRep.mutableBytes;

	// correct value of parameters
	CLAMP(hue, -180.f, 180.f);
	CLAMP(saturation, -100.f, 100.f);
	CLAMP(luminance, -100.f, 100.f);
    
	UInt32 i = 0;
	for(UInt32 y = 0; y < height; ++y) {
		for(UInt32 x = 0; x < width; ++x, ++i) {
			size_t index = (width * y + x) * 4; 
			RGB rgb = {src[index], src[index + 1], src[index + 2]};
			HSL hsl = {0.f, 0.f, 0.f};
			rgb2hsl(&rgb, &hsl);
			
			// this approach is in the form of setting the value of 
			// value range is from -100 to 100
			CGFloat scale = 0.f;
			CGFloat hueDegree = hsl.h;
			CGFloat diff = -1.f;
			if (colorDegree == kUIColorDegreesMaster)
				diff = 0.f;
			else {
				// get a minimum degree of two-way.
				diff = fabs(MIN(fabs(colorDegree + 360.f - hueDegree), 
											fabs(hueDegree - colorDegree)));
				// reduced by 0.022 to 1 degree per. 
				// (based photoshop cs4 hue control)
				if (diff >= 0 && diff < 50.f)
					scale = (diff * 0.022); 
			}  
			
			if (diff >= 0 && diff < 50.f) {
				hsl.h += hue;	
				hsl.s += ((saturation - (saturation * scale))) * 0.01f;
				hsl.l += luminance * 0.01f;
				
				hsl.s = CLAMP(hsl.s, 0.f, 1.f);
				hsl.l = CLAMP(hsl.l, 0.f, 1.f);
			}
			
			hsl2rgb(&hsl, &rgb);
			
			src[i++] = CLAMP(rgb.r, 0.f, 255.f);
			src[i++] = CLAMP(rgb.g, 0.f, 255.f);
			src[i++] = CLAMP(rgb.b, 0.f, 255.f);
		}
	}
	
	UIImage* newImage = [UIImage imageWithCGImageRep:image];
	[image release];
	return newImage;
}

/**
 * Change contrast of the image.
 */
- (UIImage*)contrastImage:(CGFloat)level contrast:(CGFloat)contrast {
	CGImageMutableRep* image = [[CGImageMutableRep alloc] initWithCGImage:[self CGImage]];
	size_t height = image.height;
	size_t width = image.width;
	UInt8* src = image.CFMutableDataRep.mutableBytes;

	UInt32 i = 0;
	UInt32 bpp = (image.bitsPerPixel / 8);
	for(UInt32 y = 0; y < height; ++y) {
		for(UInt32 x = 0; x < width; ++x, ++i) {
			size_t index = (width * y + x) * bpp; 
			RGB rgb = {src[index], src[index + 1], src[index + 2]};			
			src[i++] = CLAMP(level + (contrast * (rgb.r - level)), 0.f, 255.f);
			src[i++] = CLAMP(level + (contrast * (rgb.g - level)), 0.f, 255.f);
			src[i++] = CLAMP(level + (contrast * (rgb.b - level)), 0.f, 255.f);
		}
	}
	UIImage* newImage = [UIImage imageWithCGImageRep:image];
	[image release];
	return newImage;	
}

/**
 * Do conversion operator.
 */
- (void)conversion:(const UInt8*)src 
		dest:(UInt8*)dest width:(size_t)iw height:(size_t)ih 
	  kernel:(CGFloat*)kernel kernelWidth:(size_t)kw kernelHeight:(size_t)kh {

	UInt32 i = 0;
	for(UInt32 y = 0; y < ih; ++y) {
		for(UInt32 x = 0; x < iw; ++x) {
			RGB rgb = {0, 0, 0};
			CGFloat sum = 0.0f;
			for(UInt32 fx = 0; fx < kw; ++fx)  {
				for(UInt32 fy = 0; fy < kh; fy++) { 
					UInt32 ix = (x - kw / 2 + fx + iw) % iw; 
					UInt32 iy = (y - kh / 2 + fy + ih) % ih; 
					
					size_t index = (iw * iy + ix) * 4;
					CGFloat kv = kernel[(fx * kw) + fy];
					sum += kv;
					rgb.r += src[index] * kv;
					rgb.g += src[index + 1] * kv;
					rgb.b += src[index + 2] * kv; 
				}
			}
			
			dest[i++] = CLAMP(rgb.r / sum, 0.f, 255.f);
			dest[i++] = CLAMP(rgb.g / sum, 0.f, 255.f);
			dest[i++] = CLAMP(rgb.b / sum, 0.f, 255.f);
			dest[i++] = src[i]; // alpha, a stub
		}
	}
}

/**
 * Make image with spatial filter.
 */
- (UIImage*)imageWithSpatialFilter:(CGFloat*)kernel size:(size_t)size {
	CGImageRep* src = [[CGImageRep alloc] initWithCGImage:[self CGImage]];	
	CFMutableDataRep* dest = [[CFMutableDataRep alloc] 
							  initWithCapacity:src.CFDataRep.length
							  allocator:kCFAllocatorDefault];
	
	
	[self conversion:src.CFDataRep.bytes
		  dest:dest.mutableBytes 
		 width:src.width height:src.height 
		kernel:kernel kernelWidth:size kernelHeight:size];
	
	UIImage* newImage = [UIImage imageWithWidth:src.width
										 height:src.height
							   bitsPerComponent:src.bitsPerComponent
								   bitsPerPixel:src.bitsPerPixel
									bytesPerRow:src.bytesPerRow
										  space:CGColorSpaceCreateDeviceRGB()
									 bitmapInfo:src.alphaInfo
									   provider:dest.CGDataProvider
										 intent:kCGRenderingIntentDefault];
	[dest release];
	[src release];
	return newImage;
}

/**
 * Sharpen filter.
 * Sharpen sample matrix kernel with σ = 1
 CGFloat kernel[] = {
	 -1, -1, -1,
	 -1,  9, -1,
	 -1, -1, -1
 };
 */
- (UIImage*)sharpen:(CGFloat)sigma {
	if (sigma == 0.f) return self;
	
	CGFloat kernel[] = {
		-1, -1, -1,
		-1,  9, -1,
		-1, -1, -1
	};
	
	if (sigma < 1.f) {
		kernel[0] = kernel[2] = kernel[6] = kernel[8] = (kernel[0] * sigma);
		kernel[1] = kernel[3] = kernel[5] = kernel[7] = (kernel[0]);
		kernel[4] = 1.f - (kernel[0] * 8.f); // center take rest of values.
	}
	
	return [self imageWithSpatialFilter:kernel size:3];	
}

/**
 * Subtle sharpen filter.
 */
- (UIImage*)subtleSharpen {
	CGFloat kernel[] = {
		-1, -1, -1, -1, -1,
		-1,  2,  2,  2, -1,
		-1,  2,  8,  2, -1,
		-1,  2,  2,  2, -1,
		-1, -1, -1, -1, -1,
	};
	
	return [self imageWithSpatialFilter:kernel size:5];
}

/**
 * More shapen filter.
 */
- (UIImage*)moreSharpen:(CGFloat)sigma {
	if (sigma == 0.f) return self;
	
	CGFloat kernel[] = {
		-1, -1, -1,
		-1,  9, -1,
		-1, -1, -1
	};
	
	if (sigma < 1.f) {
		sigma *= 10.f;
		CGFloat edge = (1.f - sigma) / 8.f;
		CGFloat edgeSum = (edge * 8.f);
		kernel[0] = kernel[2] = kernel[6] = kernel[8] = edge;
		kernel[1] = kernel[3] = kernel[5] = kernel[7] = edge;
		kernel[4] = sigma - (sigma + edgeSum - 1.f);  // correct value
	}
	return [self imageWithSpatialFilter:kernel size:3];
}

/**
 * Blur filter. make image to smooth.
 * Blur sample matrix kernel with σ = 1(= (1/2) * 5)
 CGFloat kernel[] = {
	0,		1/2.f, 0,
	1/2.f,	1/2.f, 1/2.f,
	0,		1/2.f, 0,
 };
 */
- (UIImage*)blur:(CGFloat)sigma {
	if (sigma == 0.f) return self;
	
	sigma = round((((sigma < 0.1f) ? 0.1f : sigma) * 10.f));
	size_t size = (2.f * sigma) + 1.f;
	size_t center = size / 2;
	size_t dim = 2;
	
	size_t length = sizeof(CGFloat) * (size * pow(size, dim));
	CFMutableDataRep* kernelData = [[CFMutableDataRep alloc] 
								initWithCapacity:length 
									allocator:kCFAllocatorDefault];
	CGFloat* kernel = (CGFloat*)kernelData.mutableBytes;
	
	UInt32 denominator = (size * size) / 2 + 1;
	UInt32 row, col;
	for (row = 0; row < size; ++row) {
		for (col = 0; col < size; ++col) {
			// get a step count from center.
			UInt32 step = abs(col - center) + abs(row - center);
			if (step <= center)
				kernel[(row * size) + col] = 1.f / denominator;
			else
				kernel[(row * size) + col] = 0.f;
		}
	}
	
	UIImage* newImage = [self imageWithSpatialFilter:kernel size:size];
	[kernelData release];
	return newImage;
}

/**
 * Photoshop style blur.
 */
- (UIImage*)photoshopBlur {
	// Photoshop style blur sample matrix kernel.
	CGFloat kernel[] = {
		0.0,	1/8.f, 0.0,
		1/8.f,	1/2.f, 1/8.f,
		0.0,	1/8.f, 0.0	
	};
	return [self imageWithSpatialFilter:kernel size:3];
}


/**
 * Box blur filter.
 * Sample matrix kernel with σ = 1(= (1/9) * 9)
 CGFloat kernel[] = {
	1/9.f, 1/9.f, 1/9.f,
	1/9.f, 1/9.f, 1/9.f,
	1/9.f, 1/9.f, 1/9.f,
 };
 */
- (UIImage*)boxBlur:(CGFloat)sigma {
	if (sigma == 0.f) return self;
	
	sigma = round((((sigma < 0.1f) ? 0.1f : sigma) * 10.f));
	size_t size = (2.f * sigma) + 1.f;
	size_t max = size * size;
	size_t dim = 2;

	size_t length = sizeof(CGFloat) * (size * pow(size, dim));	
	CFMutableDataRep* kernelData = [[CFMutableDataRep alloc] 
									initWithCapacity:length 
									allocator:kCFAllocatorDefault];
	CGFloat* kernel = (CGFloat*)kernelData.mutableBytes;
	
	CGFloat kv = 1.f / max;
	for (size_t i = 0; i < max; ++i)
		kernel[i] = kv;

#if 1 // Sample log of kernel
	NSLog(@"%@", NSStringFromKernel(kernel, size, size));
#endif	

	UIImage* newImage = [self imageWithSpatialFilter:kernel size:size];
	[kernelData release];
	return newImage;
}

#ifndef ROUNDOFF
#define ROUNDOFF(x, dig) (floor((x) * pow(10,dig) + 0.5) / pow(10,dig))
#endif

/**
 * Gaussian blur filter.
 */
- (UIImage*)gaussianBlur:(CGFloat)sigma {
	if (sigma == 0.f) return self;	
	
	// to normalize a value of sigma between 0.5f to 5.f
	sigma = round((((sigma < 0.1f) ? 0.1f : sigma) * 10.f) / 2.f);
	// to make window that has odd kernel
	size_t size = (size_t) fmax(3.f, 4.f * sigma + 3.f);
	size_t dim = 1;
		
	size_t length = sizeof(CGFloat) * (size * pow(size, dim));
	CFMutableDataRep* kernelData = [[CFMutableDataRep alloc] 
									initWithCapacity:length 
									allocator:kCFAllocatorDefault];
	CGFloat* kernel = (CGFloat*)kernelData.mutableBytes;

	size_t center = size / 2;
	// to make 2-D Gaussian distribution.
	for (size_t row = 0; row < size; ++row) {
		for (size_t col = 0; col < size; ++col) {
			size_t x = (col - center);
			size_t y = (row - center);
			CGFloat sqr = sigma * sigma;
			// The equation of a Gaussian function for 
			// two dimension, http://bit.ly/o6v0ik
			CGFloat kv = (1.f / (2.f * M_PI * sqr)) 
							* exp(-((x * x + y * y) / (2.f * sqr)));
			// round off below the 4-digit the decimal point
			kernel[(row * size) + col] = ROUNDOFF(kv, 4);
		}
	}				
	
	UIImage* newImage = [self imageWithSpatialFilter:kernel size:size];
	[kernelData release];
	return newImage;
}

@end

