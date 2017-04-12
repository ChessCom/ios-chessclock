//
//  CHChessClockTimeControlTabBarController.h
//  ChessClock
//
//  Created by Pedro Mancheno on 2017-04-03.
//  Copyright © 2017 Chess.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CHChessClockSettingsManager;
@class CHChessClockTimeControlTabBarController;

@protocol CHCHessClockTimeControlTabBarControllerDelegate <NSObject>

- (void)timeControlTabBarController:(CHChessClockTimeControlTabBarController *)viewController
              createdTimeControl:(CHChessClockSettings *)timeControl;

- (void)timeControlTabBarController:(CHChessClockTimeControlTabBarController *)viewController
                 updatedTimeControl:(CHChessClockSettings *)timeControl;

@end

@interface CHChessClockTimeControlTabBarController : UITabBarController

@property(weak, nonatomic) id<CHCHessClockTimeControlTabBarControllerDelegate> timeControlTabBarDelegate;


@end
