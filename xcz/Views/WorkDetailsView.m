//
//  WorkDetailsView.m
//  xcz
//
//  Created by hustlzp on 15/10/7.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZQuoteView.h"
#import "XCZCopyableLabel.h"
#import "WorkDetailsView.h"
#import "UIColor+Helper.h"
#import <Masonry/Masonry.h>

@interface WorkDetailsView ()

@property (strong, nonatomic) XCZWork *work;
@property (strong, nonatomic) HTCopyableLabel *titleLabel;
@property (strong, nonatomic) UILabel *authorLabel;
@property (strong, nonatomic) XCZCopyableLabel *contentLabel;
@property (strong, nonatomic) UILabel *introHeaderLabel;
@property (strong, nonatomic) XCZCopyableLabel *introLabel;
@property (strong, nonatomic) UILabel *quotesHeaderLabel;

@end

@implementation WorkDetailsView

- (instancetype)initWithWork:(XCZWork *)work
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.work = work;
    
    NSInteger quotesCount = [XCZQuote getByWorkId:self.work.id].count;
    
    // 标题
    HTCopyableLabel *titleLabel = [HTCopyableLabel new];
    self.titleLabel = titleLabel;
    titleLabel.numberOfLines = 0;
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.font = [UIFont systemFontOfSize:25];
    NSMutableParagraphStyle *titleParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    titleParagraphStyle.lineHeightMultiple = 1.2;
    titleParagraphStyle.alignment = NSTextAlignmentCenter;
    titleLabel.attributedText = [[NSAttributedString alloc] initWithString:self.work.title attributes:@{NSParagraphStyleAttributeName: titleParagraphStyle}];
    [self addSubview:titleLabel];
    
    // 作者
    UILabel *authorLabel = [UILabel new];
    self.authorLabel = authorLabel;
    authorLabel.textAlignment = NSTextAlignmentCenter;
    authorLabel.text = [NSString stringWithFormat:@"[%@] %@", self.work.dynasty, self.work.author];
    [self addSubview:authorLabel];
    
    // 内容
    XCZCopyableLabel *contentLabel = [XCZCopyableLabel new];
    self.contentLabel = contentLabel;
    contentLabel.numberOfLines = 0;
    contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    NSMutableParagraphStyle *contentParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    if ([self.work.layout isEqual: @"indent"]) {
        // 缩进排版
        contentParagraphStyle.firstLineHeadIndent = 25;
        contentParagraphStyle.paragraphSpacing = 10;
        contentParagraphStyle.lineHeightMultiple = 1.35;
    } else {
        // 居中排版
        contentParagraphStyle.alignment = NSTextAlignmentCenter;
        contentParagraphStyle.paragraphSpacing = 10;
        contentParagraphStyle.lineHeightMultiple = 1;
    }
    contentLabel.attributedText = [[NSAttributedString alloc] initWithString:self.work.content attributes:@{NSParagraphStyleAttributeName: contentParagraphStyle}];
    [self addSubview:contentLabel];
    
    // 评析header
    UILabel *introHeaderLabel = [UILabel new];
    self.introHeaderLabel = introHeaderLabel;
    introHeaderLabel.text = @"评析";
    introHeaderLabel.textColor = [UIColor XCZMainColor];
    [self addSubview:introHeaderLabel];
    
    // 评析
    XCZCopyableLabel *introLabel = [XCZCopyableLabel new];
    self.introLabel = introLabel;
    introLabel.numberOfLines = 0;
    introLabel.lineBreakMode = NSLineBreakByWordWrapping;
    introLabel.font = [UIFont systemFontOfSize:14];
    introLabel.textColor = [UIColor colorWithRGBA:0x333333FF];
    NSMutableParagraphStyle *introParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    introParagraphStyle.lineHeightMultiple = 1.3;
    introParagraphStyle.paragraphSpacing = 8;
    introLabel.attributedText = [[NSAttributedString alloc] initWithString:self.work.intro attributes:@{NSParagraphStyleAttributeName: introParagraphStyle}];
    [self addSubview:introLabel];
    
    // 摘录header
    UILabel *quotesHeaderLabel = [UILabel new];
    self.quotesHeaderLabel = quotesHeaderLabel;
    quotesHeaderLabel.text = [NSString stringWithFormat:@"摘录 / %ld", (long)quotesCount];
    quotesHeaderLabel.text = @"摘录";
    quotesHeaderLabel.textColor = [UIColor XCZMainColor];
    [self addSubview:quotesHeaderLabel];
    
    // 约束
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(40);
        make.left.equalTo(self).offset(30);
        make.right.equalTo(self).offset(-30);
    }];
    
    [authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(15);
        make.left.equalTo(self).offset(15);
        make.right.equalTo(self).offset(-15);
    }];
    
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if ([self.work.layout isEqual: @"indent"]) {
            make.top.equalTo(authorLabel.mas_bottom).offset(10);
        } else {
            make.top.equalTo(authorLabel.mas_bottom).offset(16);
        }
        
        make.left.equalTo(self).offset(15);
        make.right.equalTo(self).offset(-15);
    }];
    
    [introHeaderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.right.equalTo(self).offset(-15);
        make.top.equalTo(contentLabel.mas_bottom).offset(20);
    }];
    
    [introLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(introHeaderLabel.mas_bottom).offset(5);
        make.left.equalTo(self).offset(15);
        make.right.equalTo(self).offset(-15);
    }];
    
    [quotesHeaderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(introLabel.mas_bottom).offset(18);
        make.left.equalTo(self).offset(15);
        make.right.equalTo(self).offset(-15);
        
        if (quotesCount > 0) {
            make.bottom.equalTo(self).offset(0);
        } else {
            make.bottom.equalTo(self).offset(-15);
        }
    }];
    
    return self;
}

#pragma mark - public methods

- (void)enterFullScreenMode
{
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(60);
    }];
}

- (void)exitFullScreenMode
{
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(40);
    }];
}

@end
