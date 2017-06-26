//
//  OMMSearchTableViewController.m
//  ToDoList
//
//  Created by Oleg Myatlikov on 15/06/2017.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMSearchTableViewController.h"
#import "OMMTaskService.h"
#import "OMMTasksGroup.h"
#import "OMMTask.h"
#import "OMMTaskCell.h"
#import "OMMTaskDetailTableVC.h"

@interface OMMSearchTableViewController () <UISearchBarDelegate, UISearchResultsUpdating>

@property (strong, nonatomic) OMMTaskService *taskService;
@property (nonatomic, strong) NSArray *resultTaskArray;
@property (nonatomic, strong) UISearchController *searchController;

@property (nonatomic, strong) NSPredicate *activeTasksPredicate;
@property (nonatomic, strong) NSPredicate *closedTasksPredicate;

@end

@implementation OMMSearchTableViewController

static NSString * const OMMsearchTaskIsOpen = @"closed = 0";
static NSString * const OMMsearchTaskIsClosed = @"closed = 1";
static NSString * const OMMsearchActiveTasks = @"Active tasks";
static NSString * const OMMsearchComplitedTasks = @"Completed";
static NSString * const OMMsearchClearText = @"";
static NSString * const OMMsearchNoResultText = @"No Result";;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.taskService = [OMMTaskService sharedInstance];
    self.activeTasksPredicate = [NSPredicate predicateWithFormat:OMMsearchTaskIsOpen];
    self.closedTasksPredicate = [NSPredicate predicateWithFormat:OMMsearchTaskIsClosed];
    
    self.resultTaskArray = [self filterArrayUsingSelectScopeButton:self.taskService.allTasksArray];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.scopeButtonTitles = @[OMMsearchActiveTasks, OMMsearchComplitedTasks];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES; // hide searchController if present another viewController and do visible if go back
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerTaskWasCreatedOrEdited:) name:@"TaskWasCreatedOrEdited" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerGroupWasDeleted) name:@"GroupWasDeleted" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.searchController.searchBar becomeFirstResponder];
}

- (void)triggerTaskWasCreatedOrEdited:(NSNotification *)notification {
    self.resultTaskArray = [self filterArrayUsingSelectScopeButton:self.taskService.allTasksArray];
    self.searchController.searchBar.text = OMMsearchClearText;
    [self.tableView reloadData];
}

- (void)triggerGroupWasDeleted {
    self.resultTaskArray = [self filterArrayUsingSelectScopeButton:self.taskService.allTasksArray];
    self.searchController.searchBar.text = OMMsearchClearText;
    [self.tableView reloadData];
}

- (NSArray *)filterArrayUsingSelectScopeButton:(NSArray *)array {
    NSArray *resultArray = [[NSArray alloc] init];
    if (self.searchController.searchBar.selectedScopeButtonIndex == 0) {
        resultArray = [array filteredArrayUsingPredicate:self.activeTasksPredicate];
    } else {
        resultArray = [array filteredArrayUsingPredicate:self.closedTasksPredicate];
    }
    return resultArray;
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.resultTaskArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OMMTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OMMTaskCellIdentifier"];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"OMMTaskCell" bundle:nil] forCellReuseIdentifier:@"OMMTaskCellIdentifier"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"OMMTaskCellIdentifier"];
    }
    
    OMMTask *task = [self.resultTaskArray objectAtIndex:indexPath.row];
    cell.taskName.text = task.name;
    cell.taskNote.text = task.note;
    cell.taskStartDate.text = [task.startDate convertDateToString];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OMMTask *task = [self.resultTaskArray objectAtIndex:indexPath.row];
    OMMTaskDetailTableVC *taskDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"OMMTaskDetailVCIndentifair"];
    taskDetails.task = task;
    [self.navigationController pushViewController:taskDetails animated:YES];
}


#pragma mark - search and update result

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.resultTaskArray = [self filterArrayUsingSelectScopeButton:self.taskService.allTasksArray];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchText];
    if (searchText.length != 0) {
        self.resultTaskArray = [self.resultTaskArray filteredArrayUsingPredicate:predicate];
    }
}

// "No result" on dispaly if resultArray is empty

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.resultTaskArray.count > 0) {
        self.tableView.backgroundView = nil;
        
        return 1;
    } else {
        UILabel *noResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        noResultLabel.text = OMMsearchNoResultText;
        [noResultLabel setFont:[UIFont systemFontOfSize:24 weight:normal]];
        noResultLabel.textColor = [UIColor lightGrayColor];
        noResultLabel.textAlignment = NSTextAlignmentCenter;
        self.tableView.backgroundView = noResultLabel;
        
        return 0;
    }
}

// select scope another button

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    if (selectedScope == 0) {
        self.resultTaskArray = [self.taskService.allTasksArray filteredArrayUsingPredicate:self.activeTasksPredicate];
    } else {
        self.resultTaskArray = [self.taskService.allTasksArray filteredArrayUsingPredicate:self.closedTasksPredicate];
    }
    [self.tableView reloadData];
    self.searchController.searchBar.text = OMMsearchClearText;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.resultTaskArray = [self filterArrayUsingSelectScopeButton:self.taskService.allTasksArray];
}


@end
