//
//  ZEPointAuditView.m
//  NewCentury
//
//  Created by Stenson on 16/2/17.
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
#define kRightButtonWidth 70.0f
#define kRightButtonHeight 44.0f
#define kRightButtonMarginLeft kNavBarWidth - kRightButtonWidth - 10.0f
#define kRightButtonMarginTop  22.0f
// 导航栏标题
#define kNavTitleLabelWidth SCREEN_WIDTH
#define kNavTitleLabelHeight 44.0f
#define kNavTitleLabelMarginLeft 0.0f
#define kNavTitleLabelMarginTop 20.0f

#define kContentViewMarginTop   64.0f
#define kContentViewMarginLeft  0.0f
#define kContentViewWidth       SCREEN_WIDTH
#define kContentViewHeight      (SCREEN_HEIGHT - kNavBarHeight)

#import "ZEPointAuditView.h"
#import "MJRefresh.h"

//#import "ZEPointAuditModel.h"

#import "ZEEPM_TEAM_RATION_REGModel.h"
@interface ZEPointAuditView ()
{
    UITableView * _contentTableView;
    NSInteger _currentSelectRow;
    NSArray * statusArr;
    NSString * _multipleStr;
    
    UILabel * navTitleLabel;
    UIButton *rightBtn;
}
@property (nonatomic,retain) NSMutableArray * dateArr;
@property (nonatomic,retain) NSMutableArray * listDataArr;

@property (nonatomic,retain) NSMutableArray * detailListDataArr;
@property (nonatomic,retain) NSMutableDictionary * detailListDataDic;

@end

@implementation ZEPointAuditView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        statusArr = @[@"未提交",@"班长登记",@"已汇总",@"主任退回",@"汇总提交",@"发布退回",@"待发布",@"已发布",@"已审核",@"已退回",@"待审核"];

        [self initNavBar];
        [self initView];
    }
    return self;
}

#pragma mark - initView
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
        
    navTitleLabel = [UILabel new];
    navTitleLabel.backgroundColor = [UIColor clearColor];
    navTitleLabel.textAlignment = NSTextAlignmentCenter;
    navTitleLabel.textColor = [UIColor whiteColor];
    navTitleLabel.font = [UIFont systemFontOfSize:24.0f];
    navTitleLabel.text = @"工时审核";
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
    
    rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(kRightButtonMarginLeft, kRightButtonMarginTop, kRightButtonWidth, kRightButtonHeight);
    rightBtn.backgroundColor = [UIColor clearColor];
    rightBtn.contentMode = UIViewContentModeScaleAspectFit;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [rightBtn setTitle:@"批量审核" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(goEdit:) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:rightBtn];
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

#pragma mark - PublicMethod
/**
 *  刷新界面
 */
-(void)reloadFirstView:(NSArray *)array withDetailDataArr:(NSArray *)arr
{
    self.listDataArr = [NSMutableArray array];
    self.detailListDataArr = [NSMutableArray array];
    self.detailListDataDic = [NSMutableDictionary dictionary];
    self.dateArr = [NSMutableArray array];
    
    [self reloadView:array withDetailDataArr:arr];
}
-(void)reloadView:(NSArray *)array withDetailDataArr:(NSArray *)arr
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
            ZEEPM_TEAM_RATION_REGModel * pointAM = [ZEEPM_TEAM_RATION_REGModel getDetailWithDic:dic];
            pointAM.ENDDATE = [pointAM.ENDDATE stringByReplacingOccurrencesOfString:@"00:00:00.0" withString:@""];

            if (_dateArr.count > 0) {
                if([pointAM.ENDDATE isEqualToString:[_dateArr lastObject]]){
                    [detailArr addObject:pointAM];
                    if (i == array.count - 1) {
                        [self.listDataArr addObject:detailArr];
                    }
                }else{
                    [_dateArr addObject:pointAM.ENDDATE];
                    [self.listDataArr addObject:detailArr];
                    detailArr = [NSMutableArray array];
                    [detailArr addObject:pointAM];
                    if (i == array.count - 1) {
                        [self.listDataArr addObject:detailArr];
                    }
                }
            }else{
                [_dateArr addObject:pointAM.ENDDATE];
                [detailArr addObject:pointAM];
                if (i == array.count - 1) {
                    [self.listDataArr addObject:detailArr];
                }
            }
        }
        
        for (int j = 0 ; j < arr.count; j++) {
            NSDictionary * dic = arr[j];
            NSString * taskID = [dic objectForKey:@"TASKID"];
            NSMutableArray * keyArr = [NSMutableArray arrayWithArray:[_detailListDataDic objectForKey:taskID]];
            [keyArr addObject:dic];
            [_detailListDataDic setObject:keyArr forKey:taskID];
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            _contentTableView.editing = NO;
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
 *  停止刷新
 */
-(void)headerEndRefreshing
{
    [_contentTableView.mj_header endRefreshing];
}

/**
 *  审核成功，刷新界面
 */
-(void)auditSuccessRefreshView
{
    
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

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.listDataArr.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = RGBA(230, 230, 230, 1);
    headerLabel.opaque = NO;
    headerLabel.text = [NSString stringWithFormat:@"   %@",[self weekdayStringFromDate:_dateArr[section]]];
//    headerLabel.textColor = ;
    headerLabel.highlightedTextColor = [UIColor whiteColor];
    headerLabel.font = [UIFont systemFontOfSize:13];
    headerLabel.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, 30.0);
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
    
    for (UIView * view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    if(tableView.isEditing){
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }else{
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    ZEEPM_TEAM_RATION_REGModel * pointAM = nil;
    if ([ZEUtil isNotNull:self.listDataArr]) {
        NSArray * sectionDataArr = self.listDataArr[indexPath.section];
        if (sectionDataArr.count > indexPath.row) {
            pointAM = self.listDataArr[indexPath.section][indexPath.row];
        }
    }
    
    UIView * cellContent = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50.0f)];
    cellContent.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:cellContent];
    
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10.0f, 5.0f, 46.0f, 40.0f)];
    [imageView setImage:[UIImage imageNamed:@"epm_work_icon.png"]];
    [cellContent addSubview:imageView];
    

