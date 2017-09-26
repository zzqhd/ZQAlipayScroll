//
//  ZQAliPayScrollVC.h
//  ZQAlipayScrollDemo
//
//  Created by ZzQ on 2017/9/26.
//  Copyright © 2017年 ZzQ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZQAliPayScrollVC : UIViewController

/** tableview */
@property(nonatomic,strong) UITableView *tableView;


/** 下拉刷新方法  */
- (void) MJHeadViewRefresh;

@end
