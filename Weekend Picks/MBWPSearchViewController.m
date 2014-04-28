//
//  MTSearchViewController.m
//  Transit PDX
//
//  Created by Justin Miller on 6/15/12.
//  Copyright (c) 2012 MapBox / Development Seed. All rights reserved.
//

#import "MBWPSearchViewController.h"

@implementation MBWPSearchViewController

@synthesize favorites;
@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@"Toggle All" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleFilterTypes:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissModalViewControllerAnimated:)];
    
/*    NSMutableArray *sortedFilterTypes = [NSMutableArray array];
    
    for (NSDictionary *filterType in [self.filterTypes sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"marker-symbol" ascending:YES]]])
        [sortedFilterTypes addObject:filterType];
    
    self.filterTypes = [NSArray arrayWithArray:sortedFilterTypes];*/
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.delegate respondsToSelector:@selector(searchViewController:didApplyFilterTypes:)])
        [self.delegate searchViewController:self didApplyFilterTypes:[[self.filterTypes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"selected = YES"]] valueForKeyPath:@"marker-symbol"]];
}

#pragma mark -

- (void)toggleFilterTypes:(id)sender
{
/*    int selectedCount = [[self.filterTypes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"selected = YES"]] count];
    
    BOOL newState = (selectedCount != [self.tableView.dataSource tableView:self.tableView numberOfRowsInSection:0]);
    
    for (int i = 0; i < [self.filterTypes count]; i++)
    {
        [[self.filterTypes objectAtIndex:i] setObject:[NSNumber numberWithBool:newState] forKey:@"selected"];
        
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]].accessoryType = (newState ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
    }*/
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.favorites count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"favoritesCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ( ! cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    cell.textLabel.text  = [[[[self.favorites objectAtIndex:indexPath.row] objectForKey:@"marker-symbol"] stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
    
    // draw slightly-cropped pin image for cell
    //
    UIImage *pinImage = [[self.favorites objectAtIndex:indexPath.row] objectForKey:@"image"];
    
    float dimension = pinImage.size.height * 2/3;
    
    UIGraphicsBeginImageContext(CGSizeMake(dimension, dimension));
    
    [pinImage drawInRect:CGRectMake((dimension - pinImage.size.width) / 2, 0, pinImage.size.width, pinImage.size.height)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

    cell.imageView.image = image;
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    cell.selectedBackgroundView.backgroundColor = self.navigationController.navigationBar.tintColor;

    cell.accessoryType = ([[[self.favorites objectAtIndex:indexPath.row] objectForKey:@"selected"] boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
    
    return cell;
}

#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BOOL newState = ([[[self.favorites objectAtIndex:indexPath.row] objectForKey:@"selected"] boolValue] ? NO : YES);
    
    [[self.favorites objectAtIndex:indexPath.row] setObject:[NSNumber numberWithBool:newState] forKey:@"selected"];
    
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = (newState ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
}

@end
