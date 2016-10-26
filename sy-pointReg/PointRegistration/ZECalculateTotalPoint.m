//
//  ZECalculateTotalPoint.m
//  sy-pointReg
//
//  Created by Stenson on 16/8/26.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import "ZECalculateTotalPoint.h"

#import "ZEPointRegCache.h"

#import "ZEFormulaStringCalcUtility.h"

#import "ZEEPM_TEAM_RATION_COMMON.h"
#import "ZEEPM_TEAM_RATIONTYPEDETAIL.h"

static ZECalculateTotalPoint * pointRegCahe = nil;

@interface ZECalculateTotalPoint ()
{
    NSMutableArray * _personalDataArr;
    NSMutableDictionary * _taskDic;
    
    NSMutableArray * _orginPersonalDataArr;
    NSDictionary * _originTaskDic;
    
    float _resultPoint;
}
@end

@implementation ZECalculateTotalPoint

-(id)initSingle
{
    self = [super init];
    if (self) {
        _personalDataArr = [NSMutableArray array];
        _taskDic = [NSMutableDictionary dictionary];
    }
    return self;
}

-(id)init
{
    return [ZECalculateTotalPoint instance];
}


+(ZECalculateTotalPoint *)instance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        pointRegCahe = [[ZECalculateTotalPoint alloc] initSingle];
    });
    return pointRegCahe;
}

