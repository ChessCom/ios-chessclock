//
//  CHChessClockSettingsTableViewController.m
//  Chess.com
//
//  Created by Pedro Bolaños on 10/24/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import "CHChessClockSettingsTableViewController.h"
#import "CHChessClockViewController.h"
#import "CHChessClockTimeControlTableViewController.h"
#import "CHChessClockTimeControlTabBarController.h"

#import "CHTableViewCell.h"

#import "CHChessClockTimeControl.h"
#import "CHChessClockSettingsManager.h"
#import "CHChessClockSettings.h"

#import "CHUtil.h"
#import "CHAppDelegate.h"
#import "UIColor+ChessClock.h"

//------------------------------------------------------------------------------
#pragma mark - Private methods declarations
//------------------------------------------------------------------------------
@interface CHChessClockSettingsTableViewController()
<CHCHessClockTimeControlTabBarControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIViewController* currentViewController;
@property (weak, nonatomic) IBOutlet UIButton *startClockButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) CHChessClockTimeControl* timeControlUponAppearance;
@property (strong, nonnull) CHChessClockTimeControl *selectedTimeControl;

@end

//------------------------------------------------------------------------------
#pragma mark - CHChessClockSettingsTableViewController implementation
//------------------------------------------------------------------------------
@implementation CHChessClockSettingsTableViewController

static const NSUInteger CHAddNewTimeControlSection = 0;
static const NSUInteger CHExistingTimeControlSection = 1;
static const NSUInteger CHVersionSection = 2;

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    CHChessClockSettingsManager* settingsManager = [[CHChessClockSettingsManager alloc] init];
    self.settingsManager = settingsManager;
    self.timeControlUponAppearance = self.settingsManager.timeControl;
    
    self.title = NSLocalizedString(@"Settings", nil);
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.startClockButton setTitle:NSLocalizedString(@"Start", nil)
                           forState:UIControlStateNormal];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if ([self.tableView isEditing]) {
        // If the tableView is already in edit mode, turn it off. Also change the title of the button to reflect the intended verb (‘Edit’, in this case).
        [self.tableView setEditing:NO animated:YES];
        self.navigationItem.rightBarButtonItem.title = @"Edit";
    }
    else {
        self.navigationItem.rightBarButtonItem.title = @"Done";
        [self.tableView setEditing:YES animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.currentViewController = nil;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    NSIndexPath* selectedIndexPath = self.tableView.indexPathForSelectedRow;
    if (selectedIndexPath != nil)
    {
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if(self.currentViewController == nil) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    [super viewWillDisappear:animated];
    [self saveSettings];
}

//------------------------------------------------------------------------------
#pragma mark - Private methods definitions
//------------------------------------------------------------------------------
- (void)updateClockTimeControl:(CHChessClockTimeControl *)timeControl
{
    self.settingsManager.timeControl = timeControl;

    [self.delegate settingsTableViewController:self didUpdateTimeControl:timeControl];
}

- (void)saveSettings
{
    // TODO: The settings should only be saved when there are modifications!
    [self.settingsManager saveTimeControls];
}

- (void)selectCell:(UITableViewCell*)cell
{
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

- (UITableViewCell*)cellWithIdentifier:(NSString*)identifier
{
    CHTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[CHTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    [cell setupStyle];
    
    return cell;
}

- (void)populateNewTimeControlCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath*)indexPath
{
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.textLabel.textAlignment = NSTextAlignmentNatural;
    cell.textLabel.text = NSLocalizedString(@"New Time Control", nil);
}

- (void)populateExistingTimeControlCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath*)indexPath
{
    CHChessClockTimeControl* timeControl = [[self.settingsManager allTimeControls] objectAtIndex:indexPath.row];
    cell.textLabel.text = timeControl.name;
    cell.textLabel.textAlignment = NSTextAlignmentNatural;
    cell.accessoryType = timeControl == self.settingsManager.timeControl ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
}

- (void)populateVersionCell:(UITableViewCell*)cell
{
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString* shortVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString* versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    cell.textLabel.text = [NSString stringWithFormat:@"v%@ (%@)", shortVersionString, versionString];
}

- (void)existingTimeControlSelectedAtIndexPath:(NSIndexPath*)indexPath inTableView:(UITableView*)tableView
{
    CHChessClockTimeControl* selectedTimeControl = [[self.settingsManager allTimeControls] objectAtIndex:indexPath.row];
    
    if ([tableView isEditing]) {
        [self timeControlSelected:selectedTimeControl];
    }
    else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        CHChessClockTimeControl* lastSelectedTimeControl = self.settingsManager.timeControl;
        
        if (selectedTimeControl != lastSelectedTimeControl) {
            
            // Remove the check mark from the last selected cell
            NSUInteger lastSelectedIndex = [[self.settingsManager allTimeControls] indexOfObject:lastSelectedTimeControl];
            UITableViewCell* lastSelectedCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastSelectedIndex
                                                                                                    inSection:CHExistingTimeControlSection]];
            lastSelectedCell.accessoryType = UITableViewCellAccessoryNone;
            
            // Add checkmark to the newly selected cell
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
            [self selectCell:cell];
            
            [self updateClockTimeControl:selectedTimeControl];
        }
    }
}

