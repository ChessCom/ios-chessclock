//
//  CHIncrementTableViewController.m
//  Chess.com
//
//  Created by Pedro Bolaños on 11/1/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import "CHChessClockIncrementTableViewController.h"
#import "CHChessClockTimeViewController.h"

#import "CHTableViewHeader.h"
#import "CHIncrementCell.h"

#import "CHChessClockIncrement.h"
#import "CHUtil.h"
#import "UIColor+ChessClock.h"

//------------------------------------------------------------------------------
#pragma mark - Private methods declarations
//------------------------------------------------------------------------------
@interface CHChessClockIncrementTableViewController()
<CHChessClockTimeViewControllerDelegate, CHIncrementCellDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) NSDictionary* incrementsTypesDictionary;
@property (assign, nonatomic) NSUInteger selectedIncrementValue;
@property (strong, nonatomic) UIPopoverController* customPopoverController;

@end

//------------------------------------------------------------------------------
#pragma mark - CHChessClockIncrementTableViewController implementation
//------------------------------------------------------------------------------
@implementation CHChessClockIncrementTableViewController

static const NSUInteger CHIncrementTypeSection = 0;
static const NSUInteger CHIncrementValueSection = 1;

static const NSUInteger CHDelaySegmentIndex = 0;
static const NSUInteger CHBronsteinSegmentIndex = 1;
static const NSUInteger CHFischerSegmentIndex = 2;

static NSString* const CHIncrementCellIdentifier = @"CHIncrementCell";


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Increment", nil);
    self.selectedIncrementValue = self.increment.incrementValue;
    
    NSString *tableViewHeaderIdentifier = NSStringFromClass([CHTableViewHeader class]);
    [self.tableView registerNib: [UINib nibWithNibName:tableViewHeaderIdentifier
                                                bundle:nil]
                    forHeaderFooterViewReuseIdentifier:tableViewHeaderIdentifier];
    
    self.tableView.sectionHeaderHeight = self.tableView.sectionFooterHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedSectionHeaderHeight = self.tableView.estimatedSectionFooterHeight = 10;
    self.tableView.estimatedRowHeight = 20;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.tableView registerNib:[UINib nibWithNibName:CHIncrementCellIdentifier bundle:nil]
         forCellReuseIdentifier:CHIncrementCellIdentifier];
}

//------------------------------------------------------------------------------
#pragma mark - Private methods definitions
//------------------------------------------------------------------------------
- (NSDictionary*)incrementsTypesDictionary
{
    if (_incrementsTypesDictionary == nil) {
        self.incrementsTypesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithInt:CHDelaySegmentIndex], @"CHChessClockDelayIncrement",
                                          [NSNumber numberWithInt:CHBronsteinSegmentIndex], @"CHChessClockBronsteinIncrement",
                                          [NSNumber numberWithInt:CHFischerSegmentIndex], @"CHChessClockFischerIncrement",
                                          nil];
    }
    
    return _incrementsTypesDictionary;
    
    return nil;
}

- (CHIncrementCell*)incrementTypeCellForIndexPath:(NSIndexPath*)indexPath
{
    CHIncrementCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CHIncrementCellIdentifier
                                                                 forIndexPath:indexPath];
    cell.delegate = self;
    cell.descriptionLabel.text = [self.increment incrementDescription];
    
    NSString* incrementClassName = NSStringFromClass([self.increment class]);
    [cell.segmentedControl setSelectedSegmentIndex:[[self.incrementsTypesDictionary objectForKey:incrementClassName] integerValue]];

    return cell;
}

