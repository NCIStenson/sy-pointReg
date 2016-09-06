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


-(void)getTotalPointTaskDic:(NSDictionary *)rationDic withPersonalDetailArr:(NSArray *)personalData
{
    
    _taskDic = [NSMutableDictionary dictionaryWithDictionary:rationDic];
    _personalDataArr = [NSMutableArray arrayWithArray:personalData];
    
    ZEEPM_TEAM_RATION_COMMON * taskM = [ZEEPM_TEAM_RATION_COMMON getDetailWithDic:rationDic];
    
    /**
     *  @author Stenson, 16-09-03 17:09:33
     *
     *  获取缓存中 分配类型系数列表
     */
    NSDictionary * coefficientDic = [[ZEPointRegCache instance] getDistributionTypeCoefficient];
    
    /**
     *  @author Stenson, 16-09-05 09:09:39
     *
     *  获取到总公式
     */

    for (NSDictionary * dic in [[ZEPointRegCache instance] getDistributionTypeCaches]) {
        ZEEPM_TEAM_RATIONTYPEDETAIL * RATIONTYPEDETAIL = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:dic];
        if ([RATIONTYPEDETAIL.RATIONTYPECODE isEqualToString:taskM.RATIONTYPE]) {
            float totalPoint = [[self getRationTypeValue:RATIONTYPEDETAIL.FORMULA withTaskDic:rationDic withPersonalData:nil] floatValue];
            _resultPoint = totalPoint;
        }
    }
    /**
     *  @author Stenson, 16-09-03 17:09:53
     *
     *  获取选定的任务类型的分配系数列表
     */
    NSArray * coefficientArr = [coefficientDic objectForKey:taskM.RATIONTYPE];
    
    for (int i = 0 ; i < coefficientArr.count; i ++) {
        
        ZEEPM_TEAM_RATIONTYPEDETAIL * rationTypeDetailM = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:coefficientArr[i]];
        /**
         *  @author Stenson, 16-09-03 17:09:35
         *
         *  选定的系数列表 是否跟随任务
         */
        if ([rationTypeDetailM.ISRATION boolValue]) {
            if ([ZEUtil isStrNotEmpty:rationTypeDetailM.FORMULA]) {
            }
        }else{
            if ([ZEUtil isStrNotEmpty:rationTypeDetailM.FORMULA]) {
                for (int j = 0 ; j < personalData.count; j ++) {
        
                    float coefficentPoint = [[self getRationTypeValue:rationTypeDetailM.FORMULA withTaskDic:rationDic withPersonalData:personalData[j]] floatValue];
                    
                    if (coefficentPoint < [rationTypeDetailM.MINVALUE floatValue]) {
                        coefficentPoint = [rationTypeDetailM.MINVALUE floatValue];
                    }
                    
                    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:personalData[j]];
                    
                    float personalAspect = [[dic objectForKey:[rationTypeDetailM.FIELDNAME stringByReplacingOccurrencesOfString:@"CODE" withString:@""]] floatValue];
                    
                    float finalPoint = 0.0f;
                    
                    if ([rationTypeDetailM.TYPE integerValue] == 1) {
                        //  如果是分摊法 计算个人占总体的比例
                        float denominator = 0.0f;
                        for (int h = 0; h < personalData.count; h ++) {
                            NSDictionary * calculateDenoPersonData = personalData[h];
                            denominator += [[calculateDenoPersonData objectForKey:[rationTypeDetailM.FIELDNAME stringByReplacingOccurrencesOfString:@"CODE" withString:@""]] floatValue];
                        }
                        finalPoint = [self calculateStandardPointRideCoefficent:_resultPoint
                                                  coefficientPoint:coefficentPoint
                                              rationTypeDetailType:rationTypeDetailM.TYPE
                                                withPersonalAspect:personalAspect / denominator];
                        
                    }else{
                        finalPoint = [self calculateStandardPointRideCoefficent:_resultPoint
                                                                 coefficientPoint:coefficentPoint
                                                             rationTypeDetailType:rationTypeDetailM.TYPE
                                                               withPersonalAspect:0.0f];
                    }
                    
                    [dic setObject:[NSString stringWithFormat:@"%.2f",coefficentPoint] forKey:[rationTypeDetailM.FIELDNAME stringByReplacingOccurrencesOfString:@"CODE" withString:@""]];
                    
                    [dic setObject:[NSString stringWithFormat:@"%.2f",finalPoint] forKey:@"WORKPOINTS"];
                    [dic setObject:[NSString stringWithFormat:@"%.2f",finalPoint] forKey:@"SUMPOINTS"];

                    [_personalDataArr replaceObjectAtIndex:j withObject:dic];
                }
            }else{
                for (int j = 0 ; j < personalData.count; j ++) {
                    
                    NSDictionary * personDic = personalData[j];
                    
                    NSString * coefficentValue = [personDic objectForKey:[rationTypeDetailM.FIELDNAME stringByReplacingOccurrencesOfString:@"CODE" withString:@""]];
                    NSLog(@" =====  %f ",_resultPoint);
                    float finalPoint = 0.0f;
                    finalPoint = [self calculateStandardPointRideCoefficent:_resultPoint
                                              coefficientPoint:[coefficentValue floatValue]
                                          rationTypeDetailType:rationTypeDetailM.TYPE
                                            withPersonalAspect:0.0f];
                    
                    NSLog(@" %f =====  %f ",[coefficentValue floatValue],_resultPoint);

                    
                    
                    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:personalData[j]];
                    
                    [dic setObject:[NSString stringWithFormat:@"%.2f",finalPoint] forKey:@"WORKPOINTS"];
                    [dic setObject:[NSString stringWithFormat:@"%.2f",finalPoint] forKey:@"SUMPOINTS"];

                    [_personalDataArr replaceObjectAtIndex:j withObject:dic];
                }
            }
        }
        
        
