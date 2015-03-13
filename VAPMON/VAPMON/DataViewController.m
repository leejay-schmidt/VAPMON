
//
//  DataViewController.m
//  VAPMON
//
//  Created by Leejay Schmidt on 2015-03-01.
//  Copyright (c) 2015 Leejay Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DataViewController.h"

@interface DataViewController ()

@end

@implementation DataViewController
@synthesize dataForPlot;
@synthesize mainNav;
@synthesize back;
@synthesize patientObject;
@synthesize plot;
@synthesize image;

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    doctor = [Doctor getInstance];
    self.mainNav.title = [patientObject valueForKey:@"patientName"];
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    //NSLog(@"Set Name, now running fetch request");
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DataPoint"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(doctorCode like %@) AND (patientNumber like %@)",
                              doctor.code, [patientObject valueForKey:@"patientNumber"]];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"date"
                                                                 ascending:YES];
    self.dataForPlot = [[[managedObjectContext executeFetchRequest:fetchRequest error:nil]
                         sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]] mutableCopy];
    NSLog(@"%@", self.dataForPlot);
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:@"http://chart.googleapis.com/chart?cht=lc&chs=600x400"];
    BOOL firstItem = YES;
    NSMutableString *dateUrlString = [[NSMutableString alloc] init];
    NSMutableString *valUrlString = [[NSMutableString alloc] init];
    for(NSDictionary *dp in self.dataForPlot) {
        if(firstItem == YES) firstItem = NO;
        else {
            [dateUrlString appendString:@"|"];
            [valUrlString appendString:@","];
        }
        NSString *dateString = [NSDateFormatter localizedStringFromDate:[dp valueForKey:@"date"]
                                                dateStyle:NSDateFormatterShortStyle
                                                timeStyle:NSDateFormatterNoStyle];
        NSString *valString = [NSString stringWithFormat:@"%@", [dp valueForKey:@"pressureValue"]];
        [dateUrlString appendString:dateString];
        [valUrlString appendString:valString];
    }
    [urlString appendString:@"&chl="];
    [urlString appendString:dateUrlString];
    [urlString appendString:@"&chd=t:"];
    [urlString appendString:valUrlString];
    [urlString appendString:@"&chxt=x,y&chds=a&chof=png"];
    //NSString *fullURLString = @"https://www.drupal.org/files/issues/sample_7.png";
    NSString *fullURLString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:fullURLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //self.plot = [[UIImageView alloc] init];
    self.image = [[UIImage alloc] init];
    [request setTimeoutInterval: 4.0];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               if (data != nil && error == nil)
                               {
                                   self.image = [UIImage imageWithData:data];
                                   self.plot.image = self.image;
                                   NSLog(@"Got data");
                               }
                               else
                               {
                                   NSLog(@"Didn't get the Data");
                               }
                               
                           }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self performSegueWithIdentifier:@"Back" sender:self];
    
}
@end