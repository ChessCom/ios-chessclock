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
@class CHChessClockTimeControl;

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
@property (assign, nonatomic, readonly) BOOL timeEnded;

@property (strong, nonatomic) CHTimePiece* playerOneTimePiece;
@property (strong, nonatomic) CHTimePiece* playerTwoTimePiece;

- (instancetype)initWithTimeControl:(CHChessClockTimeControl *)timeControl
                           delegate:(id<CHChessClockDelegate>)delegate;
- (void)cleanup;
- (void)touchedTimePieceWithId:(NSUInteger)timePieceId;
- (void)togglePause;
- (void)resetWithTimeControl:(CHChessClockTimeControl *)timeControl;
- (BOOL)isActive;

@end
