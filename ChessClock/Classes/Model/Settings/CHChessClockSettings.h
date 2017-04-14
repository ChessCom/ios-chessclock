//
//  CHChessClockSetting.h
//  Chess.com
//
//  Created by Pedro Bolaños on 10/24/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CHChessClockIncrement;
@class CHChessClockTimeControlStageManager;

@interface CHChessClockSettings : NSObject

@property (strong, nonatomic) CHChessClockIncrement* increment;
@property (readonly, nonatomic) CHChessClockTimeControlStageManager* stageManager;

- (id)initWithIncrement:(CHChessClockIncrement*)increment
           stageManager:(CHChessClockTimeControlStageManager*)stageManager;

@end
