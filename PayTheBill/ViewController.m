//
//  ViewController.m
//  PayTheBill
//
//  Created by yaoxinpan on 2017/11/24.
//  Copyright © 2017年 yaoxp. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>
#import <MJRefresh/MJRefresh.h>

#define kDeviceIsiPhoneX                            ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125,2436),[[UIScreen mainScreen] currentMode].size) : NO)

#define kStatusBarHeight                      (kDeviceIsiPhoneX ? 44 : 20)
#define kStatusBarHeighterThanCommon                (kDeviceIsiPhoneX ? 24 : 0)

#define kUIColorFromRGB(rgbValue)\
\
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]

//#define kNavigationColor            kUIColorFromRGB(0x5167ec)
#define KScreenSize                 [UIScreen mainScreen].bounds.size
@interface ViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate> {
    CGFloat rangeX;  // 动画开始和结束X方向的距离
    CGFloat rangeY;  // 动画开始和结束Y方向的距离
    CGFloat originY; // 动画开始时Y原点
}

@property (nonatomic, strong) UIView *navigationView;
@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) UITableView *tableView;

// navigationView上的视图
@property (nonatomic, strong) UIView *navigationBackView;
@property (nonatomic, strong) UIImageView *smallImgView;
@property (nonatomic, strong) UILabel *titleLabel;

// headView上的视图
@property (nonatomic, strong) UIImageView *iconImgView;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self layoutMainView];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 左线和底线对齐
        rangeX = fabs(self.smallImgView.frame.origin.x - self.iconImgView.frame.origin.x);
        rangeY = fabs((self.smallImgView.frame.origin.y + self.smallImgView.frame.size.height)- (self.iconImgView.frame.origin.y + self.iconImgView.frame.size.height));
        originY = self.tableView.frame.origin.y;
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)endRefresh {
    [self.tableView.mj_header endRefreshing];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (rangeY == 0) {
        return;
    }

    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY == originY) {
        // 原位静止
        self.navigationView.alpha = 1.f;
        self.navigationBackView.alpha = 0.f;
        self.nameLabel.alpha = 1.f;
        [self.iconImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-20);
            make.leading.mas_equalTo(13.5);
            make.width.height.mas_equalTo(60);
        }];

    } else if (offsetY < originY) {
        // 下拉
        self.navigationView.alpha = 0.f;
        self.navigationBackView.alpha = 0.f;
        self.nameLabel.alpha = 1.f;
        [self.iconImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-20);
            make.leading.mas_equalTo(13.5);
            make.width.height.mas_equalTo(60);
        }];
    } else {
        // 上推
        self.navigationView.alpha = 1.f;
        CGFloat currentRangeY = fabs(offsetY - originY);
        CGFloat ratioY = currentRangeY / rangeY; // Y轴已经位移的百分比
        if (ratioY >= 1) {
            self.navigationBackView.alpha = 1.f; //
            self.smallImgView.alpha = 1.f;
            self.iconImgView.alpha = 0.f;
        } else {
            self.iconImgView.alpha = 1.f;
            self.smallImgView.alpha = 0.f;
            self.navigationBackView.alpha = 0.f;
            self.nameLabel.alpha = 1 - ratioY;
            
            [self.iconImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-20);
                make.leading.mas_equalTo(13.5 + rangeX * ratioY);
                make.width.height.mas_equalTo(60 - 30 * ratioY);
            }];

        }
    }

}

#pragma mark - 界面布局
- (void)layoutMainView {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.navigationView];
    
    [self.navigationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(0);
        make.height.mas_equalTo(64 + kStatusBarHeighterThanCommon);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.leading.trailing.mas_equalTo(0);
        make.top.mas_equalTo(-kStatusBarHeight);
    }];
    
    [self layoutNavigationView];
}

- (void)layoutNavigationView {
    [self.navigationView addSubview:self.navigationBackView];
    [self.navigationView addSubview:self.titleLabel];
    [self.navigationView addSubview:self.smallImgView];
    
    [self.navigationBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.bottom.mas_equalTo(0);
        make.top.mas_equalTo(kStatusBarHeight);
        make.width.greaterThanOrEqualTo(@20);
    }];
    [self.smallImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
        make.width.height.mas_equalTo(30);
        make.trailing.mas_equalTo(self.titleLabel.mas_leading).with.offset(-10);
    }];
}


#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    
    cell.textLabel.text = [NSString stringWithFormat:@"row: %ld", (long)indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 160 + kDeviceIsiPhoneX;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"headerBackgroundImg"]];
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.backgroundColor = kUIColorFromRGB(0x1E90FF);
    [view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [view addSubview:self.iconImgView];
    [view addSubview:self.nameLabel];
    [self.iconImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-20);
        make.leading.mas_equalTo(13.5);
        make.width.height.mas_equalTo(60);
    }];
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.iconImgView.mas_trailing).with.offset(10);
        make.centerY.mas_equalTo(self.iconImgView.mas_centerY);
        make.height.mas_equalTo(20);
        make.width.greaterThanOrEqualTo(@40);
    }];
    self.headView = view;
    
    return view;
}

#pragma mark - 属性初始化
- (UIView *)navigationView {
    if (!_navigationView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        _navigationView = view;
    }
    return _navigationView;
}

- (UIView *)navigationBackView {
    if (!_navigationBackView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = kUIColorFromRGB(0x1E90FF);
        view.alpha = 0.f;
        _navigationBackView = view;
    }
    return _navigationBackView;
}


- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, KScreenSize.width, KScreenSize.height-244) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    
        _tableView.rowHeight = 44;
        _tableView.backgroundColor = kUIColorFromRGB(0xf2f2f2);
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(endRefresh)];
        header.lastUpdatedTimeLabel.hidden = YES;
        header.stateLabel.hidden = YES;
        self.tableView.mj_header = header;
    }
    return _tableView;
}

- (UIImageView *)smallImgView {
    if (!_smallImgView) {
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"smallHeaderImg"]];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.alpha = 0.f;
        _smallImgView = imgView;
    }
    return _smallImgView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:17];
        label.text = @"标题";
        _titleLabel = label;
    }
    return _titleLabel;
}

- (UIImageView *)iconImgView {
    if (!_iconImgView) {
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.image = [UIImage imageNamed:@"HeaderImg"];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        _iconImgView = imgView;
    }
    return _iconImgView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.text = @"名字";
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:16];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        _nameLabel = label;
    }
    return _nameLabel;
}

@end
