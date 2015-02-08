//
//  PatientSelectorViewController.h
//  VAPMON
//
//  Created by Leejay Schmidt on 2015-02-07.
//  Copyright (c) 2015 Leejay Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PatientSelectorViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property IBOutlet UIBarButtonItem *back;
@property (nonatomic, strong) IBOutlet UITableView *patientTable;

@property (nonatomic, strong) NSMutableArray *patientArray;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;


@end

