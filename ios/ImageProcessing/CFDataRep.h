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

//
// CFDataRep
//
@interface CFDataRep : NSObject {
@protected
	CFDataRef _dataRef;
	CGDataProviderRef _providerRef;
	UInt8* _bytes;
}

@property (nonatomic, readonly) CFDataRef CFData;
@property (nonatomic, readonly) CGDataProviderRef CGDataProvider;
@property (nonatomic, readonly) const UInt8 *bytes;
@property (nonatomic, readonly) size_t length;

- (id)initWithCFData:(CFDataRef)dataRef allocator:(CFAllocatorRef)allocator;

@end

//
// CFMutableDataRep
//
@interface CFMutableDataRep : CFDataRep {
}

@property (nonatomic, readonly) UInt8 *mutableBytes;

- (id)initWithCapacity:(CFIndex)capacity allocator:(CFAllocatorRef)allocator;

@end


