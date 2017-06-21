//
//  NSDate+OMMDateConverter.h
//  ToDoList
//
//  Created by Admin on 04.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (OMMDateConverter)

- (NSString *)convertDateToString;
- (NSString *)convertToStringForCompareDate;
+ (NSDate *)convertStringToDate:(NSString *)dateInString;

@end