-(void)calcul
{
    ZEEPM_TEAM_RATION_COMMON * taskM = [ZEEPM_TEAM_RATION_COMMON getDetailWithDic:_taskDic];

    // 计算是否均摊
    double JunTanHj = 0;
    for (NSInteger i = 0 ; i < _personalDataArr.count ; i ++) {
        double Hj = 1;
        double JkHj = 0;
        double JunTanHjPer = 0;
        
        /**
         *  @author Stenson, 16-09-03 17:09:33
         *
         *  获取缓存中 分配类型系数列表
         */
        NSDictionary * coefficientDic = [[ZEPointRegCache instance] getDistributionTypeCoefficient];
        
        /**
         *  @author Stenson, 16-09-03 17:09:53
         *
         *  获取选定的任务类型的分配系数列表
         */
        NSArray * coefficientArr = [coefficientDic objectForKey:taskM.RATIONTYPE];

        NSMutableDictionary * personalDic = [NSMutableDictionary dictionaryWithDictionary:_personalDataArr[i]];
        for (int j = 1; j  <= coefficientArr.count; j++) {
            NSDictionary * quotietycodeMap = coefficientArr[j - 1];
            
            ZEEPM_TEAM_RATIONTYPEDETAIL * detailM = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:quotietycodeMap];
            NSString * type = detailM.TYPE;
            NSString * isselect = detailM.ISSELECT;
            NSString * formulaquotiety = detailM.FORMULA;
            NSString * isration = detailM.ISRATION;
            NSString * minvalue = detailM.MINVALUE;
            
            if([isration boolValue]){
                NSString * QUOTIETY = [detailM.FIELDNAME stringByReplacingOccurrencesOfString:@"CODE" withString:@""];

                NSString * quotietytemp= [NSString stringWithFormat:@"%@",[_taskDic objectForKey:QUOTIETY]];
                if([ZEUtil strIsEmpty:quotietytemp]){
                    if([type integerValue] == 1||[type integerValue] == 2){
                        [_taskDic setObject:@"1" forKey:QUOTIETY];
                    }
                    if([type integerValue] == 1){
                        [_taskDic setObject:@"0" forKey:QUOTIETY];
                    }
                }
            }else{
                NSString * QUOTIETY = [detailM.FIELDNAME stringByReplacingOccurrencesOfString:@"CODE" withString:@""];
                NSString * quotietytemp= [NSString stringWithFormat:@"%@",[personalDic objectForKey:QUOTIETY]];
                if([ZEUtil strIsEmpty:quotietytemp]){
                    if([type integerValue] == 1||[type integerValue] == 2){
                        [personalDic setObject:@"1" forKey:QUOTIETY];
                    }
                    if([type integerValue] == 1){
                        [personalDic setObject:@"0" forKey:QUOTIETY];
                    }
                }
                [_personalDataArr replaceObjectAtIndex:i withObject:personalDic];
            }

            if([ZEUtil strIsEmpty:minvalue]){
                minvalue=@"1";
            }

            if ([isselect boolValue] && ![isration boolValue]) {
                
                NSString * QUOTIETY = [detailM.FIELDNAME stringByReplacingOccurrencesOfString:@"CODE" withString:@""];
                
                if (![ZEUtil strIsEmpty:formulaquotiety]) {
                    formulaquotiety = [self getRationTypeValue:formulaquotiety withTaskDic:_personalDataArr[i] withPersonalData:_personalDataArr[i]];
                    if([formulaquotiety doubleValue] < [minvalue doubleValue]){
                        formulaquotiety=minvalue;
                    }
                    [personalDic setObject:formulaquotiety forKey:QUOTIETY];
                }
                if (![ZEUtil strIsEmpty:type]) {
                    if ([type integerValue] == 1 || [type integerValue] == 2) {
                        NSString * temp = [NSString stringWithFormat:@"%@",[personalDic objectForKey:QUOTIETY]];

                        if ([ZEUtil strIsEmpty:temp] || [temp doubleValue] == 0) {
                            temp = @"1";
                        }
                        Hj = Hj * [temp doubleValue];
                    }
                    if ([type integerValue] == 1) {
                        NSString * temp = [NSString stringWithFormat:@"%@",[personalDic objectForKey:QUOTIETY]];
                        if ([ZEUtil strIsEmpty:temp] || [temp doubleValue] == 0) {
                            temp = @"1";
                        }
                        if(JunTanHjPer==0){
                            JunTanHjPer = [temp doubleValue];
                        }else{
                            JunTanHjPer = JunTanHjPer * [temp doubleValue];
                        }
                        
                    }
                    if ([type integerValue] == 3) {
                        NSString * temp = [NSString stringWithFormat:@"%@",[personalDic objectForKey:QUOTIETY]];
                        if ([ZEUtil strIsEmpty:temp] || [temp doubleValue] == 0) {
                            temp = @"0";
                        }
                        JkHj = JkHj + [temp doubleValue];
                    }
                }
                
            }
        }
        [personalDic setObject:[NSString stringWithFormat:@"%f",Hj] forKey:@"SUMPOINTS"];
        [personalDic setObject:[NSString stringWithFormat:@"%f",Hj] forKey:@"WORKPOINTS"];
        [personalDic setObject:[NSString stringWithFormat:@"%f",JkHj] forKey:@"QSPOINTS"];
        [_personalDataArr replaceObjectAtIndex:i withObject:personalDic];
        JunTanHj=JunTanHj+JunTanHjPer;
    }
    if(JunTanHj==0){
        JunTanHj=1;
    }
    
    /**
     *  @author Stenson, 16-09-05 09:09:39
     *
     *  获取到总公式
     */
    
    for (NSDictionary * dic in [[ZEPointRegCache instance] getDistributionTypeCaches]) {
        ZEEPM_TEAM_RATIONTYPEDETAIL * RATIONTYPEDETAIL = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:dic];
        if ([RATIONTYPEDETAIL.RATIONTYPECODE isEqualToString:taskM.RATIONTYPE]) {
            float totalPoint = [[self getRationTypeValue:RATIONTYPEDETAIL.FORMULA withTaskDic:_taskDic withPersonalData:nil] floatValue];
            _resultPoint = totalPoint;
        }
    }
    
    for (NSInteger i = 0 ; i < _personalDataArr.count ; i++) {
        NSMutableDictionary * personalDic = [NSMutableDictionary dictionaryWithDictionary:_personalDataArr[i]];
        
        double sumpoints = _resultPoint * [[personalDic objectForKey:@"SUMPOINTS"] doubleValue] / JunTanHj + [[personalDic objectForKey:@"QSPOINTS"] doubleValue];
        
        [personalDic setObject:[self decimalwithFormat:@"0.00" floatV:sumpoints] forKey:@"SUMPOINTS"];
        [personalDic setObject:[self decimalwithFormat:@"0.00" floatV:sumpoints] forKey:@"WORKPOINTS"];

        [_personalDataArr replaceObjectAtIndex:i withObject:personalDic];
    }

}

