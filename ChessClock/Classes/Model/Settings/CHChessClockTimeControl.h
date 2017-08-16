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

@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) CHChessClockSettings *playerOneSettings;
@property (strong, nonatomic) CHChessClockSettings *playerTwoSettings;
@property (assign, nonatomic) BOOL shouldDuplicateSettings;

@end
