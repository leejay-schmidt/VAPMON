//
//  CSVParse.h
//  VAPMON
//
//  Created by Leejay Schmidt on 2015-02-08.
//  Copyright (c) 2015 Leejay Schmidt. All rights reserved.
//

#ifndef VAPMON_CSVParse_h
#define VAPMON_CSVParse_h
#import <Foundation/Foundation.h>

#endif



@interface CSVParse : NSObject


-(NSMutableArray *)parseCSV:(NSString *)csv withSeparator:(NSString *)sep;

@end