//
//  CHChessClockSettingsTableViewController.h
//  Chess.com
//
//  Created by Pedro Bolaños on 10/24/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CHChessClockSettingsManager;
@class CHChessClockSettings;
@class CHChessClockSettingsTableViewController;
@class CHChessClockTimeControl;

@protocol CHChessClockSettingsTableViewControllerDelegate <NSObject>

- (void)settingsTableViewController:(CHChessClockSettingsTableViewController *)viewController
               didUpdateTimeControl:(CHChessClockTimeControl *)timeControl;

- (void)settingsTableViewControllerDidStartClock:(CHChessClockSettingsTableViewController *)viewController
                                     byResetting:(BOOL)didReset;

@end

//------------------------------------------------------------------------------
#pragma mark - CHChessClockSettingsTableViewController
//------------------------------------------------------------------------------
@interface CHChessClockSettingsTableViewController : UIViewController

@property (strong, nonatomic) CHChessClockSettingsManager* settingsManager;
@property (weak, nonatomic) id <CHChessClockSettingsTableViewControllerDelegate> delegate;


@end
