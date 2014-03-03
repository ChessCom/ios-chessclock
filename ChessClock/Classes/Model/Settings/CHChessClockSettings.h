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

@property (copy, nonatomic) NSString* name;
@property (retain, nonatomic) CHChessClockIncrement* increment;
@property (retain, nonatomic, readonly) CHChessClockTimeControlStageManager* stageManager;

- (id)initWithName:(NSString*)name increment:(CHChessClockIncrement*)increment
   andStageManager:(CHChessClockTimeControlStageManager*)stageManager;

@end
