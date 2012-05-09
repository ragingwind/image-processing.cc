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

#import "CFDataRep.h"


@implementation CFDataRep

@synthesize bytes, CFData = _dataRef, CGDataProvider = _providerRef;

- (const UInt8*)bytes {return _bytes;}

- (size_t)length {return CFDataGetLength(_dataRef);}

- (id)initWithCFData:(CFDataRef)dataRef allocator:(CFAllocatorRef)allocator {
    self = [super init];
    if (self) {
		_providerRef = CGDataProviderCreateWithCFData(dataRef);
		_dataRef = CGDataProviderCopyData(_providerRef);;
		_bytes = (UInt8*) CFDataGetBytePtr(_dataRef);
    }
    
    return self;
}

- (void)dealloc
{
	CFRelease(_dataRef);
	CGDataProviderRelease(_providerRef);
    [super dealloc];
}

@end


@implementation CFMutableDataRep

@synthesize mutableBytes;

- (UInt8*)mutableBytes {return _bytes;}

- (id)initWithCapacity:(CFIndex)capacity allocator:(CFAllocatorRef)allocator {
	self = [super init];
    if (self) {
		CFMutableDataRef newDataRef = CFDataCreateMutable(allocator, capacity);
		_dataRef = newDataRef;
		_providerRef = CGDataProviderCreateWithCFData(_dataRef); 
		_bytes = CFDataGetMutableBytePtr(newDataRef);		
    }
    
    return self;
}

- (id)initWithCFData:(CFDataRef)dataRef allocator:(CFAllocatorRef)allocator {
    self = [super init];
    if (self) {
		CFMutableDataRef newDataRef = CFDataCreateMutableCopy(allocator, 0, dataRef);
		_dataRef = newDataRef;
		_providerRef = CGDataProviderCreateWithCFData(_dataRef);
		_bytes = CFDataGetMutableBytePtr(newDataRef);
    }
    
    return self;
}

@end
