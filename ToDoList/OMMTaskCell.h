//
//  OMMTaskCell.h
//  ToDoList
//
//  Created by Admin on 11.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMMTaskCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *taskName;
@property (weak, nonatomic) IBOutlet UILabel *taskNote;
@property (weak, nonatomic) IBOutlet UILabel *taskFinishDate;

@end
