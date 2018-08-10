//
//  ZEHistoryView.m
//  NewCentury
//
//  Created by Stenson on 16/1/27.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

// 导航栏
#define kNavBarWidth SCREEN_WIDTH
#define kNavBarHeight 64.0f
#define kNavBarMarginLeft 0.0f
#define kNavBarMarginTop 0.0f

// 返回按钮位置
#define kCloseBtnWidth  60.0f
#define kCloseBtnHeight 60.0f
#define kCloseBtnMarginLeft 10.0f
#define kCloseBtnMarginTop 12.0f

// 导航栏内右侧按钮
#define kRightButtonWidth 76.0f
#define kRightButtonHeight 40.0f
#define kRightButtonMarginRight -10.0f
#define kRightButtonMarginTop 20.0f + 2.0f
// 导航栏标题
#define kNavTitleLabelWidth SCREEN_WIDTH
#define kNavTitleLabelHeight 44.0f
#define kNavTitleLabelMarginLeft 0.0f
#define kNavTitleLabelMarginTop 20.0f

#define kContentViewMarginTop   NAV_HEIGHT
#define kContentViewMarginLeft  0.0f
#define kContentViewWidth       SCREEN_WIDTH
#define kContentViewHeight      (SCREEN_HEIGHT - kNavBarHeight)


#import "ZEHistoryView.h"
#import "MJRefresh.h"
#import "MJRefreshComponent.h"
#import "ZEEPM_TEAM_RATION_REGModel.h"
#import "JCAlertView.h"
#import "ZEAlertSearchView.h"

@interface ZEHistoryView ()<UITableViewDataSource,UITableViewDelegate,ZEAlertSearchViewDlegate>
{
    CGRect _viewFrame;
    UITableView * _contentTableView;
    
    NSMutableArray * _dateArr;//存储一共有多少个日期
    NSMutableArray * _listDataArr;
    NSInteger _currentMinDate;
    
    JCAlertView * _alertView;
    
    NSArray * statusArr;
    
}
@property (nonatomic,retain) NSMutableArray * dateArr;
@property (nonatomic,retain) NSMutableArray * listDataArr;
@end

@implementation ZEHistoryView
-(id)initWithFrame:(CGRect)rect
{
    self = [super initWithFrame:rect];
    if (self) {
        _viewFrame = rect;
        statusArr = @[@"未提交",@"班长登记",@"已汇总",@"主任退回",@"汇总提交",@"发布退回",@"待发布",@"已发布",@"已审核",@"已退回",@"待审核"];
        self.dateArr = [NSMutableArray array];
        self.listDataArr = [NSMutableArray array];
        [self initNavBar];
        [self initView];
    }
    return self;
}

- (void)initNavBar
{
    UIView *navBar = [[UIView alloc] initWithFrame:CGRectMake(kNavBarMarginLeft, kNavBarMarginTop, kNavBarWidth, kNavBarHeight)];
    [self addSubview:navBar];
    
    [navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(kNavBarMarginLeft);
        make.top.offset(kNavBarMarginTop);
        make.size.mas_equalTo(CGSizeMake(kNavBarWidth, kNavBarHeight));
    }];
    navBar.backgroundColor = MAIN_NAV_COLOR;
    navBar.clipsToBounds = YES;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTitle:@"查询" forState:UIControlStateNormal];
    rightBtn.backgroundColor = [UIColor clearColor];
    rightBtn.contentMode = UIViewContentModeScaleAspectFit;
    [rightBtn addTarget:self action:@selector(goSearch) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:rightBtn];
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(kRightButtonMarginRight);
        make.top.offset(kRightButtonMarginTop);
        make.size.mas_equalTo(CGSizeMake(kRightButtonWidth, kRightButtonHeight));
    }];
    
    UILabel *navTitleLabel = [UILabel new];
    navTitleLabel.backgroundColor = [UIColor clearColor];
    navTitleLabel.textAlignment = NSTextAlignmentCenter;
    navTitleLabel.textColor = [UIColor whiteColor];
    navTitleLabel.font = [UIFont systemFontOfSize:24.0f];
    navTitleLabel.text = @"历史查询";
    [navBar addSubview:navTitleLabel];
    [navTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.rightMargin.offset(kNavTitleLabelMarginLeft);
        make.top.offset(kNavTitleLabelMarginTop);
        make.size.mas_equalTo(CGSizeMake(kNavTitleLabelWidth, kNavTitleLabelHeight));
    }];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(kCloseBtnMarginLeft, kCloseBtnMarginTop, kCloseBtnWidth, kCloseBtnHeight);
    closeBtn.backgroundColor = [UIColor clearColor];
    closeBtn.contentMode = UIViewContentModeScaleAspectFit;
    [closeBtn setImage:[UIImage imageNamed:@"icon_back" color:[UIColor whiteColor]] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    [navBar addSubview:closeBtn];

}

-(void)initView
{
    _contentTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    _contentTableView.delegate = self;
    _contentTableView.dataSource = self;
    [self addSubview:_contentTableView];
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(kContentViewMarginLeft);
        make.top.offset(kContentViewMarginTop);
        make.size.mas_equalTo(CGSizeMake(kContentViewWidth, kContentViewHeight));
    }];
    MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    _contentTableView.mj_header = header;
    
    MJRefreshFooter * footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    _contentTableView.mj_footer = footer;
}


