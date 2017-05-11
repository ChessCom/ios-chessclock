//
//  CHChessClockTimeUpdateViewController.h
//  ChessClock
//
//  Created by Pedro Mancheno on 2017-05-03.
//  Copyright © 2017 Chess.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CHTimePiece.h"

@class CHChessClockTimeUpdateViewController;

@protocol CHChessClockTimeUpdateViewControllerDelegate <NSObject>

- (void)timeUpdateViewControllerShouldDismiss:(CHChessClockTimeUpdateViewController *)viewController;

@end

@interface CHChessClockTimeUpdateViewController : UIViewController

@property (strong, nonatomic) CHTimePiece *playerOneTimePiece;
@property (strong, nonatomic) CHTimePiece *playerTwoTimePiece;
@property (weak, nonatomic) id<CHChessClockTimeUpdateViewControllerDelegate> delegate;

@end
