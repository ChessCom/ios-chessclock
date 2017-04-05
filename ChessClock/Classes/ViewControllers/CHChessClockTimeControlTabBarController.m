//
//  CHChessClockTimeControlTabBarController.m
//  ChessClock
//
//  Created by Pedro Mancheno on 2017-04-03.
//  Copyright © 2017 Chess.com. All rights reserved.
//

#import "CHChessClockTimeControlTabBarController.h"
#import "CHChessClockTimeControlTableViewController.h"
#import "CHChessClockSettingsManager.h"

@interface CHChessClockTimeControlTabBarController ()

@property (readonly, nonatomic) CHChessClockTimeControlTableViewController *playerOneTimeControlTableViewController;
@property (readonly, nonatomic) CHChessClockTimeControlTableViewController *playerTwoTimeControlTableViewController;

@end

@implementation CHChessClockTimeControlTabBarController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.playerOneTimeControlTableViewController.title = NSLocalizedString(@"Player One", nil);
    self.playerTwoTimeControlTableViewController.title = NSLocalizedString(@"Player Two", nil);
}

- (void)setTimeControlTableViewDelegate:(id<CHChessClockTimeControlTableViewControllerDelegate>)timeControlTableViewDelegate
{
    self.playerOneTimeControlTableViewController.delegate =
    self.playerTwoTimeControlTableViewController.delegate = timeControlTableViewDelegate;
}

- (void)setSettingsManager:(CHChessClockSettingsManager *)settingsManager
{
    self.playerOneTimeControlTableViewController.chessClockSettings = settingsManager.playerOneSettings;
    self.playerTwoTimeControlTableViewController.chessClockSettings = settingsManager.playerTwoSettings;
}

- (CHChessClockTimeControlTableViewController *)playerOneTimeControlTableViewController
{
    return self.viewControllers.firstObject;
}

- (CHChessClockTimeControlTableViewController *)playerTwoTimeControlTableViewController
{
    return self.viewControllers.lastObject;
}

@end
