//
//  CHTimePiece.m
//  Chess.com
//
//  Created by Pedro Bolaños on 10/22/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import "CHTimePiece.h"
#import "CHChessClockIncrement.h"
#import "CHChessClockTimeControlStageManager.h"
#import "CHChessClockTimeControlStage.h"

//------------------------------------------------------------------------------
#pragma mark - Private methods declarations
//------------------------------------------------------------------------------
@interface CHTimePiece()

@property (assign, nonatomic, readwrite) NSUInteger stageIndex;
@property (assign, nonatomic, readwrite) NSTimeInterval availableTime;
@property (assign, nonatomic, readwrite) NSUInteger movesCount;

@end

//------------------------------------------------------------------------------
#pragma mark - CHTimePiece implementation
//------------------------------------------------------------------------------
@implementation CHTimePiece

- (id)initWithTimePieceId:(NSUInteger)timePieceId andTimeControlStageManager:(CHChessClockTimeControlStageManager*)stageManager
{
    self = [super init];
    if (self) {
        _timePieceId = timePieceId;
        self.stageManager = stageManager;
        self.stageIndex = 1;
        
        CHChessClockTimeControlStage* stage = [stageManager stageAtIndex:_stageIndex];
        self.availableTime = stage.maximumTime;
        self.movesCount = 0;
    }
    
    return self;
}

- (void)updateWithDelta:(NSTimeInterval)delta
{
    if (self.updateAvailableTime) {
        self.availableTime -= delta;
        if (self.availableTime < 0.0f) {
            self.availableTime = 0.0f;
            self.stageIndex++;
        }
    }
}

- (void)increaseAvailableTimeBy:(float)incrementValue
{
    self.availableTime += incrementValue;
}

- (void)startWithIncrement:(CHChessClockIncrement*)increment
{
    [increment timePieceStarted:self];
}

- (void)stopWithIncrement:(CHChessClockIncrement*)increment
{
    [increment timePieceStopped:self];
    
    CHChessClockTimeControlStage* stage = [self.stageManager stageAtIndex:self.stageIndex - 1];
    
    if (self.movesCount < stage.movesCount) {
        self.movesCount += 1;
        if (self.movesCount >= stage.movesCount) {
            self.stageIndex++;
        }
    }
}

- (void)reset
{
    self.stageIndex = 1;
}

- (BOOL)isInLastStage
{
    return self.stageIndex == [self.stageManager stageCount];
}

//------------------------------------------------------------------------------
#pragma mark - Private methods definitions
//------------------------------------------------------------------------------
- (void)setAvailableTime:(NSTimeInterval)availableTime
{
    _availableTime = availableTime;
    [self.delegate timePieceAvailableTimeUpdated:self];
}

- (void)setMovesCount:(NSUInteger)movesCount
{
    _movesCount = movesCount;
    [self.delegate timePieceMovesCountUpdated:self];
}

- (void)setStageIndex:(NSUInteger)stageIndex
{
    _stageIndex = stageIndex;
    [self.delegate timePieceUpdatedStage:self];
    [self updateStateAccordingToCurrentTimeStage];
}

- (void)setStageManager:(CHChessClockTimeControlStageManager *)stageManager
{
    if (_stageManager != stageManager) {
        _stageManager = stageManager;
        [self updateStateAccordingToCurrentTimeStage];
    }
}

- (void)updateStateAccordingToCurrentTimeStage
{
    // We substract one since the stages at the state manager are zero based
    NSUInteger nextStageIndex = self.stageIndex - 1;
    CHChessClockTimeControlStage* nextStage = [self.stageManager stageAtIndex:nextStageIndex];

    if (nextStageIndex == 0) {
        self.availableTime = nextStage.maximumTime;
    }
    else {
        self.availableTime += nextStage.maximumTime;
    }
    
    self.movesCount = 0;
}

@end
