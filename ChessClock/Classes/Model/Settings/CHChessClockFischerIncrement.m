//
//  CHChessClockFischerIncrement.m
//  Chess.com
//
//  Created by Pedro Bolaños on 10/24/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import "CHChessClockFischerIncrement.h"
#import "CHTimePiece.h"

@implementation CHChessClockFischerIncrement

- (void)timePieceStarted:(CHTimePiece*)timePiece
{
    timePiece.updateAvailableTime = YES;
}

- (void)timePieceStopped:(CHTimePiece*)timePiece
{
    [timePiece increaseAvailableTimeBy:self.incrementValue];
}

- (NSString*)description {

    return @"Fischer";
}

- (NSString*)incrementDescription
{
    return NSLocalizedString(@"Players receive a full increment at the end of each turn.", nil);
}

@end
