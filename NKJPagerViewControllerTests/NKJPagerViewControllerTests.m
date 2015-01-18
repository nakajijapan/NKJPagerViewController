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

@interface NKJPagerViewControllerTests : XCTestCase <NKJPagerViewDataSource>
@property NKJPagerViewController *pagerViewController;
@end

@implementation NKJPagerViewControllerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.pagerViewController = [[NKJPagerViewController alloc] init];
    self.pagerViewController.dataSource = self;
    [UIApplication.sharedApplication.delegate.window setRootViewController:self.pagerViewController];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    self.pagerViewController = nil;
}

- (void)testTabsCount {
    XCTAssert(self.pagerViewController.tabs.count == 10 , "Count of tabs is correct.");
}

- (void)testTabsViewOfSubViewsCount {
    XCTAssert(self.pagerViewController.tabsView.subviews.count == 10 , "Count of subviews is correct.");
}

- (void)testTabViewOfWidth {
    UIView *view = (UIView *)self.pagerViewController.tabs[0];
    NSLog(@"%@", view);
    XCTAssert(view.frame.size.width == 125 , "Width of tabView is correct.");
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
