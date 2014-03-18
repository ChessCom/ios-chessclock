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

#import "CHUtil.h"

//#import "ChessAppDelegate.h"

//------------------------------------------------------------------------------
#pragma mark - Private methods declarations
//------------------------------------------------------------------------------
@interface CHChessClockViewController()
<CHChessClockDelegate,
UIActionSheetDelegate,
CHChessClockSettingsTableViewControllerDelegate>

@property (retain, nonatomic) IBOutlet UIView *portraitView;
@property (retain, nonatomic) IBOutlet UIView *landscapeView;

@property (retain, nonatomic) IBOutletCollection(CHTimePieceView) NSArray *playerOneTimePieceViews;
@property (retain, nonatomic) IBOutletCollection(CHTimePieceView) NSArray *playerTwoTimePieceViews;

@property (retain, nonatomic) IBOutletCollection(UIButton) NSArray *pauseButtons;
@property (weak, nonatomic) IBOutlet UIButton *resetButtonPortrait;
@property (weak, nonatomic) IBOutlet UIButton *resetButtonLandscape;

@property (retain, nonatomic) CHChessClock* chessClock;

@property (retain, nonatomic) CHChessClockSettingsManager* settingsManager;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;

@end

//------------------------------------------------------------------------------
#pragma mark - CHChessClockViewController implementation
//------------------------------------------------------------------------------
@implementation CHChessClockViewController

static const float CHShowTenthsTime = 10.0f;

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
    self.resetButtonPortrait.titleLabel.font = customFont;
    
    for (UIButton* button in self.pauseButtons) {
        button.titleLabel.font = customFont;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    // Set Clock
    self.chessClock = [[CHChessClock alloc] initWithSettings:self.settingsManager.currentTimeControl
                                                          andDelegate:self];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    // Rotate the view according to the orientation selected by the user
    BOOL isLandscape = NO;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        isLandscape = [self.settingsManager isLandscape];
    }
    else {
        isLandscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
    }
    
    if (isLandscape) {
        self.view = self.landscapeView;
    }
    else {
        self.view = self.portraitView;
    }

    [self rotateTimePieces];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self rotateMainView];
    }
    
    [self resetClock];
}

- (void)resetInterfaceForLandscape
{
    self.view = self.landscapeView;
    [self rotateTimePieces];
}

- (void)resetInterfaceForPortrait
{
    self.view = self.portraitView;
    [self rotateTimePieces];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

//------------------------------------------------------------------------------
#pragma mark - Lazy loading
//------------------------------------------------------------------------------

- (CHChessClockSettingsManager *)settingsManager
{
    if (!_settingsManager) {
        _settingsManager = [[CHChessClockSettingsManager alloc] initWithUserName:@"settings"];
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

- (NSArray*)timePieceViewsWithId:(NSUInteger)timePieceId
{
    NSMutableArray* timePieceViews = [NSMutableArray array];
    
    UIView* portraitTimePieceView = [self.portraitView viewWithTag:timePieceId];
    UIView* landscapeTimePieceView = [self.landscapeView viewWithTag:timePieceId];
    
    if ([portraitTimePieceView isKindOfClass:[CHTimePieceView class]]) {
        [timePieceViews addObject:portraitTimePieceView];
    }

    if ([landscapeTimePieceView isKindOfClass:[CHTimePieceView class]]) {
        [timePieceViews addObject:landscapeTimePieceView];
    }
    
    return timePieceViews;
}

- (void)resetTimeStageDots
{
    NSUInteger stageCount = [self.chessClock.settings.stageManager stageCount];
    for (CHTimePieceView* timePieceView in self.playerOneTimePieceViews) {
        [timePieceView setTimeControlStageDotCount:stageCount];
    }
    
    for (CHTimePieceView* timePieceView in self.playerTwoTimePieceViews) {
        [timePieceView setTimeControlStageDotCount:stageCount];
    }
}

- (void)rotateTimePieces
{
    float playerOneRotation = 0.0f;
    float playerTwoRotation = M_PI;
    BOOL isLandscape = self.view == self.landscapeView;
    
    if (isLandscape)
    {
        playerOneRotation = playerTwoRotation = 0.0f;
    }
    
    for (CHTimePieceView* timePieceView in self.playerOneTimePieceViews) {
        timePieceView.transform = CGAffineTransformMakeRotation(playerOneRotation);
    }
    
    for (CHTimePieceView* timePieceView in self.playerTwoTimePieceViews) {
        timePieceView.transform = CGAffineTransformMakeRotation(playerTwoRotation);
    }
}

- (void)rotateMainView
{
    float mainViewRotation = 0.0f;
    if ([self.settingsManager isLandscape]) {
        mainViewRotation = M_PI_2;
    }
    
    self.view.transform = CGAffineTransformMakeRotation(mainViewRotation);
}

- (void)playSound:(NSString*)soundName
{
#warning Sound playing through AppDelegate
    //[m_pAppDelegate.m_pSoundsManager playSound:soundName];
}

- (void)pauseClock
{
    if (!self.chessClock.paused) {
        [self pauseTapped];
    }
}

- (void)resetClock
{
    [self.chessClock reset];
    for (CHTimePieceView* timePieceView in self.playerOneTimePieceViews) {
        [timePieceView unhighlightAndActivate:YES];
    }
    
    for (CHTimePieceView* timePieceView in self.playerTwoTimePieceViews) {
        [timePieceView unhighlightAndActivate:YES];
    }
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
    if (!self.chessClock.paused) {
        if (![UIApplication sharedApplication].idleTimerDisabled) {
            [self disableIdleTimer:YES];
        }
        
        [self setPauseButtonsEnabled:YES];
        
        NSUInteger selectedTimePieceId = sender.superview.tag;
        [self.chessClock touchedTimePieceWithId:selectedTimePieceId];
    
        NSArray* selectedTimePieceViews = [self timePieceViewsWithId:selectedTimePieceId];
        
        for (CHTimePieceView* selectedTimePieceView in selectedTimePieceViews) {
            [selectedTimePieceView unhighlightAndActivate:NO];
        }
    
        if (selectedTimePieceId == ((CHTimePieceView*)[self.playerOneTimePieceViews lastObject]).tag) {
            for (CHTimePieceView* timePieceView in self.playerTwoTimePieceViews) {
                [timePieceView highlight];
            }
#warning Sound playing through AppDelegate
            //[self playSound:SOUND_TIME_PIECE_PLAYER_1];
        }
        else if (selectedTimePieceId == ((CHTimePieceView*)[self.playerTwoTimePieceViews lastObject]).tag) {
            for (CHTimePieceView* timePieceView in self.playerOneTimePieceViews) {
                [timePieceView highlight];
            }
#warning Sound playing through AppDelegate
            //[self playSound:SOUND_TIME_PIECE_PLAYER_2];
        }
    } else {
        [self.chessClock togglePause];
        [self disableIdleTimer:!self.chessClock.paused];
        
       [self setPauseButtonsEnabled:YES];
    }
}

- (IBAction)settingsTapped
{
    [self pauseClock];
 
    NSString *nibName = [CHUtil nibNameWithBaseName:@"CHChessClockSettingsView"];
    CHChessClockSettingsTableViewController *settingsViewController =
    [[CHChessClockSettingsTableViewController alloc] initWithNibName:nibName
                                                              bundle:nil];
    settingsViewController.settingsManager = self.settingsManager;
    settingsViewController.delegate = self;
    [self.navigationController pushViewController:settingsViewController
                                         animated:YES];
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
        CGRect bounds = self.resetButtonPortrait.bounds;
        UIButton* resetButton = self.resetButtonPortrait;

        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            bounds = self.resetButtonLandscape.bounds;
            resetButton = self.resetButtonLandscape;
        }
    
        [actionSheet showFromRect:bounds inView:resetButton animated:YES];
    }
    else {
        [actionSheet showInView:self.view];
    }
}

- (IBAction)pauseTapped
{
    if ([self.chessClock isActive]) {
        [self.chessClock togglePause];
        [self disableIdleTimer:!self.chessClock.paused];
        
        [self setPauseButtonsEnabled:NO];
    }
}

- (void)setPauseButtonsEnabled:(BOOL)enabled
{
    for (UIButton* button in self.pauseButtons) {
        NSString *title = enabled ? @"K" : @"";
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateHighlighted];
        button.userInteractionEnabled = enabled;
    }
}

