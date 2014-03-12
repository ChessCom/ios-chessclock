//
//  CHOrangeButton.m
//  ChessClock
//
//  Created by Pedro Mancheno on 3/11/14.
//  Copyright (c) 2014 Chess.com. All rights reserved.
//

#import "CHOrangeButton.h"

@implementation CHOrangeButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initialize];
}

- (void)initialize
{
    UIImage* normalImage = [UIImage imageNamed:@"rectLightOrangeButton"];
    UIEdgeInsets capInsets = UIEdgeInsetsMake(0,1, 0, 1);
    UIImage *normalResizableImage = [normalImage resizableImageWithCapInsets:capInsets];

    [self setImage:normalResizableImage forState:UIControlStateNormal];
    
//    UIImage* pressedImage = [UIImage imageNamed:@"rectLightOrangeButtonPressed"];
//    capInsets = UIEdgeInsetsMake(pressedImage.size.height/2.0, pressedImage.size.width/2.0, pressedImage.size.height/2.0+1, pressedImage.size.width/2.0+1);
//    UIImage *pressedResizableImage = [pressedImage resizableImageWithCapInsets:capInsets];
//    
//    [self setImage:pressedResizableImage forState:UIControlStateSelected];
    
    
}

@end
