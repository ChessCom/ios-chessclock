//
//  CHTimeControlTableViewController.m
//  Chess.com
//
//  Created by Pedro Bolaños on 10/25/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import "CHChessClockTimeControlTableViewController.h"
#import "CHChessClockSettings.h"
#import "CHChessClockIncrementTableViewController.h"
#import "CHChessClockTimeControlStageTableViewController.h"
#import "CHChessClockIncrement.h"
#import "CHChessClockFischerIncrement.h"
#import "CHChessClockTimeControlStageManager.h"
#import "CHChessClockTimeControlStage.h"
#import "CHChessClockTimeViewController.h"
#import "CHUtil.h"
#import "UIColor+ChessClock.h"
#import "CHTableViewHeader.h"

static const NSInteger kAddButtonTag = 1000;

//------------------------------------------------------------------------------
#pragma mark Private methods declarations
//------------------------------------------------------------------------------
@interface CHChessClockTimeControlTableViewController()
<CHChessClockIncrementTableViewControllerDelegate, CHChessClockTimeControlStageTableViewControllerDelegate,
CHChessClockTimeViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableViewCell* nameTableViewCell;
@property (weak, nonatomic) IBOutlet UISwitch *duplicateSettingsSwitch;
@property (strong, nonatomic) IBOutlet UIView *tableFooterView;

@property (weak, nonatomic) CHChessClockTimeControlStage* stageToUpdate;
@property (strong, nonatomic) UIPopoverController *customPopoverController;

@end

//------------------------------------------------------------------------------
#pragma mark CHTimeControlTableViewController implementation
//------------------------------------------------------------------------------
@implementation CHChessClockTimeControlTableViewController

static const NSUInteger CHNameSection = 0;
static const NSUInteger CHExistingTimeControlStagesSection = 1;
static const NSUInteger CHNewTimeControlStageSection = 2;
static const NSUInteger CHIncrementSection = 3;
static const NSUInteger CHSectionCount = 4;
static const NSUInteger CHNameTextFieldTag = 1;
static const NSUInteger CHMaxTimeControlStages = 3;

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *tableViewHeaderIdentifier = NSStringFromClass([CHTableViewHeader class]);
    [self.tableView registerNib: [UINib nibWithNibName:tableViewHeaderIdentifier
                                                bundle:nil]
                    forHeaderFooterViewReuseIdentifier:tableViewHeaderIdentifier];
    
    self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedSectionHeaderHeight = 10;
    self.tableView.estimatedRowHeight = 20;
    
    self.duplicateSettingsSwitch.on = [self.dataSource timeControlTableViewcontrollerShouldDuplicateSettings:self];
    
    self.tableView.tableFooterView = self.tableFooterView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO
                                             animated:YES];
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.dataSource.timeControlName = self.nameTextField.text;
}

- (void)createDefaultSettings
{
    CHChessClockFischerIncrement* increment = [[CHChessClockFischerIncrement alloc] initWithIncrementValue:5];
    CHChessClockTimeControlStageManager* stageManager = [[CHChessClockTimeControlStageManager alloc] init];
    [stageManager addTimeStageWithMovesCount:0 andMaximumTime:300];
    
    // The user wants to create new time control. By default, use a Fischer
    // increment, and a single time stage
    self.settings = [[CHChessClockSettings alloc] initWithIncrement:increment
                                                       stageManager:stageManager];
}

//------------------------------------------------------------------------------
#pragma mark - UITableViewDataSource methods
//------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.settings.stageManager stageCount] == CHMaxTimeControlStages) {
        return CHSectionCount - 1;
    }
    
    return CHSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case CHNameSection:
            return 1;
            break;
            
        case CHExistingTimeControlStagesSection:
            return [self.settings.stageManager stageCount];
            break;
            
        case CHNewTimeControlStageSection:
            return 1;
            break;
            
        case CHIncrementSection:
            return 1;
            break;
            
        default:
            break;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    switch (indexPath.section) {
        case CHNameSection:
            cell = [self nameCell];
            break;
            
        case CHExistingTimeControlStagesSection:
            cell = [self timeControlStageCellForRow:indexPath.row];
            break;
            
        case CHNewTimeControlStageSection:
            if ([self.settings.stageManager stageCount] == CHMaxTimeControlStages) {
                // If the number of time control stages is the maximum, it means that
                // that the new time control section was deleted. Treat this
                // section as the increment section
                cell = [self incrementCell];
            }
            else {
                cell = [self addTimeControlStageCell];
            }
            
            break;
            
        case CHIncrementSection:
            cell = [self incrementCell];
            break;
            
        default:
            break;
    }
    
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:15]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Allow editing (deleting rows) if the row is:
    // - One of the time control stages
    // - Not the first time control stage row (we always need at least one stage)
    return indexPath.section == CHExistingTimeControlStagesSection && indexPath.row != 0;
}

