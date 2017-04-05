//
//  CHChessClockTimeControlTabBarController.h
//  ChessClock
//
//  Created by Pedro Mancheno on 2017-04-03.
//  Copyright © 2017 Chess.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CHChessClockSettingsManager;
@protocol CHChessClockTimeControlTableViewControllerDelegate;

@interface CHChessClockTimeControlTabBarController : UITabBarController

- (void)setSettingsManager:(CHChessClockSettingsManager *)settingsManager;
- (void)setTimeControlTableViewDelegate:(id<CHChessClockTimeControlTableViewControllerDelegate>)delegate;

@end
