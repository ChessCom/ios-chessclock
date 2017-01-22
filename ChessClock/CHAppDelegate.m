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

@implementation CHAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    NSString *baseNibName = [CHUtil nibNameWithBaseName:@"CHChessClockView"];
    CHChessClockViewController *rootViewController = [[CHChessClockViewController alloc] initWithNibName:baseNibName bundle:nil];
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:rootViewController];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
