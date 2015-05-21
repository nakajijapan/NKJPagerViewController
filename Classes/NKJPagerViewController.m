//
//  MIPagerViewController.m
//  NKJPagerViewController
//
//  Created by nakajijapan on 11/28/14.
//  Copyright (c) 2015 net.nakajijapan. All rights reserved.
//

#import "NKJPagerViewController.h"

#define kTabViewTag 18
#define kContentViewTag 24

#define kTabsViewBackgroundColor [UIColor colorWithRed:234.0 / 255.0 green:234.0 / 255.0 blue:234.0 / 255.0 alpha:0.75]
#define kContentViewBackgroundColor [UIColor colorWithRed:248.0 / 255.0 green:248.0 / 255.0 blue:248.0 / 255.0 alpha:0.75]

@interface NKJPagerViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate>

@property CGFloat leftTabIndex;
@property NSInteger tabCount;
@property UIPageViewController *pageViewController;

@property (nonatomic) NSInteger activeContentIndex;
@property (nonatomic) NSInteger activeTabIndex;

@end

@implementation NKJPagerViewController

#pragma mark - Initialize

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self defaultSettings];
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self defaultSettings];
    }
    return self;
}

- (void)defaultSettings
{
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
    [self addChildViewController:self.pageViewController];

    ((UIScrollView *)[self.pageViewController.view.subviews objectAtIndex:0]).delegate = self;

    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;

    self.heightOfTabView = 44.0;
    self.yPositionOfTabView = 64.0;
    self.tabsViewBackgroundColor = kTabsViewBackgroundColor;
}

- (void)defaultSetUp
{
    // Empty tabs and contents
    for (UIView *tabView in self.tabs) {
        [tabView removeFromSuperview];
    }
    self.tabsView.contentSize = CGSizeZero;

    [self.tabs removeAllObjects];
    [self.contents removeAllObjects];

    // Initializes
    self.tabCount = [self.dataSource numberOfTabView];
    self.leftTabIndex = 2;
    self.tabs = [NSMutableArray array];
    self.contents = [NSMutableArray array];

    // Add tabsView in Superview
    if (!self.tabsView) {

        self.tabsView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, self.yPositionOfTabView, CGRectGetWidth(self.view.frame), self.heightOfTabView)];
        self.tabsView.userInteractionEnabled = YES;
        self.tabsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.tabsView.backgroundColor = self.tabsViewBackgroundColor;
        self.tabsView.scrollsToTop = NO;
        self.tabsView.showsHorizontalScrollIndicator = NO;
        self.tabsView.showsVerticalScrollIndicator = NO;
        self.tabsView.tag = kTabViewTag;
        self.tabsView.delegate = self;
        self.tabsView.bounces = NO;
        self.tabsView.scrollEnabled = NO;

        [self.view insertSubview:self.tabsView atIndex:0];

        UISwipeGestureRecognizer *leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.tabsView addGestureRecognizer:leftSwipeGestureRecognizer];

        UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        [self.tabsView addGestureRecognizer:rightSwipeGestureRecognizer];
    }

    NSInteger contentSizeWidth = 0;
    for (NSUInteger i = 0; i < self.tabCount; i++) {
        
        if (self.tabs.count >= self.tabCount) {
            continue;
        }

        UIView *tabView = [self.dataSource viewPager:self viewForTabAtIndex:i];
        tabView.tag = i;
        CGRect frame = tabView.frame;
        frame.origin.x = contentSizeWidth;
        frame.size.width = [self.dataSource widthOfTabView];
        tabView.frame = frame;
        tabView.userInteractionEnabled = YES;

        [self.tabsView addSubview:tabView];
        [self.tabs addObject:tabView];

        contentSizeWidth += CGRectGetWidth(tabView.frame);

        // To capture tap events
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [tabView addGestureRecognizer:tapGestureRecognizer];

        // view controller
        [self.contents addObject:[self.dataSource viewPager:self contentViewControllerForTabAtIndex:i]];
    }
    self.tabsView.contentSize = CGSizeMake(contentSizeWidth, self.heightOfTabView);

    // Positioning
    NSInteger contentOffsetWidth =
        [self.dataSource widthOfTabView] * 2 + [self.dataSource widthOfTabView] - ([[UIScreen mainScreen] bounds].size.width - [self.dataSource widthOfTabView]) / 2;
    self.tabsView.contentOffset = CGPointMake(contentOffsetWidth, 0);

    // Add contentView in Superview
    self.contentView = [self.view viewWithTag:kContentViewTag];
    if (!self.contentView) {

        // Populate pageViewController.view in contentView
        self.contentView = self.pageViewController.view;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.contentView.backgroundColor = kContentViewBackgroundColor;
        self.contentView.bounds = self.view.bounds;
        self.contentView.tag = kContentViewTag;
        [self.view insertSubview:self.contentView atIndex:0];

        // constraints
        if ([self.delegate respondsToSelector:@selector(viewPagerDidAddContentView)]) {
            [self.delegate viewPagerDidAddContentView];
        } else {
            self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
            NSDictionary *views = @{
                                    @"contentView"       : self.contentView,
                                    @"topLayoutGuide"    : self.topLayoutGuide,
                                    @"bottomLayoutGuide" : self.bottomLayoutGuide
                                    };
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[contentView]-0-|" options:0 metrics:nil views:views]];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLayoutGuide]-0-[contentView]-0-[bottomLayoutGuide]" options:0 metrics:nil views:views]];
        }
    }

    // Setting Active Index
    [self selectTabAtIndex:3];

    // Default Design
    if ([self.delegate respondsToSelector:@selector(viewPager:didSwitchAtIndex:withTabs:)]) {
        [self.delegate viewPager:self didSwitchAtIndex:self.activeContentIndex withTabs:self.tabs];
    }
}

