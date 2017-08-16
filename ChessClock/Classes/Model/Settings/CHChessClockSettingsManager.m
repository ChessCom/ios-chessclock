//
//  CHChessClockSettingsManager.m
//  Chess.com
//
//  Created by Pedro Bolaños on 10/24/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import "CHChessClockSettingsManager.h"
#import "CHChessClockSettings.h"
#import "CHChessClockTimeControl.h"
#import "CHChessClockIncrement.h"
#import "CHChessClockTimeControlStageManager.h"

//------------------------------------------------------------------------------
#pragma mark - Private methods declarations
//------------------------------------------------------------------------------
@interface CHChessClockSettingsManager()

@property (strong, nonatomic) NSMutableArray<CHChessClockTimeControl *>* timeControls;
@property (strong, nonatomic) NSMutableDictionary* preferences;

@end

//------------------------------------------------------------------------------
#pragma mark - CHChessClockSettingsManager implementation
//------------------------------------------------------------------------------
@implementation CHChessClockSettingsManager

static NSString *const CHChessClockTimeControlNameKey = @"CHChessClockTimeControlNameKey";

- (id)init
{
    self = [super init];
    if (self) {
        if (![self loadSettings]) {
            [self loadDefaultSettings];
        }
    }
    
    return self;
}

- (void)addTimeControl:(CHChessClockTimeControl *)timeControl
{
    [self.timeControls insertObject:timeControl atIndex:0];
    [self saveTimeControls];
}

- (void)removeTimeControlAtIndex:(NSUInteger)index
{
    if (index < [self.timeControls count]) {
        [self.timeControls removeObjectAtIndex:index];
        [self saveTimeControls];
    }
}

- (void)moveTimeControlFrom:(NSUInteger)sourceIndex
                         to:(NSUInteger)destinationIndex
{
    CHChessClockTimeControl* timeControlToMove = [self.timeControls objectAtIndex:sourceIndex];
    [self.timeControls removeObjectAtIndex:sourceIndex];
    [self.timeControls insertObject:timeControlToMove atIndex:destinationIndex];
}

- (NSArray<CHChessClockTimeControl *> *)allTimeControls
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

- (void)savePreferences
{
    NSURL* chessClockPreferencesPath = [self chessClockPreferencesPath];
    if (![NSKeyedArchiver archiveRootObject:self.preferences toFile:[chessClockPreferencesPath path]]) {
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

- (void)setTimeControl:(CHChessClockTimeControl *)timeControl
{
    if (_timeControl != timeControl) {
        _timeControl = timeControl;
        [self.preferences setObject:_timeControl.name forKey:CHChessClockTimeControlNameKey];
        [self savePreferences];
    }
}

- (void)loadDefaultSettings
{
    self.preferences = [NSMutableDictionary dictionary];

    NSString* defaultTimeControlsPath =
    [[NSBundle mainBundle] pathForResource:@"DefaultChessClockSettings"
                                    ofType:@"plist"];
    
    NSArray* defaultSettings =
    [[NSDictionary dictionaryWithContentsOfFile:defaultTimeControlsPath]
     objectForKey:@"defaultSettings"];
    
    NSMutableArray* allTimeControls = [NSMutableArray arrayWithCapacity:[defaultSettings count]];
    
    for (NSDictionary* settingsDefinitions in defaultSettings) {
        
        NSString* name = [settingsDefinitions objectForKey:@"name"];
        
        // Create the increment
        NSDictionary* incrementDefinition = [settingsDefinitions objectForKey:@"increment"];
        NSString* incrementType = [incrementDefinition objectForKey:@"type"];
        NSUInteger incrementValue = [[incrementDefinition objectForKey:@"incrementValue"] integerValue];
        Class IncrementClass = NSClassFromString(incrementType);
        CHChessClockIncrement* increment = [[IncrementClass alloc] initWithIncrementValue:incrementValue];
        
        // Create the time control stages manager
        NSDictionary* timeStagesDefinition = [settingsDefinitions objectForKey:@"timeStages"];
        CHChessClockTimeControlStageManager* timeControlStageManager = [[CHChessClockTimeControlStageManager alloc] init];
        
        for (NSDictionary* timeStageDefinition in timeStagesDefinition) {
            NSUInteger movesCount = [[timeStageDefinition objectForKey:@"movesCount"] integerValue];
            NSUInteger maximumTime = [[timeStageDefinition objectForKey:@"maximumTime"] integerValue] * 60;
            [timeControlStageManager addTimeStageWithMovesCount:movesCount andMaximumTime:maximumTime];
        }
        
        // Create the clock settings
        CHChessClockSettings *playerOneSettings =
        [[CHChessClockSettings alloc] initWithIncrement:increment
                                           stageManager:timeControlStageManager];
        
        CHChessClockSettings *playerTwoSettings =
        [[CHChessClockSettings alloc] initWithIncrement:increment
                                           stageManager:timeControlStageManager];

        // For defaults, we have the same settings for player one and two
        CHChessClockTimeControl *timeControl = [CHChessClockTimeControl new];
        timeControl.name = name;
        timeControl.playerOneSettings = playerOneSettings;
        timeControl.playerTwoSettings = playerTwoSettings;
        timeControl.shouldDuplicateSettings = YES;

        if ([settingsDefinitions objectForKey:@"default"]) {
            self.timeControl = timeControl;
        }
        
        [allTimeControls addObject:timeControl];
    }
    
    self.timeControls = allTimeControls;
    [self saveTimeControls];
}

- (BOOL)loadSettings
{
    NSFileManager* fileManager = [[NSFileManager alloc] init];
    NSString* timeControlsPath = [[self chessClockTimeControlsPath] path];
    NSString* preferencePath = [[self chessClockPreferencesPath] path];
    
    if ([fileManager fileExistsAtPath:preferencePath]) {
        self.preferences = [NSKeyedUnarchiver unarchiveObjectWithFile:preferencePath];
    }
    
    if ([fileManager fileExistsAtPath:timeControlsPath]) {
        self.timeControls = [NSKeyedUnarchiver unarchiveObjectWithFile:timeControlsPath];
        
        NSString *timeControlName = [self.preferences objectForKey:CHChessClockTimeControlNameKey];
        for (CHChessClockTimeControl* timeControl in self.timeControls) {
            if ([timeControl.name isEqualToString:timeControlName]) {
                self.timeControl = timeControl;
            }
        }
    }
    
    return self.timeControls != nil && self.preferences != nil;
}

- (NSURL*)chessClockFilePathWithBaseName:(NSString*)baseName
{
    NSFileManager* fileManager = [[NSFileManager alloc] init];
    NSURL* documentsPath = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    return [documentsPath URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", baseName]];
}

- (NSURL*)chessClockTimeControlsPath
{
    return [self chessClockFilePathWithBaseName:@"chessClockTimeControls-v2.0"];
}

- (NSURL*)chessClockPreferencesPath
{
    return [self chessClockFilePathWithBaseName:@"chessClockPreferences-v2.0"];
}

@end
