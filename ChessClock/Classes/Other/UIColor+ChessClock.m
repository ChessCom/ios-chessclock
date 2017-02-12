//
//  UIColor+ChessClock.m
//  ChessClock
//
//  Created by Pedro Mancheno on 2017-02-06.
//  Copyright © 2017 Chess.com. All rights reserved.
//

#import "UIColor+ChessClock.h"

@implementation UIColor (ChessClock)

+ (UIColor *)selectedTimePieceButtonColor
{
    return [UIColor colorWithRed:227.0f / 255.0f green:143.0f / 255.0f blue:51.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)unselectedTimePieceButtonColor
{
    return [UIColor colorWithRed:69.0f / 255.0f green:65.0f / 255.0f blue:61.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)unselectedTimePieceTextColor
{
    return [UIColor colorWithRed:39.0f / 255.0f green:33.0f / 255.0f blue:27.0f / 255.0f alpha:1.0f];
}

@end
