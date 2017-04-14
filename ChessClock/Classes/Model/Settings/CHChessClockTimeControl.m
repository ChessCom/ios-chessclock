//
//  CHChessClockTimeControl.m
//  ChessClock
//
//  Created by Pedro Mancheno on 2017-04-13.
//  Copyright © 2017 Chess.com. All rights reserved.
//

#import "CHChessClockTimeControl.h"
#import "CHChessClockSettings.h"

static NSString* const CHNameArchiveKey = @"name";
static NSString* const CHPlayerOneNameKey = @"playerOneSettings";
static NSString* const CHPlayerTwoNameKey = @"playerTwoSettings";


@interface CHChessClockTimeControl () <NSCoding>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) CHChessClockSettings *playerOneSettings;
@property (strong, nonatomic) CHChessClockSettings *playerTwoSettings;

@end

@implementation CHChessClockTimeControl

- (instancetype)initWithName:(NSString *)name
           playerOneSettings:(CHChessClockSettings *)playerOneSettings
           playerTwoSettings:(CHChessClockSettings *)playerTwoSettings
{
    if (self = [super init]) {
        self.name = name;
        self.playerOneSettings = playerOneSettings;
        self.playerTwoSettings = playerTwoSettings;
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.name = [aDecoder decodeObjectForKey:CHNameArchiveKey];
        self.playerOneSettings = [aDecoder decodeObjectForKey:CHPlayerOneNameKey];
        self.playerTwoSettings = [aDecoder decodeObjectForKey:CHPlayerTwoNameKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_name forKey:CHNameArchiveKey];
    [aCoder encodeObject:_playerOneSettings forKey:CHPlayerOneNameKey];
    [aCoder encodeObject:_playerTwoSettings forKey:CHPlayerTwoNameKey];
}

@end
