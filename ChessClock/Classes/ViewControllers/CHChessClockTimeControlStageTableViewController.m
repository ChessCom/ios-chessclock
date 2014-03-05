//
//  CHTimeControlStageTableViewController.m
//  Chess.com
//
//  Created by Pedro Bolaños on 11/1/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import "CHChessClockTimeControlStageTableViewController.h"
#import "CHChessClockTimeControlStage.h"
#import "CHChessClockTimeViewController.h"
#import "CHChessClockTimeControlStageManager.h"
#import "CHUtil.h"

//------------------------------------------------------------------------------
#pragma mark - Private methods declarations
//------------------------------------------------------------------------------
@interface CHChessClockTimeControlStageTableViewController()
<CHChessClockTimeViewControllerDelegate, UIActionSheetDelegate, UIPopoverControllerDelegate>

@property (retain, nonatomic) IBOutlet UITableViewCell* movesTableViewCell;

@property (assign, nonatomic) NSUInteger stageIndex;

@end

//------------------------------------------------------------------------------
#pragma mark - CHTimeControlStageTableViewController implementation
//------------------------------------------------------------------------------
@implementation CHChessClockTimeControlStageTableViewController

static const NSUInteger CHMovesCountSection = 0;
static const NSUInteger CHTimeSection = 1;
static const NSUInteger CHDeleteSection = 2;
static const NSUInteger CHMaxSectionCount = 3;

static const NSUInteger CHMovesCountTextFieldTag = 1;
static const NSUInteger CHMovesCountLabelTag = 2;
static const NSUInteger CHDeleteButtonTag = 1;
static const NSUInteger CHDeleteButtonIndex = 0;

static const NSUInteger CHMaxMoves = 99;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.stageIndex = [self.timeControlStageManager indexOfStage:self.timeControlStage];
    
    // Do not treat stage indices as zero based
    self.stageIndex++;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (![self isLastStage]) {
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:CHMovesCountSection]];
        UITextField* movesTextField = (UITextField*)[cell viewWithTag:CHMovesCountTextFieldTag];
        NSUInteger moves = [movesTextField.text integerValue];
        
        if (moves <= 0) {
            moves = 1;
        }
        
        self.timeControlStage.movesCount = moves;
        [self.delegate timeControlStageTableViewControllerStageUpdated:self];
    }
}

//------------------------------------------------------------------------------
#pragma mark - Private methods definitions
//------------------------------------------------------------------------------
- (NSString*)formatMaximumTime:(NSUInteger)maximumTime
{
    NSString* maximumTimeString = [CHUtil formatTime:maximumTime showTenths:NO];
    
    if (maximumTime < 60) {
        NSString* secondsString = NSLocalizedString(@"secs", @"Abbreviation for seconds");
        if (maximumTime == 1) {
            secondsString = NSLocalizedString(@"sec", @"Abbreviation for second");
        }

        maximumTimeString = [NSString stringWithFormat:@"%ld %@", (long)maximumTime, secondsString];
    }
    
    return maximumTimeString;
}

- (UITableViewCell*)timeCell
{
    NSString* cellIdentifier = @"CHChessClockTimeCell";
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                       reuseIdentifier:cellIdentifier];
        
        cell.textLabel.text = NSLocalizedString(@"Time", nil);
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0f];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    cell.detailTextLabel.text = [self formatMaximumTime:self.timeControlStage.maximumTime];
    return cell;
}

- (UITableViewCell*)movesCountCell
{
    NSString* cellIdentifier = @"CHChessClockMovesCountCell";
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"CHChessClockStageMovesCell"
                                                     owner:self options:nil];
        if ([nib count] > 0) {
            cell = self.movesTableViewCell;
            ((UILabel*)[cell viewWithTag:CHMovesCountLabelTag]).text = NSLocalizedString(@"Moves", nil);
            
            UITextField* movesTextField = (UITextField*)[cell viewWithTag:CHMovesCountTextFieldTag];
            [movesTextField addTarget:self action:@selector(movesTextFieldBeingEdited:) forControlEvents:UIControlEventEditingChanged];
        }
    }
    

    [self updateMovesCountTextFieldWithCell:cell];
    return cell;
}

- (UITableViewCell*)deleteCell
{
    NSString* cellIdentifier = @"CHChessClockDeleteCell";
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:cellIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // This removes the cell rounded background
        UIView* backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
        cell.backgroundView = backgroundView;
        
        UIButton* deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        deleteButton.tag = CHDeleteButtonTag;
        deleteButton.frame = cell.bounds;
        deleteButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [deleteButton setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:deleteButton];
    }
    
    return cell;
}

- (IBAction)movesTextFieldBeingEdited:(UITextField*)sender
{
    NSUInteger moves = [sender.text integerValue];
    if (moves > CHMaxMoves) {
        moves = CHMaxMoves;
        sender.text = [NSString stringWithFormat:@"%ld", (long)moves];
    }
}

