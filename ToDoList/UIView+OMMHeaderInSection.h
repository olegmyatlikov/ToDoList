//
//  UIView+OMMHeaderInSection.h
//  ToDoList
//
//  Created by Oleg Myatlikov on 22/06/2017.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (OMMHeaderInSection)

+ (UIView *)createViewForHeaderInSection:(UITableView *)tableView withTitle:(NSString *)title;

@end
