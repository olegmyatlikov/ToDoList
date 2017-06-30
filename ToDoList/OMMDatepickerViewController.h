//
//  OMMDatepickerViewController.h
//  ToDoList
//
//  Created by Admin on 04.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OMMDatepickerViewControllerDelegate;


@interface OMMDatepickerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *selectedDateLabel;
@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) NSDate *startDate;
@property (weak, nonatomic) id <OMMDatepickerViewControllerDelegate> delegate;

@end


@protocol OMMDatepickerViewControllerDelegate <NSObject>

- (void)viewControllerDidDoneAction:(OMMDatepickerViewController *)sender;
- (void)viewControllerDidCancelAction:(id)sender;

@end