//------------------------------------------------------------------------------
#pragma mark - UITableViewDelegate methods
//------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataSource timeControlTableViewcontrollerShouldDuplicateSettings:self]) {
        return;
    }
    
    switch (indexPath.section) {
        case CHNameSection:
            [self selectedNameCellWithIndexPath:indexPath];
            break;
            
        case CHExistingTimeControlStagesSection:
            [self selectedExistingTimeControllCellWithIndexPath:indexPath];
            break;
        
        case CHNewTimeControlStageSection:
            if ([self.settings.stageManager stageCount] == CHMaxTimeControlStages) {
                [self selectedIncrementCellWithIndexPath:indexPath];
            }
            break;
            
        case CHIncrementSection:
            [self selectedIncrementCellWithIndexPath:indexPath];
            break;
            
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self removeTimeStageAtIndex:indexPath.row];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CHTableViewHeader *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([CHTableViewHeader class])];
    
    switch (section) {
        case CHNameSection:
            headerView.titleLabel.text = NSLocalizedString(@"Name", nil);
            break;
            
        case CHExistingTimeControlStagesSection:
            headerView.titleLabel.text = NSLocalizedString(@"Stages", nil);
            break;
            
        case CHNewTimeControlStageSection:
            if ([self.settings.stageManager stageCount] == CHMaxTimeControlStages) {
                // If the number of time control stages is the maximum, it means that
                // that the new time control stage section was deleted. Treat this
                // section as the increment section
                headerView.titleLabel.text = NSLocalizedString(@"Increment", nil);
            }
            
            break;
            
        case CHIncrementSection:
            headerView.titleLabel.text = NSLocalizedString(@"Increment", nil);
            break;
            
        default:
            break;
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case CHNameSection:
        case CHExistingTimeControlStagesSection:
        case CHIncrementSection:
            return UITableViewAutomaticDimension;
            
        case CHNewTimeControlStageSection:
            return ([self.settings.stageManager stageCount] == CHMaxTimeControlStages) ? UITableViewAutomaticDimension : 0;
        
        default: return 0;
    }
}

//------------------------------------------------------------------------------
#pragma mark Private methods definitions
//------------------------------------------------------------------------------
- (UITableViewCell*)nameCell
{
    NSString* cellIdentifier = @"CHChessClockTimeControlNameCell";
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"CHChessClockTimeControlNameCell" owner:self options:nil];
        if ([nib count] > 0) {
            cell = self.nameTableViewCell;
            
            UITextField* nameTextField = (UITextField*)[cell viewWithTag:CHNameTextFieldTag];
            [nameTextField addTarget:self action:@selector(nameTextFielEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
            [nameTextField addTarget:self action:@selector(nameTextFieldBeingEdited:) forControlEvents:UIControlEventEditingChanged];
        }
    }

    UITextField* nameTextField = (UITextField*)[cell viewWithTag:CHNameTextFieldTag];
    nameTextField.text = self.dataSource.timeControlName;
    nameTextField.enabled = ![self.dataSource timeControlTableViewcontrollerShouldDuplicateSettings:self];

    NSString *placeholderText = NSLocalizedString(@"Enter time control name", nil);
    UIColor *textColor = [self.dataSource timeControlTableViewcontrollerShouldDuplicateSettings:self] ? [UIColor darkGrayColor] : [UIColor tableViewCellTextColor];
    nameTextField.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:placeholderText
                                    attributes:@{NSForegroundColorAttributeName: textColor}];
    return cell;
}

- (UITableViewCell*)timeControlStageCellForRow:(NSUInteger)row
{
    NSString* cellIdentifier = @"CHChessClockTimeControlStageCell";
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                       reuseIdentifier:cellIdentifier];
    }
    
    [self addStyleToCell:cell];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %lu", NSLocalizedString(@"Stage", nil), row + 1];
    cell.detailTextLabel.text = [[self.settings.stageManager stageAtIndex:row] description];
    
    UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
    if (idiom == UIUserInterfaceIdiomPad && [self.settings.stageManager stageCount] == 1) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    return cell;
}

