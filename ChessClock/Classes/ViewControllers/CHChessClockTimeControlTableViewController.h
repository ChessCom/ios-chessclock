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

- (void)timeControlTableViewController:(CHChessClockTimeControlTableViewController *)viewController
                               setName:(NSString *)name;

@end

@protocol CHChessClockTimeControlTableViewControllerDataSource <NSObject>

@property (strong, nonatomic) NSString *timeControlName;

@end

//------------------------------------------------------------------------------
#pragma mark - CHTimeControlTableViewController
//------------------------------------------------------------------------------
@interface CHChessClockTimeControlTableViewController : UITableViewController

@property (weak, nonatomic) id<CHChessClockTimeControlTableViewControllerDelegate> delegate;
@property (weak, nonatomic) id<CHChessClockTimeControlTableViewControllerDataSource> dataSource;
@property (strong, nonatomic) CHChessClockSettings* settings;
@property (readonly, nonatomic) BOOL shouldDuplicatePlayerOne;

- (void)createDefaultSettings;

@end
