//
//  CHChessClockTimeControlStage.h
//  Chess.com
//
//  Created by Pedro Bolaños on 10/24/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHChessClockTimeControlStage : NSObject

@property (assign, nonatomic) NSUInteger movesCount;
@property (assign, nonatomic) NSUInteger maximumTime;

- (id)initWithMovesCount:(NSUInteger)movesCount
          andMaximumTime:(NSUInteger)maximumTimeInSeconds;

@end