- (void)deleteButtonTapped
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                               destructiveButtonTitle:[NSString stringWithFormat:@"%@ %@",
                                                                       NSLocalizedString(@"Delete", nil), self.title]
                                                    otherButtonTitles:nil, nil];
    
    NSUInteger deleteSection = CHDeleteSection;
    if ([self isLastStage]) {
        deleteSection = CHTimeSection;
    }
    
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:deleteSection]];
    NSAssert(cell != nil, @"Cell must be non nil!");
    
    UIButton* deleteButton = (UIButton*)[cell viewWithTag:CHDeleteButtonTag];
    [actionSheet showFromRect:deleteButton.bounds inView:deleteButton animated:YES];
}

- (void)updateMovesCountTextFieldWithCell:(UITableViewCell*)cell
{
    UITextField* movesCountTextfield = (UITextField*)[cell viewWithTag:CHMovesCountTextFieldTag];
    movesCountTextfield.text = [NSString stringWithFormat:@"%ld", (long)self.timeControlStage.movesCount];
}

- (BOOL)isFirstStage
{
    return self.stageIndex == 1;
}

- (BOOL)isLastStage
{
    return self.stageIndex == [self.timeControlStageManager stageCount];
}

- (void)selectedTimeCell:(UITableViewCell*)cell
{
    NSString* nibName = [CHUtil nibNameWithBaseName:@"CHChessClockTimeView"];
    CHChessClockTimeViewController* timeViewController = [[CHChessClockTimeViewController alloc]
                                                          initWithNibName:nibName bundle:nil];
    timeViewController.delegate = self;
    timeViewController.maximumHours = 11;
    timeViewController.maximumMinutes = 60;
    timeViewController.maximumSeconds = 60;
    timeViewController.selectedTime = self.timeControlStage.maximumTime;
    timeViewController.title = NSLocalizedString(@"Time", nil);
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UIPopoverController* popover = [[UIPopoverController alloc] initWithContentViewController:timeViewController];
        popover.delegate = self;
        [popover presentPopoverFromRect:cell.bounds inView:cell
               permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        [self.navigationController pushViewController:timeViewController animated:YES];
    }
}

- (void)selectedMovesCellWithIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UITextField* movesTextField = (UITextField*)[cell viewWithTag:CHMovesCountTextFieldTag];
    [movesTextField becomeFirstResponder];
}

//------------------------------------------------------------------------------
#pragma mark - UIActionSheetDelegate methods
//------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == CHDeleteButtonIndex) {
        [self.delegate timeControlStageTableViewControllerStageDeleted:self];
        [self.navigationController popViewControllerAnimated:YES];
    }
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
#pragma mark - UITableViewDataSource methods
//------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self isLastStage]) {
        if ([self isFirstStage]) {
            // The first stage can't be deleted
            return CHMaxSectionCount - 2;
        }
        
        return CHMaxSectionCount - 1;
    }
    else {
        if ([self isFirstStage]) {
            // The first stage can't be deleted
            return CHMaxSectionCount - 1;
        }
    }
    
    return CHMaxSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7)
    {
        tableView.tintColor = [UIColor blackColor];
    }
    UITableViewCell* cell = nil;
    switch (indexPath.section) {
        case CHMovesCountSection:
            if ([self isLastStage]) {                
                cell = [self timeCell];
            }
            
            else
                cell = [self movesCountCell];
            break;
            
        case CHTimeSection:
            if ([self isLastStage]) {
                cell = [self deleteCell];
            }
            
            else
                cell = [self timeCell];
            break;
            
        case CHDeleteSection:
            cell = [self deleteCell];
            break;
            
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
        case CHMovesCountSection:
            if ([self isLastStage]) {
                [self selectedTimeCell:[tableView cellForRowAtIndexPath:indexPath]];
            }
            else {
                [self selectedMovesCellWithIndexPath:indexPath];
            }
            
            break;

        case CHTimeSection:
            [self selectedTimeCell:[tableView cellForRowAtIndexPath:indexPath]];
            break;
            
        default:
            break;
    }
}

//------------------------------------------------------------------------------
#pragma mark - CHChessClockTimeViewControllerDelegate methods
//------------------------------------------------------------------------------
- (void)chessClockTimeViewController:(CHChessClockTimeViewController*)timeViewController
              closedWithSelectedTime:(NSUInteger)timeInSeconds
{
    NSUInteger section = CHTimeSection;
    if ([self isLastStage]) {
        section = CHMovesCountSection;
    }
    
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                                     inSection:section]];
    
    cell.detailTextLabel.text = [self formatMaximumTime:timeInSeconds];
    self.timeControlStage.maximumTime = timeInSeconds;
    
    [self.delegate timeControlStageTableViewControllerStageUpdated:self];
}

@end
