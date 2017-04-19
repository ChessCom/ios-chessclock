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
#import "CHChessClockTimeControl.h"

@interface CHChessClockTimeControlTabBarController ()
<CHChessClockTimeControlTableViewControllerDelegate,
CHChessClockTimeControlTableViewControllerDataSource>

@property (readonly, nonatomic) CHChessClockTimeControlTableViewController *playerOneTimeControlTableViewController;
@property (readonly, nonatomic) CHChessClockTimeControlTableViewController *playerTwoTimeControlTableViewController;

@end

@implementation CHChessClockTimeControlTabBarController
@synthesize timeControlName;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.playerOneTimeControlTableViewController.delegate = self;
    self.playerOneTimeControlTableViewController.dataSource = self;
    self.playerOneTimeControlTableViewController.title = NSLocalizedString(@"Player One", nil);
    
    
    self.playerTwoTimeControlTableViewController.delegate = self;
    self.playerTwoTimeControlTableViewController.dataSource = self;
    self.playerTwoTimeControlTableViewController.title = NSLocalizedString(@"Player Two", nil);
    
    self.title = NSLocalizedString(@"Time Controls", nil);
    
    UIBarButtonItem* rightBarButtonItem = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                           target:self action:@selector(saveButtonTapped)];
    
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.timeControlName = self.timeControl.name;
    
    if (self.timeControl) {
        self.playerOneTimeControlTableViewController.settings = self.timeControl.playerOneSettings;
        self.playerTwoTimeControlTableViewController.settings = self.timeControl.playerTwoSettings;
    } else {
        [self.playerOneTimeControlTableViewController createDefaultSettings];
        [self.playerTwoTimeControlTableViewController createDefaultSettings];
    }
}

- (IBAction)saveButtonTapped
{
    BOOL isNewTimeControl = NO;
    
    if (!self.timeControl) {
        self.timeControl = [[CHChessClockTimeControl alloc] init];
        isNewTimeControl = YES;
    }

    self.timeControl.name = timeControlName;
    self.timeControl.playerOneSettings = self.playerOneTimeControlTableViewController.settings;
    self.timeControl.playerTwoSettings = self.playerTwoTimeControlTableViewController.settings;
    
    if (isNewTimeControl) {
        [self.timeControlTabBarDelegate timeControlTabBarController:self createdTimeControl:self.timeControl];
    } else {
        [self.timeControlTabBarDelegate timeControlTabBarController:self updatedTimeControl:self.timeControl];
    }

    
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

- (void)timeControlTableViewController:(CHChessClockTimeControlTableViewController *)viewController
                               setName:(NSString *)name
{
    self.timeControlName = name;
    self.navigationItem.rightBarButtonItem.enabled = (name != nil);
}

@end
