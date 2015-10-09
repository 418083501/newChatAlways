//
//  LCcodingHeader.h
//  lcs
//
//  Created by lurong on 15/3/19.
//  Copyright (c) 2015年 张鹏. All rights reserved.
//

#ifndef lcs_LCcodingHeader_h
#define lcs_LCcodingHeader_h

#define AUTO_CODER(type,key) {\
if (![LCCommon checkIsEmptyString:[coder decodeObjectForKey:key]]) {\
self.type = [NSString stringWithFormat:@"%@",[coder decodeObjectForKey:key]];\
}\
}


#define AUTO_ECODE(type,key) {\
if (![LCCommon checkIsEmptyString:self.type]) {\
[aCoder encodeObject:[NSString stringWithFormat:@"%@",self.type] forKey:key];\
}\
}


#endif
