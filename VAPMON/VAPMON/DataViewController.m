
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
@synthesize patientObject;
@synthesize plot;
@synthesize image;
@synthesize overlayView;
@synthesize activityView;

/**
 * Function to enable loading state
 * written by Leejay
 */
- (void)stateIsLoading
{
    if(![self.overlayView isDescendantOfView:self.view])
    {
        self.overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        self.overlayView.backgroundColor = [UIColor blackColor];
        self.overlayView.alpha = 0.4;
        [self.view addSubview:self.overlayView];
        self.activityView=[[UIActivityIndicatorView alloc]
                           initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityView.center=self.view.center;
        [self.activityView startAnimating];
        [self.overlayView addSubview:self.activityView];
    }
}

/**
 * Function to disable loading state
 * written by Leejay
 */
- (void)stateIsLoaded
{
    if([self.overlayView isDescendantOfView:self.view])
    {
        [self.activityView removeFromSuperview];
        [self.overlayView removeFromSuperview];
    }
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [self stateIsLoaded];
    if(pressureWarning) {
        [self alertWithMessage:@"Abnormally high pressure reading, with possible upward trend" title:@"Pressure Warning"];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self stateIsLoading];
    doctor = [Doctor getInstance];
    pressureWarning = false;
    self.mainNav.title = [patientObject valueForKey:@"patientName"];
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DataPoint"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(doctorCode like %@) AND (patientNumber like %@)",
                              doctor.code, [patientObject valueForKey:@"patientNumber"]];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"date"
                                                                 ascending:YES];
    self.dataForPlot = [[[managedObjectContext executeFetchRequest:fetchRequest error:nil]
                         sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]] mutableCopy];
    NSLog(@"%@", self.dataForPlot);
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:@"<html><head><script type=\"text/javascript\" \
                                  src=\"https://www.google.com/jsapi?autoload={ \
                                  'modules':[{ \
                                  'name':'visualization', \
                                  'version':'1', \
                                  'packages':['corechart'] \
                                  }] \
                                  }\"></script> \
                                  \
                                  <script type=\"text/javascript\"> \
                                  google.setOnLoadCallback(drawChart); \
                                  \
                                  function drawChart() {\
                                      var data = google.visualization.arrayToDataTable([\
                                                                                        ['Date', 'Pressure (mmHg)/Flow Rate (mL/s)'],"];
    BOOL firstItem = YES;
    int count = 0;
    int consistentBlips = 0;
    float runningSum = 0;


    
    for(NSDictionary *dp in self.dataForPlot) {
        if(firstItem == YES) firstItem = NO;
        else {
            [urlString appendString:@","];
        }
        NSString *dateString = [NSDateFormatter localizedStringFromDate:[dp valueForKey:@"date"]
                                                dateStyle:NSDateFormatterShortStyle
                                                timeStyle:NSDateFormatterNoStyle];
        int pressureVal = (int)[dp valueForKey:@"pressureValue"];
        int flowRateVal = (int)[dp valueForKey:@"flowRateValue"];
        
        float proportion = (float)pressureVal / (float)flowRateVal;
        
        //used to calculate if the pressure warning should trigger
        if(count == 0 && runningSum == 0) {
            //if first value, simply increment
            ++count, runningSum +=proportion;
        }
        else {
            //otherwise, do the check
            float averageProp = runningSum / (float)count;
            //using the average proportion, determine if the value falls within the tolerance
            if(averageProp > proportion) {
                //if it does not, increment the trend counter
                //doing this will naturally normalize the data, to get an upward curve and generate
                //a trend that will properly trigger the warning
                if(averageProp - proportion > (averageProp * (TOLERANCE_PERCENTAGE / 100)))
                    ++consistentBlips;
                else
                    consistentBlips = 0;
            }
            else {
                if(proportion - averageProp > (averageProp * (TOLERANCE_PERCENTAGE / 100)))
                    ++consistentBlips;
                else
                    consistentBlips = 0;
            }
            
        }
        //trigger the warning with normalized data or if the latest value was high
        if(consistentBlips > 0) {
            if(count > 3) {
                //since the values will only be high if they are at the end of the graph,
                //this will demonstrate a consistent upward trend from the latest readings
                //and will ignore previous high readings
                if(consistentBlips > 3) pressureWarning = true;
            }
        }
        
        
        NSNumber *propVal = [NSNumber numberWithFloat:proportion];
        
        [urlString appendFormat:@"['%@', %@]", dateString, propVal];
    }
    plot.delegate = self;
    plot.scalesPageToFit = YES;
    
    [urlString appendString:@"]);\
     \
     var options = {\
     width: 1000,\
     height: 640,\
     chartArea:{left:60,top:0,width:\"85%\",height:\"90%\"},\
     hAxis: {\
        title: 'Date'\
     },\
     vAxis: {\
        title: 'Pressure (mmHg)/Flow Rate(mL/s)'\
     },\
     legend: 'none'\
     };\
     \
     var chart = new google.visualization.LineChart(document.getElementById('ex0'));\
     \
     chart.draw(data, options);\
     }\
     </script>\
     </head>\
     <body>\
     <div id=\"ex0\"></div>\
     </body>\
     </html>"];
    plot.userInteractionEnabled = YES;
    plot.opaque = NO;
    plot.backgroundColor = [UIColor clearColor];
    [plot loadHTMLString:[NSString stringWithFormat:@"%@", urlString] baseURL: nil];
    NSLog(@"%@", plot);
    
}

