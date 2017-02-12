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
#import "UIColor+ChessClock.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@implementation CHAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self configureAppearance];
    [self configureViewHierarchy];
    [self configureFabric];
    
    return YES;
}

- (void)configureAppearance
{
    [[UINavigationBar appearance] setBarTintColor:[UIColor navigationBarTintColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor navigationBarTextColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor navigationBarTextColor]}];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
}

- (void)configureViewHierarchy
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CHClock" bundle:nil];
    UINavigationController *navigationController = [storyboard instantiateInitialViewController];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
}

- (void)configureFabric
{
     [Fabric with:@[[Crashlytics class]]];
}

@end