- (void)addStyleToCell:(UITableViewCell *)cell
{
    cell.backgroundColor = [UIColor clearColor];
    cell.tintColor = [UIColor tableViewCellTextColor];
    cell.separatorInset = UIEdgeInsetsZero;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0f];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    

    cell.textLabel.textColor = cell.detailTextLabel.textColor =
    [self.dataSource timeControlTableViewcontrollerShouldDuplicateSettings:self] ? [UIColor darkGrayColor] : [UIColor tableViewCellTextColor];
}

- (UITableViewCell*)addTimeControlStageCell
{
    NSString* cellIdentifier = @"CHChessClockNewTimeControlStageCell";
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:cellIdentifier];
        
        // This removes the cell rounded background
        UIView* backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
        cell.backgroundView = backgroundView;
        
        UIButton* addButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        addButton.frame = cell.bounds;
        addButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [addButton setTitle:NSLocalizedString(@"Add stage", nil) forState:UIControlStateNormal];
        [addButton addTarget:self action:@selector(addStageButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [addButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
        addButton.tag = kAddButtonTag;
        [cell.contentView addSubview:addButton];
    }
    
    UIButton *addButton = [cell viewWithTag:kAddButtonTag];
    addButton.enabled = ![self.dataSource timeControlTableViewcontrollerShouldDuplicateSettings:self];
    [self addStyleToCell:cell];
        
    return cell;
}

- (UITableViewCell*)incrementCell
{
    NSString* cellIdentifier = @"CHChessClockIncrementCell";
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                       reuseIdentifier:cellIdentifier];
        
        cell.textLabel.text = NSLocalizedString(@"Type", nil);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [self addStyleToCell:cell];
    NSUInteger incrementValue = self.settings.increment.incrementValue;
    NSString* incrementValueString = [CHUtil formatTime:incrementValue showTenths:NO];
    
    if (incrementValue < 60) {
        NSString* secondsString = NSLocalizedString(@"secs", @"Abbreviation for seconds");
        if (incrementValue == 1) {
            secondsString = NSLocalizedString(@"sec", @"Abbreviation for second");
        }
        
        incrementValueString = [NSString stringWithFormat:@"%lu %@", (unsigned long)incrementValue, secondsString];
    }
    
    NSString* detailString = [NSString stringWithFormat:@"%@, %@",
                              [self.settings.increment description], incrementValueString];
    
    cell.detailTextLabel.text = detailString;
    return cell;
}

- (NSString*)validateName
{
    UITextField* nameTextField = [self nameTextField];
    NSString* timeControlName = [nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([timeControlName length] == 0) {
        return nil;
    }
    
    return timeControlName;
}

- (void)removeTimeStageAtIndex:(NSUInteger)timeStageIndex
{
    [self.settings.stageManager removeTimeStageAtIndex:timeStageIndex];
    
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:CHExistingTimeControlStagesSection]
                  withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if ([self.tableView numberOfSections] < CHSectionCount) {
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:CHNewTimeControlStageSection]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [self.tableView endUpdates];
}

- (UITextField*)nameTextField
{
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:CHNameSection]];
    UIView* view = [cell viewWithTag:CHNameTextFieldTag];
    if ([view isKindOfClass:[UITextField class]]) {
        UITextField* nameTextField = (UITextField*)view;
        return nameTextField;
    }
    
    return nil;
}

- (void)addStageButtonTapped
{
    // The last stage can't have a number of moves
    CHChessClockTimeControlStage* stage = [[CHChessClockTimeControlStage alloc]
                                           initWithMovesCount:0 andMaximumTime:300];
    
    [self.settings.stageManager addTimeStage:stage];
    
    NSUInteger stageCount = [self.settings.stageManager stageCount];
    
    [self.tableView beginUpdates];

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:CHExistingTimeControlStagesSection]
                  withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if (stageCount == CHMaxTimeControlStages) {
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:CHNewTimeControlStageSection]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [self.tableView endUpdates];
}

- (void)reloadRowWithStage:(CHChessClockTimeControlStage*)stage
{
    if (stage != nil) {
        NSUInteger stageIndex = [self.settings.stageManager indexOfStage:stage];
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:stageIndex inSection:CHExistingTimeControlStagesSection];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)selectedNameCellWithIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UITextField* nameTextField = (UITextField*)[cell viewWithTag:CHNameTextFieldTag];
    [nameTextField becomeFirstResponder];
}

- (void)selectedExistingTimeControllCellWithIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row == 0 && [self.settings.stageManager stageCount] == 1) {
        // If there's only one stage, send the player directly to the
        // screen where we can pick the time
        NSString* nibName = @"CHChessClockTimeView";
        CHChessClockTimeViewController* timeViewController = [[CHChessClockTimeViewController alloc]
                                                              initWithNibName:nibName bundle:nil];
        
        self.stageToUpdate = [self.settings.stageManager stageAtIndex:indexPath.row];
        
        timeViewController.delegate = self;
        timeViewController.maximumHours = 11;
        timeViewController.maximumMinutes = 60;
        timeViewController.maximumSeconds = 60;
        timeViewController.selectedTime = self.stageToUpdate.maximumTime;
        timeViewController.title = NSLocalizedString(@"Time", nil);
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.customPopoverController = [[UIPopoverController alloc] initWithContentViewController:timeViewController];
            self.customPopoverController.delegate = self;
            UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            [self.customPopoverController presentPopoverFromRect:cell.bounds inView:cell
                   permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            
        }
        else {
            [self.navigationController pushViewController:timeViewController animated:YES];
        }
    }
    else {
        NSString* nibName = @"CHChessClockTimeControlStageView";
        CHChessClockTimeControlStageTableViewController* stageViewController = [[CHChessClockTimeControlStageTableViewController alloc]
                                                                      initWithNibName:nibName bundle:nil];
        stageViewController.delegate = self;
        stageViewController.title = [self.tableView cellForRowAtIndexPath:indexPath].textLabel.text;
        stageViewController.timeControlStageManager = self.settings.stageManager;
        stageViewController.timeControlStage = [self.settings.stageManager stageAtIndex:indexPath.row];
        
        [self.navigationController pushViewController:stageViewController animated:YES];
    }
}

- (void)selectedIncrementCellWithIndexPath:(NSIndexPath*)indexPath
{
    NSString* nibName = @"CHChessClockIncrementView";
    CHChessClockIncrementTableViewController* vc = [[CHChessClockIncrementTableViewController alloc]
                                                    initWithNibName:nibName bundle:nil];
    
    vc.increment = self.settings.increment;
    vc.delegate = self;

    [self.navigationController pushViewController:vc animated:YES];
}

//------------------------------------------------------------------------------
#pragma mark - IBActions
//------------------------------------------------------------------------------
- (IBAction)duplicateSwitchValueChanged:(UISwitch *)sender
{
    [self.delegate timeControlTableViewController:self didUpdateShouldDuplicateSettings:sender.on];
    [self.tableView reloadData];
}

- (IBAction)nameTextFielEditingDidEndOnExit:(UITextField*)sender
{
    [sender resignFirstResponder];
}

- (IBAction)nameTextFieldBeingEdited:(UITextField*)sender
{
    NSString* name = [self validateName];
    [self.delegate timeControlTableViewController:self setName:name];
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
#pragma mark - CHChessClockIncrementViewControllerDelegate methods
//------------------------------------------------------------------------------
- (void)chessClockIncrementTableViewControllerUpdatedIncrement:(CHChessClockIncrementTableViewController*)viewController
{
    self.settings.increment = viewController.increment;
    
    NSUInteger section = CHIncrementSection;
    if ([self.settings.stageManager stageCount] == CHMaxTimeControlStages) {
        // If the number of time control stages is the maximum, it means that
        // that the new time control section was deleted. The increment section
        // is now the "new time control stage" section
        section = CHNewTimeControlStageSection;
    }
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

//------------------------------------------------------------------------------
#pragma mark - CHTimeControlStageTableViewControllerDelegate methods
//------------------------------------------------------------------------------
- (void)timeControlStageTableViewControllerStageUpdated:(CHChessClockTimeControlStageTableViewController*)viewController
{
    [self reloadRowWithStage:viewController.timeControlStage];
}

- (void)timeControlStageTableViewControllerStageDeleted:(CHChessClockTimeControlStageTableViewController*)viewController
{
    NSUInteger stageIndex = [self.settings.stageManager indexOfStage:viewController.timeControlStage];
    [self removeTimeStageAtIndex:stageIndex];
}

//------------------------------------------------------------------------------
#pragma mark - CHChessClockTimeViewControllerDelegate methods
//------------------------------------------------------------------------------
- (void)chessClockTimeViewController:(CHChessClockTimeViewController*)timeViewController
              closedWithSelectedTime:(NSUInteger)timeInSeconds
{
    self.stageToUpdate.maximumTime = timeInSeconds;
    [self reloadRowWithStage:self.stageToUpdate];
    self.stageToUpdate = nil;
}

@end
