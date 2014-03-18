//
//  CHSoundPlayer.m
//  ChessClock
//
//  Created by Pedro Mancheno on 3/18/14.
//  Copyright (c) 2014 Chess.com. All rights reserved.
//

#import "CHSoundPlayer.h"

#import <AudioToolbox/AudioToolbox.h>

@implementation CHSoundPlayer

+ (void)playSwitch1Sound
{
    [self playSoundWithName:@"chess_clock_switch1" ofType:@"mp3"];
}

+ (void)playSwitch2Sound
{
    [self playSoundWithName:@"chess_clock_switch2" ofType:@"mp3"];
}

+ (void)playEndSound
{
    [self playSoundWithName:@"chess_clock_time_ended" ofType:@"mp3"];
}

+ (void)playSoundWithName:(NSString *)name ofType:(NSString *)type
{
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:name
                                                          ofType:type];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    AudioServicesPlaySystemSound (soundID);
}

@end
