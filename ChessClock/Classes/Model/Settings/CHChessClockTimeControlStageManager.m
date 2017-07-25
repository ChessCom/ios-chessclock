
//
//  CHChessClockTimeControlStageManager.m
//  Chess.com
//
//  Created by Pedro Bolaños on 10/29/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import "CHChessClockTimeControlStageManager.h"
#import "CHChessClockTimeControlStage.h"

//------------------------------------------------------------------------------
#pragma mark - Private methods declarations
//------------------------------------------------------------------------------
@interface CHChessClockTimeControlStageManager() <NSCoding>

@property (strong, nonatomic) NSMutableArray* timeControlStages;

@end

//------------------------------------------------------------------------------
#pragma mark - CHChessClockTimeControlStageManager implementation
//------------------------------------------------------------------------------
@implementation CHChessClockTimeControlStageManager

static NSString* const CHTimeStagesArchiveKey = @"timeStages";

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.timeControlStages = [aDecoder decodeObjectForKey:CHTimeStagesArchiveKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_timeControlStages forKey:CHTimeStagesArchiveKey];
}

- (void)addTimeStageWithMovesCount:(NSUInteger)movesCount
                    andMaximumTime:(NSUInteger)maximumTimeInSeconds
{
    CHChessClockTimeControlStage* stage = [[CHChessClockTimeControlStage alloc] initWithMovesCount:movesCount
                                                                                    andMaximumTime:maximumTimeInSeconds];
    
    [self.timeControlStages addObject:stage];
}

- (void)addTimeStage:(CHChessClockTimeControlStage*)stage
{
    // Set a default move count to the existing stages
    [self.timeControlStages enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CHChessClockTimeControlStage* stage = obj;
        
        if (stage.movesCount == 0) {
            if (idx == 0)
            {
                stage.movesCount = 40;
            }
            else if (idx == 1)
            {
                stage.movesCount = 20;
            }
        }
    }];
    
    [self.timeControlStages addObject:stage];
}

- (void)removeTimeStageAtIndex:(NSUInteger)stageIndex
{
    if (stageIndex < [self.timeControlStages count]) {
        [self.timeControlStages removeObjectAtIndex:stageIndex];
        
        // The last stage can't have a number of moves
        CHChessClockTimeControlStage* stage = [self.timeControlStages lastObject];
        stage.movesCount = 0;
    }
}

- (NSUInteger)stageCount
{
    return [self.timeControlStages count];
}

- (CHChessClockTimeControlStage*)stageAtIndex:(NSUInteger)stageIndex;
{
    if (stageIndex < [self.timeControlStages count]) {
        return [self.timeControlStages objectAtIndex:stageIndex];
    }
    
    return nil;
}

- (NSUInteger)indexOfStage:(CHChessClockTimeControlStage*)stage
{
    return [self.timeControlStages indexOfObject:stage];
}

//------------------------------------------------------------------------------
#pragma mark - Private methods definitions
//------------------------------------------------------------------------------
- (NSMutableArray*)timeControlStages
{
    if (_timeControlStages == nil) {
        _timeControlStages = [[NSMutableArray alloc] init];
    }
    
    return _timeControlStages;
}

@end
