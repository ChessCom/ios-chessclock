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

+ (UIColor *)navigationBarTintColor
{
    return [UIColor colorWithRed:39.0f / 255.0f green:37.0f / 255.0f blue:34.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)navigationBarTextColor
{
    return [UIColor colorWithRed:159.0f / 255.0f green:158.0f / 255.0f blue:157.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)tableViewCellTextColor
{
    return [UIColor colorWithRed:201.0f / 255.0f green:200.0f / 255.0f blue:200.0f / 255.0f alpha:1.0f];
}

@end
