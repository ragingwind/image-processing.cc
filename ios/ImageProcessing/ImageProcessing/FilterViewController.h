//
//  FilterViewController.h
//  ImageProcessing
//
//  Created by ragingwind on 11. 10. 14..
//  Copyright 2011 devnight.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Filter;
@interface FilterViewController : UIViewController {
@private
    UIImageView* _imageView;
	BOOL _filteredImage;
	NSMutableArray* _sliders;
}

@property (nonatomic, retain) Filter* filter;
@property (nonatomic, retain) UIImage* sourceImage;

@end
