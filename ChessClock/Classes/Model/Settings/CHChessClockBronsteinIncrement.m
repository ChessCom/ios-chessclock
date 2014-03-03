//
//  CHChessClockBronsteinIncrement.m
//  Chess.com
//
//  Created by Pedro Bolaños on 10/25/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import "CHChessClockBronsteinIncrement.h"
#import "CHTimePiece.h"

//------------------------------------------------------------------------------
#pragma mark - Private methods declarations
//------------------------------------------------------------------------------
@interface CHChessClockBronsteinIncrement()

@property (assign, nonatomic) NSTimeInterval accumulatedTime;

@end

//------------------------------------------------------------------------------
#pragma mark - CHChessClockBronsteinIncrement implementation
//------------------------------------------------------------------------------
@implementation CHChessClockBronsteinIncrement

- (void)timePieceStarted:(CHTimePiece*)timePiece
{
    timePiece.updateAvailableTime = YES;
    self.accumulatedTime = 0;
}

- (void)updateWithDelta:(NSTimeInterval)delta andTimePiece:(CHTimePiece*)timePiece
{
    self.accumulatedTime += delta;
}

- (void)timePieceStopped:(CHTimePiece*)timePiece
{
    if (self.accumulatedTime > self.incrementValue) {
        [timePiece increaseAvailableTimeBy:self.incrementValue];
    }
    else {
        [timePiece increaseAvailableTimeBy:self.accumulatedTime];
    }
}

- (NSString*)description
{
    return @"Bronstein";
}

- (NSString*)incrementDescription
{
    return NSLocalizedString(@"Players receive the used portion of the increment at the end of each turn.", nil);
}

@end
