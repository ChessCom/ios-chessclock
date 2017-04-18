//
//  CHChessClockTimeControlTabBarController.h
//  ChessClock
//
//  Created by Pedro Mancheno on 2017-04-03.
//  Copyright © 2017 Chess.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CHChessClockTimeControlTabBarController;
@class CHChessClockTimeControl;

@protocol CHCHessClockTimeControlTabBarControllerDelegate <NSObject>

- (void)timeControlTabBarController:(CHChessClockTimeControlTabBarController *)viewController
              createdTimeControl:(CHChessClockTimeControl *)timeControl;

- (void)timeControlTabBarController:(CHChessClockTimeControlTabBarController *)viewController
                 updatedTimeControl:(CHChessClockTimeControl *)timeControl;

@end

@interface CHChessClockTimeControlTabBarController : UITabBarController

@property (weak, nonatomic) id<CHCHessClockTimeControlTabBarControllerDelegate> timeControlTabBarDelegate;
@property (strong, nonatomic) CHChessClockTimeControl* timeControl;

@end
