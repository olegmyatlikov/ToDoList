//
//  UIView+OMMHeaderInSection.m
//  ToDoList
//
//  Created by Oleg Myatlikov on 22/06/2017.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "UIView+OMMHeaderInSection.h"

@implementation UIView (OMMHeaderInSection)

+ (UIView *)createViewForHeaderInSection:(UITableView *)tableView withTitle:(NSString *)sectionTitle {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 50.0f)];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 25, tableView.bounds.size.width, 20)];
    headerView.backgroundColor = [UIColor colorWithRed:224.0f/255.0f green:224.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
    headerLabel.textColor = [UIColor grayColor];
    headerLabel.text = sectionTitle;
    [headerView addSubview:headerLabel];
    
    return headerView;
}

@end
