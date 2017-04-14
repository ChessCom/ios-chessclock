//
//  CHChessClockSettingsManager.h
//  Chess.com
//
//  Created by Pedro Bolaños on 10/24/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CHChessClockTimeControl;

@interface CHChessClockSettingsManager : NSObject

@property (strong, nonatomic) CHChessClockTimeControl *timeControl;

- (void)addTimeControl:(CHChessClockTimeControl *)timeControl;
- (void)removeTimeControlAtIndex:(NSUInteger)index;
- (void)moveTimeControlFrom:(NSUInteger)sourceIndex
                         to:(NSUInteger)destinationIndex;

- (NSArray<CHChessClockTimeControl *> *)allTimeControls;

- (void)saveTimeControls;
- (void)restoreDefaultClockSettings;

@end
