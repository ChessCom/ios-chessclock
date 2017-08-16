//
//  CHTableViewCell.m
//  ChessClock
//
//  Created by Pedro Bolaños on 6/27/17.
//  Copyright © 2017 Chess.com. All rights reserved.
//

#import "CHTableViewCell.h"

#import "UIColor+ChessClock.h"

@implementation CHTableViewCell

- (void)setupStyle
{
    [self setupStyleWithShouldDuplicateSettings:NO];
}

- (void)setupStyleWithShouldDuplicateSettings:(BOOL)shouldDuplicateSettings
{
    self.backgroundColor = [UIColor clearColor];
    
    UIView* selectedBackgroundView = [[UIView alloc] init];
    selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
    self.selectedBackgroundView = selectedBackgroundView;
    
    self.tintColor = [UIColor tableViewCellTextColor];
    self.separatorInset = UIEdgeInsetsZero;
    self.textLabel.font = [UIFont boldSystemFontOfSize:16];
    self.detailTextLabel.font = [UIFont systemFontOfSize:15.0f];
    
    UIColor* textColor = shouldDuplicateSettings ? [UIColor darkGrayColor] : [UIColor tableViewCellTextColor];
    self.textLabel.textColor = textColor;
    self.detailTextLabel.textColor = textColor;
}

@end
