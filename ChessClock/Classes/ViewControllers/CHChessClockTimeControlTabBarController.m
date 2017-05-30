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
@property (assign, nonatomic) BOOL isNewTimeControl;
@property (assign, nonatomic) BOOL shouldDuplicateSettings;

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
    
    self.title = NSLocalizedString(@"Time Control", nil);
    
    UIBarButtonItem* rightBarButtonItem = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                           target:self action:@selector(saveButtonTapped)];
    
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    self.timeControlName = self.timeControl.name;
    
    if (self.timeControl) {
        self.playerOneTimeControlTableViewController.settings = self.timeControl.playerOneSettings;
        self.playerTwoTimeControlTableViewController.settings = self.timeControl.playerTwoSettings;
        self.shouldDuplicateSettings = self.timeControl.shouldDuplicateSettings;
    } else {
        self.timeControl = [[CHChessClockTimeControl alloc] init];
        self.isNewTimeControl = YES;
        [self.playerOneTimeControlTableViewController createDefaultSettings];
        [self.playerTwoTimeControlTableViewController createDefaultSettings];
        self.shouldDuplicateSettings = YES;
    }
    
    self.tabBar.tintColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateRightBarButtonItem];
}

- (IBAction)saveButtonTapped
{
    self.timeControl.name = timeControlName;
    self.timeControl.playerOneSettings = self.playerOneTimeControlTableViewController.settings;
    self.timeControl.playerTwoSettings = self.playerTwoTimeControlTableViewController.settings;
    self.timeControl.shouldDuplicateSettings = self.shouldDuplicateSettings;
    
    if (self.isNewTimeControl) {
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
    [self updateRightBarButtonItem];
}

- (void)timeControlTableViewController:(CHChessClockTimeControlTableViewController *)viewController didUpdateShouldDuplicateSettings:(BOOL)shouldDuplicate
{
    self.shouldDuplicateSettings = shouldDuplicate;
}

- (BOOL)timeControlTableViewcontrollerShouldDuplicateSettings:(CHChessClockTimeControlTableViewController *)viewController
{
    return viewController == self.playerOneTimeControlTableViewController ? NO : self.shouldDuplicateSettings;
}

- (void)updateRightBarButtonItem
{
    self.navigationItem.rightBarButtonItem.enabled = (self.timeControlName.length > 0);
}

@end
