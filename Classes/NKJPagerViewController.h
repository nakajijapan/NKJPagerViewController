//
//  NKJPagerViewController.h
//  NKJPagerViewController
//
//  Created by nakajijapan on 11/28/14.
//  Copyright (c) 2015 net.nakajijapan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NKJPagerViewDataSource;
@protocol NKJPagerViewDelegate;

@interface NKJPagerViewController : UIViewController

@property NSMutableArray *tabs;     // Views
@property NSMutableArray *contents; // ViewControllers

@property UIScrollView *tabsView;
@property UIView *contentView;

@property id<NKJPagerViewDataSource> dataSource;
@property id<NKJPagerViewDelegate> delegate;

- (void)setActiveContentIndex:(NSInteger)index;

@property CGFloat heightOfTabView;
@property CGFloat yPositionOfTabView;
@property UIColor *tabsViewBackgroundColor;
@end

#pragma mark NKJPagerViewDataSource

@protocol NKJPagerViewDataSource <NSObject>
- (NSUInteger)numberOfTabView;
- (NSInteger)widthOfTabView;

- (UIView *)viewPager:(NKJPagerViewController *)viewPager viewForTabAtIndex:(NSUInteger)index;
- (UIViewController *)viewPager:(NKJPagerViewController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index;
@end

#pragma mark NKJPagerViewDelegate

@protocol NKJPagerViewDelegate <NSObject>

@optional
- (void)viewPager:(NKJPagerViewController *)viewPager didSwitchAtIndex:(NSInteger)index withTabs:(NSArray *)tabs;
- (void)viewPagerDidAddContentView;
@end
