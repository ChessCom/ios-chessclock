//
//  CustomPresentationController.m
//  Chess.com
//
//  Created by Pedro Mancheno on 27/11/14.
//  Copyright (c) 2017 psbt. All rights reserved.
//

#import "CustomPresentationController.h"

static const CGFloat CustomPresentationAnimationDuration = 0.25f;

@interface CustomPresentationController () <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

@property (assign, nonatomic) BOOL isPresenting;
@property (assign, nonatomic) CustomPresentationAnimation animation;
@property (assign, nonatomic) CGFloat duration;


@end

@implementation CustomPresentationController

- (instancetype)init
{
    if (self = [super init]) {
        self.duration = CustomPresentationAnimationDuration;
    }
    
    return self;
}

- (void)presentViewController:(UIViewController *)presentedViewController
           fromViewController:(UIViewController *)presentingViewController
        presentationAnimation:(CustomPresentationAnimation)animation
{
    self.animation = animation;
    presentedViewController.modalPresentationStyle = UIModalPresentationCustom;
    presentedViewController.transitioningDelegate = self;
    presentedViewController.modalPresentationCapturesStatusBarAppearance = YES;
    
    [presentedViewController setNeedsStatusBarAppearanceUpdate];
    
    //this means the same controller is already pushed, lets skip this call then
    if ([presentingViewController.presentedViewController isKindOfClass:presentedViewController.class]) {
        return;
    }
    [presentingViewController presentViewController:presentedViewController
                                           animated:YES
                                         completion:nil];
}

- (void)presentViewController:(UIViewController *)presentedViewController
           fromViewController:(UIViewController *)presentingViewController
        presentationAnimation:(CustomPresentationAnimation)animation
                     duration:(CGFloat)duration
{
    self.duration = duration;
    
    [self presentViewController:presentedViewController
             fromViewController:presentingViewController
          presentationAnimation:animation];
}

#pragma mark - UIViewController transition delegate

- (id <UIViewControllerAnimatedTransitioning> )animationControllerForPresentedController:(UIViewController *)presented

                                                                    presentingController:(UIViewController *)presenting
                                                                        sourceController:(UIViewController *)source
{
    self.isPresenting = YES;
    
    return self;
}

- (id <UIViewControllerAnimatedTransitioning> )animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.isPresenting = NO;
    
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning protocol

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning> )transitionContext
{
    return CustomPresentationAnimationDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning> )transitionContext
{
    UIViewController *firstVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *secondVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    UIView *firstView = firstVC.view;
    UIView *secondView = secondVC.view;
    
    BOOL isBottomToTopAnimation = self.animation == CustomPresentationAnimationBottomToTop;
    
    if (self.isPresenting) {
        [containerView addSubview:secondView];
        secondView.frame = (CGRect) {
            containerView.frame.origin.x,
            isBottomToTopAnimation ? containerView.frame.origin.y + containerView.frame.size.height : containerView.frame.origin.y,
            containerView.frame.size
        };
        
        secondView.alpha = isBottomToTopAnimation ? 1.f : 0.f;
        
        [UIView animateWithDuration:CustomPresentationAnimationDuration
                         animations: ^{
                             if (isBottomToTopAnimation) {
                                 secondView.frame = containerView.frame;
                             }
                             else {
                                 secondView.alpha = 1.f;
                             }
                         } completion: ^(BOOL finished) {
                             [transitionContext completeTransition:YES];
                         }];
    }
    else {
        [UIView animateWithDuration:CustomPresentationAnimationDuration
                         animations: ^{
                             if (isBottomToTopAnimation) {
                                 firstView.frame = (CGRect) {
                                     containerView.frame.origin.x,
                                     containerView.frame.origin.y + containerView.frame.size.height,
                                     containerView.frame.size
                                 };
                             }
                             else {
                                 firstView.alpha = 0.f;
                             }
                         } completion: ^(BOOL finished) {
                             [transitionContext completeTransition:YES];
                         }];
    }
}

@end

