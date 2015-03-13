//
//  DataViewController.h
//  VAPMON
//
//  Created by Leejay Schmidt on 2015-03-01.
//  Copyright (c) 2015 Leejay Schmidt. All rights reserved.
//

#ifndef VAPMON_DataViewController_h
#define VAPMON_DataViewController_h


#endif

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Doctor.h"
#import <MessageUI/MessageUI.h>

@interface DataViewController : UIViewController <UITableViewDelegate,
                                                  UITableViewDataSource,
                                                  MFMailComposeViewControllerDelegate> {
    NSMutableArray *dataForPlot;
    Doctor *doctor;
}

@property (nonatomic, strong) IBOutlet UITableView *dataPointTable;
@property (strong, nonatomic) NSMutableArray *dataForPlot;
@property (nonatomic, strong) IBOutlet UIImageView *plot;
@property (nonatomic, strong) NSDictionary *patientObject;
@property (nonatomic, strong) IBOutlet UINavigationItem *mainNav;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

-(NSString *)createCSV:(NSMutableArray *)array separator:(NSString *)sep;
-(IBAction)emailTheCSV:(id)sender;
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error;
-(void)showEmail:(NSString*)file withPatientName:(NSString *)patientName withRecipient:(NSString *)recipient;
-(NSString *)saveCSV:(NSString *)csv filename:(NSString *)name;
-(void)alertWithMessage:(NSString *)message title:(NSString *)title;


@end
