//
//  CHUtil.m
//  Chess.com
//
//  Created by Pedro Bolaños on 11/27/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import "CHUtil.h"

@implementation CHUtil

+ (NSString*)imageNameWithBaseName:(NSString*)baseImageName
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        baseImageName = [baseImageName stringByAppendingString:@"@2x"];
    }
    
    return baseImageName;
}

+ (NSString*)formatTime:(NSTimeInterval)timeInSeconds showTenths:(BOOL)showTenths
{
    NSUInteger timeInSecondsInt = timeInSeconds;
    NSUInteger hours = timeInSeconds / 3600;
    NSUInteger seconds = timeInSecondsInt % 60;
    NSUInteger minutes = (timeInSecondsInt / 60) % 60;
        
    if (hours > 0) {
        if (showTenths) {
            return [NSString stringWithFormat:@"%ld:%02ld:%04.1f", (long)hours, (long)minutes, seconds + fmod(timeInSeconds, 1.0f)];
        }

        return [NSString stringWithFormat:@"%ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    }
    else {
        if (showTenths) {
            return [NSString stringWithFormat:@"%ld:%04.1f", (long)minutes, seconds + fmod(timeInSeconds, 1.0f)];
        }
        
        return [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
    }
}

@end
