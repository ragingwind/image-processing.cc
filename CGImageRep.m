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

#import "CGImageRep.h"



#
#pragma mark CGImageRep impelementation
#

@implementation CGImageRep

@synthesize width, height, alphaInfo, bitsPerPixel;
@synthesize bytesPerRow, bitsPerComponent, CGImage = _imageRef;

- (size_t)width {return CGImageGetWidth(_imageRef);}
- (size_t)height {return CGImageGetHeight(_imageRef);}
- (CGImageAlphaInfo)alphaInfo {return CGImageGetAlphaInfo(_imageRef);}
- (size_t)bitsPerPixel {return CGImageGetBitsPerPixel(_imageRef);}
- (size_t)bytesPerRow {return CGImageGetBytesPerRow(_imageRef);}
- (size_t)bitsPerComponent {return CGImageGetBitsPerComponent(_imageRef);}
- (CFDataRep*)CFDataRep {return _dataRep;}


- (id)initWithCGImage:(CGImageRef)imageRef allocator:(CFAllocatorRef)allocator {
	if (self = [super init]) {
		_imageRef = CGImageRetain(imageRef);
		CFDataRef dataRef = CGDataProviderCopyData(CGImageGetDataProvider(_imageRef));
		_dataRep = [[CFDataRep alloc] initWithCFData:dataRef 
										   allocator:kCFAllocatorDefault];
		CFRelease(dataRef);
	}
	return self;
}

- (id)initWithCGImage:(CGImageRef)imageRef {
	return [self initWithCGImage:imageRef allocator:kCFAllocatorDefault];
}


- (void)dealloc {
	CGImageRelease(_imageRef);
	[_dataRep release];
	[super dealloc];
}

@end


@implementation CGImageMutableRep
@synthesize CFMutableDataRep;

- (CFMutableDataRep*)CFMutableDataRep {return (CFMutableDataRep*)_dataRep;}

- (id)initWithCGImage:(CGImageRef)imageRef allocator:(CFAllocatorRef)allocator {
	if (self = [super init]) {
		_imageRef = CGImageCreateCopy(imageRef);
		CFDataRef dataRef = CGDataProviderCopyData(CGImageGetDataProvider(_imageRef));;
		
		CFMutableDataRep* dataRep = [[CFMutableDataRep alloc] 
									 initWithCFData:dataRef 
									 allocator:kCFAllocatorDefault];
		_dataRep = dataRep;
		CFRelease(dataRef);	
	}
	return self;
}

@end

NSString* NSStringFromCGImageRep(CGImageRep* imageRep) {
	return [NSString stringWithFormat:
			@"CGImageRep {width:%d, height:%d, bpp:%d, bpr:%d, bpc:%d}"
			, imageRep.width, imageRep.height, imageRep.bitsPerPixel
			, imageRep.bytesPerRow, imageRep.bitsPerComponent];
}