- (void)timeControlSelected:(CHChessClockTimeControl *)selectedTimeControl
{
    self.selectedTimeControl = selectedTimeControl;
    NSString *segueIdentifier = NSStringFromClass([CHChessClockTimeControlTabBarController class]);
    [self performSegueWithIdentifier:segueIdentifier sender:nil];
}

- (void)startClockAndReset:(BOOL)reset
{
    [self.delegate settingsTableViewControllerDidStartClock:self byResetting:reset];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIStoryboard Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[CHChessClockTimeControlTabBarController class]]) {
        CHChessClockTimeControlTabBarController *tabBarController = (CHChessClockTimeControlTabBarController *)segue.destinationViewController;
        tabBarController.timeControlTabBarDelegate = self;
        tabBarController.timeControl = self.tableView.isEditing ? self.selectedTimeControl : nil;
        self.currentViewController = tabBarController;
    }
}

//------------------------------------------------------------------------------
#pragma mark - UITableViewDataSource methods
//------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == CHAddNewTimeControlSection ||
        section == CHVersionSection)
    {
        return 1;
    }
    
    return [[self.settingsManager allTimeControls] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    
    switch (indexPath.section) {
        case CHAddNewTimeControlSection:
            cell = [self cellWithIdentifier:@"CHAddNewTimeControlCell"];
            [self populateNewTimeControlCell:cell withIndexPath:indexPath];
            break;
            
        case CHExistingTimeControlSection:
            cell = [self cellWithIdentifier:@"CHExistingTimeControlCell"];
            [self populateExistingTimeControlCell:cell withIndexPath:indexPath];
            break;
            
        case CHVersionSection:
            cell = [self cellWithIdentifier:@"CHVersionCell"];
            [self populateVersionCell:cell];
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == CHExistingTimeControlSection;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == CHExistingTimeControlSection;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [self.settingsManager moveTimeControlFrom:sourceIndexPath.row to:destinationIndexPath.row];
}

//------------------------------------------------------------------------------
#pragma mark - UITableViewDelegate methods
//------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case CHAddNewTimeControlSection:
            [self timeControlSelected:nil];
            break;
            
        case CHExistingTimeControlSection:
            [self existingTimeControlSelectedAtIndexPath:indexPath inTableView:tableView];
            break;
                    
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([[self.settingsManager allTimeControls] count] > 1) {
            NSUInteger selectedSettingIndex = [[self.settingsManager allTimeControls] indexOfObject:self.settingsManager.timeControl];
            NSUInteger settingToDeleteIndex = indexPath.row;
        
            [self.settingsManager removeTimeControlAtIndex:settingToDeleteIndex];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
            // If the deleted time contol is the one currently selected,
            // select the first time control from the list automatically
            if (selectedSettingIndex == settingToDeleteIndex) {
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:CHExistingTimeControlSection];
                [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            
                [self updateClockTimeControl:[[self.settingsManager allTimeControls] objectAtIndex:0]];
            
                UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
                [self selectCell:cell];
            }
        }
        else {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Can't delete!", nil)
                                                            message:NSLocalizedString(@"There must be at least one time control.", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

//------------------------------------------------------------------------------
#pragma mark - CHCHessClockTimeControlTabBarControllerDelegate
//------------------------------------------------------------------------------
- (void)timeControlTabBarController:(CHChessClockTimeControlTabBarController *)viewController
                 createdTimeControl:(CHChessClockTimeControl *)timeControl
{
    [self.settingsManager addTimeControl:timeControl];
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0
                                                inSection:CHExistingTimeControlSection];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)timeControlTabBarController:(CHChessClockTimeControlTabBarController *)viewController
                 updatedTimeControl:(CHChessClockTimeControl *)timeControl
{
    if (self.settingsManager.timeControl == timeControl) {
        // So that the clock has the correct state in the case in which the user edits a time control,
        // and immediately after that, tapped the Start button
        [self.delegate settingsTableViewController:self
                              didUpdateTimeControl:timeControl];
        
        // This means the player returned from the time control screen (possibly editing the time control),
        // so in this case we want to reset the clock as soon as the Start button is tapped
        self.timeControlUponAppearance = nil;
    }
    
    NSUInteger savedTimeControlIndex = [[self.settingsManager allTimeControls] indexOfObject:timeControl];
    if (savedTimeControlIndex != NSNotFound) {
        NSIndexPath* savedSetttingIndexPath = [NSIndexPath indexPathForRow:savedTimeControlIndex inSection:CHExistingTimeControlSection];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:savedSetttingIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

//------------------------------------------------------------------------------
#pragma mark - IBAction methods
//------------------------------------------------------------------------------
- (IBAction)startClockTapped
{
    if (self.timeControlUponAppearance == self.settingsManager.timeControl)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Reset Clock?", nil)
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Yes", nil)
                                              otherButtonTitles:NSLocalizedString(@"No", nil), nil];
        [alert show];
    }
    else
    {
        [self startClockAndReset:YES];
    }
}

- (IBAction)didTouchUpInsideChessLogoButton:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/app/chess-play-learn/id329218549?mt=8"];
    
    [[UIApplication sharedApplication] openURL:url];
}

//------------------------------------------------------------------------------
#pragma mark - UIAlertViewDelegate methods
//------------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self startClockAndReset:buttonIndex == alertView.cancelButtonIndex];
}

@end
