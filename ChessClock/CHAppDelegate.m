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

#import <Crashlytics/Crashlytics.h>
#import "Flurry.h"

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
    
    [Flurry startSession:@"CYCQ6GY9XZCZKVB2VGRV"];
    [Crashlytics startWithAPIKey:@"47969ba8b0f44f287503d0c51b95040668dfa536"];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
