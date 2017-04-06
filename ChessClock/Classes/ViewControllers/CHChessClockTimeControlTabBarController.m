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

@interface CHChessClockTimeControlTabBarController () <CHChessClockTimeControlTableViewControllerDelegate>

@property (readonly, nonatomic) CHChessClockTimeControlTableViewController *playerOneTimeControlTableViewController;
@property (readonly, nonatomic) CHChessClockTimeControlTableViewController *playerTwoTimeControlTableViewController;

@end

@implementation CHChessClockTimeControlTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.playerOneTimeControlTableViewController.delegate = self;
    self.playerTwoTimeControlTableViewController.delegate = self;
    
    if (!self.playerOneTimeControlTableViewController.chessClockSettings ||
        !self.playerTwoTimeControlTableViewController.chessClockSettings) {
        
        UIBarButtonItem* rightBarButtonItem = [[UIBarButtonItem alloc]
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                               target:self action:@selector(saveButtonTapped)];
        
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.playerOneTimeControlTableViewController.title = NSLocalizedString(@"Player One", nil);
    self.playerTwoTimeControlTableViewController.title = NSLocalizedString(@"Player Two", nil);
}

- (void)setSettingsManager:(CHChessClockSettingsManager *)settingsManager
{
    self.playerOneTimeControlTableViewController.chessClockSettings = settingsManager.playerOneSettings;
    self.playerTwoTimeControlTableViewController.chessClockSettings = settingsManager.playerTwoSettings;
}

- (IBAction)saveButtonTapped
{
    [self.playerOneTimeControlTableViewController save];
    [self.playerTwoTimeControlTableViewController save];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (CHChessClockTimeControlTableViewController *)playerOneTimeControlTableViewController
{
    return self.viewControllers.firstObject;
}

- (CHChessClockTimeControlTableViewController *)playerTwoTimeControlTableViewController
{
    return self.viewControllers.lastObject;
}

- (void)timeControlTableViewController:(CHChessClockTimeControlTableViewController*)viewController
                 newTimeControlCreated:(BOOL)newTimeControlCreated
{
   [self.timeControlTabBarDelegate timeControlTabBarViewController:self newTimeControlCreated:newTimeControlCreated];
}

- (void)timeControlTableViewController:(CHChessClockTimeControlTableViewController *)viewController setName:(NSString *)name
{
    if (name) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

@end
