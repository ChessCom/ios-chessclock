//
//  CHIncrementTableViewController.h
//  Chess.com
//
//  Created by Pedro Bolaños on 11/1/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CHChessClockIncrementTableViewController;
@class CHChessClockIncrement;

//------------------------------------------------------------------------------
#pragma mark - CHChessClockIncrementViewControllerDelegate
//------------------------------------------------------------------------------
@protocol CHChessClockIncrementTableViewControllerDelegate <NSObject>

- (void)chessClockIncrementTableViewControllerUpdatedIncrement:(CHChessClockIncrementTableViewController*)viewController;

@end

//------------------------------------------------------------------------------
#pragma mark - CHIncrementTableViewController
//------------------------------------------------------------------------------
@interface CHChessClockIncrementTableViewController : UITableViewController

@property (weak, nonatomic) id<CHChessClockIncrementTableViewControllerDelegate> delegate;
@property (strong, nonatomic) CHChessClockIncrement* increment;

@end
