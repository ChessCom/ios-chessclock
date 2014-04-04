//
//  CHChessClockSettingsManager.m
//  Chess.com
//
//  Created by Pedro Bolaños on 10/24/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import "CHChessClockSettingsManager.h"
#import "CHChessClockSettings.h"
#import "CHChessClockIncrement.h"
#import "CHChessClockTimeControlStageManager.h"

//------------------------------------------------------------------------------
#pragma mark - Private methods declarations
//------------------------------------------------------------------------------
@interface CHChessClockSettingsManager()

@property (strong, nonatomic) NSMutableArray* timeControls;
@property (strong, nonatomic) NSMutableDictionary* settings;

@end

//------------------------------------------------------------------------------
#pragma mark - CHChessClockSettingsManager implementation
//------------------------------------------------------------------------------
@implementation CHChessClockSettingsManager

static NSString* const CHChessClockCurrentTimeControl = @"CHChessClockCurrentTimeControl";
static NSString* const CHChessClockIsLandscape = @"CHChessClockIsLandscape";

- (id)init
{
    self = [super init];
    if (self)
    {
        if (![self loadSettings])
        {
            [self loadDefaultSettings];
        }
    }
    
    return self;
}

- (void)setIsLandscape:(BOOL)isLandscape
{
    [self.settings setObject:[NSNumber numberWithBool:isLandscape] forKey:CHChessClockIsLandscape];
    [self saveSettings];
}

- (BOOL)isLandscape
{
    return [[self.settings objectForKey:CHChessClockIsLandscape] boolValue];
}

- (void)addTimeControl:(CHChessClockSettings*)settings
{
    [self.timeControls insertObject:settings atIndex:0];
    [self saveTimeControls];
}

- (void)removeTimeControlAtIndex:(NSUInteger)index
{
    if (index < [self.timeControls count])
    {
        [self.timeControls removeObjectAtIndex:index];
        [self saveTimeControls];
    }
}

- (void)moveTimeControlFrom:(NSUInteger)sourceIndex to:(NSUInteger)destinationIndex
{
    CHChessClockSettings* settingToMove = [self.timeControls objectAtIndex:sourceIndex];
    [self.timeControls removeObjectAtIndex:sourceIndex];
    [self.timeControls insertObject:settingToMove atIndex:destinationIndex];
}

- (NSArray*)allChessClockSettings
{
    return [NSArray arrayWithArray:self.timeControls];
}

- (void)saveTimeControls
{
    NSURL* timeControlsPath = [self chessClockTimeControlsPath];
    if (![NSKeyedArchiver archiveRootObject:self.timeControls toFile:[timeControlsPath path]]) {
        NSLog(@"Couldn't save Chess clock time controls!");
    }
}

- (void)saveSettings
{
    NSURL* chessClockSettingsPath = [self chessClockSettingsPath];
    if (![NSKeyedArchiver archiveRootObject:self.settings toFile:[chessClockSettingsPath path]]) {
        NSLog(@"Couldn't save Chess clock settings!");
    }
}

- (void)restoreDefaultClockSettings
{
    NSFileManager* fileManager = [[NSFileManager alloc] init];
    NSString* chessClockSettingsPath = [[self chessClockTimeControlsPath] path];
    [fileManager removeItemAtPath:chessClockSettingsPath error:nil];
    
    [self loadDefaultSettings];
}

//------------------------------------------------------------------------------
#pragma mark - Private methods definitions
//------------------------------------------------------------------------------
- (void)setCurrentTimeControl:(CHChessClockSettings *)currentClockSettings
{
    if (_currentTimeControl != currentClockSettings) {
        _currentTimeControl = currentClockSettings;
        [self saveCurrentChessClockSettingsName];
    }
}

