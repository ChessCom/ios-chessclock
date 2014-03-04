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

//------------------------------------------------------------------------------
#pragma mark - Private methods declarations
//------------------------------------------------------------------------------
@interface CHChessClock() <CHTimePieceDelegate>

@property (weak, nonatomic) id<CHChessClockDelegate> delegate;
@property (retain, nonatomic) NSDictionary* timePiecesDictionary;
@property (retain, nonatomic) CHTimePiece* playerOneTimePiece;
@property (retain, nonatomic) CHTimePiece* playerTwoTimePiece;
@property (weak, nonatomic) CHTimePiece* activePiece;
@property (retain, nonatomic) NSTimer* timer;
@property (assign, nonatomic) NSTimeInterval interval;
@property (assign, nonatomic, readwrite) BOOL paused;
@property (assign, nonatomic) BOOL timeEnded;

@end

//------------------------------------------------------------------------------
#pragma mark - CHChessClock implementation
//------------------------------------------------------------------------------
@implementation CHChessClock

- (id)initWithSettings:(CHChessClockSettings*)settings
           andDelegate:(id<CHChessClockDelegate>)delegate
{
    self = [super init];
    if (self) {
        
        self.delegate = delegate;
        self.settings = settings;
        
        // We are assuming that each one of the players will have the same starting conditions. That's why
        // we use the same time control stage manager for both
        CHTimePiece* playerOneTimePiece = [[CHTimePiece alloc] initWithTimePieceId:1
                                                        andTimeControlStageManager:settings.stageManager];
        self.playerOneTimePiece = playerOneTimePiece;
        self.playerOneTimePiece.delegate = self;
        
        CHTimePiece* playerTwoTimePiece = [[CHTimePiece alloc] initWithTimePieceId:2
                                                        andTimeControlStageManager:settings.stageManager];
        
        self.playerTwoTimePiece = playerTwoTimePiece;
        self.playerTwoTimePiece.delegate = self;
        
        self.timePiecesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                     self.playerOneTimePiece, [NSNumber numberWithInt:self.playerOneTimePiece.timePieceId],
                                     self.playerTwoTimePiece, [NSNumber numberWithInt:self.playerTwoTimePiece.timePieceId], nil];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self
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
        CHTimePiece* touchedTimePiece = [self.timePiecesDictionary objectForKey:[NSNumber numberWithInt:timePieceId]];
    
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
                
                [touchedTimePiece stopWithIncrement:self.settings.increment];
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
    [self.activePiece startWithIncrement:self.settings.increment];
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

- (void)reset
{
    if (self.activePiece != nil) {
        self.paused = NO;
        self.activePiece = nil;
        self.timeEnded = NO;
    }
    
    // Reset all time pieces
    for (CHTimePiece* timePiece in self.timePiecesDictionary.allValues) {
        [timePiece reset];
    }
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
    [self.settings.increment updateWithDelta:delta andTimePiece:self.activePiece];
    
    return currentInterval;
}

- (void)setSettings:(CHChessClockSettings *)settings
{
    if (_settings != settings) {
        _settings = settings;
        
        for (CHTimePiece* currentTimePiece in [self.timePiecesDictionary allValues]) {
            currentTimePiece.stageManager = _settings.stageManager;
        }
    }
}

//------------------------------------------------------------------------------
#pragma mark - CHTimePieceDelegate methods
//------------------------------------------------------------------------------
- (void)timePieceAvailableTimeUpdated:(CHTimePiece*)timePiece
{
    [self.delegate chessClock:self availableTimeUpdatedForTimePiece:timePiece];
    
    if (timePiece.availableTime <= 0.0f &&
        timePiece.stageIndex == [self.settings.stageManager stageCount])
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
