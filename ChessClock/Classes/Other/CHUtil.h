//
//  CHUtil.h
//  Chess.com
//
//  Created by Pedro Bolaños on 11/27/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHUtil : NSObject

+ (NSString*)imageNameWithBaseName:(NSString*)baseImageName;
+ (NSString*)formatTime:(NSTimeInterval)timeInSeconds showTenths:(BOOL)showTenths;

@end
