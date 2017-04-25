//
//  CHChessClock.m
//  Chess.com
//
//  Created by Pedro Bolaños on 10/22/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import "CHChessClock.h"
#import "CHTimePiece.h"
#import "CHChessClockSettings.h"
#import "CHChessClockIncrement.h"
#import "CHChessClockTimeControlStageManager.h"
#import "CHChessClockTimeControl.h"

static const NSInteger CHChessClockFirstTimePieceID = 1;
static const NSInteger CHChessClockSecondTimePieceID = 2;

//------------------------------------------------------------------------------
#pragma mark - Private methods declarations
//------------------------------------------------------------------------------
@interface CHChessClock() <CHTimePieceDelegate>

@property (weak, nonatomic) id<CHChessClockDelegate> delegate;
@property (strong, nonatomic) CHTimePiece* playerOneTimePiece;
@property (strong, nonatomic) CHTimePiece* playerTwoTimePiece;
@property (weak, nonatomic) CHTimePiece* activePiece;
@property (strong, nonatomic) NSTimer* timer;
@property (assign, nonatomic) NSTimeInterval interval;
@property (assign, nonatomic, readwrite) BOOL paused;
@property (assign, nonatomic) BOOL timeEnded;

@end

//------------------------------------------------------------------------------
#pragma mark - CHChessClock implementation
//------------------------------------------------------------------------------
@implementation CHChessClock

- (instancetype)initWithTimeControl:(CHChessClockTimeControl *)timeControl
                           delegate:(id<CHChessClockDelegate>)delegate
{
    if (self = [super init]) {
        _delegate = delegate;
        _playerOneTimePiece = [[CHTimePiece alloc] initWithTimePieceId:CHChessClockFirstTimePieceID
                                                              settings:timeControl.playerOneSettings];
        _playerTwoTimePiece = [[CHTimePiece alloc] initWithTimePieceId:CHChessClockSecondTimePieceID
                                                              settings:timeControl.playerTwoSettings];
        
        _playerOneTimePiece.delegate = self;
        _playerTwoTimePiece.delegate = self;
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self
                                                selector:@selector(updateTime)
                                                userInfo:nil repeats:YES];
    }
    
    return self;
}

- (void)cleanup
{
    // NOTE: This is here and not in dealloc, since the timer causes the instance
    // to not get released. Once we invalidate the timer, the instance gets released
    [self.timer invalidate];
    self.timer = nil;
}

- (void)touchedTimePieceWithId:(NSUInteger)timePieceId
{
    if (!self.paused) {
        CHTimePiece* touchedTimePiece =
        timePieceId == CHChessClockFirstTimePieceID ?
        self.playerOneTimePiece : self.playerTwoTimePiece;
    
        if (self.activePiece == nil) {
            [self activateOtherTimePiece:touchedTimePiece];
        }
        else {
            if (touchedTimePiece == self.activePiece) {
                // Make sure that we are not giving "extra" time to the piece
                // that's being stopped. This MUST be done before stopping the
                // piece, since when the time piece gets stopped, various
                // calculations that depend on the available time are made
                [self updateChessClock];
                
                [touchedTimePiece stop];
                [self activateOtherTimePiece:touchedTimePiece];
            }
        }
    }
}

- (void)activateOtherTimePiece:(CHTimePiece*)timePiece
{
    if (timePiece.timePieceId == self.playerOneTimePiece.timePieceId) {
        self.activePiece = self.playerTwoTimePiece;
    }
    else {
        self.activePiece = self.playerOneTimePiece;
    }
    
    self.interval = [[NSDate date] timeIntervalSince1970];
    [self.activePiece start];
}

- (void)togglePause
{
    if (self.activePiece != nil) {
        self.paused = !self.paused;
        
        if (self.paused) {
            // Make sure that we are not giving "extra" time to the active piece
            [self updateChessClock];
        }
        else {
            self.interval = [[NSDate date] timeIntervalSince1970];
        }
    }
}

- (void)resetWithTimeControl:(CHChessClockTimeControl *)timeControl
{
    if (self.activePiece != nil) {
        self.paused = NO;
        self.activePiece = nil;
        self.timeEnded = NO;
    }
    
    // Reset all time pieces
    [self.playerOneTimePiece resetWithSettings:timeControl.playerOneSettings];
    [self.playerTwoTimePiece resetWithSettings:timeControl.playerTwoSettings];
}

- (BOOL)isActive
{
    return self.activePiece != nil || self.timeEnded;
}

//------------------------------------------------------------------------------
#pragma mark - Private methods definitions
//------------------------------------------------------------------------------
- (void)updateTime
{
    if (!self.paused && self.activePiece) {
        NSTimeInterval currentInterval = [self updateChessClock];
        self.interval = currentInterval;
    }
}

- (NSTimeInterval)updateChessClock
{
    NSTimeInterval currentInterval = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval delta = currentInterval - self.interval;
    [self.activePiece updateWithDelta:delta];
    
    return currentInterval;
}

//------------------------------------------------------------------------------
#pragma mark - CHTimePieceDelegate methods
//------------------------------------------------------------------------------
- (void)timePieceAvailableTimeUpdated:(CHTimePiece*)timePiece
{
    [self.delegate chessClock:self availableTimeUpdatedForTimePiece:timePiece];
    
    if (timePiece.availableTime <= 0.0f &&
        timePiece.stageIndex == [timePiece.settings.stageManager stageCount])
    {
        self.activePiece = nil;
        self.timeEnded = YES;
        [self.delegate chessClockTimeEnded:self withLastActiveTimePiece:timePiece];
    }
}

- (void)timePieceMovesCountUpdated:(CHTimePiece*)timePiece
{
    [self.delegate chessClock:self movesCountUpdatedForTimePiece:timePiece];
}

- (void)timePieceUpdatedStage:(CHTimePiece*)timePiece
{
    [self.delegate chessClock:self stageUpdatedForTimePiece:timePiece];
}

@end
