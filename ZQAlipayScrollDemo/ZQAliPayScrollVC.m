//
//  ZQAliPayScrollVC.m
//  ZQAlipayScrollDemo
//
//  Created by ZzQ on 2017/9/26.
//  Copyright © 2017年 ZzQ. All rights reserved.
//

#import "ZQAliPayScrollVC.h"
#import "MJRefreshModel.h"
#import "HeadView.h"
#import "Masonry.h"

@interface ZQAliPayScrollVC ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>
/** 最底部的基类ScrollView*/
@property (nonatomic, strong) UIScrollView *baseScrollView;
/** 城市+搜索+消息*/
@property (nonatomic, strong) HeadView *headView;
/** 需要 转换MJRefresh的箭头方向 */
@property (nonatomic) BOOL needChangeMjRefreshDirection;

@property (nonatomic) NSInteger row_num;

@end

@implementation ZQAliPayScrollVC
#define DefWeakSelf __weak typeof(self) weakSelf = self;
/** 屏幕宽 */
#define G_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
/** 屏幕高 */
#define G_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
/** 下方ScrollView留出的空白，便于观察滚动    */
#define TableViewFootEmptyHeight 120
/** baseScrollView 向上滚动距离最大值    */
#define MaxFloatHeight  60
#define RowHeight 40

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initParameters];
    [self initNavi];
}

#pragma mark - Init

- (void) initParameters {
    self.row_num = 20;
}

- (void) initNavi {
    /*  这句话 可以让tableview 下拉后不留出一段空白不弹回  */
    self.automaticallyAdjustsScrollViewInsets = NO;
    CGRect frame = CGRectMake(0, self.headView.frame.origin.y + self.headView.frame.size.height, G_SCREEN_WIDTH, G_SCREEN_HEIGHT);
    self.tableView = [[UITableView alloc] initWithFrame:frame style: UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.showsVerticalScrollIndicator = YES;
    self.tableView.scrollEnabled = NO;
    [self.baseScrollView addSubview:self.tableView];
    [self.baseScrollView bringSubviewToFront:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor greenColor];
    //下拉刷新
    [MJRefreshModel initMJRefreshHead:self];
    DefWeakSelf;
    CGFloat g_height = G_SCREEN_HEIGHT-ALL_HEADER_HEIGHT - 40;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.headView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(G_SCREEN_WIDTH, g_height));
        make.left.mas_equalTo(weakSelf.view.mas_left);
    }];
    
    [self tableViewReloadData];
}

#pragma mark -  tableView ReloadData
- (void) tableViewReloadData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
    /*  在tableView刷新完成后 更新BaseScrollView的contentSize,因为获取数据后，tableView的内容高度会变，所以BaseScrollView的高度也要跟着变 */
    dispatch_async(dispatch_get_main_queue(), ^{
        /** tableView的高度等于：section*Stop的高度 + routes(选中的站点)*Route的高度 + 更多的高度*/
        
        CGFloat tableViewHeight = (_row_num)*RowHeight;
        CGFloat scrollViewHeight = ALL_HEADER_HEIGHT + tableViewHeight  +  49;
        /** 到目前为止，高度至少应该是屏幕的高度，不然ScrollView的contentSize高度小于实际高度，则不能滑动*/
        scrollViewHeight = MAX(scrollViewHeight, G_SCREEN_HEIGHT);
        scrollViewHeight += TableViewFootEmptyHeight;
        
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(tableViewHeight);
        }];
        
        self.baseScrollView.contentSize = CGSizeMake(G_SCREEN_WIDTH,scrollViewHeight);
    });
}




#pragma mark - Action
- (void)MJHeadViewRefresh {
    NSLog(@"开始刷新");
    _row_num ++;
    [self performSelector:@selector(refreshEnd) withObject:nil afterDelay:1.0f];
}

- (void) refreshEnd {
    [self.tableView.mj_header endRefreshing];
    [self tableViewReloadData];
}


#pragma mark - delegate
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _row_num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%d",(int)(indexPath.row * _row_num)];
    cell.textLabel.textColor = [UIColor blackColor];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return RowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - 支付宝首页滚动效果