- (UITableViewCell*)incrementValueCell
{
    NSString* reuseIdentifier = @"CHIncrementValueCell";
    CHTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[CHTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
        [cell setupStyle];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    cell.textLabel.text = NSLocalizedString(@"Value", nil);
    
    NSUInteger incrementValue = self.increment.incrementValue;
    NSString* incrementValueString = [CHUtil formatTime:incrementValue showTenths:NO];
    
    if (incrementValue < 60) {
        NSString* secondsString = NSLocalizedString(@"secs", @"Abbreviation for seconds");
        if (incrementValue == 1) {
            secondsString = NSLocalizedString(@"sec", @"Abbreviation for second");
        }
        
        incrementValueString = [NSString stringWithFormat:@"%lu %@", (unsigned long)incrementValue, secondsString];
    }
    
    cell.detailTextLabel.text = incrementValueString;
    
    return cell;
}

- (void)selectedIncrementValueCell:(UITableViewCell*)cell
{
    NSString* nibName = @"CHChessClockTimeView";
    CHChessClockTimeViewController* timeViewController = [[CHChessClockTimeViewController alloc]
                                                          initWithNibName:nibName bundle:nil];
    timeViewController.maximumMinutes = 60;
    timeViewController.maximumSeconds = 60;
    timeViewController.zeroSelectionAllowed = YES;
    timeViewController.selectedTime = self.increment.incrementValue;
    timeViewController.title = NSLocalizedString(@"Value", nil);
    timeViewController.delegate = self;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.customPopoverController = [[UIPopoverController alloc] initWithContentViewController:timeViewController];
        self.customPopoverController.delegate = self;
        [self.customPopoverController presentPopoverFromRect:cell.bounds inView:cell
               permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    }
    else {
        [self.navigationController pushViewController:timeViewController animated:YES];
    }
}

//------------------------------------------------------------------------------
#pragma mark - UITableViewDataSource methods
//------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    switch (indexPath.section) {
        case CHIncrementTypeSection:
            cell = [self incrementTypeCellForIndexPath:indexPath];
            break;

        case CHIncrementValueSection:
            cell = [self incrementValueCell];
            [cell.textLabel setFont:[UIFont boldSystemFontOfSize:15]];
            
        default:
            break;
    }

    return cell;
}

//------------------------------------------------------------------------------
#pragma mark - UITableViewDelegate methods
//------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case CHIncrementValueSection:
            [self selectedIncrementValueCell:[tableView cellForRowAtIndexPath:indexPath]];
            break;
            
        default:
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CHTableViewHeader *headerView = nil;
    if (section == CHIncrementTypeSection) {
        headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([CHTableViewHeader class])];
        headerView.titleLabel.text = NSLocalizedString(@"Type", nil);
    }
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section == CHIncrementTypeSection) ? UITableViewAutomaticDimension : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0;
}

//------------------------------------------------------------------------------
#pragma mark - UIPopoverControllerDelegate methods
//------------------------------------------------------------------------------
- (void)popoverControllerDidDismissPopover:(UIPopoverController*)popoverController
{
    NSIndexPath* selectedIndexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
}

//------------------------------------------------------------------------------
#pragma mark - CHChessClockTimeViewControllerDelegate methods
//------------------------------------------------------------------------------
- (void)chessClockTimeViewController:(CHChessClockTimeViewController*)timeViewController
              closedWithSelectedTime:(NSUInteger)timeInSeconds
{
    self.increment.incrementValue = timeInSeconds;
    self.selectedIncrementValue = timeInSeconds;
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:CHIncrementValueSection]
                  withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.delegate chessClockIncrementTableViewControllerUpdatedIncrement:self];
}

//------------------------------------------------------------------------------
#pragma mark - CHIncrementCellDelegate
//------------------------------------------------------------------------------
- (void)incrementCell:(CHIncrementCell*)cell changedToIncrementWithIndex:(NSUInteger)index
{
    NSString* selectedIncrementClassName = nil;
    
    for (NSString* incrementClassName in self.incrementsTypesDictionary) {
        if ([[self.incrementsTypesDictionary objectForKey:incrementClassName] integerValue] == index) {
            selectedIncrementClassName = incrementClassName;
            break;
        }
    }
    
    CHChessClockIncrement* increment = [[NSClassFromString(selectedIncrementClassName) alloc]
                                        initWithIncrementValue:self.selectedIncrementValue];
    self.increment = increment;
    [self.delegate chessClockIncrementTableViewControllerUpdatedIncrement:self];
    
    [self.tableView reloadData];
}

@end
