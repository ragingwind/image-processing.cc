//
//  FiltersViewController.m
//  ImageProcessing
//
//  Created by ragingwind on 11. 10. 14..
//  Copyright 2011 devnight.net. All rights reserved.
//

#import "Filter.h"
#import "FilterViewController.h"
#import "FiltersViewController.h"

@implementation FiltersViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_filters = [NSArray arrayWithObjects:[Filter grey]
				, [Filter bright]
				, [Filter contrast]
				, [Filter hue]
				, [Filter sharpen]
				, [Filter moreSharpen]
				, [Filter subtleSharpen]
				, [Filter blur]
				, [Filter photoshopBlur]
				, [Filter boxBlur]
				, [Filter gaussianBlur]
				, nil];
	[_filters retain];
	self.navigationController.navigationBarHidden = YES;
	
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_filters count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    Filter* filter = [_filters objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	cell.textLabel.text = filter.name;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	FilterViewController *vc = [FilterViewController new];
	vc.filter = [_filters objectAtIndex:indexPath.row];
	vc.sourceImage = [UIImage imageNamed:@"Butterfly.png"];
	[self.navigationController pushViewController:vc animated:YES];
	[vc release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	[_filters release];
}

- (void)dealloc
{
    [super dealloc];
}

@end
