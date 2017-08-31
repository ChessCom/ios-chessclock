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
@property (assign, nonatomic) NSUInteger currentSwitchSoundIndex;

@end

//------------------------------------------------------------------------------
#pragma mark - CHSoundPlayer implementation
//------------------------------------------------------------------------------
@implementation CHSoundPlayer

static NSString* const kCHStartSoundName = @"start";
static NSString* const kCHTimeEndedSoundName = @"timeEnded";
static NSString* const kCHResetSoundName = @"reset";
static NSString* const kCHPauseSoundName = @"pause";

static const NSUInteger kCHSwitchSoundsCount = 4;

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
        _currentSwitchSoundIndex = 0;
    }
    
    return self;
}

- (void)preloadSounds
{
    for (NSUInteger i = 0; i < kCHSwitchSoundsCount; i++)
    {
        NSString* switchOneSound = [self soundPathForSoundName:[self switchSoundNameWithIsForPlayerOne:YES currentSoundIndex:i]];
        NSString* switchTwoSound = [self soundPathForSoundName:[self switchSoundNameWithIsForPlayerOne:NO currentSoundIndex:i]];
        
        [self.oalSimpleAudio preloadEffect:switchOneSound];
        [self.oalSimpleAudio preloadEffect:switchTwoSound];
    }
    
    [self.oalSimpleAudio preloadEffect:[self soundPathForSoundName:kCHTimeEndedSoundName]];
}

- (void)playSwitch1Sound
{
    NSString* switchSoundName = [self switchSoundNameWithIsForPlayerOne:YES currentSoundIndex:self.currentSwitchSoundIndex];
    [self.oalSimpleAudio playEffect:[self soundPathForSoundName:switchSoundName]];
}

- (void)playSwitch2Sound
{
    NSString* switchSoundName = [self switchSoundNameWithIsForPlayerOne:NO currentSoundIndex:self.currentSwitchSoundIndex];
    [self.oalSimpleAudio playEffect:[self soundPathForSoundName:switchSoundName]];
}

- (void)playStartSound
{
    [self.oalSimpleAudio playEffect:[self soundPathForSoundName:kCHStartSoundName]];
}

- (void)playEndSound
{
    [self.oalSimpleAudio playEffect:[self soundPathForSoundName:kCHTimeEndedSoundName]];
}

- (void)playResetSound
{
    [self.oalSimpleAudio playEffect:[self soundPathForSoundName:kCHResetSoundName]];
}

- (void)playPauseSound
{
    [self.oalSimpleAudio playEffect:[self soundPathForSoundName:kCHPauseSoundName]];
}

- (void)moveToNextSwitchSound
{
    self.currentSwitchSoundIndex++;
    
    if (self.currentSwitchSoundIndex >= kCHSwitchSoundsCount)
    {
        self.currentSwitchSoundIndex = 0;
    }
}

//------------------------------------------------------------------------------
#pragma mark - Private methods definitions
//------------------------------------------------------------------------------
- (NSString*)soundPathForSoundName:(NSString*)soundName
{
    NSString* type = @"wav";
    if ([soundName isEqualToString:@"switch1_0"] ||
        [soundName isEqualToString:@"switch2_0"])
    {
        type = @"mp3";
    }
    
    return [[NSBundle mainBundle] pathForResource:soundName ofType:type];
}

- (NSString*)switchSoundNameWithIsForPlayerOne:(BOOL)isForPlayerOne currentSoundIndex:(NSUInteger)currentSoundIndex
{
    return [NSString stringWithFormat:@"switch%@_%@", isForPlayerOne ? @(1) : @(2), @(currentSoundIndex)];
}

@end
