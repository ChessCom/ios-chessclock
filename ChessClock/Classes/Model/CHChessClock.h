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

// Note: We are assuming that both timepieces will share the same settings
@property (retain, nonatomic) CHChessClockSettings* settings;

@property (assign, nonatomic, readonly) BOOL paused;

- (id)initWithSettings:(CHChessClockSettings*)settings
           andDelegate:(id<CHChessClockDelegate>)delegate;

- (void)cleanup;
- (void)touchedTimePieceWithId:(NSUInteger)timePieceId;
- (void)togglePause;
- (void)reset;
- (BOOL)isActive;

@end
