//
//  LOHMTableViewController.m
//  IOTDemo1
//
//  Created by linfeng on 14-10-10.
//  Copyright (c) 2014年 ___SHARPFF___. All rights reserved.
//

#import "LOHMTableViewController.h"
#import "LOHMTableViewCell.h"
#import "NetworkManager.h"

@interface LOHMTableViewController ()
@property (nonatomic, strong, readwrite) NSMutableArray *listOhm;
@property (nonatomic, strong, readwrite) NSURLConnection *connection;
@end

@implementation LOHMTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self requestSenInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Internal methods
- (void)requestSenInfo
{
    int dev_id = 14437;
    int sen_id = 24937;
    
    //    NSString *body = @""; // [body UTF8String] string2bytes
    //    _connection = [[NetworkManager sharedInstance] genericData:@"GET" APIKey:nil deviceID:dev_id sensorID:sen_id data:[body UTF8String] photo:nil id:self];
    _connection = [[NetworkManager sharedInstance] historyDeviceID:dev_id sensorID:sen_id from:-3600.00*24 id:self];
    if (_connection != nil) {
        [[NetworkManager sharedInstance] didStartNetworkOperation];
        self.listOhm = nil;
    }
}


#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 3;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    // get the cell obj.

    return self.listOhm ? self.listOhm.count : 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOHMTableViewCell *cell = (LOHMTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"idOhm" forIndexPath:indexPath];
    
    NSString *strVal = [self.listOhm objectAtIndex:indexPath.row];
    float fVal = [strVal floatValue];
    fVal = fVal / 1023;
    NSLog(@"fVal is [%f]", fVal);
    cell.pvVal.progress = fVal;
//    cell.pvVal.progress = 0.37f;
//    cell.pvVal.t
    // Configure the cell...
    
    return cell;
}

#pragma mark - Network delegate


- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
// A delegate method called by the NSURLConnection when the request/response
// exchange is complete.  We look at the response to check that the HTTP
// status code is 2xx.  If it isn't, we fail right now.
{
#pragma unused(theConnection)
    NSHTTPURLResponse * httpResponse;
    
    assert(theConnection == self.connection);
    
    httpResponse = (NSHTTPURLResponse *) response;
    assert( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] );
    
    if ((httpResponse.statusCode / 100) != 2) {
        [self stopSendWithStatus:[NSString stringWithFormat:@"HTTP error %zd", (ssize_t) httpResponse.statusCode]];
    } else {
        //        self.tfGenericData.text = @"Response OK.";
        //        [self.tfGenericData setText:@"Response OK."];
    }
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
// A delegate method called by the NSURLConnection as data arrives.  The
// response data for a POST is only for useful for debugging purposes,
// so we just drop it on the floor.
{
#pragma unused(theConnection)
#pragma unused(data)
    
    assert(theConnection == self.connection);
    
    // do nothing
    NSInteger dataLength = [data length];
    const uint8_t *dataBytes  = [data bytes];
    
    //    NSString *str = _tvOhm.text;
    NSString *tmp = [[NSString alloc] initWithBytes:dataBytes length:dataLength encoding:NSASCIIStringEncoding]; // bytes2string

    
    NSError *err;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[tmp dataUsingEncoding:NSASCIIStringEncoding] options:NSJSONReadingMutableLeaves error:&err];
    
    //    NSLog(@"json log %@", json);
    for (NSDictionary *tmp in json) {
        NSLog(@"%@", [NSString stringWithFormat:@"%@ => %@", [tmp valueForKey:@"timestamp"], [tmp valueForKey:@"value" ]]);
        
//        // enum the every record.
//        NSString * record = [NSString stringWithFormat:@"%@ => %@", [tmp valueForKey:@"timestamp"], [tmp valueForKey:@"value" ]];
        
        [self.listOhm insertObject:[tmp valueForKey:@"timestamp"] atIndex:0];
        
    }
    
    // refresh all cells
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];

    
    
    
    //    _tvOhm.text = [str stringByAppendingString:tmp];
    
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
// A delegate method called by the NSURLConnection if the connection fails.
// We shut down the connection and display the failure.  Production quality code
// would either display or log the actual error.
{
#pragma unused(theConnection)
#pragma unused(error)
    assert(theConnection == self.connection);
    
    [self stopSendWithStatus:@"Connection failed"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
// A delegate method called by the NSURLConnection when the connection has been
// done successfully.  We shut down the connection with a nil status, which
// causes the image to be displayed.
{
#pragma unused(theConnection)
    assert(theConnection == self.connection);
    
    [self stopSendWithStatus:nil];
    
    //    [self requestSenInfo];
}

- (void)stopSendWithStatus:(NSString *)statusString
{
    if (self.connection != nil) {
        [self.connection cancel];
        self.connection = nil;
    }
    //    if (statusString != nil)
    //    {
    //        self.tfGenericData.text = statusString;
    //    }
    //    
    [[	NetworkManager sharedInstance] didStopNetworkOperation];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
