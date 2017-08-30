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
static NSString* const kCHTimeEndedSoundName = @"timeEnded";

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
    [self.oalSimpleAudio preloadEffect:[self soundPathForSoundName:kCHSwitchOneSoundName]];
    [self.oalSimpleAudio preloadEffect:[self soundPathForSoundName:kCHSwitchTwoSoundName]];
    [self.oalSimpleAudio preloadEffect:[self soundPathForSoundName:kCHTimeEndedSoundName]];
}

- (void)playSwitch1Sound
{
    [self.oalSimpleAudio playEffect:[self soundPathForSoundName:kCHSwitchOneSoundName]];
}

- (void)playSwitch2Sound
{
    [self.oalSimpleAudio playEffect:[self soundPathForSoundName:kCHSwitchTwoSoundName]];
}

- (void)playEndSound
{
    [self.oalSimpleAudio playEffect:[self soundPathForSoundName:kCHTimeEndedSoundName]];
}

//------------------------------------------------------------------------------
#pragma mark - Private methods definitions
//------------------------------------------------------------------------------
- (NSString*)soundPathForSoundName:(NSString*)soundName
{
    return [[NSBundle mainBundle] pathForResource:soundName ofType:@"wav"];
}

@end
