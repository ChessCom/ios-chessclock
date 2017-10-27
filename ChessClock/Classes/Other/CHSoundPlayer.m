//
//  CHSoundPlayer.m
//  ChessClock
//
//  Created by Pedro Mancheno on 3/18/14.
//  Copyright (c) 2014 Chess.com. All rights reserved.
//

#import "CHSoundPlayer.h"

#import "OALSimpleAudio.h"

//------------------------------------------------------------------------------
#pragma mark - Private methods declarations
//------------------------------------------------------------------------------
@interface CHSoundPlayer()

@property (strong, nonatomic) OALSimpleAudio* oalSimpleAudio;

@end

//------------------------------------------------------------------------------
#pragma mark - CHSoundPlayer implementation
//------------------------------------------------------------------------------
@implementation CHSoundPlayer

static NSString* const kCHSwitchOneSoundName = @"switch1";
static NSString* const kCHSwitchTwoSoundName = @"switch2";
static NSString* const kCHStartSoundName = @"start";
static NSString* const kCHTimeEndedSoundName = @"timeEnded";
static NSString* const kCHResetSoundName = @"reset";
static NSString* const kCHPauseSoundName = @"pause";

+ (instancetype)sharedSoundPlayer
{
    static dispatch_once_t predicate = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&predicate, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _oalSimpleAudio = [OALSimpleAudio sharedInstance];
        _oalSimpleAudio.allowIpod = YES;
        _oalSimpleAudio.useHardwareIfAvailable = NO;
        _oalSimpleAudio.honorSilentSwitch = YES;
    }
    
    return self;
}

- (void)preloadSounds
{
    [self.oalSimpleAudio preloadEffect:[self soundPathForSoundName:kCHSwitchOneSoundName withIsWav:NO]];
    [self.oalSimpleAudio preloadEffect:[self soundPathForSoundName:kCHSwitchTwoSoundName withIsWav:NO]];
    [self.oalSimpleAudio preloadEffect:[self soundPathForSoundName:kCHStartSoundName withIsWav:YES]];
    [self.oalSimpleAudio preloadEffect:[self soundPathForSoundName:kCHTimeEndedSoundName withIsWav:YES]];
    [self.oalSimpleAudio preloadEffect:[self soundPathForSoundName:kCHResetSoundName withIsWav:YES]];
    [self.oalSimpleAudio preloadEffect:[self soundPathForSoundName:kCHPauseSoundName withIsWav:YES]];
}

- (void)playSwitch1Sound
{
    [self.oalSimpleAudio playEffect:[self soundPathForSoundName:kCHSwitchOneSoundName withIsWav:NO]];
}

- (void)playSwitch2Sound
{
    [self.oalSimpleAudio playEffect:[self soundPathForSoundName:kCHSwitchTwoSoundName withIsWav:NO]];
}

- (void)playStartSound
{
    [self.oalSimpleAudio playEffect:[self soundPathForSoundName:kCHStartSoundName withIsWav:YES]];
}

- (void)playEndSound
{
    [self.oalSimpleAudio playEffect:[self soundPathForSoundName:kCHTimeEndedSoundName withIsWav:YES]];
}

- (void)playResetSound
{
    [self.oalSimpleAudio playEffect:[self soundPathForSoundName:kCHResetSoundName withIsWav:YES]];
}

- (void)playPauseSound
{
    [self.oalSimpleAudio playEffect:[self soundPathForSoundName:kCHPauseSoundName withIsWav:YES]];
}

//------------------------------------------------------------------------------
#pragma mark - Private methods definitions
//------------------------------------------------------------------------------
- (NSString*)soundPathForSoundName:(NSString*)soundName withIsWav:(BOOL)isWav
{
    NSString* type = @"wav";
    if (!isWav)
    {
        type = @"mp3";
    }
    
    return [[NSBundle mainBundle] pathForResource:soundName ofType:type];
}

@end
