//
//  CHChessClockFooterView.m
//  ChessClock
//
//  Created by Pedro Mancheno on 3/8/14.
//  Copyright (c) 2014 Chess.com. All rights reserved.
//

#import "CHChessClockSettingsFooterView.h"

@interface CHChessClockSettingsFooterView ()

@property (weak, nonatomic) IBOutlet UIButton *startButton;

@end

@implementation CHChessClockSettingsFooterView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
//    [self.startButton setBackgroundImage:nil forState:UIControlStateHighlighted];
//    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7){
//        self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeRight;
//    }
}

@end