- (void)loadDefaultSettings
{
    self.settings = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                     [NSNumber numberWithBool:NO], CHChessClockIsLandscape, nil];

    NSString* defaultTimeControlsPath = [[NSBundle mainBundle] pathForResource:@"DefaultChessClockSettings"
                                                                    ofType:@"plist"];
    
    NSArray* defaultTimeControls = [[NSDictionary dictionaryWithContentsOfFile:defaultTimeControlsPath] objectForKey:@"defaultSettings"];
    NSMutableArray* allTimeControls = [NSMutableArray arrayWithCapacity:[defaultTimeControls count]];
    
    for (NSDictionary* timeControlDefinition in defaultTimeControls) {
        
        NSString* name = [timeControlDefinition objectForKey:@"name"];
                
        // Create the increment
        NSDictionary* incrementDefinition = [timeControlDefinition objectForKey:@"increment"];
        NSString* incrementType = [incrementDefinition objectForKey:@"type"];
        NSUInteger incrementValue = [[incrementDefinition objectForKey:@"incrementValue"] integerValue];
        Class incrementClass = NSClassFromString(incrementType);
        CHChessClockIncrement* increment = [[incrementClass alloc] initWithIncrementValue:incrementValue];
        
        // Create the time control stages manager
        NSDictionary* timeStagesDefinition = [timeControlDefinition objectForKey:@"timeStages"];
        CHChessClockTimeControlStageManager* timeControlStageManager = [[CHChessClockTimeControlStageManager alloc] init];
        
        for (NSDictionary* timeStageDefinition in timeStagesDefinition) {
            NSUInteger movesCount = [[timeStageDefinition objectForKey:@"movesCount"] integerValue];
            NSUInteger maximumTime = [[timeStageDefinition objectForKey:@"maximumTime"] integerValue] * 60;
            [timeControlStageManager addTimeStageWithMovesCount:movesCount andMaximumTime:maximumTime];
        }
        
        // Create the clock settings
        CHChessClockSettings* settings = [[CHChessClockSettings alloc] initWithName:name
                                                                          increment:increment
                                                                    andStageManager:timeControlStageManager];
        
        [allTimeControls addObject:settings];
        
        if ([timeControlDefinition objectForKey:@"default"]) {
            self.currentTimeControl = settings;
        }
    }
    
    self.timeControls = allTimeControls;
    [self saveTimeControls];
}

- (BOOL)loadSettings
{
    NSFileManager* fileManager = [[NSFileManager alloc] init];
    NSString* timeControlsPath = [[self chessClockTimeControlsPath] path];
    NSString* settingsPath = [[self chessClockSettingsPath] path];
    
    if ([fileManager fileExistsAtPath:settingsPath]) {
        self.settings = [NSKeyedUnarchiver unarchiveObjectWithFile:settingsPath];
    }
    
    if ([fileManager fileExistsAtPath:timeControlsPath]) {
        self.timeControls = [NSKeyedUnarchiver unarchiveObjectWithFile:timeControlsPath];
        NSString* currentSettingsName = [self.settings objectForKey:CHChessClockCurrentTimeControl];

        for (CHChessClockSettings* settings in self.timeControls) {
            if ([settings.name isEqualToString:currentSettingsName]) {
                self.currentTimeControl = settings;
                break;
            }
        }
    }
    
    return self.timeControls != nil && self.settings != nil;
}

- (NSURL*)chessClockFilePathWithBaseName:(NSString*)baseName
{
    NSFileManager* fileManager = [[NSFileManager alloc] init];
    NSURL* documentsPath = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    return [documentsPath URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", baseName]];
}

- (NSURL*)chessClockTimeControlsPath
{
    return [self chessClockFilePathWithBaseName:@"chessClockTimeControls"];
}

- (NSURL*)chessClockSettingsPath
{
    return [self chessClockFilePathWithBaseName:@"chessClockSettings"];
}

- (void)saveCurrentChessClockSettingsName
{
    [self.settings setObject:self.currentTimeControl.name forKey:CHChessClockCurrentTimeControl];
    [self saveSettings];
}

@end
