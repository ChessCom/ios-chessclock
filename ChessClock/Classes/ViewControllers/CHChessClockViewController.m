//
//  CHChessClockViewController.m
//  Chess.com
//
//  Created by Pedro Bolaños on 10/22/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import "CHChessClockViewController.h"
#import "CHChessClock.h"
#import "CHChessClockSettings.h"
#import "CHChessClockTimeControlStageManager.h"
#import "CHChessClockSettingsTableViewController.h"
#import "CHChessClockSettingsManager.h"
#import "CHTimePiece.h"
#import "CHTimePieceView.h"
#import "CHChessClockTimeControl.h"

#import "CHUtil.h"
#import "CHSoundPlayer.h"

#import "CHChessClockTimeViewController.h"

//------------------------------------------------------------------------------
#pragma mark - Private methods declarations
//------------------------------------------------------------------------------
@interface CHChessClockViewController()
<CHChessClockDelegate,
UIActionSheetDelegate,
CHChessClockSettingsTableViewControllerDelegate,
CHChessClockTimeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet CHTimePieceView *playerOneTimePieceView;
@property (strong, nonatomic) IBOutlet CHTimePieceView *playerTwoTimePieceView;

@property (weak, nonatomic) IBOutlet UIButton* resetButton;
@property (weak, nonatomic) IBOutlet UIButton* pauseButton;
@property (weak, nonatomic) IBOutlet UIButton* settingsButton;

@property (strong, nonatomic) CHChessClock* chessClock;
@property (strong, nonatomic) CHChessClockSettingsManager* settingsManager;
@property (weak, nonatomic) CHTimePiece *currentTimePiece;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *timeUpdateButtons;

@end

//------------------------------------------------------------------------------
#pragma mark - CHChessClockViewController implementation
//------------------------------------------------------------------------------
@implementation CHChessClockViewController

static const float CHShowTenthsTime = 10.0f;

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self updateInterfaceWithTraitCollection:newCollection];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self disableIdleTimer:NO];
    [self.chessClock cleanup];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerToApplicationNotification:UIApplicationDidEnterBackgroundNotification];
    [self registerToApplicationNotification:UIApplicationWillResignActiveNotification];
    
    self.title = NSLocalizedString(@"Clock", nil);
    
    BOOL isiPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    CGFloat fontSize = isiPad ? 82.0f : 46.0f;
    UIFont *customFont = [UIFont fontWithName:@"ChessGlyph-Regular" size:fontSize];
    
    self.settingsButton.titleLabel.font = customFont;
    self.resetButton.titleLabel.font = customFont;
    self.pauseButton.titleLabel.font = customFont;
    
    // Set Clock
    self.chessClock = [[CHChessClock alloc] initWithTimeControl:self.settingsManager.timeControl
                                                       delegate:self];
    
    [self resetClock];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self updateInterfaceWithTraitCollection:self.traitCollection];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)updateInterfaceWithTraitCollection:(UITraitCollection *)traitCollection
{
    CGFloat angle = traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular ? M_PI : 0.0f;
    self.playerTwoTimePieceView.layer.affineTransform = CGAffineTransformMakeRotation(angle);
}

//------------------------------------------------------------------------------
#pragma mark - Lazy loading
//------------------------------------------------------------------------------

- (CHChessClockSettingsManager *)settingsManager
{
    if (!_settingsManager) {
        _settingsManager = [[CHChessClockSettingsManager alloc] init];
    }
    return _settingsManager;
}

//------------------------------------------------------------------------------
#pragma mark - Private methods definitions
//------------------------------------------------------------------------------
- (void)registerToApplicationNotification:(NSString*)notificationName
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationNotificationReceived)
                                                 name:notificationName
                                               object:nil];
}

- (void)applicationNotificationReceived
{
    // Just in case the notification is posted on a thread that's not the main one
    [self performSelectorOnMainThread:@selector(pauseClock) withObject:nil waitUntilDone:NO];
}

- (CHTimePieceView *)timePieceViewWithId:(NSUInteger)timePieceId
{
    return (CHTimePieceView *)[self.view viewWithTag:timePieceId];
}