- (void)viewWillLayoutSubviews
{
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self defaultSetUp];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Gesture

- (void)handleTapGesture:(UITapGestureRecognizer *)sender
{
    [self trasitionTabViewWithView:sender.view];
    [self selectTabAtIndex:sender.view.tag];
}
- (void)trasitionTabViewWithView:(UIView *)view
{
    CGFloat buttonSize = [self.dataSource widthOfTabView];
    CGFloat sizeSpace = ([[UIScreen mainScreen] bounds].size.width - buttonSize) / 2;

    [UIView animateWithDuration:0.3
        animations:^{ self.tabsView.contentOffset = CGPointMake(view.frame.origin.x - sizeSpace, 0); }
        completion:^(BOOL finished) {
            if ([self.delegate respondsToSelector:@selector(viewPager:didSwitchAtIndex:withTabs:)]) {
                [self.delegate viewPager:self didSwitchAtIndex:self.activeContentIndex withTabs:self.tabs];
            }
        }];
}

- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)sender
{
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        UIView *activeTabView = [self tabViewAtIndex:4];
        [self trasitionTabViewWithView:activeTabView];
        [self selectTabAtIndex:activeTabView.tag];

    } else if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        UIView *activeTabView = [self tabViewAtIndex:2];
        [self trasitionTabViewWithView:activeTabView];
        [self selectTabAtIndex:activeTabView.tag];
        [self scrollWithDirection:1];
    }
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{

    NSUInteger index = [self indexForViewController:viewController];
    index++;

    if (index == [self.contents count]) {
        index = 0;
    }

    return [self viewControllerAtIndex:index];
}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexForViewController:viewController];

    if (index == 0) {
        index = [self.contents count] - 1;
    } else {
        index--;
    }

    return [self viewControllerAtIndex:index];
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController
         didFinishAnimating:(BOOL)finished
    previousViewControllers:(NSArray *)previousViewControllers
        transitionCompleted:(BOOL)completed
{
    UIViewController *viewController = self.pageViewController.viewControllers[0];

    // Select tab
    NSUInteger index = [self indexForViewController:viewController];
    for (UIView *view in self.tabsView.subviews) {
        if (view.tag == index) {
            [self trasitionTabViewWithView:view];
        }
    }

    _activeContentIndex = index;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.tag == kTabViewTag) { // To scroll

        NSInteger buttonSize = [self.dataSource widthOfTabView];
        CGFloat position = self.tabsView.contentOffset.x / buttonSize;
        CGFloat delta = position - (CGFloat)self.leftTabIndex;

        if (fabs(delta) >= 1.0f) {
            if (delta > 0) {
                [self scrollWithDirection:0];
            } else {
                [self scrollWithDirection:1];
            }
        }
    }
}

