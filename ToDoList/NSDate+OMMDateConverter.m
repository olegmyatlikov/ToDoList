//
//  NSDate+OMMDateConverter.m
//  ToDoList
//
//  Created by Admin on 04.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "NSDate+OMMDateConverter.h"

@implementation NSDate (OMMDateConverter)

- (NSString *)convertDateToString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    return [formatter stringFromDate:self];
}


+ (NSDate *)convertStringToDate:(NSString *)dateInString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    return [formatter dateFromString:dateInString];
}

@end