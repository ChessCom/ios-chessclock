//
//  CHTimeControlTableViewController.h
//  Chess.com
//
//  Created by Pedro Bolaños on 10/25/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CHChessClockTimeControlTableViewController;
@class CHChessClockSettings;

//------------------------------------------------------------------------------
#pragma mark - CHChessClockTimeControlTableViewControllerDelegate
//------------------------------------------------------------------------------
@protocol CHChessClockTimeControlTableViewControllerDelegate <NSObject>

- (void)timeControlTableViewController:(CHChessClockTimeControlTableViewController*)viewController
                 newTimeControlCreated:(BOOL)newTimeControlCreated;

@end

//------------------------------------------------------------------------------
#pragma mark - CHTimeControlTableViewController
//------------------------------------------------------------------------------
@interface CHChessClockTimeControlTableViewController : UITableViewController

@property (weak, nonatomic) id<CHChessClockTimeControlTableViewControllerDelegate> delegate;
@property (retain, nonatomic) CHChessClockSettings* chessClockSettings;

@end
