//
//  CHChessClockTimeControlStage.m
//  Chess.com
//
//  Created by Pedro Bolaños on 10/24/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import "CHChessClockTimeControlStage.h"
#import "CHUtil.h"

//------------------------------------------------------------------------------
#pragma mark CHChessClockTimeControlStage implementation
//------------------------------------------------------------------------------
@implementation CHChessClockTimeControlStage

static NSString* const CHMovesCountArchiveKey = @"movesCount";
static NSString* const CHMaximumTimeArchiveKey = @"maximumTime";

- (id)initWithMovesCount:(NSUInteger)movesCount
          andMaximumTime:(NSUInteger)maximumTimeInSeconds
{
    self = [super init];
    if (self) {
        _movesCount = movesCount;
        _maximumTime = maximumTimeInSeconds;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _movesCount = [aDecoder decodeIntegerForKey:CHMovesCountArchiveKey];
        _maximumTime = [aDecoder decodeIntegerForKey:CHMaximumTimeArchiveKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_movesCount forKey:CHMovesCountArchiveKey];
    [aCoder encodeInteger:_maximumTime forKey:CHMaximumTimeArchiveKey];
}

- (NSString*)description
{
    if (self.maximumTime != 0) {
        NSString* maximumTimeString = [CHUtil formatTime:self.maximumTime showTenths:NO];
        
        if (self.maximumTime < 60) {
            NSString* secondsString = NSLocalizedString(@"secs", @"Abbreviation for seconds");
            if (self.maximumTime == 1) {
                secondsString = NSLocalizedString(@"sec", @"Abbreviation for second");
            }
            
            maximumTimeString = [NSString stringWithFormat:@"%d %@", self.maximumTime, secondsString];
        }
        
        if (self.movesCount != 0) {
            NSString* movesString = NSLocalizedString(@"moves in", nil);
            if (self.movesCount == 1) {
                movesString = NSLocalizedString(@"move in", nil);
            }
            
            return [NSString stringWithFormat:@"%d %@ %@", self.movesCount, movesString, maximumTimeString];
        }
        else {
            return [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Game in", nil), maximumTimeString];
        }
    }
    
    return nil;
}

@end
