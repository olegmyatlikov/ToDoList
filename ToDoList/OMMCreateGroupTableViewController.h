//
//  OMMCreateGroupTableViewController.h
//  ToDoList
//
//  Created by Oleg Myatlikov on 6/25/17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMMCreateGroupTableViewController : UITableViewController

@property (nonatomic, copy, nonnull) void (^createNewGroup)(NSString *_Nonnull);

@end
