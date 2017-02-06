//
//  CHAppDelegate.m
//  ChessClock
//
//  Created by Pedro Bolaños on 3/3/14.
//  Copyright (c) 2014 Chess.com. All rights reserved.
//

#import "CHAppDelegate.h"

#import "CHUtil.h"
#import "CHChessClockViewController.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@implementation CHAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CHClock" bundle:nil];
    UINavigationController *navigationController = [storyboard instantiateInitialViewController];
    
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    [Fabric with:@[[Crashlytics class]]];
    
    return YES;
}

@end