#pragma mark - Public Method
-(void)canLoadMoreData
{
    MJRefreshFooter * footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    _contentTableView.mj_footer = footer;
}
-(void)reloadFirstView:(NSArray *)array
{
    self.listDataArr = [NSMutableArray array];
    self.dateArr = [NSMutableArray array];

    [self reloadView:array];
}
-(void)reloadView:(NSArray *)array
{
    dispatch_queue_t queue = dispatch_queue_create("my.concurrent.queue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        NSMutableArray * detailArr = [NSMutableArray array];
        if (_dateArr.count > 0) {
            detailArr = [NSMutableArray arrayWithArray:[self.listDataArr lastObject]];
            [self.listDataArr removeLastObject];
        }
        for (int i = 0; i < array.count ; i ++ ) {
            NSDictionary * dic = array[i];
            ZEEPM_TEAM_RATION_REGModel * hisModel = [ZEEPM_TEAM_RATION_REGModel getDetailWithDic:dic];
            
            hisModel.ENDDATE = [hisModel.ENDDATE stringByReplacingOccurrencesOfString:@"00:00:00.0" withString:@""];
            
            if (_dateArr.count > 0) {
                if([hisModel.ENDDATE isEqualToString:[_dateArr lastObject]]){
                    [detailArr addObject:hisModel];
                    
                    if (i == array.count - 1) {
                        [self.listDataArr addObject:detailArr];
                    }
                }else{
                    [_dateArr addObject:hisModel.ENDDATE];
                    [self.listDataArr addObject:detailArr];
                    detailArr = [NSMutableArray array];
                    [detailArr addObject:hisModel];                    
                    if (i == array.count - 1) {
                        [self.listDataArr addObject:detailArr];
                    }

                }
            }else{
                [_dateArr addObject:hisModel.ENDDATE];
                [detailArr addObject:hisModel];
                if (i == array.count - 1) {
                    [self.listDataArr addObject:detailArr];
                }
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [_contentTableView.mj_header endRefreshing];
            if (array.count % 20 != 0) {
                [_contentTableView.mj_footer endRefreshingWithNoMoreData];
            }else{
                [_contentTableView.mj_footer endRefreshing];
            }
            [_contentTableView reloadData];
        });
    });
}


/**
 *  隐藏弹出框
 */
-(void)showAlertView:(BOOL)isShow
{
    if(isShow){
        [_alertView dismissWithCompletion:nil];
    }else{
        [self goSearch];
    }
}

-(void)loadNoMoreData
{
    [_contentTableView.mj_footer endRefreshingWithNoMoreData];
}


-(void)loadNewData
{
    if([self.delegate respondsToSelector:@selector(loadNewData:)]){
        [self.delegate loadNewData:self];
    }
}

-(void)loadMoreData{
    if([self.delegate respondsToSelector:@selector(loadMoreData:)]){
        [self.delegate loadMoreData:self];
    }
}
/**
 *  停止刷新
 */
-(void)headerEndRefreshing
{
    [_contentTableView.mj_header endRefreshing];
}

#pragma mark - Provite Method
- (NSString*)weekdayStringFromDate:(NSString*)inputDateStr {
    
    NSArray * dateStrArr = [inputDateStr componentsSeparatedByString:@"-"];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags =NSCalendarUnitYear | NSCalendarUnitMonth |NSCalendarUnitDay | NSCalendarUnitWeekday |
    NSCalendarUnitHour |NSCalendarUnitMinute | NSCalendarUnitSecond;
    [comps setDay:[dateStrArr[2] integerValue]];
    [comps setMonth:[dateStrArr[1] integerValue]];
    [comps setYear:[dateStrArr[0] integerValue]];

    NSDate * date = [calendar dateFromComponents:comps];
    comps = [calendar components:unitFlags fromDate:date];
    
    NSArray *characters = [NSArray arrayWithObjects: [NSNull null], @"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六", nil];
    NSInteger weekday = [comps weekday];
    NSString * weekdayStr = [characters objectAtIndex:weekday];

    return [NSString stringWithFormat:@"%@ %@",inputDateStr,weekdayStr];
}


