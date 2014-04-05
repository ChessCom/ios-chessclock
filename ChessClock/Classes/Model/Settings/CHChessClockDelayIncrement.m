//
//  CHChessClockDelayIncrement.m
//  Chess.com
//
//  Created by Pedro Bolaños on 10/25/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import "CHChessClockDelayIncrement.h"
#import "CHTimePiece.h"

//------------------------------------------------------------------------------
#pragma mark - Private methods declarations
//------------------------------------------------------------------------------
@interface CHChessClockDelayIncrement()

@property (assign, nonatomic) NSTimeInterval accumulatedTime;

@end

//------------------------------------------------------------------------------
#pragma mark - CHChessClockDelayIncrement implementation
//------------------------------------------------------------------------------
@implementation CHChessClockDelayIncrement

- (void)timePieceStarted:(CHTimePiece*)timePiece
{
    timePiece.updateAvailableTime = NO;
    self.accumulatedTime = 0;
}

- (void)updateWithDelta:(NSTimeInterval)delta andTimePiece:(CHTimePiece*)timePiece
{
    if (!timePiece.updateAvailableTime) {
        self.accumulatedTime += delta;
    
        if (self.accumulatedTime >= self.incrementValue) {
            timePiece.updateAvailableTime = YES;
        }
    }
}

- (NSString*)description {
    
    return @"Delay";
}

- (NSString*)incrementDescription
{
    return NSLocalizedString(@"The player's clock starts after the delay period.", nil);
}

@end
