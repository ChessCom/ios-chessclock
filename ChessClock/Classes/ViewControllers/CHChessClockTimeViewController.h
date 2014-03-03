//
//  CHChessClockTimeViewController.h
//  Chess.com
//
//  Created by Pedro Bolaños on 11/1/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CHChessClockTimeViewController;

//------------------------------------------------------------------------------
#pragma mark - CHChessClockTimeViewControllerDelegate
//------------------------------------------------------------------------------
@protocol CHChessClockTimeViewControllerDelegate <NSObject>

- (void)chessClockTimeViewController:(CHChessClockTimeViewController*)timeViewController
              closedWithSelectedTime:(NSUInteger)timeInSeconds;

@end

//------------------------------------------------------------------------------
#pragma mark - CHChessClockTimeViewController
//------------------------------------------------------------------------------
@interface CHChessClockTimeViewController : UIViewController

@property (assign, nonatomic) id<CHChessClockTimeViewControllerDelegate> delegate;
@property (assign, nonatomic) NSUInteger maximumHours;
@property (assign, nonatomic) NSUInteger maximumMinutes;
@property (assign, nonatomic) NSUInteger maximumSeconds;
@property (assign, nonatomic) NSUInteger selectedTime;
@property (assign, nonatomic) BOOL zeroSelectionAllowed;

@end
