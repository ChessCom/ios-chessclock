//
//  CHUtil.m
//  Chess.com
//
//  Created by Pedro Bolaños on 11/27/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import "CHUtil.h"

@implementation CHUtil

+ (NSString*)nibNameWithBaseName:(NSString*)baseNibName
{
    NSString* platformSuffix = nil;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        platformSuffix = @"_iPhone";
    }
    else {
        platformSuffix = @"_iPad";
    }
    
    return [baseNibName stringByAppendingString:platformSuffix];
}

+ (NSString*)imageNameWithBaseName:(NSString*)baseImageName
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        baseImageName = [baseImageName stringByAppendingString:@"@2x"];
    }
    
    return [NSString stringWithFormat:@"%@.png", baseImageName];
}

+ (NSString*)formatTime:(NSTimeInterval)timeInSeconds showTenths:(BOOL)showTenths
{
    NSUInteger timeInSecondsInt = timeInSeconds;
    NSUInteger hours = timeInSeconds / 3600;
    NSUInteger seconds = timeInSecondsInt % 60;
    NSUInteger minutes = (timeInSecondsInt / 60) % 60;
        
    if (hours > 0) {
        if (showTenths) {
            return [NSString stringWithFormat:@"%d:%02d:%04.1f", hours, minutes, seconds + fmod(timeInSeconds, 1.0f)];
        }

        return [NSString stringWithFormat:@"%d:%02d:%02d", hours, minutes, seconds];
    }
    else {
        if (showTenths) {
            return [NSString stringWithFormat:@"%d:%04.1f", minutes, seconds + fmod(timeInSeconds, 1.0f)];
        }
        
        return [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    }
}

@end
