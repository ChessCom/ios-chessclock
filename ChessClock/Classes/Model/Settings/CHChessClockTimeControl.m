//
//  CHChessClockTimeControl.m
//  ChessClock
//
//  Created by Pedro Mancheno on 2017-04-13.
//  Copyright © 2017 Chess.com. All rights reserved.
//

#import "CHChessClockTimeControl.h"
#import "CHChessClockSettings.h"
#import "CHChessClockIncrement.h"
#import "CHChessClockTimeControlStageManager.h"
#import "CHChessClockTimeControlStage.h"

static NSString* const CHNameArchiveKey = @"name";
static NSString* const CHPlayerOneNameKey = @"playerOneSettings";
static NSString* const CHPlayerTwoNameKey = @"playerTwoSettings";
static NSString* const CHShouldDuplicateSettingsKey = @"shouldDuplicateSettings";

@interface CHChessClockTimeControl () <NSCoding>
@end

@implementation CHChessClockTimeControl

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _name = [aDecoder decodeObjectForKey:CHNameArchiveKey];
        _playerOneSettings = [aDecoder decodeObjectForKey:CHPlayerOneNameKey];
        _playerTwoSettings = [aDecoder decodeObjectForKey:CHPlayerTwoNameKey];
        _shouldDuplicateSettings = [[aDecoder decodeObjectForKey:CHShouldDuplicateSettingsKey] boolValue];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_name forKey:CHNameArchiveKey];
    [aCoder encodeObject:_playerOneSettings forKey:CHPlayerOneNameKey];
    [aCoder encodeObject:_playerTwoSettings forKey:CHPlayerTwoNameKey];
    [aCoder encodeObject:@(_shouldDuplicateSettings) forKey:CHShouldDuplicateSettingsKey];
}

- (void)setShouldDuplicateSettings:(BOOL)shouldDuplicateSettings
{
    _shouldDuplicateSettings = shouldDuplicateSettings;
    if (shouldDuplicateSettings) {
        Class IncrementClass = [self.playerOneSettings.increment class];
        CHChessClockIncrement *increment = [[IncrementClass alloc] initWithIncrementValue:self.playerOneSettings.increment.incrementValue];
        CHChessClockTimeControlStageManager *stageManager = [[CHChessClockTimeControlStageManager alloc] init];
        
        for (CHChessClockTimeControlStage *stage in self.playerOneSettings.stageManager.timeControlStages) {
            CHChessClockTimeControlStage *newStage = [[CHChessClockTimeControlStage alloc] initWithMovesCount:stage.movesCount andMaximumTime:stage.maximumTime];
            [stageManager addTimeStage:newStage];
        }
        
        self.playerTwoSettings = [[CHChessClockSettings alloc] initWithIncrement:increment stageManager:stageManager];
    }
}

@end
