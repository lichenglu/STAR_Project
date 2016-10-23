//
//  SCPopoverView.h
//  smartchat
//
//  Created by Yong Lin on 9/5/15.
//  Copyright © 2015 palmdrive. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface SCPopoverView : UIView

- (id)initWithPoint:(CGPoint)point titles:(NSArray *)titles images:(NSArray *)images;
- (void)showWithSelectedIndex:(NSInteger)index;
- (void)dismiss;
- (void)dismiss:(BOOL)animated;

@property (nonatomic, copy) UIColor *borderColor;
@property (nonatomic, copy) void (^selectRowAtIndex)(NSInteger index);

@end
