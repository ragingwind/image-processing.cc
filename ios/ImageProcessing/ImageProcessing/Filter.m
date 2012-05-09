//
//  Filter.m
//  ImageProcessing
//
//  Created by ragingwind on 11. 10. 14..
//  Copyright 2011 devnight.net. All rights reserved.
//

#import "UIImage+Processing.h"
#import "Filter.h"

@implementation FilterRange

@synthesize value, max, min;

+ (FilterRange*)filterRangeWithValue:(CGFloat)aValue max:(CGFloat)aMax
								 min:(CGFloat)aMin {
	FilterRange* fr = [FilterRange new];
	fr.value = aValue;
	fr.max = aMax;
	fr.min = aMin;
	return [fr autorelease];
}

@end

@implementation Filter

@synthesize name=_name, ranges=_ranges;

- (id)initWithWithName:(NSString*)filterName action:(SEL)filterMethod {
	if (self = [super init]) {
		_name = filterName;
		_ranges = nil;
		_filterMethod = filterMethod;
	}
	return self;
}

- (void)dealloc {
	[_name release];
	[_ranges release];
	[super dealloc];
}

+ (Filter*)filterWithName:(NSString*)name action:(SEL)filterMethod {
	return [[[Filter alloc] initWithWithName:name 
									  action:filterMethod] autorelease];
}

- (UIImage*)filterImage:(UIImage*)originImage args:(NSArray*)args {
	return [self performSelector:_filterMethod 
					  withObject:originImage 
					  withObject:args];
}

- (UIImage*)greyImage:(UIImage*)originImage args:(NSArray*)args {
	NSAssert(args == nil, @"Invalid argument for Grey");
	
	return [originImage greyImage];
}

+ (Filter*)grey {
	return [Filter filterWithName:@"Grey" action:@selector(greyImage:args:)];
}

- (UIImage*)hueImage:(UIImage*)originImage args:(NSArray*)args{
	NSAssert(args && args.count == 3, @"Invalid argument for HUE");
	
	return [originImage hueImage:kUIColorDegreesMaster 
							 hue:[[args objectAtIndex:0] floatValue]
					  saturation:[[args objectAtIndex:1] floatValue]
					   luminance:[[args objectAtIndex:2] floatValue]];
}

+ (Filter*)hue {
	Filter* f = [Filter filterWithName:@"HUE" action:@selector(hueImage:args:)];
	f.ranges = [NSArray arrayWithObjects:
				[FilterRange filterRangeWithValue:0.f max:100.f min:-100.f]
				, [FilterRange filterRangeWithValue:0.f max:100.f min:-100.f]
				, [FilterRange filterRangeWithValue:0.f max:100.f min:-100.f]
				, nil];
	return f;
}

- (UIImage*)brightImage:(UIImage*)originImage args:(NSArray*)args{
	NSAssert(args && args.count == 1, @"Invalid argument for Bright");
	
	return [originImage brightImage:[[args objectAtIndex:0] floatValue]];
}

+ (Filter*)bright {
	Filter* f = [Filter filterWithName:@"Bright" 
								action:@selector(brightImage:args:)];
	f.ranges = [NSArray arrayWithObjects:
				[FilterRange filterRangeWithValue:1.f max:2.f min:0.f]
				, nil];
	return f;
}

- (UIImage*)contrastImage:(UIImage*)originImage args:(NSArray*)args{
	NSAssert(args && args.count == 1, @"Invalid argument for Contrast");
	
	return [originImage contrastImage:180.f 
							 contrast:[[args objectAtIndex:0] floatValue]];
}

+ (Filter*)contrast {
	Filter* f = [Filter filterWithName:@"Contrast" 
								action:@selector(contrastImage:args:)];
	f.ranges = [NSArray arrayWithObject:
				[FilterRange filterRangeWithValue:1.f max:2.f min:0.f]];
	return f;	
}

- (UIImage*)sharpenImage:(UIImage*)originImage args:(NSArray*)args{
	NSAssert(args && args.count == 1, @"Invalid argument for Shapern");
	
	return [originImage sharpen:[[args objectAtIndex:0] floatValue]];
}

+ (Filter*)sharpen {
	Filter* f = [Filter filterWithName:@"Sharpen" 
								action:@selector(sharpenImage:args:)];
	f.ranges = [NSArray arrayWithObject:
				[FilterRange filterRangeWithValue:0.f max:1 min:0.f]];
	return f;
}


- (UIImage*)moreSharpenImage:(UIImage*)originImage args:(NSArray*)args{
	NSAssert(args && args.count == 1, @"Invalid argument for More Shapern");
	
	return [originImage moreSharpen:[[args objectAtIndex:0] floatValue]];
}

+ (Filter*)moreSharpen {
	Filter* f = [Filter filterWithName:@"More Sharpen" 
								action:@selector(moreSharpenImage:args:)];
	f.ranges = [NSArray arrayWithObject:
				[FilterRange filterRangeWithValue:0.f max:1 min:0.f]];
	return f;
}


- (UIImage*)subtleSharpenImage:(UIImage*)originImage args:(NSArray*)args{
	NSAssert(args == nil, @"Invalid argument for Subtle Shapern");
	
	return [originImage subtleSharpen];
}

+ (Filter*)subtleSharpen {
	Filter* f = [Filter filterWithName:@"Subtle Sharpen" 
								action:@selector(subtleSharpenImage:args:)];
	return f;
}

- (UIImage*)blurImage:(UIImage*)originImage args:(NSArray*)args{
	NSAssert(args && args.count == 1, @"Invalid argument for Blur");
	
	return [originImage blur:[[args objectAtIndex:0] floatValue]];
}


+ (Filter*)blur {
	Filter* f = [Filter filterWithName:@"Blur" 
								action:@selector(blurImage:args:)];
	f.ranges = [NSArray arrayWithObject:
				[FilterRange filterRangeWithValue:0.f max:1 min:0.f]];
	return f;
}

- (UIImage*)photoshopBlurImage:(UIImage*)originImage args:(NSArray*)args{
	NSAssert(args == nil, @"Invalid argument for Blur");
	
	return [originImage photoshopBlur];
}

+ (Filter*)photoshopBlur {
	Filter* f = [Filter filterWithName:@"Photoshop Blur" 
								action:@selector(photoshopBlurImage:args:)];
	return f;
}

- (UIImage*)boxBlurImage:(UIImage*)originImage args:(NSArray*)args{
	NSAssert(args && args.count == 1, @"Invalid argument for Box Blur");
	
	return [originImage boxBlur:[[args objectAtIndex:0] floatValue]];
}


+ (Filter*)boxBlur {
	Filter* f = [Filter filterWithName:@"Box Blur" 
								action:@selector(boxBlurImage:args:)];
	f.ranges = [NSArray arrayWithObject:
				[FilterRange filterRangeWithValue:0.f max:1 min:0.f]];
	return f;
}

- (UIImage*)gaussianBlurImage:(UIImage*)originImage args:(NSArray*)args{
	NSAssert(args && args.count == 1, @"Invalid argument for Gaussian Blur");
	
	return [originImage gaussianBlur:[[args objectAtIndex:0] floatValue]];
}


+ (Filter*)gaussianBlur {
	Filter* f = [Filter filterWithName:@"Gaussian Blur 2D" 
								action:@selector(gaussianBlurImage:args:)];
	f.ranges = [NSArray arrayWithObject:
				[FilterRange filterRangeWithValue:0.f max:1 min:0.f]];
	return f;
}

@end