// 触发MJ Refresh 偏移量：65
//只要滚动了就会触发
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat edge = scrollView.contentOffset.y;
    
    /*  拦截 只执行scrollview偏移 如果是tableview 则不执行*/
    if (scrollView == self.tableView ) return;
    NSLog(@"%f",edge);
    /** 向下滑动    */
    if ( edge <= 0 ) {
        [self setScrollFrame:edge];
    } else {
        /** 向上滑动    */
    }
    DefWeakSelf
    
    
    /** 设置TitleView的高度，最低不能低于 64 */
    CGFloat height = ALL_HEADER_HEIGHT - edge;
    height = (height <= 80 ) ? 80 : height;
    height = (height >= ALL_HEADER_HEIGHT ) ? ALL_HEADER_HEIGHT : height;
    [self.headView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    /**
     设置tableView top
     如果偏移量小于 xxx 则tableView头部还是顶在titleView上
     如果偏移量大于 xxx 则tableView头部 要再往上走
     */
    CGFloat tableViewEdge = edge - (ALL_HEADER_HEIGHT - 64);
    tableViewEdge = (tableViewEdge >= 0) ? tableViewEdge : 0;
    
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.headView.mas_bottom).offset(-tableViewEdge);
    }];
}


- (void) setScrollFrame: (CGFloat)edge {
    /** 这里设置TableView的 偏移量 使之可以下拉刷新*/
    if (![self.tableView.mj_header isRefreshing]) {
        self.tableView.contentOffset = CGPointMake(0, edge);
    }
    
    /** 因为直接设置 MJRefresh SetStatus 会出现同时设置TableView的ContentSize 导致界面显示BUG，目前先改了MJRefresh的库，手动添加了下动画*/
    if ((_needChangeMjRefreshDirection == NO) && (edge <= -MJRefreshHeaderHeight)) {
        MJRefreshNormalHeader *header = (MJRefreshNormalHeader *)self.tableView.mj_header;
        [header setTitle:@"松开刷新" forState:MJRefreshStateIdle];
        [header transformImageViewByDirection:_needChangeMjRefreshDirection];
        _needChangeMjRefreshDirection = YES;
    } else if ((_needChangeMjRefreshDirection == YES) && (edge <=0) && (edge > -MJRefreshHeaderHeight)) {
        MJRefreshNormalHeader *header = (MJRefreshNormalHeader *)self.tableView.mj_header;
        [header setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
        [header transformImageViewByDirection:_needChangeMjRefreshDirection];
        _needChangeMjRefreshDirection = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat edge = scrollView.contentOffset.y;
    NSLog(@"滑动完毕 BaseScrollView偏移量：%f",edge);
    
    if (scrollView == self.baseScrollView) {
        
        if ( edge < - MJRefreshHeaderHeight )
        {
            [self.tableView.mj_header beginRefreshing];
        }
        /** 自动偏移 位置*/
        [self setBgScrollViewAnimationWithOffsetY:edge];
    }
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    CGFloat edge = scrollView.contentOffset.y;
    
    if (scrollView == self.baseScrollView) {
        
        if ( edge < - MJRefreshHeaderHeight )
        {
            [self.tableView.mj_header beginRefreshing];
        }
        /** 自动偏移 位置*/
        [self setBgScrollViewAnimationWithOffsetY:edge];
    }
}

- (void)setBgScrollViewAnimationWithOffsetY:(CGFloat)edge
{
    if ((edge > 0) && (edge < (ALL_HEADER_HEIGHT - 64))) {
        CGFloat minMove = (ALL_HEADER_HEIGHT - 64)/2;
        if (edge > minMove) {
            [self.baseScrollView setContentOffset:CGPointMake(0, (ALL_HEADER_HEIGHT - 64)) animated:YES];
        } else {
            [self.baseScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    }
}



#pragma mark - =========  getter  ==========

// 基类的ScrollView
- (UIScrollView *)baseScrollView {
    if (!_baseScrollView) {
        _baseScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, G_SCREEN_WIDTH, G_SCREEN_HEIGHT)];
        _baseScrollView.contentSize = CGSizeMake(G_SCREEN_WIDTH, G_SCREEN_HEIGHT + TableViewFootEmptyHeight);
        _baseScrollView.delegate = self;
        _baseScrollView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:_baseScrollView];
        _baseScrollView.layer.zPosition = 90;
    }
    return _baseScrollView;
}

- (HeadView *)headView {
    if (!_headView) {
        DefWeakSelf
        _headView = [[HeadView alloc] init];
        [self.baseScrollView addSubview:_headView];
        _headView.layer.zPosition = 100;
        _headView.userInteractionEnabled = YES;
        [_headView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.view.mas_top);
            make.left.right.mas_equalTo(weakSelf.view);
            make.height.mas_equalTo(ALL_HEADER_HEIGHT);
        }];
    }
    return _headView;
}



@end
