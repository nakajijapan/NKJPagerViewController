//
//  NKJPagerViewControllerTests.m
//  NKJPagerViewControllerTests
//
//  Created by nakajijapan on 12/2/14.
//  Copyright (c) 2015 net.nakajijapan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NKJPagerViewController.h"
#import "ViewController.h"

@interface NKJPagerViewControllerTests : XCTestCase <NKJPagerViewDataSource>
@property NKJPagerViewController *pagerViewController;
@end

@implementation NKJPagerViewControllerTests

- (void)setUp {
    [super setUp];
    self.pagerViewController = [[NKJPagerViewController alloc] initWithNibName:nil bundle:nil];
    self.pagerViewController.dataSource = self;
    [UIApplication.sharedApplication.delegate.window setRootViewController:self.pagerViewController];
    [self.pagerViewController viewDidLoad];
}

- (void)tearDown {
    [super tearDown];
    self.pagerViewController = nil;
}

- (void)testTabsNotNil {
    XCTAssertTrue(self.pagerViewController.tabs != nil , "");
}

- (void)testTabsCount {
    XCTAssertTrue(self.pagerViewController.tabs.count == 10 , "Count of tabs is correct.");
}

- (void)testTabsViewOfSubViewsCount {
    [self.pagerViewController viewDidLoad];
    XCTAssertTrue(self.pagerViewController.tabsView.subviews.count == 10 , "Count of subviews is correct.");
}

- (void)testTabViewOfWidth {
    UIView *view = (UIView *)self.pagerViewController.tabs[0];
    XCTAssertTrue(view != nil);
    XCTAssertTrue(view.frame.size.width == 125);
}

#pragma mark - NKJPagerViewDataSource

- (NSUInteger)numberOfTabView
{
    return 10;
}

- (NSInteger)widthOfTabView
{
    return 125;
}

- (UIView *)viewPager:(NKJPagerViewController *)viewPager viewForTabAtIndex:(NSUInteger)index
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width / 3, 44)];
    return label;
}

- (UIViewController *)viewPager:(NKJPagerViewController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index
{
    UIViewController *viewController = [[UIViewController alloc] init];
    return viewController;
}

@end