- (void)resetTimeStageDots
{
    CHChessClockTimeControl *timeControl = self.settingsManager.timeControl;
    
    NSUInteger playerOneStageCount = timeControl.playerOneSettings.stageManager.stageCount;
    NSUInteger playerTwoStageCount = timeControl.playerTwoSettings.stageManager.stageCount;
    
    [self.playerOneTimePieceView setTimeControlStageDotCount:playerOneStageCount];
    [self.playerTwoTimePieceView setTimeControlStageDotCount:playerTwoStageCount];
}

- (void)pauseClock
{
    if (!self.chessClock.paused && !self.chessClock.timeEnded) {
        [self pauseTapped];
    }
}

- (void)resetClock
{
    self.pauseButton.hidden = NO;
    [self.chessClock resetWithTimeControl:self.settingsManager.timeControl];
    [self.playerOneTimePieceView unhighlightAndActivate:YES];
    [self.playerTwoTimePieceView unhighlightAndActivate:YES];
}

- (void)disableIdleTimer:(BOOL)disable
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:disable];
}

//------------------------------------------------------------------------------
#pragma mark - IBAction methods
//------------------------------------------------------------------------------
- (IBAction)timePieceTouched:(UIButton *)sender
{
    NSUInteger selectedTimePieceId = sender.superview.tag;
    
    if (!self.chessClock.paused) {
        if (![UIApplication sharedApplication].idleTimerDisabled) {
            [self disableIdleTimer:YES];
        }
        
        [self setPauseButtonEnabled:YES];
    
        CHTimePieceView *selectedTimePieceView = [self timePieceViewWithId:selectedTimePieceId];
        [selectedTimePieceView unhighlightAndActivate:NO];
    } else {
        [self.chessClock togglePause];
        [self disableIdleTimer:!self.chessClock.paused];
        [self setPauseButtonEnabled:YES];
    }
    
    [self.chessClock touchedTimePieceWithId:selectedTimePieceId];
    
    if (selectedTimePieceId == self.playerOneTimePieceView.tag) {
        [self.playerTwoTimePieceView highlight];
        [self.playerOneTimePieceView unhighlightAndActivate:NO];
        [CHSoundPlayer playSwitch1Sound];
    }
    else if (selectedTimePieceId == self.playerTwoTimePieceView.tag) {
        [self.playerOneTimePieceView highlight];
        [self.playerTwoTimePieceView unhighlightAndActivate:NO];
        [CHSoundPlayer playSwitch2Sound];
    }
}

- (IBAction)settingsTapped
{
    [self pauseClock];
 
    [self performSegueWithIdentifier:NSStringFromClass([CHChessClockSettingsTableViewController class]) sender:nil];
}

- (IBAction)resetTapped
{
    [self pauseClock];

    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                               destructiveButtonTitle:NSLocalizedString(@"Reset", nil)
                                                    otherButtonTitles:nil, nil];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        CGRect bounds = self.resetButton.bounds;
    
        [actionSheet showFromRect:bounds
                           inView:self.resetButton
                         animated:YES];
    }
    else {
        [actionSheet showInView:self.view];
    }
}

- (IBAction)pauseTapped
{
    if (self.chessClock.isActive) {
        [self.chessClock togglePause];
        [self disableIdleTimer:!self.chessClock.paused];
        [self setPauseButtonEnabled:NO];
        
        // Unhighlight piece
        [self.playerOneTimePieceView unhighlightAndActivate:YES];
        [self.playerTwoTimePieceView unhighlightAndActivate:YES];
    }
}

- (IBAction)updatePlayerOneTimeButtonWasPressed:(id)sender
{
    [self presentTimeViewControllerWithTimeControlStage:self.chessClock.playerOneTimePiece];
}

- (IBAction)updatePlayerTwoTimeButtonWasPressed:(id)sender
{
    [self presentTimeViewControllerWithTimeControlStage:self.chessClock.playerTwoTimePiece];
}

- (void)presentTimeViewControllerWithTimeControlStage:(CHTimePiece *)timePiece
{
    self.currentTimePiece = timePiece;
    
    NSString* nibName = @"CHChessClockTimeView";
    CHChessClockTimeViewController* timeViewController = [[CHChessClockTimeViewController alloc]
                                                          initWithNibName:nibName bundle:nil];
    timeViewController.delegate = self;
    timeViewController.maximumHours = 11;
    timeViewController.maximumMinutes = 60;
    timeViewController.maximumSeconds = 60;
    timeViewController.selectedTime = timePiece.availableTime;
    timeViewController.title = NSLocalizedString(@"Time", nil);
    
    [self.navigationController pushViewController:timeViewController animated:YES];
}

