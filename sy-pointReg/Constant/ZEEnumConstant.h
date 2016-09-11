//
//  ZEEnumConstant.h
//  NewCentury
//
//  Created by Stenson on 16/1/20.
//  Copyright © 2016年 Stenson. All rights reserved.
//

#ifndef ZEEnumConstant_h
#define ZEEnumConstant_h

/*  登记工分选项 */
typedef NS_ENUM (NSInteger,POINT_REG){
    POINT_REG_TASK,
    POINT_REG_DATE,
    POINT_REG_WORKING_HOURS,
    POINT_REG_TYPE,
    POINT_REG_JOB_COUNT,
    POINT_REG_DEGREE,
    POINT_REG_JOB_ROLES,
    POINT_REG_JOB_TIME,
    POINT_REG_QUALITY,
    POINT_REG_EXPLAIN,
    POINT_REG_ALLSCORE,
};

/*  分摊类型 */
typedef NS_ENUM (NSInteger,POINT_REG_SHARE_TYPE){
    POINT_REG_SHARE_TYPE_COE = 1,//按系数分配
    POINT_REG_SHARE_TYPE_PEO,//按人分配
    POINT_REG_SHARE_TYPE_COUNT,//按次数分配
    POINT_REG_SHARE_TYPE_WP,//按 工分 * 系数 分配（workPoints）
};


/*  任务列表 json等级 */
typedef NS_ENUM (NSInteger,TASK_LIST_LEVEL){
    TASK_LIST_LEVEL_NOJSON, //数组中没有包含json数据
    TASK_LIST_LEVEL_JSON    //数组中包含json数据
};

///*  进入工分登记页面方式 */
//typedef NS_ENUM (NSInteger,ENTER_POINTREG_TYPE){
//    ENTER_POINTREG_TYPE_SCAN,      //扫描进入工分登记页面
//    ENTER_POINTREG_TYPE_DEFAULT,   //手动点击进入工分登记页面
//    ENTER_POINTREG_TYPE_HISTORY    //历史详情进入工分登记页面
//};


/* 进入不可以修改的工分登记界面 */
typedef NS_ENUM (NSInteger,ENTER_PERSON_POINTREG_TYPE){
    ENTER_PERSON_POINTREG_TYPE_DEFAULT,
    ENTER_PERSON_POINTREG_TYPE_HISTORY,      //历史进入工分登记固定页面
    ENTER_PERSON_POINTREG_TYPE_AUDIT,    //审核进入工分登记固定页面
};
#endif /* ZEEnumConstant_h */