//------------------------------------------------------------------------------
#pragma mark - CHChessClockSettingsTableViewControllerDelegate methods
//------------------------------------------------------------------------------
- (void)settingsTableViewController:(id)settingsTableViewController
                  didUpdateSettings:(CHChessClockSettings *)settings
{
    self.settingsManager.currentTimeControl = settings;
}

- (void)settingsTableViewControllerDidStartClock:(id)settingsTableViewController
{
    [self resetClock];
}

//------------------------------------------------------------------------------
#pragma mark - CHChessClockDelegate methods
//------------------------------------------------------------------------------
- (void)chessClock:(CHChessClock*)chessClock availableTimeUpdatedForTimePiece:(CHTimePiece*)timePiece
{
    NSArray* timePieceViews = [self timePieceViewsWithId:timePiece.timePieceId];
    NSTimeInterval timePieceAvailableTime = timePiece.availableTime;
    BOOL showTenths = timePieceAvailableTime < CHShowTenthsTime;
    
    
    for (CHTimePieceView* timePieceView in timePieceViews) {
        timePieceView.availableTimeLabel.text = [CHUtil formatTime:timePieceAvailableTime showTenths:showTenths];
    }
}

- (void)chessClock:(CHChessClock*)chessClock movesCountUpdatedForTimePiece:(CHTimePiece*)timePiece
{
    NSArray* timePieceViews = [self timePieceViewsWithId:timePiece.timePieceId];

    NSString* movesText = NSLocalizedString(@"Moves", nil);
    movesText = [movesText stringByAppendingFormat:@": %ld", (long)timePiece.movesCount];
    
    for (CHTimePieceView* timePieceView in timePieceViews) {
        timePieceView.movesCountLabel.text = movesText;
    }
}

- (void)chessClock:(CHChessClock*)chessClock stageUpdatedForTimePiece:(CHTimePiece*)timePiece
{
    if (timePiece.stageIndex == 1) {
        [self resetTimeStageDots];
    }
    else {
        NSArray* timePieceViews = [self timePieceViewsWithId:[timePiece timePieceId]];
        for (CHTimePieceView* timePieceView in timePieceViews) {
            [timePieceView updateTimeControlStage:timePiece.stageIndex];
        }
    }
}

- (void)chessClockTimeEnded:(CHChessClock*)chessClock withLastActiveTimePiece:(CHTimePiece *)timePiece
{
    for (CHTimePieceView* timePieceView in self.playerOneTimePieceViews) {
        if (timePieceView.tag == timePiece.timePieceId) {
            [timePieceView timeEnded];
        }
        else {
            [timePieceView unhighlightAndActivate:NO];
        }
    }
    
    for (CHTimePieceView* timePieceView in self.playerTwoTimePieceViews) {
        if (timePieceView.tag == timePiece.timePieceId) {
            [timePieceView timeEnded];
        }
        else {
            [timePieceView unhighlightAndActivate:NO];
        }
    }

#warning Sounds play through App Delegate
    //[self playSound:SOUND_TIME_PIECE_TIME_ENDED];
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
