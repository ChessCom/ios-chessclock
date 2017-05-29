//
//  CHChessClockTimeControlStageManager.h
//  Chess.com
//
//  Created by Pedro Bolaños on 10/29/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CHChessClockTimeControlStage;

@interface CHChessClockTimeControlStageManager : NSObject

- (void)addTimeStageWithMovesCount:(NSUInteger)movesCount
                    andMaximumTime:(NSUInteger)maximumTime;

- (void)addTimeStage:(CHChessClockTimeControlStage*)stage;
- (void)removeTimeStageAtIndex:(NSUInteger)stageIndex;

- (NSUInteger)stageCount;
- (CHChessClockTimeControlStage*)stageAtIndex:(NSUInteger)stageIndex;
- (NSUInteger)indexOfStage:(CHChessClockTimeControlStage*)stage;

@property (readonly, nonatomic) NSMutableArray* timeControlStages;

@end
