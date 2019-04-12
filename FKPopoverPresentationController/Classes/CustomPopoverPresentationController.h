//
//  CustomPopoverPresentationController.h
//  CustomPopoverPresentationController
//
//  Created by 周宏辉 on 2019/4/4.
//  Copyright © 2019 Wefint. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomPopoverPresentationController : UIPresentationController<UIViewControllerTransitioningDelegate>

@property (nonatomic) CGRect sourceRect;

@property (nullable, nonatomic, weak) UIBarButtonItem *barButtonItem;

@end

NS_ASSUME_NONNULL_END