- (NSInteger)tableView:(UITableView *)dataPointTable
 numberOfRowsInSection:(NSInteger)section{
    return [self.dataForPlot count];
}

- (UITableViewCell *)tableView:(UITableView *)patientTable cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.dataPointTable dequeueReusableCellWithIdentifier:@"DataPointCell"];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"DataPointCell"];
    }
    NSManagedObject *object = [self.dataForPlot objectAtIndex:indexPath.row];
    NSLog(@"%@", [object valueForKey:@"doctorCode"]);
    cell.textLabel.text = [NSString stringWithFormat:@"Pressure: %@ mmHg", [object valueForKey:@"pressureValue"]];
    NSString *dateString = [NSDateFormatter localizedStringFromDate:[object valueForKey:@"date"]
                                                          dateStyle:NSDateFormatterMediumStyle
                                                          timeStyle:NSDateFormatterNoStyle];
    cell.detailTextLabel.text = dateString;
    return cell;
}

- (NSString *)createCSV:(NSMutableArray *)array separator:(NSString *)sep {
    NSMutableString *csvStr = [[NSMutableString alloc] initWithFormat:@"Date%@Pressure(mmHg)%@Flow Rate(mL/s)", sep, sep];
    for (NSDictionary *item in array) {
        [csvStr appendString:@"\n"];
        NSString *date = [NSDateFormatter localizedStringFromDate:[item valueForKey:@"date"]
                                                        dateStyle:NSDateFormatterShortStyle
                                                        timeStyle:NSDateFormatterNoStyle];
        NSString *pressure = [NSString stringWithFormat:@"%@", [item valueForKey:@"pressureValue"]];
        NSString *flowRate = [NSString stringWithFormat:@"%@", [item valueForKey:@"flowRateValue"]];
        NSString *appendString = [NSString stringWithFormat:@"%@%@%@%@%@", date, sep, pressure, sep, flowRate];
        [csvStr appendString:appendString];
    }
    return [NSString stringWithFormat:@"%@", csvStr];
}

