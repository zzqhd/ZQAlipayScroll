//
//  MJRefreshModel.m
//  HZBus
//
//  Created by Rdic on 16/10/14.
//  Copyright © 2016年 user. All rights reserved.
//

#import "MJRefreshModel.h"
#import "ZQAliPayScrollVC.h"

@implementation MJRefreshModel

+(void) initMJRefresh:(ZQAliPayScrollVC *)vc {
    
    [[self alloc ]initHeadView:vc];
//    [[self alloc ]initFootView:vc];
}
+ (void) initMJRefreshHead:(ZQAliPayScrollVC *)vc {
    [[self alloc]initHeadView:vc];
}
- (void) initHeadView: (ZQAliPayScrollVC *)vc {
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:vc refreshingAction:@selector(MJHeadViewRefresh)];
    
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;
    
    // 设置文字
    [header setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
    [header setTitle:@"松开刷新" forState:MJRefreshStatePulling];
    [header setTitle:@"加载中 ..." forState:MJRefreshStateRefreshing];
    
    // 设置字体
    header.stateLabel.font = [UIFont systemFontOfSize:15];
    header.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:14];
    
    // 设置颜色
    header.stateLabel.textColor = [UIColor blueColor];
    header.lastUpdatedTimeLabel.textColor = [UIColor blueColor];
    
    // 马上进入刷新状态
//    [header beginRefreshing];
    
    // 设置刷新控件
    vc.tableView.mj_header = header;
}
//- (void) initFootView: (BaseViewController *)vc {
//    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
//    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:vc refreshingAction:@selector(MJFootViewADD)];
//    
//    // 设置文字
//    [footer setTitle:NSLocalString(@"加载更多") forState:MJRefreshStateIdle];
//    [footer setTitle:NSLocalString(@"加载中 ...") forState:MJRefreshStateRefreshing];
//    [footer setTitle:NSLocalString(@"没有更多了") forState:MJRefreshStateNoMoreData];
//
//    // 设置字体
//    footer.stateLabel.font = [UIFont systemFontOfSize:14];
//    
//    // 设置颜色
//    footer.stateLabel.textColor = [UIColor colorWithHexString:@"#8e8e93"];
//    
//    // 设置footer
//    vc.tableView.mj_footer = footer;
//    footer.automaticallyRefresh = NO;
//}

@end

