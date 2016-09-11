//
//  ZEColorConstant.h
//  NewCentury
//
//  Created by Stenson on 16/1/20.
//  Copyright © 2016年 Stenson. All rights reserved.
//

#ifndef ZEColorConstant_h
#define ZEColorConstant_h

#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define MAIN_COLOR [UIColor colorWithRed:28/255.0 green:157/255.0 blue:209/255.0 alpha:1]

#define MAIN_LINE_COLOR [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1]
#define MAIN_ARM_COLOR [UIColor colorWithRed:(arc4random()%255)/255.0 green:(arc4random()%255)/255.0 blue:(arc4random()%255)/255.0 alpha:1]

#define MAIN_NAV_COLOR [UIColor colorWithRed:0/255.0 green:84/255.0 blue:74/255.0 alpha:1]

#define kFontColor RGBA(47,79,79,1)

#endif /* ZEColorConstant_h */