//        if (i == coefficientArr.count - 1) {
//            for (int j = 0 ; j < _personalDataArr.count; j ++) {
//                NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:personalData[j]];
////                if(j == _personalDataArr.count - 1){
//                    [dic setObject:[NSString stringWithFormat:@"%.2f",_resultPoint] forKey:@"WORKPOINTS"];
//                    [dic setObject:[NSString stringWithFormat:@"%.2f",_resultPoint] forKey:@"SUMPOINTS"];
////                }
//                [_personalDataArr replaceObjectAtIndex:j withObject:dic];
//            }
//        }
    }
}

/**
 *  @author Stenson, 16-09-06 00:09:50
 *
 *  根据type类型进行计算总分
 *
 *  @param standardPoint 原始分值
 *  @param coeffPoint    系数值
 *  @param type          分摊类型
 *  @param aspect        按工分*系数分配时 个人 占 该系数总 的比值
 *
 *  @return 返回总分
 */
-(float)calculateStandardPointRideCoefficent:(float)standardPoint
                        coefficientPoint:(float)coeffPoint
                       rationTypeDetailType:(id)type
                         withPersonalAspect:(float)aspect
{
    /**
     *  @author Stenson, 16-09-05 10:09:12
     *
     *  根据该系数的类型 进行计算总分
     *      1  按系数均摊
     *      2  按系数倍乘
     *      3  加分项
     *      4  不参与计算
     */
    
    switch ([type integerValue])
    {
        case 1:
        {
            _resultPoint = standardPoint * aspect * coeffPoint;
        }
            break;
        case 2:
        {
            _resultPoint = standardPoint * coeffPoint;
        }
            break;
        case 3:
        {
            _resultPoint = standardPoint + coeffPoint;
        }
            break;
        case 4:
        {
            
        }
            break;
            
        default:
            break;
    }
    return _resultPoint;
}


-(NSDictionary *)getResultDic
{
    return @{kFieldDic:_taskDic,
             kDefaultFieldDic:_personalDataArr};
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

        formula = [formula stringByReplacingCharactersInRange:replaceRange withString:value];
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