-(void)getTotalPointTaskDic:(NSDictionary *)rationDic withPersonalDetailArr:(NSArray *)personalData
{
    _originTaskDic = rationDic;
    _orginPersonalDataArr = [NSMutableArray arrayWithArray:personalData];
    
    _taskDic = [NSMutableDictionary dictionaryWithDictionary:rationDic];
    _personalDataArr = [NSMutableArray arrayWithArray:personalData];
        
    [self calcul];
}

-(NSDictionary *)getResultDic
{
    for (int i = 0 ; i < _orginPersonalDataArr.count; i ++) {
        NSMutableDictionary * originDic = [NSMutableDictionary dictionaryWithDictionary: _orginPersonalDataArr[i]];
        
        NSDictionary * changeDic = _personalDataArr[i];
        
        [originDic setObject:[changeDic objectForKey:@"SUMPOINTS"] forKey:@"SUMPOINTS"];
        [originDic setObject:[changeDic objectForKey:@"WORKPOINTS"] forKey:@"WORKPOINTS"];
        
        [_orginPersonalDataArr replaceObjectAtIndex:i withObject:originDic];
    }
    
    return @{kFieldDic:_originTaskDic,
             kDefaultFieldDic:_orginPersonalDataArr};
}

-(NSString *)getRationTypeValue:(NSString *)formula
                    withTaskDic:(NSDictionary *)taskDic
               withPersonalData:(NSDictionary *)personalDic
{
    NSInteger strLength = formula.length;
    
    for (int i = 0 ; i < strLength; i ++) {
        
        NSRange resultRange = [formula rangeOfString:@"[" options:NSBackwardsSearch range:NSMakeRange(0,strLength)];
        NSRange resultRange1 = [formula rangeOfString:@"]" options:NSBackwardsSearch range:NSMakeRange(0,strLength)];
        
        if (strLength <= 0 || resultRange.length == 0 || resultRange1.length == 0) {
            break;
        }
        
        NSRange range = NSMakeRange(resultRange.location + resultRange.length, resultRange1.location - resultRange.location - resultRange1.length);
        
        NSString * resultStr = [formula substringWithRange:range];
        
        NSRange replaceRange = NSMakeRange(resultRange.location , resultRange1.location - resultRange.location + 1);
        
        NSString * value = [NSString stringWithFormat:@"%@",[taskDic objectForKey:[NSString stringWithFormat:@"%@",resultStr]]];
        
        if ([resultStr isEqualToString:@"K"]) {
            value = [NSString stringWithFormat:@"%@",[ZESettingLocalData getKValue]];
        }else if([value isEqualToString:@"(null)"]){
            value = [personalDic objectForKey:[NSString stringWithFormat:@"%@",resultStr]];
        }

        formula = [formula stringByReplacingCharactersInRange:replaceRange withString:[NSString stringWithFormat:@"%@",value]];
        strLength = formula.length;
        strLength = resultRange.location;
    }
    
    if([formula rangeOfString:@"sqrt"].location != NSNotFound){
        NSRange resultRange = [formula rangeOfString:@"method1" options:NSBackwardsSearch range:NSMakeRange(0,formula.length)];
        NSRange resultRange1 = [formula rangeOfString:@"method2" options:NSBackwardsSearch range:NSMakeRange(0,formula.length)];
        
        NSRange range = NSMakeRange(resultRange.location + resultRange.length, resultRange1.location - resultRange.location - resultRange.length);
        
        NSString * resultStr = [formula substringWithRange:range];
        
        NSString * sqrtValue = [ZEFormulaStringCalcUtility calcComplexFormulaString:resultStr];
        
        NSString * sqrtNum = [NSString stringWithFormat:@"%f",sqrtf([sqrtValue floatValue])];
        
        NSRange sqrtRange = [formula rangeOfString:@"sqrt" options:NSBackwardsSearch range:NSMakeRange(0,formula.length)];

        NSRange replaceRange = NSMakeRange(sqrtRange.location, resultRange1.location + resultRange1.length);

        formula = [formula stringByReplacingCharactersInRange:replaceRange withString:sqrtNum];
    }
    
    return [ZEFormulaStringCalcUtility calcComplexFormulaString:formula];
}

//格式化小数 四舍五入类型
- (NSString *) decimalwithFormat:(NSString *)format  floatV:(float)floatV
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    
    [numberFormatter setPositiveFormat:format];
    
    return  [numberFormatter stringFromNumber:[NSNumber numberWithFloat:floatV]];
}




@end
