# VAPMON

This is the Github for the iOS application part of VAPMON. This is designed to work as a complement to the measuring device and the Python code therein.

LIMITED LICENSE: This software is provided as-is and without warranty. Despite our best efforts to ensure code reliablility and general bug-freedom, this is not in any way guaranteed. Please know that we do take bugs very seriously and will work to stop and bugs from becoming a further problem, but are in no way responsible for damages this may cause to the user's device, data, or general sanity. Cha.

CUSTOM LIBRARIES USED
--------------------------
-CSVParse (created by Leejay Schmidt)

THIRD PARTY LIBRARIES USED
--------------------------
-Google Charts (JavaScript library, loaded through a UIWebView)

APPLE LIBRARIES USED (documented in iOS SDK documentation)
--------------------------
-Core Bluetooth
-Core Data
-UIKit
-Foundation

--------------------------
CSVParse Documentation
--------------------------
CSV Parse Library Documentation
Created by Leejay Schmidt

Preamble:
  This documentation assumes that the reader has some knowledge of iOS
  development and of Objective C. The CSV Parse Library is built in Objective C.
  To move this library to Swift, please refer to Apple documentation (iOS SDK)
  on how to do this.

Usage:
  Create a new instance of the parser using
    CSVParse *parser = [[CSVParse alloc] init];

  The CSV will parse into an NSMutableArray of NSDictionaries when the CSV parse
  function is called. The usage of this is
    data = [parser parseCSV:(NSString *) withSeparator:(NSString *)];
  The withSeparator NSString is the separator that is used to split the values.

How it works:
  The parser reads the first line to determine the field names. It then parses 
  each line into an NSDictionary using the field names as keys and the parsed
  value as values. This NSDictionary is then appended to the NSMutableArray 
  that gets returned.

Pseudocode:

  function parseCSV(csv, separator)
    mutableArray data, mutableArray fields
    while(!csv.end)
      line -> scanLine
      if(firstLine)
        while(!line.end)
          value -> scanToNextSeparator(separator)
          fields.append(value)
      else
        dictionary fieldVals
        while(!line.end)
          value -> scanToNextSeparator(separator)
          dictionary.add(value, fieldAtIndex[currentIteration])
        data.append(fieldVals)
    return data
  
---------------------------------------------------------------------------
App Workflow (As Is)
LOAD APP->Enter Doctor Code->Select --Get Data from Device->Select Device->Download Data->Select
                                    --View Patient Data<->View Patient<->Email as CSV
