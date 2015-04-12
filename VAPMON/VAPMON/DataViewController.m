
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

/**
 * Needed for Core Data
 */
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

/**
 * Standard Apple view controller load thing
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    [self stateIsLoading];
    doctor = [Doctor getInstance];
    pressureWarning = false;
    //Show the patient name at the top of the view controller
    self.mainNav.title = [patientObject valueForKey:@"patientName"];
    //Fetch the data from Core Data
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
    //Create the url string for the Google Charts Javascript library
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


    //Do all of the magic on the data
    //This involves iterating over the returned dictionaries, formatting/appending to the HTML, and reading for abnormal values
    for(NSDictionary *dp in self.dataForPlot) {
        if(firstItem == YES) firstItem = NO;
        else {
            [urlString appendString:@","];
        }
        NSString *dateString = [NSDateFormatter localizedStringFromDate:[dp valueForKey:@"date"]
                                                dateStyle:NSDateFormatterShortStyle
                                                timeStyle:NSDateFormatterNoStyle];
        float pressureVal = [[dp valueForKey:@"pressureValue"] floatValue] * 8.57;
        float flowRateVal = [[dp valueForKey:@"flowRateValue"] floatValue];
        
        float proportion = pressureVal / flowRateVal;
        
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
                if(averageProp - proportion > (averageProp * (TOLERANCE_PERCENTAGE / 100))) {
                    ++consistentBlips;
                    NSLog(@"We have a blip: %d", consistentBlips);
                }
                else
                    consistentBlips = 0;
            }
            else {
                if(proportion - averageProp > (averageProp * (TOLERANCE_PERCENTAGE / 100))) {
                    ++consistentBlips;
                    NSLog(@"We have a blip: %d", consistentBlips);
                }
                else
                    consistentBlips = 0;
            }
            ++count; runningSum += proportion;
        }
        
        
        NSNumber *propVal = [NSNumber numberWithFloat:proportion];
        
        [urlString appendFormat:@"['%@', %@]", dateString, propVal];
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
    plot.delegate = self;
    plot.scalesPageToFit = YES;
    //Creates the closing values for the Google Charts information
    
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
    //Settings for the WebView
    plot.userInteractionEnabled = YES;
    plot.opaque = NO;
    plot.backgroundColor = [UIColor clearColor];
    //Loads the HTML in the WebView
    [plot loadHTMLString:[NSString stringWithFormat:@"%@", urlString] baseURL: nil];
    NSLog(@"%@", plot);
    
}

/*
 * Standard Apple Tableview stuffz
 */
- (NSInteger)tableView:(UITableView *)dataPointTable
 numberOfRowsInSection:(NSInteger)section{
    return [self.dataForPlot count];
}

/**
 * Tableview handler for the flow rate/pressure handler
 * Refer to Apple Documentation for more information
 */
- (UITableViewCell *)tableView:(UITableView *)patientTable cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.dataPointTable dequeueReusableCellWithIdentifier:@"DataPointCell"];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"DataPointCell"];
    }
    NSManagedObject *object = [self.dataForPlot objectAtIndex:indexPath.row];
    NSLog(@"%@", [object valueForKey:@"doctorCode"]);
    //main label formatting
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
    //format the number strings to be 2 decimal places
    NSString *pressureString = [NSString stringWithFormat:@"%0.2f", ([[object valueForKey:@"pressureValue"] floatValue] * 8.57)];
    NSString *flowRateString = [NSString stringWithFormat:@"%0.2f", [[object valueForKey:@"flowRateValue"] floatValue]];
    //Set the text label string to the pressure and flow rate string
    cell.textLabel.text = [NSString stringWithFormat:@"Pressure: %@ mmHg  |  Flow Rate: %@ mL/s",
                           pressureString, flowRateString];
    //Set the detail to the date that the flow rate was taken on (formatted from the string)
    NSString *dateString = [NSDateFormatter localizedStringFromDate:[object valueForKey:@"date"]
                                                          dateStyle:NSDateFormatterMediumStyle
                                                          timeStyle:NSDateFormatterNoStyle];
    cell.detailTextLabel.text = dateString;
    return cell;
}

/**
 * Basically the inverse of the parse CSV -- creates a CSV string from a mutable array of dictionaries
 * array = the mutable array of the patient's values
 * sep = the desired separator to be used in the CSV
 */
- (NSString *)createCSV:(NSMutableArray *)array separator:(NSString *)sep {
    NSMutableString *csvStr = [[NSMutableString alloc] initWithFormat:@"Date%@Pressure(mmHg)%@Flow Rate(mL/s)", sep, sep];
    for (NSDictionary *item in array) {
        [csvStr appendString:@"\n"];
        NSString *date = [NSDateFormatter localizedStringFromDate:[item valueForKey:@"date"]
                                                        dateStyle:NSDateFormatterShortStyle
                                                        timeStyle:NSDateFormatterNoStyle];
        NSString *pressure = [NSString stringWithFormat:@"%0.2f", ([[item valueForKey:@"pressureValue"] floatValue] * 8.57)];
        NSString *flowRate = [NSString stringWithFormat:@"%0.2f", [[item valueForKey:@"flowRateValue"] floatValue]];
        NSString *appendString = [NSString stringWithFormat:@"%@%@%@%@%@", date, sep, pressure, sep, flowRate];
        [csvStr appendString:appendString];
    }
    return [NSString stringWithFormat:@"%@", csvStr];
}


/**
 * Saves the given string to a CSV file with a given filename
 * csv = the CSV string to save
 * name = the desired filename (no .csv...the method will handle this)
 */
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

/**
 * Creates a new email message with a given file as an attachment
 * file = the FULL filename/path (including extension) that is desired to be attached
 * patientName = the name of the partient that you want to be included in the message
 * recipient = the email address of the desired recipient
 */
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

/**
 * Creates a new alert message with the desired message and title
 * message = the desired message
 * title = the desired title (the thing on top)
 */
- (void)alertWithMessage:(NSString *)message title:(NSString *)title {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

/**
 * Handles mail composer view controller changes
 * will give a failure, success, or saved message
 */
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    //Checks the resulting state change
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

/**
 * Action to email the CSV for the currently selected patient
 * triggered by the "Email" button push
 */
- (IBAction)emailTheCSV:(id)sender {
    NSString *csv = [self createCSV:self.dataForPlot separator:@","];
    NSLog(@"%@", csv);
    NSString *patientName = [NSString stringWithFormat:@"%@", [self.patientObject valueForKey:@"patientName"]];
    NSString *file = [self saveCSV:csv filename:patientName];
    [self showEmail:file withPatientName:patientName withRecipient:nil];
}

/**
 * BAD THINGS
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * Segues back to the patient view controller
 */
- (IBAction)back:(id)sender {
    [self performSegueWithIdentifier:@"Back" sender:self];
    
}
@end