//
//  CHChessClockTimeUpdateViewController.m
//  ChessClock
//
//  Created by Pedro Mancheno on 2017-05-03.
//  Copyright © 2017 Chess.com. All rights reserved.
//

#import "CHChessClockTimeUpdateViewController.h"

@interface CHChessClockTimeUpdateViewController ()

@end

@implementation CHChessClockTimeUpdateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)mainViewWasPressed:(id)sender
{
    [self.delegate timeUpdateViewControllerShouldDismiss:self];
}

@end
