//
//  CHChessClockSetting.m
//  Chess.com
//
//  Created by Pedro Bolaños on 10/24/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import "CHChessClockSettings.h"
#import "CHChessClockIncrement.h"

//------------------------------------------------------------------------------
#pragma mark - Private methods declarations
//------------------------------------------------------------------------------
@interface CHChessClockSettings() <NSCoding>

@end

//------------------------------------------------------------------------------
#pragma mark - CHChessClockSetting implementation
//------------------------------------------------------------------------------
@implementation CHChessClockSettings

static NSString* const CHIncrementArchiveKey = @"increment";
static NSString* const CHTimeStagesManagerArchiveKey = @"timeStagesManager";

- (instancetype)initWithIncrement:(CHChessClockIncrement *)increment
                     stageManager:(CHChessClockTimeControlStageManager *)stageManager
{
    self = [super init];
    if (self) {
        self.increment = increment;
        self.stageManager = stageManager;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.increment = [aDecoder decodeObjectForKey:CHIncrementArchiveKey];
        self.stageManager = [aDecoder decodeObjectForKey:CHTimeStagesManagerArchiveKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_increment forKey:CHIncrementArchiveKey];
    [aCoder encodeObject:_stageManager forKey:CHTimeStagesManagerArchiveKey];
}

@end