#pragma mark - UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.listDataArr.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor lightGrayColor];
    headerLabel.opaque = NO;
    headerLabel.text = [NSString stringWithFormat:@"   %@",[self weekdayStringFromDate:_dateArr[section]]];
    headerLabel.textColor = MAIN_COLOR;
    headerLabel.highlightedTextColor = [UIColor whiteColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:13];
    headerLabel.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, 20.0);
    return headerLabel;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * arr = self.listDataArr[section];
    return arr.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{   
    return 50.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellID = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
       cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    for (UIView * view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    ZEEPM_TEAM_RATION_REGModel * hisMod = nil;
    if ([ZEUtil isNotNull:self.listDataArr]) {
        NSArray * sectionDataArr = self.listDataArr[indexPath.section];
        if (sectionDataArr.count > indexPath.row) {
            hisMod = sectionDataArr[indexPath.row];
        }
    }
    
    UIView * cellContent = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50.0f)];
    cellContent.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:cellContent];
    
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10.0f, 5.0f, 46.0f, 40.0f)];
    [imageView setImage:[UIImage imageNamed:@"epm_work_icon.png"]];
    [cellContent addSubview:imageView];
    
    UILabel * realHourLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 80.0f, 0.0f, 70.0f, 50.0f)];
    realHourLabel.font = [UIFont systemFontOfSize:12.0f];
    realHourLabel.textColor = [UIColor lightGrayColor];
    realHourLabel.textAlignment = NSTextAlignmentRight;
    realHourLabel.text = statusArr[[hisMod.STATUS integerValue]];
    [cellContent addSubview:realHourLabel];

    UILabel * taskNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(65.0f, 5.0f, 200.0f, 20.0f)];
    taskNameLabel.font = [UIFont systemFontOfSize:15.0f];
    taskNameLabel.text = hisMod.RATIONNAME;
    [cellContent addSubview:taskNameLabel];
    
    UILabel * staffNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(65.0f, 27.0f, 200.0f, 20.0f)];
    staffNameLabel.text = hisMod.PSNNAME;
    staffNameLabel.font = [UIFont systemFontOfSize:13.0f];
    [cellContent addSubview:staffNameLabel];
    
    return cell;
}

#pragma mark - 删除功能
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZEEPM_TEAM_RATION_REGModel * hisMod = nil;
    if ([ZEUtil isNotNull:self.listDataArr] && self.listDataArr.count > 0) {
        NSArray * sectionDataArr = self.listDataArr[indexPath.section];
        if (sectionDataArr.count > indexPath.row) {
            hisMod = sectionDataArr[indexPath.row];
        }
    }
    
    NSArray * leaderDeleteStatusArr = @[@"0",@"1",@"2",@"3",@"8",@"9",@"10"];
    NSArray * commonDeleteStatusArr = @[@"0",@"9",@"10"];
    
    NSArray * deleteArr = nil;
    if ([ZESettingLocalData getISLEADER]) {
        deleteArr = leaderDeleteStatusArr;
    }else{
        deleteArr = commonDeleteStatusArr;
    }
    
    for (NSString * str in deleteArr) {
        if ([str isEqualToString:hisMod.STATUS]) {
            return YES;
        }
    }

    return NO;
}
//设置编辑风格EditingStyle
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //当表视图处于没有未编辑状态时选择左滑删除
    return UITableViewCellEditingStyleDelete;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZEEPM_TEAM_RATION_REGModel * hisMod = nil;
    if ([ZEUtil isNotNull:self.listDataArr]) {
        NSArray * sectionDataArr = self.listDataArr[indexPath.section];
        if (sectionDataArr.count > indexPath.row) {
            hisMod = sectionDataArr[indexPath.row];
        }
    }
    
//    NSArray * leaderDeleteStatusArr = @[@"0",@"1",@"2",@"3",@"8",@"9",@"10"];
//    NSArray * commonDeleteStatusArr = @[@"0",@"9",@"10"];
//    
//    NSArray * deleteArr = nil;
//    if ([ZESettingLocalData getISLEADER]) {
//        deleteArr = leaderDeleteStatusArr;
//    }else{
//        deleteArr = commonDeleteStatusArr;
//    }
//    
//    for (NSString * str in deleteArr) {
//        if ([str isEqualToString:hisMod.STATUS]) {
//            return;
//        }
//    }

    
    if ([self.delegate respondsToSelector:@selector(deleteHistory:)]) {
        [self.delegate deleteHistory:hisMod.SEQKEY];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZEEPM_TEAM_RATION_REGModel * hisMod = nil;
    if ([ZEUtil isNotNull:self.listDataArr]) {
        hisMod = self.listDataArr[indexPath.section][indexPath.row];
    }
    
    if ([self.delegate respondsToSelector:@selector(enterDetailView:)]) {
        [self.delegate enterDetailView:hisMod.SEQKEY];
    }
}

#pragma mark - ZEHistoryViewDelegate
-(void)goBack
{
    if ([self.delegate respondsToSelector:@selector(goBack)]) {
        [self.delegate goBack];
    }
}

-(void)goSearch
{
    ZEAlertSearchView * customAlertView = [[ZEAlertSearchView alloc]initWithFrame:CGRectZero];
    customAlertView.delegate = self;
    _alertView = [[JCAlertView alloc]initWithCustomView:customAlertView dismissWhenTouchedBackground:NO];
    [_alertView show];
}

#pragma mark - ZEAlertSearchViewDelegate

-(void)cancelSearch
{
    [_alertView dismissWithCompletion:nil];
}
-(void)confirmSearchStartDate:(NSString *)startDate endDate:(NSString *)endDate withPeopleName:(NSString *)name
{
    if ([self.delegate respondsToSelector:@selector(beginSearch:withStartDate:withEndDate:witnPeopleName:)]) {
        [self.delegate beginSearch:self withStartDate:startDate withEndDate:endDate witnPeopleName:name];
    }
}
@end
