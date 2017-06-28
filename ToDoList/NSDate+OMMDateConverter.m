//
//  NSDate+OMMDateConverter.m
//  ToDoList
//
//  Created by Admin on 04.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "NSDate+OMMDateConverter.h"

@implementation NSDate (OMMDateConverter)

static NSString * const OMMDateConverterFormatterDDMMYYYY_HHMM = @"dd-MM-yyyy HH:mm";
static NSString * const OMMDateConverterFormatterDDMMYYYY = @"dd-MM-yyyy";

- (NSString *)convertDateToLongDateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:OMMDateConverterFormatterDDMMYYYY_HHMM];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    return [formatter stringFromDate:self];
}

- (NSString *)convertToStringForCompareDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:OMMDateConverterFormatterDDMMYYYY];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    return [formatter stringFromDate:self];
}

+ (NSDate *)convertStringToDate:(NSString *)dateInString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:OMMDateConverterFormatterDDMMYYYY_HHMM];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    return [formatter dateFromString:dateInString];
}

@end
