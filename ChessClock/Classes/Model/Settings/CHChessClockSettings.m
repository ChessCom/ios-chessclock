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

@property (retain, nonatomic, readwrite) CHChessClockTimeControlStageManager* stageManager;

@end

//------------------------------------------------------------------------------
#pragma mark - CHChessClockSetting implementation
//------------------------------------------------------------------------------
@implementation CHChessClockSettings

static NSString* const CHNameArchiveKey = @"name";
static NSString* const CHIncrementArchiveKey = @"increment";
static NSString* const CHTimeStagesManagerArchiveKey = @"timeStagesManager";

- (id)initWithName:(NSString*)name increment:(CHChessClockIncrement*)increment
   andStageManager:(CHChessClockTimeControlStageManager*)stageManager;
{
    self = [super init];
    if (self) {
        self.name = name;
        self.increment = increment;
        self.stageManager = stageManager;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.name = [aDecoder decodeObjectForKey:CHNameArchiveKey];
        self.increment = [aDecoder decodeObjectForKey:CHIncrementArchiveKey];
        self.stageManager = [aDecoder decodeObjectForKey:CHTimeStagesManagerArchiveKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_name forKey:CHNameArchiveKey];
    [aCoder encodeObject:_increment forKey:CHIncrementArchiveKey];
    [aCoder encodeObject:_stageManager forKey:CHTimeStagesManagerArchiveKey];
}

- (NSString*)description {
    
    return self.name;
}

@end
