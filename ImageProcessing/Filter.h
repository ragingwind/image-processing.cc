//
//  Filter.h
//  ImageProcessing
//
//  Created by ragingwind on 11. 10. 14..
//  Copyright 2011 devnight.net. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FilterRange : NSObject {
}

@property (nonatomic) CGFloat min;
@property (nonatomic) CGFloat max;
@property (nonatomic) CGFloat value;

+ (FilterRange*)filterRangeWithValue:(CGFloat)aValue max:(CGFloat)aMax
								 min:(CGFloat)aMin;

@end
/**
 * Supper class of filters
 */
@interface Filter : NSObject {
	SEL _filterMethod;
}

@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSArray* ranges;

// return filter
+ (Filter*)grey;
+ (Filter*)bright;
+ (Filter*)contrast;
+ (Filter*)hue;
+ (Filter*)sharpen;
+ (Filter*)moreSharpen;
+ (Filter*)subtleSharpen;
+ (Filter*)blur;
+ (Filter*)photoshopBlur;
+ (Filter*)boxBlur;
+ (Filter*)gaussianBlur;

// return filtered image
- (UIImage*)filterImage:(UIImage*)aImage args:(NSArray*)anArgs;

@end