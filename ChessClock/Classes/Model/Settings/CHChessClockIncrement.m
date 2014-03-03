//
//  CHChessClockIncrement.m
//  Chess.com
//
//  Created by Pedro Bolaños on 10/24/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import "CHChessClockIncrement.h"

//------------------------------------------------------------------------------
#pragma mark - Private methods declarations
//------------------------------------------------------------------------------
@interface CHChessClockIncrement() <NSCoding>
@end

//------------------------------------------------------------------------------
#pragma mark - CHChessClockIncrement implementation
//------------------------------------------------------------------------------
@implementation CHChessClockIncrement

static NSString* const CHIncrementValueArchiveKey = @"value";

- (id)initWithIncrementValue:(NSUInteger)incrementValue
{
    self = [super init];
    if (self) {
        _incrementValue = incrementValue;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _incrementValue = [aDecoder decodeIntegerForKey:CHIncrementValueArchiveKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_incrementValue forKey:CHIncrementValueArchiveKey];
}

- (void)timePieceStarted:(CHTimePiece*)timePiece
{
}

- (void)timePieceStopped:(CHTimePiece*)timePiece
{
}

- (void)updateWithDelta:(NSTimeInterval)delta andTimePiece:(CHTimePiece*)timePiece
{

}

- (NSString*)incrementDescription
{
    return nil;
}

@end
