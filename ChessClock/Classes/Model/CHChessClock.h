//
//  CHChessClock.h
//  Chess.com
//
//  Created by Pedro Bolaños on 10/22/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CHChessClock;
@class CHTimePiece;
@class CHChessClockSettings;

//------------------------------------------------------------------------------
#pragma mark - CHEChessClockDelegate protocol
//------------------------------------------------------------------------------
@protocol CHChessClockDelegate <NSObject>

- (void)chessClock:(CHChessClock*)chessClock availableTimeUpdatedForTimePiece:(CHTimePiece*)timePiece;
- (void)chessClock:(CHChessClock*)chessClock movesCountUpdatedForTimePiece:(CHTimePiece*)timePiece;
- (void)chessClock:(CHChessClock*)chessClock stageUpdatedForTimePiece:(CHTimePiece*)timePiece;
- (void)chessClockTimeEnded:(CHChessClock*)chessClock withLastActiveTimePiece:(CHTimePiece*)timePiece;

@end

//------------------------------------------------------------------------------
#pragma mark - CHChessClock
//------------------------------------------------------------------------------
@interface CHChessClock : NSObject

@property (assign, nonatomic, readonly) BOOL paused;

- (instancetype)initWithPlayerOneSettings:(CHChessClockSettings *)playerOneSettings
                        playerTwoSettings:(CHChessClockSettings *)playerTwoSettings
                              andDelegate:(id<CHChessClockDelegate>)delegate;
- (void)cleanup;
- (void)touchedTimePieceWithId:(NSUInteger)timePieceId;
- (void)togglePause;
- (void)resetWithPlayerOneSettings:(CHChessClockSettings *)playerOneSettings
                 playerTwoSettings:(CHChessClockSettings *)playerTwoSettings;
- (BOOL)isActive;

@end
