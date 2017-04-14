//
//  CHChessClockTimeControl.h
//  ChessClock
//
//  Created by Pedro Mancheno on 2017-04-13.
//  Copyright © 2017 Chess.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class  CHChessClockSettings;

@interface CHChessClockTimeControl : NSObject

- (instancetype)initWithName:(NSString *)name
           playerOneSettings:(CHChessClockSettings *)playerOneSettings
           playerTwoSettings:(CHChessClockSettings *)playerTwoSettings;

@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) CHChessClockSettings *playerOneSettings;
@property (readonly, nonatomic) CHChessClockSettings *playerTwoSettings;

@end
