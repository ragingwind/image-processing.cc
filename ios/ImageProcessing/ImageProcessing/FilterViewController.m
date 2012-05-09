//
//  FilterViewController.m
//  ImageProcessing
//
//  Created by ragingwind on 11. 10. 14..
//  Copyright 2011 devnight.net. All rights reserved.
//

#import "Filter.h"
#import "FilterViewController.h"


@implementation FilterViewController

@synthesize filter = _filter, sourceImage = _sourceImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
	[_filter release];
	[_sourceImage release];
	[_sliders release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Subroutines

- (void)resetSourceImage {
	_filteredImage = NO;
	_imageView.image = _sourceImage;
}


#pragma mark - Events

- (void)touchedTapToBack:(UITapGestureRecognizer *)sender {
	[self.navigationController popViewControllerAnimated:YES];
}


- (void)touchedDoubleTapToFilter:(UITapGestureRecognizer *)sender {
	if (_filteredImage == NO) {
		_imageView.image = [self.filter filterImage:self.sourceImage 
											   args:nil];
		_filteredImage = YES;
	}
	else
		[self resetSourceImage];
}

- (void)sliderValueChangedToFilter:(UISlider*)sender {
	// make a arguments
	NSMutableArray* args = [NSMutableArray new];
	for (UISlider* s in _sliders) {
		[args addObject:[NSNumber numberWithFloat:s.value]];
	}
	_imageView.image = [self.filter filterImage:self.sourceImage 
										   args:args];
	[args release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// set original image to view
	_imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	[self resetSourceImage];
	[self.view addSubview:_imageView];
	[_imageView release];
	
	// add gesture for navigation to back
	UITapGestureRecognizer *tapForBack = [[UITapGestureRecognizer alloc] 
										  initWithTarget:self
										  action:@selector(touchedTapToBack:)];
	tapForBack.numberOfTapsRequired = 2;
	[self.view addGestureRecognizer:tapForBack];
	
	
	// add control or gesture for filtering
	if (self.filter.ranges) {
		_sliders = [NSMutableArray new];
		CGFloat margin = 0.f;
		for (FilterRange* range in self.filter.ranges) {
			CGRect frame = CGRectMake(20, 360 + margin, 280, 23);
			UISlider* slider = [[UISlider alloc] initWithFrame:frame];
			slider.maximumValue = range.max;
			slider.minimumValue	= range.min;
			slider.value = range.value;
			[slider addTarget:self 
					   action:@selector(sliderValueChangedToFilter:) 
			 forControlEvents:UIControlEventTouchUpInside];
			
			[self.view addSubview:slider];
			[_sliders addObject:slider];
			[slider release];
			margin += 30.f;
		}
	}
	else {
		UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]
							initWithTarget:self
									action:@selector(touchedDoubleTapToFilter:)];
		doubleTap.numberOfTapsRequired = 1;
		[doubleTap requireGestureRecognizerToFail:tapForBack];
		[self.view addGestureRecognizer:doubleTap];
		[doubleTap release];
	}
	
	[tapForBack release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
