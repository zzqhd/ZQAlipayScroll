//
//  MJRefreshModel.h
//  HZBus
//
//  Created by Rdic on 16/10/14.
//  Copyright © 2016年 user. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJRefresh.h"

@class ZQAliPayScrollVC;

@interface MJRefreshModel : NSObject

+ (void) initMJRefreshHead:(ZQAliPayScrollVC *)vc;

+ (void) initMJRefresh:(ZQAliPayScrollVC *)vc;

@end
