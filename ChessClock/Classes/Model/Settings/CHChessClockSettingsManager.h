//
//  CHChessClockSettingsManager.h
//  Chess.com
//
//  Created by Pedro Bolaños on 10/24/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CHChessClockSettings;

@interface CHChessClockSettingsManager : NSObject

@property (strong, nonatomic) CHChessClockSettings *playerOneSettings;
@property (strong, nonatomic) CHChessClockSettings *playerTwoSettings;

- (id)init;

- (void)addTimeControl:(CHChessClockSettings*)settings;
- (void)removeTimeControlAtIndex:(NSUInteger)index;
- (void)moveTimeControlFrom:(NSUInteger)sourceIndex to:(NSUInteger)destinationIndex;

- (NSArray*)allChessClockSettings;
- (void)saveTimeControls;
- (void)restoreDefaultClockSettings;

- (void)setIsLandscape:(BOOL)isLandscape;
- (BOOL)isLandscape;

@end
