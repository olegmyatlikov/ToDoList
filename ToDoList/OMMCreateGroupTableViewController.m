//
//  OMMCreateGroupTableViewController.m
//  ToDoList
//
//  Created by Oleg Myatlikov on 6/25/17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMCreateGroupTableViewController.h"
#import "UIView+OMMHeaderInSection.h"

@interface OMMCreateGroupTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *groupNameTextField;
@end

@implementation OMMCreateGroupTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:nil action:@selector(doneButtonPressed)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:nil action:@selector(cancelButtonPressed)];
    self.navigationItem.rightBarButtonItem = doneButton;
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)cancelButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneButtonPressed {
    self.createNewGroup(self.groupNameTextField.text);
    [self.navigationController popViewControllerAnimated:YES];
}

//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
//    
//}


@end
