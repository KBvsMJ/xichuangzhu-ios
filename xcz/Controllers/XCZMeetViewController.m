//
//  MeetViewController.m
//  xcz
//
//  Created by hustlzp on 15/10/7.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZWork.h"
#import "XCZLike.h"
#import "XCZWorkView.h"
#import "XCZWikiViewController.h"
#import "XCZWorkViewController.h"
#import "XCZMeetViewController.h"
#import "Constants.h"
#import "UIColor+Helper.h"
#import <ionicons/IonIcons.h>
#import <Masonry/Masonry.h>
#import <AVOSCloud.h>

@interface XCZMeetViewController ()

@property (strong, nonatomic) XCZWork *work;
@property (strong, nonatomic) XCZWorkViewController *workDetailsViewController;

@property (strong, nonatomic) UIBarButtonItem *refreshButton;
@property (strong, nonatomic) UIBarButtonItem *wikiButton;
@property (strong, nonatomic) UIBarButtonItem *likeButton;
@property (strong, nonatomic) UIBarButtonItem *unlikeButton;

@property (strong, nonatomic) UIActivityIndicatorView *activityView;
@property (nonatomic) BOOL hasSetupViews;

@end

@implementation XCZMeetViewController

#pragma mark - LifeCycle

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.work = [XCZWork getRandomWork];
    
    [self view];
    
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]
                                             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityView = activityView;
    [activityView startAnimating];
    [self.view bringSubviewToFront:activityView];
    [self.view addSubview:activityView];
    
    [activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initNavbarShowLike:![XCZLike checkExist:self.work.id]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.hasSetupViews) {
        self.hasSetupViews = YES;
        
        [self createViews];
        [self.activityView stopAnimating];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationItem.title = self.work.title;
}

#pragma mark - Layout

- (void)createViews
{
    XCZWorkViewController *controller = [[XCZWorkViewController alloc] initWithWork:self.work];
    self.workDetailsViewController = controller;
    [self addChildViewController:controller];
    [self.view addSubview:controller.view];
    
    [controller.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - Public Interface

#pragma mark - User Interface

- (void)likeWork:(id)sender
{
    if ([XCZLike like:self.work.id]) {
        [self initNavbarShowLike:false];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLikesData" object:nil userInfo:nil];
}

- (void)unlikeWork:(id)sender
{
    if ([XCZLike unlike:self.work.id]) {
        [self initNavbarShowLike:true];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLikesData" object:nil userInfo:nil];
}

- (void)redirectToWiki
{
    if (self.work.baiduWiki) {
        XCZWikiViewController *controller = [[XCZWikiViewController alloc] initWithURL:self.work.baiduWiki];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)refreshWork
{
    [AVAnalytics event:@"refresh_work"];
    self.work = [XCZWork getRandomWork];
    [self.workDetailsViewController updateWithWork:self.work];
    [self initNavbarShowLike:![XCZLike checkExist:self.work.id]];
}

#pragma mark - SomeDelegate

#pragma mark - Internal Helpers

// 设置navbar的按钮显示
- (void)initNavbarShowLike:(bool)showLike
{
    NSMutableArray *btnArrays = [NSMutableArray new];
    
    [btnArrays addObject:self.refreshButton];
    
    if ([self.work.baiduWiki length] > 0) {
        [btnArrays addObject:self.wikiButton];
    }
    
    // 显示收藏/取消收藏按钮
    if (showLike) {
        [btnArrays addObject:self.likeButton];
    } else {
        [btnArrays addObject:self.unlikeButton];
    }
    
    self.navigationItem.rightBarButtonItems = btnArrays;
}

#pragma mark - Getters & Setters

- (UIBarButtonItem *)likeButton
{
    if (!_likeButton) {
        UIImage *likeIcon = [IonIcons imageWithIcon:ion_ios_star_outline
                                          iconColor:[UIColor grayColor]
                                           iconSize:27.0f
                                          imageSize:CGSizeMake(27.0f, 27.0f)];
        _likeButton = [[UIBarButtonItem alloc] initWithImage:likeIcon style:UIBarButtonItemStylePlain target:self action:@selector(likeWork:)];
    }
    
    return _likeButton;
}

- (UIBarButtonItem *)unlikeButton
{
    if (!_unlikeButton) {
        UIImage *unlikeIcon = [IonIcons imageWithIcon:ion_ios_star
                                            iconColor:self.view.tintColor
                                             iconSize:27.0f
                                            imageSize:CGSizeMake(27.0f, 27.0f)];
        _unlikeButton = [[UIBarButtonItem alloc] initWithImage:unlikeIcon style:UIBarButtonItemStylePlain target:self action:@selector(unlikeWork:)];
    }
    
    return _unlikeButton;
}

- (UIBarButtonItem *)refreshButton
{
    if (!_refreshButton) {
        UIImage *refreshIcon = [IonIcons imageWithIcon:ion_ios_loop_strong size:24 color:[UIColor colorWithRGBA:0x8D8D8DFF]];
        _refreshButton = [[UIBarButtonItem alloc] initWithImage:refreshIcon style:UIBarButtonItemStylePlain target:self action:@selector(refreshWork)];
    }
    
    return _refreshButton;
}

- (UIBarButtonItem *)wikiButton
{
    if (!_wikiButton) {
        UIImage *internetIcon = [IonIcons imageWithIcon:ion_ios_world_outline
                                              iconColor:[UIColor grayColor]
                                               iconSize:25.0f
                                              imageSize:CGSizeMake(25.0f, 25.0f)];
        _wikiButton = [[UIBarButtonItem alloc] initWithImage:internetIcon style:UIBarButtonItemStylePlain target:self action:@selector(redirectToWiki)];
    }
    
    return _wikiButton;
}

@end
