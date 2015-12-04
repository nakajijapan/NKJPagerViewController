//
//  MIPagerViewController.m
//  NKJPagerViewController
//
//  Created by nakajijapan on 11/28/14.
//  Copyright (c) 2015 net.nakajijapan. All rights reserved.
//

#import "NKJPagerViewController.h"

const NSInteger NKJPagerViewControllerTabViewTag = 1800;
const NSInteger NKJPagerViewControllerContentViewTag = 2400;

#define kTabsViewBackgroundColor [UIColor colorWithRed:234.0 / 255.0 green:234.0 / 255.0 blue:234.0 / 255.0 alpha:0.75]
#define kContentViewBackgroundColor [UIColor colorWithRed:248.0 / 255.0 green:248.0 / 255.0 blue:248.0 / 255.0 alpha:0.75]

@interface NKJPagerViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property CGFloat leftTabIndex;
@property NSInteger tabCount;
@property UIPageViewController *pageViewController;
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

    self.heightOfTabView = 44.f;
    self.yPositionOfTabView = 64.f;
    self.tabsViewBackgroundColor = kTabsViewBackgroundColor;
    self.infiniteSwipe = YES;
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
        self.tabsView.tag = NKJPagerViewControllerTabViewTag;
        self.tabsView.delegate = self;

        [self.view insertSubview:self.tabsView atIndex:0];

        if (self.isInfinitSwipe) {
            
            self.tabsView.bounces = NO;
            self.tabsView.scrollEnabled = NO;

            UISwipeGestureRecognizer *leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                                             action:@selector(handleSwipeGesture:)];
            leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
            [self.tabsView addGestureRecognizer:leftSwipeGestureRecognizer];
            
            UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                                              action:@selector(handleSwipeGesture:)];
            rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
            [self.tabsView addGestureRecognizer:rightSwipeGestureRecognizer];
            
        } else {
            
            self.tabsView.bounces = YES;
            self.tabsView.scrollEnabled = YES;
            
        }
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
        frame.size.width = [self.dataSource widthOfTabViewWithIndex:i];
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
    if (self.infiniteSwipe) {
        CGFloat contentOffsetWidth =
        [self.dataSource widthOfTabViewWithIndex:0] +
        [self.dataSource widthOfTabViewWithIndex:1] +
        [self.dataSource widthOfTabViewWithIndex:2] -
        ([[UIScreen mainScreen] bounds].size.width - [self.dataSource widthOfTabViewWithIndex:0]) / 2.f;
        self.tabsView.contentOffset = CGPointMake(contentOffsetWidth, 0);
    }
    
    // Add contentView in Superview
    self.contentView = [self.view viewWithTag:NKJPagerViewControllerContentViewTag];
    if (!self.contentView) {

        // Populate pageViewController.view in contentView
        self.contentView = self.pageViewController.view;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.contentView.backgroundColor = kContentViewBackgroundColor;
        self.contentView.bounds = self.view.bounds;
        self.contentView.tag = NKJPagerViewControllerContentViewTag;
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
    if (self.infiniteSwipe) {
        [self selectTabAtIndex:3];
    } else {
        [self selectTabAtIndex:0];
    }

    // Default Design
    if ([self.delegate respondsToSelector:@selector(viewPager:didSwitchAtIndex:withTabs:)]) {
        [self.delegate viewPager:self didSwitchAtIndex:self.activeContentIndex withTabs:self.tabs];
    }
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self defaultSetUp];
}

#pragma mark - Gesture

- (void)handleTapGesture:(UITapGestureRecognizer *)sender
{
    if ([self.delegate respondsToSelector:@selector(viewPager:didTapMenuTabAtIndex:)]) {
        [self.delegate viewPager:self didTapMenuTabAtIndex:sender.view.tag];
    }
    
    [self transitionTabViewWithView:sender.view];
    [self selectTabAtIndex:sender.view.tag];
}

- (void)transitionTabViewWithView:(UIView *)view
{
    CGFloat buttonSize = [self.dataSource widthOfTabViewWithIndex:view.tag];
    CGFloat sizeSpace = ([[UIScreen mainScreen] bounds].size.width - buttonSize) / 2;
    
    if (self.isInfinitSwipe) {
        [self.tabsView setContentOffset:CGPointMake(view.frame.origin.x - sizeSpace, 0) animated:YES];
    } else {
        CGFloat rightEnd = self.tabsView.contentSize.width - [[UIScreen mainScreen] bounds].size.width;
        
        if (view.frame.origin.x <= sizeSpace) {
            [self.tabsView setContentOffset:CGPointMake(0.f, 0.f) animated:YES];
        } else if (view.frame.origin.x >= rightEnd + sizeSpace) {
            [self.tabsView setContentOffset:CGPointMake(rightEnd, 0.f) animated:YES];
        } else {
            [self.tabsView setContentOffset:CGPointMake(view.frame.origin.x - sizeSpace, 0.f) animated:YES];
        }
    }
}

- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)sender
{
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        UIView *activeTabView = [self tabViewAtIndex:4];
        [self transitionTabViewWithView:activeTabView];
        [self selectTabAtIndex:activeTabView.tag];

    } else if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        UIView *activeTabView = [self tabViewAtIndex:2];
        [self transitionTabViewWithView:activeTabView];
        [self selectTabAtIndex:activeTabView.tag];

        if (!self.isInfinitSwipe) {
            [self scrollWithDirection:1];
        }
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

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    if ([self.delegate respondsToSelector:@selector(viewPagerWillTransition:)]) {
        [self.delegate viewPagerWillTransition:self];
    }
}

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
            [self transitionTabViewWithView:view];
            break;
        }
    }

    _activeContentIndex = index;
    
    if (completed) {
        
        if ([self respondsToSelector:@selector(viewPager:willSwitchAtIndex:withTabs:)]) {
            [self.delegate viewPager:self willSwitchAtIndex:self.activeContentIndex withTabs:self.tabs];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self pageAnimationDidFinish];
        });
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isInfinitSwipe) {

        // To scroll
        if (scrollView.tag == NKJPagerViewControllerTabViewTag) { // To scroll
            
            CGFloat buttonSize = [self.dataSource widthOfTabViewWithIndex:self.activeContentIndex];
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
}

#pragma mark - Private Methods

- (void)pageAnimationDidFinish
{
    if ([self.delegate respondsToSelector:@selector(viewPager:didSwitchAtIndex:withTabs:)]) {
        [self.delegate viewPager:self didSwitchAtIndex:self.activeContentIndex withTabs:self.tabs];
    }
}

- (void)setActiveContentIndex:(NSInteger)activeContentIndex
{

    UIViewController *viewController = [self viewControllerAtIndex:activeContentIndex];
    __weak typeof(self) weakSelf = self;

    if (!viewController) {
        viewController = [[UIViewController alloc] init];
        viewController.view = [[UIView alloc] init];
        viewController.view.backgroundColor = [UIColor redColor];
    }

    if (activeContentIndex == self.activeContentIndex) {

        
        if ([self respondsToSelector:@selector(viewPager:willSwitchAtIndex:withTabs:)]) {
            [self.delegate viewPager:self willSwitchAtIndex:self.activeContentIndex withTabs:self.tabs];
        }
        
        [self.pageViewController setViewControllers:@[ viewController ]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:NO
                                         completion:^(BOOL completed){

                                             [weakSelf pageAnimationDidFinish];

                                         }];

    } else {

        NSInteger direction = 0;
        if (activeContentIndex == self.contents.count - 1 && self.activeContentIndex == 0) {

            if (self.isInfinitSwipe) {
                direction = UIPageViewControllerNavigationDirectionReverse;
            } else {
                direction = UIPageViewControllerNavigationDirectionForward;
            }

        } else if (activeContentIndex == 0 && self.activeContentIndex == self.contents.count - 1) {

            if (self.isInfinitSwipe) {
                direction = UIPageViewControllerNavigationDirectionForward;
            } else {
                direction = UIPageViewControllerNavigationDirectionReverse;
            }
            
        } else if (activeContentIndex < self.activeContentIndex) {
            direction = UIPageViewControllerNavigationDirectionReverse;
        } else {
            direction = UIPageViewControllerNavigationDirectionForward;
        }
        
        if ([self respondsToSelector:@selector(viewPager:willSwitchAtIndex:withTabs:)]) {
            [self.delegate viewPager:self willSwitchAtIndex:self.activeContentIndex withTabs:self.tabs];
        }

        [self.pageViewController setViewControllers:@[ viewController ]
                                          direction:direction
                                           animated:YES
                                         completion:^(BOOL completed){

                                             [weakSelf pageAnimationDidFinish];

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
    CGFloat buttonSize = [self.dataSource widthOfTabViewWithIndex:self.activeContentIndex];

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

@end