//    UILabel * realHourLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 80.0f, 0.0f, 70.0f, 50.0f)];
//    realHourLabel.font = [UIFont systemFontOfSize:12.0f];
//    realHourLabel.textColor = [UIColor lightGrayColor];
//    realHourLabel.textAlignment = NSTextAlignmentRight;
//    realHourLabel.text = statusArr[[pointAM.STATUS integerValue]];
//    [cellContent addSubview:realHourLabel];
    
    UILabel * taskNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(65.0f, 5.0f, 200.0f, 20.0f)];
    taskNameLabel.font = [UIFont systemFontOfSize:15.0f];
    taskNameLabel.text = pointAM.RATIONNAME;
    [cellContent addSubview:taskNameLabel];
    
    UILabel * staffNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(65.0f, 27.0f, 200.0f, 20.0f)];
    staffNameLabel.text = pointAM.PSNNAME;
    staffNameLabel.font = [UIFont systemFontOfSize:13.0f];
    [cellContent addSubview:staffNameLabel];
    
    NSArray * arr = [_detailListDataDic objectForKey:pointAM.SEQKEY];
    NSString * staffName = @"";
    for (int i = 0; i < arr.count; i ++) {
        ZEEPM_TEAM_RATION_REGModel * scoreModel = [ZEEPM_TEAM_RATION_REGModel getDetailWithDic:arr[i]];
        if (staffName.length == 0) {
            staffName = [NSString stringWithFormat:@"%@（%.2f）",scoreModel.PSNNAME,[scoreModel.WORKPOINTS floatValue]];
        }else{
            staffName = [NSString stringWithFormat:@"%@,%@（%.2f）",staffName,scoreModel.PSNNAME,[scoreModel.WORKPOINTS floatValue]];
        }
    }
    staffNameLabel.text = staffName;

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
    if (tableView.isEditing) {
        // 多选
        return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
    }else{
        // 删除
        return UITableViewCellEditingStyleDelete;
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZEEPM_TEAM_RATION_REGModel * pointAM = nil;
    if ([ZEUtil isNotNull:self.listDataArr]) {
        NSArray * sectionDataArr = self.listDataArr[indexPath.section];
        if (sectionDataArr.count > indexPath.row) {
            pointAM = sectionDataArr[indexPath.row];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(deleteNoAuditHistory:)]) {
        [self.delegate deleteNoAuditHistory:pointAM.SEQKEY];
    }
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.isEditing){
        return;
    }
    ZEEPM_TEAM_RATION_REGModel * pointAM = nil;
    if ([ZEUtil isNotNull:self.listDataArr]) {
        pointAM = self.listDataArr[indexPath.section][indexPath.row];
    }
    if ([self.delegate respondsToSelector:@selector(enterDetailView:)]) {
        [self.delegate enterDetailView:pointAM.SEQKEY];
    }
}

#pragma mark - ZEPointAuditViewDelegate

-(void)goAudit
{
    if([self.delegate respondsToSelector:@selector(goAuditVC)]){
        [self.delegate goAuditVC];
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
-(void)goBack
{
    if (_contentTableView.editing) {
        [rightBtn setTitle:@"批量审核" forState:UIControlStateNormal];
        [_contentTableView setEditing:NO animated:YES];
        rightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        navTitleLabel.text = @"工时审核";
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(goBack)]) {
        [self.delegate goBack];
    }
}

-(void)goEdit:(UIButton*)btn
{
    _multipleStr = @"";
    NSArray * arr = [_contentTableView indexPathsForSelectedRows];
    for (int i = 0; i < arr.count; i ++) {
        NSIndexPath * indexPathCell = arr[i];
        NSArray * sectionDataArr = self.listDataArr[indexPathCell.section];
        if (sectionDataArr.count > indexPathCell.row) {
            ZEEPM_TEAM_RATION_REGModel * pointAM = sectionDataArr[indexPathCell.row];
            if (_multipleStr.length > 0) {
                _multipleStr = [NSString stringWithFormat:@"%@,%@",_multipleStr,pointAM.SEQKEY];
            }else{
                _multipleStr = pointAM.SEQKEY;
            }
        }
    }
    
    if(_contentTableView.isEditing){
        [btn setTitle:@"批量审核" forState:UIControlStateNormal];
        [_contentTableView setEditing:NO animated:YES];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        navTitleLabel.text = @"工时审核";
        if (_multipleStr.length > 0) {
            self.multipleBlock(_multipleStr);
        }
    }else{
        [btn setTitle:@"审核" forState:UIControlStateNormal];
        [_contentTableView setEditing:YES animated:YES];
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        navTitleLabel.text = @"批量审核";
    }
    [_contentTableView reloadData];
    
}


@end
