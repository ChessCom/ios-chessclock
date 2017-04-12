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

- (void)timeControlTableViewController:(CHChessClockTimeControlTabBarController *)viewController
                 createdTimeControl:(CHChessClockSettings *)timeControl;

- (void)timeControlTableViewController:(CHChessClockTimeControlTabBarController *)viewController
                 updatedTimeControl:(CHChessClockSettings *)timeControl;


- (void)timeControlTableViewController:(CHChessClockTimeControlTableViewController *)viewController
                               setName:(NSString *)name;

@end

@protocol CHChessClockTimeControlTableViewControllerDataSource <NSObject>

//- (NSString *) timeControlName;
//- (void)setTimeControlName:(NSString *)timeControlName;

@property (strong, nonatomic) NSString *timeControlName;

@end

//------------------------------------------------------------------------------
#pragma mark - CHTimeControlTableViewController
//------------------------------------------------------------------------------
@interface CHChessClockTimeControlTableViewController : UITableViewController

@property (weak, nonatomic) id<CHChessClockTimeControlTableViewControllerDelegate> delegate;
@property (weak, nonatomic) id<CHChessClockTimeControlTableViewControllerDataSource> dataSource;
@property (strong, nonatomic) CHChessClockSettings* chessClockSettings;

- (void)save;

@end