#pragma mark - CHChessClockTimeViewController delegate

- (void)chessClockTimeViewController:(CHChessClockTimeViewController*)timeViewController
              closedWithSelectedTime:(NSUInteger)timeInSeconds
{
    self.currentTimePiece.updateAvailableTime = YES;
    [self.currentTimePiece updateWithDelta:self.currentTimePiece.availableTime - timeInSeconds];
}

- (void)setPauseButtonEnabled:(BOOL)enabled
{
    NSString *title = enabled ? @"K" : @"";
    [self.pauseButton setTitle:title forState:UIControlStateNormal];
    [self.pauseButton setTitle:title forState:UIControlStateHighlighted];
    self.pauseButton.userInteractionEnabled = enabled;
    
    [self.timeUpdateButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL * _Nonnull stop) {
        button.hidden = enabled;
    }];
}

#pragma mark - UIStoryboard Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[CHChessClockSettingsTableViewController class]]) {
        
        ((CHChessClockSettingsTableViewController * )segue.destinationViewController).settingsManager = self.settingsManager;
        ((CHChessClockSettingsTableViewController * )segue.destinationViewController).delegate = self;
    }
}

//------------------------------------------------------------------------------
#pragma mark - CHChessClockSettingsTableViewControllerDelegate methods
//------------------------------------------------------------------------------
- (void)settingsTableViewController:(CHChessClockSettingsTableViewController *)viewController
               didUpdateTimeControl:(CHChessClockTimeControl *)timeControl
{
    self.settingsManager.timeControl = timeControl;
}

- (void)settingsTableViewControllerDidStartClock:(CHChessClockSettingsTableViewController *)viewController
                                     byResetting:(BOOL)didReset
{
    if (didReset) {
        [self resetClock];
    }
}

//------------------------------------------------------------------------------
#pragma mark - CHChessClockDelegate methods
//------------------------------------------------------------------------------
- (void)chessClock:(CHChessClock*)chessClock availableTimeUpdatedForTimePiece:(CHTimePiece*)timePiece
{
    CHTimePieceView *timePieceView = [self timePieceViewWithId:timePiece.timePieceId];
    NSTimeInterval timePieceAvailableTime = timePiece.availableTime;
    BOOL showTenths = timePieceAvailableTime < CHShowTenthsTime;
    timePieceView.availableTimeLabel.text = [CHUtil formatTime:timePieceAvailableTime showTenths:showTenths];
}

- (void)chessClock:(CHChessClock*)chessClock movesCountUpdatedForTimePiece:(CHTimePiece*)timePiece
{
    CHTimePieceView *timePieceView = [self timePieceViewWithId:timePiece.timePieceId];

    NSString* movesText = NSLocalizedString(@"Moves", nil);
    movesText = [movesText stringByAppendingFormat:@": %ld", (long)timePiece.movesCount];
    timePieceView.movesCountLabel.text = movesText;
    timePieceView.movesCountLabel.hidden = [timePiece isInLastStage];
}

- (void)chessClock:(CHChessClock*)chessClock stageUpdatedForTimePiece:(CHTimePiece*)timePiece
{
    if (timePiece.stageIndex == 1) {
        [self resetTimeStageDots];
    }
    else {
        CHTimePieceView *timePieceView = [self timePieceViewWithId:[timePiece timePieceId]];
            [timePieceView updateTimeControlStage:timePiece.stageIndex];
    }
}

- (void)chessClockTimeEnded:(CHChessClock*)chessClock withLastActiveTimePiece:(CHTimePiece *)timePiece
{
    self.pauseButton.hidden = YES;
    
    if (self.playerOneTimePieceView.tag == timePiece.timePieceId) {
        [self.playerOneTimePieceView timeEnded];
    }
    else {
        [self.playerOneTimePieceView unhighlightAndActivate:NO];
    }
    
    if (self.playerTwoTimePieceView.tag == timePiece.timePieceId) {
        [self.playerTwoTimePieceView timeEnded];
    }
    else {
        [self.playerTwoTimePieceView unhighlightAndActivate:NO];
    }
    
    
    [CHSoundPlayer playEndSound];
    [self disableIdleTimer:NO];
}

//------------------------------------------------------------------------------
#pragma mark - UIActionSheetDelegate methods
//------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self resetClock];
    }
}

@end