#pragma mark - Private Methods

- (void)setActiveContentIndex:(NSInteger)activeContentIndex
{

    UIViewController *viewController = [self viewControllerAtIndex:activeContentIndex];

    if (!viewController) {
        viewController = [[UIViewController alloc] init];
        viewController.view = [[UIView alloc] init];
        viewController.view.backgroundColor = [UIColor redColor];
    }

    if (activeContentIndex == self.activeContentIndex) {

        [self.pageViewController setViewControllers:@[ viewController ]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:NO
                                         completion:^(BOOL completed){// none
                                         }];

    } else {

        NSInteger direction = 0;
        if (activeContentIndex == self.contents.count - 1 && self.activeContentIndex == 0) {
            direction = UIPageViewControllerNavigationDirectionReverse;
        } else if (activeContentIndex == 0 && self.activeContentIndex == self.contents.count - 1) {
            direction = UIPageViewControllerNavigationDirectionForward;
        } else if (activeContentIndex < self.activeContentIndex) {
            direction = UIPageViewControllerNavigationDirectionReverse;
        } else {
            direction = UIPageViewControllerNavigationDirectionForward;
        }

        [self.pageViewController setViewControllers:@[ viewController ]
                                          direction:direction
                                           animated:YES
                                         completion:^(BOOL completed){// none
                                         }];
    }

    _activeContentIndex = activeContentIndex;
}

- (void)selectTabAtIndex:(NSUInteger)index
{
    if (index >= self.tabCount) {
        return;
    }

    [self setActiveContentIndex:index];
}

- (UIView *)tabViewAtIndex:(NSUInteger)index
{
    return [self.tabs objectAtIndex:index];
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (index >= self.tabCount) {
        return nil;
    }

    return [self.contents objectAtIndex:index];
}

- (NSUInteger)indexForViewController:(UIViewController *)viewController
{
    return [self.contents indexOfObject:viewController];
}

- (void)scrollWithDirection:(NSInteger)direction
{
    CGFloat buttonSize = [self.dataSource widthOfTabView];

    if (direction == 0) {
        UIView *firstView = [self.tabs objectAtIndex:0];
        [self.tabs removeObjectAtIndex:0];
        [self.tabs addObject:firstView];
    } else {
        UIView *lastView = [self.tabs lastObject];
        [self.tabs removeLastObject];
        [self.tabs insertObject:lastView atIndex:0];
    }

    NSUInteger index = 0;
    NSUInteger contentSizeWidth = 0;
    for (UIView *pageView in self.tabs) {

        CGRect frame = pageView.frame;
        frame.origin.x = contentSizeWidth;
        frame.size.width = buttonSize;
        pageView.frame = frame;

        contentSizeWidth += buttonSize;

        ++index;
    }

    if (direction == 0) {
        self.tabsView.contentOffset = CGPointMake(self.tabsView.contentOffset.x - buttonSize, 0);
    } else {
        self.tabsView.contentOffset = CGPointMake(self.tabsView.contentOffset.x + buttonSize, 0);
    }
}

- (void)scrollViewDidEndDirection:(NSNumber *)direction
{
    [self scrollWithDirection:[direction integerValue]];
}

@end
