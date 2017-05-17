//
//  CHChessClockTimeUpdateViewController.m
//  ChessClock
//
//  Created by Pedro Mancheno on 2017-05-03.
//  Copyright © 2017 Chess.com. All rights reserved.
//

#import "CHChessClockTimeUpdateViewController.h"

#import "CHChessClockTimeViewController.h"
#import "CHChessClockTimeControlStage.h"
#import "CHUtil.h"

static const float CHShowTenthsTime = 10.0f;

@interface CHChessClockTimeUpdateViewController () <CHChessClockTimeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *playerOneTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *playerTwoTimeButton;

@property (weak, nonatomic) CHTimePiece *currentTimePiece;

@end

@implementation CHChessClockTimeUpdateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadViews];
}

- (void)reloadViews
{
    [self.playerOneTimeButton setTitle:[self formattedTimeForTimePiece:self.playerOneTimePiece] forState:UIControlStateNormal];
    [self.playerTwoTimeButton setTitle:[self formattedTimeForTimePiece:self.playerTwoTimePiece] forState:UIControlStateNormal];
}

- (NSString *)formattedTimeForTimePiece:(CHTimePiece *)timePiece
{
    BOOL showTenths = timePiece.availableTime < CHShowTenthsTime;
    return [CHUtil formatTime:timePiece.availableTime showTenths:showTenths];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)mainViewWasPressed:(id)sender
{
    [self.delegate timeUpdateViewControllerShouldDismiss:self];
}

- (IBAction)playerOneButtonWasPressed:(id)sender
{
    [self presentTimeViewControllerWithTimeControlStage:self.playerOneTimePiece];
    self.currentTimePiece = self.playerOneTimePiece;
}

- (IBAction)playerTwoButtonWasPressed:(id)sender
{
    [self presentTimeViewControllerWithTimeControlStage:self.playerTwoTimePiece];
    self.currentTimePiece = self.playerTwoTimePiece;
}

- (void)presentTimeViewControllerWithTimeControlStage:(CHTimePiece *)timePiece
{
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

- (void)chessClockTimeViewController:(CHChessClockTimeViewController*)timeViewController
              closedWithSelectedTime:(NSUInteger)timeInSeconds
{
    self.currentTimePiece.updateAvailableTime = YES;
    [self.currentTimePiece updateWithDelta:self.currentTimePiece.availableTime - timeInSeconds];
}


@end
