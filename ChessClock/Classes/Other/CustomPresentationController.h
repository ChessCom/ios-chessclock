//
//  CustomPresentationController.h
//  Chess.com
//
//  Created by Pedro Mancheno on 27/11/14.
//  Copyright (c) 2017 psbt. All rights reserved.
//

/**
 * Presents a view controller modally by superposing it's view on top of the
 * presenting's view, but retaining it's context.
 *
 * Useful for creating a modal presentation with a dimmed background.
 */

typedef enum {
    CustomPresentationAnimationBottomToTop,
    CustomPresentationAnimationFadeIn
} CustomPresentationAnimation;


@interface CustomPresentationController : NSObject

- (void)presentViewController:(UIViewController *)presentedViewController
           fromViewController:(UIViewController *)presentingViewController
        presentationAnimation:(CustomPresentationAnimation)animation;

- (void)presentViewController:(UIViewController *)presentedViewController
           fromViewController:(UIViewController *)presentingViewController
        presentationAnimation:(CustomPresentationAnimation)animation
                     duration:(CGFloat)duration;


@end
