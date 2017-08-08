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
#import "CHChessClockSettings.h"

//------------------------------------------------------------------------------
#pragma mark - Private methods declarations
//------------------------------------------------------------------------------
@interface CHTimePiece()

@property (assign, nonatomic, readwrite) NSUInteger stageIndex;
@property (assign, nonatomic, readwrite) NSTimeInterval availableTime;
@property (assign, nonatomic, readwrite) NSUInteger movesCount;
@property (strong, nonatomic) CHChessClockSettings *settings;
@property (assign, nonatomic) NSUInteger timePieceId;

@end

//------------------------------------------------------------------------------
#pragma mark - CHTimePiece implementation
//------------------------------------------------------------------------------
@implementation CHTimePiece

- (id)initWithTimePieceId:(NSUInteger)timePieceId
                 settings:(CHChessClockSettings *)settings
{
    if (self = [super init]) {
        _settings = settings;
        _timePieceId = timePieceId;
        [self reset];
    }
    
    return self;
}

- (void)updateWithDelta:(NSTimeInterval)delta
{
    if (self.updateAvailableTime) {
        self.availableTime -= delta;
        if (self.availableTime < 0.0f) {
            self.availableTime = 0.0f;
        }
    }
    
    [self.settings.increment updateWithDelta:delta andTimePiece:self];
}

- (void)increaseAvailableTimeBy:(float)incrementValue
{
    self.availableTime += incrementValue;
}

- (void)start
{
    CHChessClockIncrement *increment = self.settings.increment;
    [self startWithIncrement:increment];
}

- (void)startWithIncrement:(CHChessClockIncrement*)increment
{
    [increment timePieceStarted:self];
}

- (void)stop
{
    CHChessClockIncrement *increment = self.settings.increment;
    [self stopWithIncrement:increment];
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

- (void)resetWithSettings:(CHChessClockSettings *)settings
{
    self.settings = settings;
    [self reset];
}

- (void)reset
{
    self.stageManager = self.settings.stageManager;
    CHChessClockTimeControlStage* stage = [self.stageManager stageAtIndex:_stageIndex];
    self.availableTime = stage.maximumTime;
    self.stageIndex = 1;
    self.movesCount = 0;
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
