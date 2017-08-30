//
//  CHSoundPlayer.h
//  ChessClock
//
//  Created by Pedro Mancheno on 3/18/14.
//  Copyright (c) 2014 Chess.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHSoundPlayer : NSObject

+ (instancetype)sharedSoundPlayer;

- (void)preloadSounds;
- (void)playSwitch1Sound;
- (void)playSwitch2Sound;
- (void)playStartSound;
- (void)playEndSound;
- (void)playResetSound;
- (void)playPauseSound;

@end
