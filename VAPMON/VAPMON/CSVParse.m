//
//  CSVParse.m
//  VAPMON
//
//  Created by Leejay Schmidt on 2015-02-08.
//  Copyright (c) 2015 Leejay Schmidt. All rights reserved.
//

#import "CSVParse.h"

@implementation CSVParse

-(NSMutableArray *)parseCSV:(NSString *)csv withSeparator:(NSString *)sep{
    NSString *currentLine = nil;
    NSMutableArray *fields = [[NSMutableArray alloc] init];
    NSMutableArray *data = [[NSMutableArray alloc] init];
    int count = 0;
    NSScanner *mainScanner = [NSScanner scannerWithString:csv];
    NSUInteger numFields = 0;
    while ([mainScanner isAtEnd] == NO) {
        NSUInteger second_count = 0;
        [mainScanner scanUpToString:@"\n" intoString:&currentLine];
        NSScanner *secondaryScanner = [NSScanner scannerWithString:currentLine];
        if (!count) {
            numFields = [[currentLine componentsSeparatedByString:sep] count] - 1;
        }
        NSString *fieldStr = nil;
        NSMutableDictionary *line = [[NSMutableDictionary alloc] init];
        while ([secondaryScanner isAtEnd] == NO) {
            if (!count) {
                fieldStr = [[NSString alloc] init];
                if (second_count < numFields) [secondaryScanner scanUpToString:sep intoString:&fieldStr];
                else [secondaryScanner scanUpToString:@"\n" intoString:&fieldStr];
                [fields addObject:[fieldStr stringByReplacingOccurrencesOfString:sep withString:@""]];
                second_count++;
            }
            else {
                NSString *lineStr = nil;
                fieldStr = [fields objectAtIndex:second_count];
                if (second_count < numFields) [secondaryScanner scanUpToString:sep intoString:&lineStr];
                else [secondaryScanner scanUpToString:@"\n" intoString:&lineStr];
                [line setValue:[lineStr stringByReplacingOccurrencesOfString:sep withString:@""] forKey:fieldStr];
                second_count++;
            }
            
        }
        if (count) {
            [data addObject:line];
        }
        count++;
    }
    return data;
}


@end