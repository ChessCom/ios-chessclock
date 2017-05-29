//
//  CHTimePiece.h
//  Chess.com
//
//  Created by Pedro Bolaños on 10/22/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CHTimePiece;
@class CHChessClockIncrement;
@class CHChessClockTimeControlStageManager;
@class CHChessClockSettings;

//------------------------------------------------------------------------------
#pragma mark - CHTimePieceDelegate
//------------------------------------------------------------------------------
@protocol CHTimePieceDelegate <NSObject>

- (void)timePieceAvailableTimeUpdated:(CHTimePiece*)timePiece;
- (void)timePieceMovesCountUpdated:(CHTimePiece*)timePiece;
- (void)timePieceUpdatedStage:(CHTimePiece*)timePiece;

@end

//------------------------------------------------------------------------------
#pragma mark - CHTimePiece
//------------------------------------------------------------------------------
@interface CHTimePiece : NSObject

@property (weak, nonatomic) id<CHTimePieceDelegate> delegate;
@property (assign, nonatomic) BOOL updateAvailableTime;
@property (strong, nonatomic) CHChessClockTimeControlStageManager* stageManager;

@property (assign, nonatomic, readonly) NSUInteger timePieceId;
@property (assign, nonatomic, readonly) NSUInteger stageIndex;
@property (assign, nonatomic, readonly) NSTimeInterval availableTime;
@property (assign, nonatomic, readonly) NSUInteger movesCount;

@property (nonatomic, readonly) CHChessClockSettings *settings;

- (id)initWithTimePieceId:(NSUInteger)timePieceId
                 settings:(CHChessClockSettings *)settings;

- (void)updateWithDelta:(NSTimeInterval)delta;
- (void)increaseAvailableTimeBy:(float)incrementValue;
- (void)start;
- (void)stop;
- (void)resetWithSettings:(CHChessClockSettings *)settings;
- (BOOL)isInLastStage;

@end