- (NSString *)saveCSV:(NSString *)csv filename:(NSString *)name {
    // For error information
    NSError *error;
    
    // Create file manager
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    // Point to Document directory
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];
    // File we want to create in the documents directory
    // Result is: /Documents/file1.txt
    NSString *filePath = [documentsDirectory
                          stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.csv", name]];
    
    // Write the file
    [csv writeToFile:filePath atomically:YES
            encoding:NSUTF8StringEncoding error:&error];
    
    // Show contents of Documents directory
    NSLog(@"Documents directory: %@",
          [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
    
    //NSString *homeDirectory;
    //homeDirectory = NSHomeDirectory(); // Get app's home directory - you could check for a folder here too.
    //BOOL isWriteable = [[NSFileManager defaultManager] isWritableFileAtPath: homeDirectory]; //Check file path is writealbe
    //if(isWriteable == YES) {
    //    NSString *newFilePath = [NSString stringWithFormat:@"%@/%@.csv", homeDirectory, name];
        
    //    [[NSFileManager defaultManager] createFileAtPath:newFilePath contents:nil attributes:nil];
    //    [csv writeToFile:csv atomically:YES encoding:NSUTF8StringEncoding error:nil];
    //    return newFilePath;
    //}
    //else {
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh Ohs"
    //                                                    message:@"We're having issues writing to your home directory."
    //                                                   delegate:nil
    //                                          cancelButtonTitle:@"OK"
    //                                          otherButtonTitles:nil];
    //    [alert show];
    //    return nil;
    //}
    
    return filePath;
}

- (void)showEmail:(NSString*)file withPatientName:(NSString *)patientName withRecipient:(NSString *)recipient {
    
    NSString *emailTitle = [NSString stringWithFormat:@"Vascular Access Port Data for %@", patientName];
    NSString *messageBody = [NSString stringWithFormat:@"Attached is the Vascular Access Port data for %@ in CSV format.", patientName];
    NSArray *toRecipents = [NSArray array];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Determine the file name and extension
    NSArray *filepart = [file componentsSeparatedByString:@"."];
    NSString *filename = [filepart objectAtIndex:0];
    NSString *extension = [filepart objectAtIndex:1];
    
    // Get the resource path and read the file using NSData
    NSString *filePath = [NSString stringWithFormat:@"%@.%@", filename, extension];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    
    // Determine the MIME type
    NSString *mimeType;
    if ([extension isEqualToString:@"jpg"]) {
        mimeType = @"image/jpeg";
    } else if ([extension isEqualToString:@"png"]) {
        mimeType = @"image/png";
    } else if ([extension isEqualToString:@"doc"]) {
        mimeType = @"application/msword";
    } else if ([extension isEqualToString:@"ppt"]) {
        mimeType = @"application/vnd.ms-powerpoint";
    } else if ([extension isEqualToString:@"html"]) {
        mimeType = @"text/html";
    } else if ([extension isEqualToString:@"pdf"]) {
        mimeType = @"application/pdf";
    } else if ([extension isEqualToString:@"csv"]) {
        mimeType = @"text/csv";
    }
    
    // Add attachment
    [mc addAttachmentData:fileData mimeType:mimeType fileName:[NSString stringWithFormat:@"%@.%@", patientName, extension]];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
}

- (void)alertWithMessage:(NSString *)message title:(NSString *)title {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            [self alertWithMessage:@"Email saved." title:@"Saved"];
            break;
        case MFMailComposeResultSent:
            [self alertWithMessage:@"CSV sent successfully!" title:@"Email Success"];
            break;
        case MFMailComposeResultFailed:
            [self alertWithMessage:[NSString stringWithFormat:@"%@: %@", @"Message send failure", [error localizedDescription]] title:@"Email Failure"];
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)emailTheCSV:(id)sender {
    NSString *csv = [self createCSV:self.dataForPlot separator:@","];
    NSLog(@"%@", csv);
    NSString *patientName = [NSString stringWithFormat:@"%@", [self.patientObject valueForKey:@"patientName"]];
    NSString *file = [self saveCSV:csv filename:patientName];
    [self showEmail:file withPatientName:patientName withRecipient:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self performSegueWithIdentifier:@"Back" sender:self];
    
}
@end