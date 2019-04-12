//
//  FKCustomPopoverPresentationController.m
//  FKCustomPopoverPresentationController
//
//  Created by 周宏辉 on 2019/4/4.
//  Copyright © 2019 Wefint. All rights reserved.
//

#import "FKCustomPopoverPresentationController.h"

@interface FKCustomPopoverPresentationController ()<UIViewControllerAnimatedTransitioning>

@property (nonatomic, strong) UIView *presentedWrapperView;
@property (nonatomic, strong) UIControl *dimmingView;

@end




@implementation FKCustomPopoverPresentationController



- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        presentedViewController.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}


- (UIView *)presentedView {
    return self.presentedWrapperView;
}


- (void)presentationTransitionWillBegin {
    
    UIControl *dimmingView = [[UIControl alloc] initWithFrame:self.containerView.bounds];
    dimmingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.containerView addSubview:dimmingView];
    [dimmingView addTarget:self action:@selector(dimmingViewDidTap:) forControlEvents:UIControlEventTouchUpInside];
    self.dimmingView = dimmingView;
    
//    UITapGestureRecognizer *tapR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissController)];
//    [dimmingView addGestureRecognizer:tapR];
    
    UIView *presentedViewControllerView = super.presentedView;
    UIView *presentedWrapperView = [[UIView alloc] initWithFrame:self.frameOfPresentedViewInContainerView];
    presentedViewControllerView.frame = presentedWrapperView.bounds;
    presentedWrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [presentedWrapperView addSubview:presentedViewControllerView];
//    [self.containerView insertSubview:presentedWrapperView aboveSubview:dimmingView];
    self.presentedWrapperView = presentedWrapperView;
    
}


- (void)dimmingViewDidTap:(UIControl *)dimmingView {
    [self.presentedViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    
    if (!completed) {
        self.dimmingView = nil;
        self.presentedWrapperView = nil;
    }
    
}

- (void)dismissalTransitionWillBegin {
    
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    if (completed) {
        self.dimmingView = nil;
        self.presentedWrapperView = nil;
    }
}


- (CGRect)frameOfPresentedViewInContainerView {
    
    CGRect sourceRect;
    
    if (self.barButtonItem) {
        UIView *view = [self.barButtonItem valueForKey:@"view"];
        CGRect frame = CGRectMake(view.frame.origin.x + view.frame.size.width / 2.f, view.frame.origin.y + view.frame.size.height, view.frame.size.width, 1.f);
        sourceRect = [view convertRect:frame toView:UIApplication.sharedApplication.keyWindow];
    } else {
       sourceRect = self.sourceRect;
    }
    
    CGPoint origin = sourceRect.origin;
    CGSize contentSize = [self sizeForChildContentContainer:self.presentedViewController withParentContainerSize:self.containerView.bounds.size];
    
    if ((sourceRect.origin.x + contentSize.width) > self.containerView.frame.size.width) {
        origin.x = self.containerView.frame.size.width - contentSize.width - 10.f;
    }
    
    origin.y = sourceRect.origin.y + sourceRect.size.height;
    
    return CGRectMake(origin.x, origin.y, contentSize.width, contentSize.height);
}

- (CGSize)sizeForChildContentContainer:(id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
    if (container == self.presentedViewController) {
        return self.presentedViewController.preferredContentSize;
    }
    return parentSize;
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(id<UIContentContainer>)container{
    [super preferredContentSizeDidChangeForChildContentContainer:container];
    if (container == self.presentedViewController) {
        [self.containerView setNeedsLayout];
    }
}


- (void)containerViewWillLayoutSubviews {
    [super containerViewWillLayoutSubviews];
    self.dimmingView.frame = self.containerView.bounds;
    self.presentedWrapperView.frame = self.frameOfPresentedViewInContainerView;
}




//animatedTransition


- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.35f;
}


- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    BOOL isPresented = (self.presentedViewController == toViewController);
    
    
    __unused CGRect fromInitialFrame = [transitionContext initialFrameForViewController:fromViewController];
    __unused CGRect toInitialFrame = [transitionContext initialFrameForViewController:toViewController];
    
    CGRect fromFinalFrame = [transitionContext finalFrameForViewController:fromViewController];
    CGRect toFinanlFrame = [transitionContext finalFrameForViewController:toViewController];
    
    NSTimeInterval duration = transitionContext.isAnimated ? [self transitionDuration:transitionContext] : 0.f;
    
    if (isPresented) {
    
        fromView.frame = fromFinalFrame;
        toView.frame = toFinanlFrame;
        
        [transitionContext.containerView addSubview:toView];
        
        toView.alpha = 0.f;
        
        [UIView animateWithDuration:duration animations:^{
            toView.alpha = 1.f;
        } completion:^(BOOL finished) {
            BOOL wasCancelled = [transitionContext transitionWasCancelled];
            [transitionContext completeTransition:!wasCancelled];
        }];
        
    } else {
        
        
        
        [UIView animateWithDuration:duration animations:^{
           
            fromView.alpha = 0.f;
            
        } completion:^(BOOL finished) {
            
            [fromView removeFromSuperview];
            BOOL wasCancelled = [transitionContext transitionWasCancelled];
            [transitionContext completeTransition:!wasCancelled];
            
        }];
        
    }

}



//transition delegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source {
    return self;
}


@end
