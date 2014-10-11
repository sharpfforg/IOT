//
//  LPicsTableViewController.m
//  IOTDemo1
//
//  Created by linfeng on 14-10-7.
//  Copyright (c) 2014年 ___SHARPFF___. All rights reserved.
//

#import "LPicsTableViewController.h"
#import "LPicsTableViewCell.h"
#import "NetworkManager.h"

// the record is for listPics
@interface LPicsRecord : NSObject
@property (nonatomic, copy, readwrite) NSString *timestamp;
@property (nonatomic, copy, readwrite) NSString *filePath;
@property (nonatomic, strong, readwrite) NSOutputStream *fileStream;
@property (nonatomic, strong, readwrite) NSURLConnection *connPic;
@property (nonatomic, readwrite) NSInteger index;
- (id)initWithTimestamp:(NSString*)timestamp index:(NSInteger)index;
@end

@implementation LPicsRecord
- (id)initWithTimestamp:(NSString*)timestamp index:(NSInteger)index
{
    self.timestamp = timestamp;
    self.fileStream = nil;
    self.filePath = nil;
    self.connPic = nil;
    self.index = index;
    return self;
}
@end


@interface LPicsTableViewController ()
{
    int dev_id;
    int sen_id;
	CGFloat orignalTop;
}
@property (nonatomic, strong, readwrite) NSURLConnection *  connection;
//@property (nonatomic, copy,   readwrite) NSString *  filePath;
@property (nonatomic, strong, readwrite) NSDictionary *dictPics;
@property (nonatomic, strong, readwrite) NSMutableArray *listPics;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *aiv;
@end

@implementation LPicsTableViewController

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
    
	// remove the subpath of tmp first
	NSString *folder = NSTemporaryDirectory();
	NSArray *subpaths = [[NSFileManager defaultManager] subpathsAtPath:folder];
	BOOL ret;
	NSError *err = [[NSError alloc] init];
	for (NSString *str in subpaths) {
		ret = [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", folder, str] error:&err];
	}

    
    // img content
    dev_id = 14437;
    sen_id = 24331;
    
    self.connection = [[NetworkManager sharedInstance] historyDeviceID:dev_id sensorID:sen_id from:-3600*24*30 id:self];
    
    if (self.connection) {
        [[NetworkManager sharedInstance] didStartNetworkOperation];
    }
    
    self.listPics = [[NSMutableArray alloc] init];
    
//    // img info
//    _conn_ts = [[NetworkManager sharedInstance] genericData:@"GET" APIKey:nil deviceID:dev_id sensorID:sen_id data:[body UTF8String] photo:@"photo/info" id:self];
//    if (self.conn_ts) {
//        [[NetworkManager sharedInstance] didStartNetworkOperation];
//    }
    // Tell the UI we're receiving.
	self->orignalTop = 0.0f;
	
	_aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	
    [self.view addSubview:_aiv];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Internal Method

- (void)LDidLoading:(UIScrollView *)scrollView {
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
    NSLog(@"LDidLoad [%f, %f, %f, %f]", self.view.bounds.origin.x, self.view.bounds.origin.y,
          self.view.bounds.size.height, self.view.bounds.size.width);
    
	[scrollView setContentInset:UIEdgeInsetsMake((CGFloat)abs(self->orignalTop) + self.view.bounds.size.height / 8, 0.0f, 0.0f, 0.0f)];
    
    
//    self.connection = [[NetworkManager sharedInstance] genericData:@"GET" APIKey:nil deviceID:self->dev_id sensorID:self->sen_id data:"" photo:nil id:self];
//    [[NetworkManager sharedInstance] didStartNetworkOperation];
	self.dictPics = nil;
	self.listPics = nil;
	self.listPics = [[NSMutableArray alloc] init];
	self.connection = [[NetworkManager sharedInstance] historyDeviceID:dev_id sensorID:sen_id from:-3600*24*30 id:self];
    
    if (self.connection) {
        [[NetworkManager sharedInstance] didStartNetworkOperation];
    }
    
	
	//    _aiv.frame = CGRectMake(self.view.bounds.size.width / 2 - 10, self->orignalTop + 20, 20.0f, 20.0f);
    [_aiv startAnimating];
    
	//    [_timer fire];
	[UIView commitAnimations];
    
}
- (void)LDidLoaded:(UIScrollView *)scrollView {
	
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    [scrollView setContentInset:UIEdgeInsetsMake((CGFloat)abs(self->orignalTop), 0.0f, 0.0f, 0.0f)];
    [UIView commitAnimations];
	//    self->isLoading = NO;
	if ([_aiv isAnimating]) {
		[_aiv stopAnimating];
	}
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
    //	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    if (0.0f == self->orignalTop) {
        self->orignalTop = scrollView.bounds.origin.y <= -10.0f ? scrollView.bounds.origin.y : 0.1f;
        NSLog(@"origin.y [%f] => [%f]", scrollView.bounds.origin.y, self->orignalTop);
        _aiv.frame = CGRectMake(self.view.bounds.size.width / 2 - 10, self->orignalTop > 0.0f ? -30.0f : self->orignalTop + 30.0f, 20.0f, 20.0f);
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	//	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    NSLog(@"decelerate is %d, origin.y is %f", decelerate, scrollView.bounds.origin.y);
    if (scrollView.bounds.origin.y - self->orignalTop < (0.0f - self.view.bounds.size.height / 8)) {
        [self LDidLoading:scrollView];
    }
	
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.

    NSLog(@"list count %d", self.listPics.count);
    return self.listPics ? self.listPics.count : 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // get the cell obj.
    LPicsTableViewCell *cell = (LPicsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"idPicture" forIndexPath:indexPath];
    
    // get the record context.
	NSLog(@"indexPath.row [%d]", indexPath.row);
	if (!self.listPics || !self.listPics.count) {
		return cell;
	}
    LPicsRecord *record = [self.listPics objectAtIndex:indexPath.row];
    if (!record) {
        return cell;
    }

    // do request the current cell picture
    if (!record.filePath)
    {
        NSString *body = @"";
        record.connPic = [[NetworkManager sharedInstance] genericData:@"GET" APIKey:nil deviceID:dev_id sensorID:sen_id data:[body UTF8String] photo:[NSString stringWithFormat:@"photo/content/%@", record.timestamp] id:self];
        if (record.connPic)
        {
            [[NetworkManager sharedInstance] didStartNetworkOperation];
            record.filePath = [[NetworkManager sharedInstance] pathForTemporaryFileWithPrefix:@"Get"];
            assert(record.filePath != nil);
            
            record.fileStream = [NSOutputStream outputStreamToFileAtPath:record.filePath append:NO];
            assert(record.fileStream != nil);
            
            
			// or else this will be a cached image.
            cell.ivPic.image = nil;
            
            [record.fileStream open];
        }

    }
    //
    else
    {
        // Configure the cell...
        // it will be called while fresh the cell positively.
        UIImage *img = [UIImage imageWithContentsOfFile:record.filePath];
        NSLog(@"idx [%@], img[%@], path[%@]", indexPath, img, record.filePath);
        cell.ivPic.image = img;
        

    }

	// set the label text
	NSString *s = [record.timestamp copy];
	s = [s stringByReplacingOccurrencesOfString:@"T" withString:@"\r\n"];
	[cell.lbTimestamp setText:s];
	NSLog(@"lbTimestamp s[%@] real[%@]", s, cell.lbTimestamp.text);
    return cell;
}

#pragma mark - Network

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
// A delegate method called by the NSURLConnection when the request/response
// exchange is complete.  We look at the response to check that the HTTP
// status code is 2xx and that the Content-Type is acceptable.  If these checks
// fail, we give up on the transfer.
{
#pragma unused(theConnection)
    NSHTTPURLResponse * httpResponse;
    NSString *          contentTypeHeader;
    
    //assert(theConnection == self.connection || theConnection == self.conn_ts);
    
    
    
    httpResponse = (NSHTTPURLResponse *) response;
    assert( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] );
    
    if ((httpResponse.statusCode / 100) != 2) {
        [self stopReceiveWithStatus:[NSString stringWithFormat:@"HTTP error %zd", (ssize_t) httpResponse.statusCode]];
        // TODO: show a pic for failed.
    } else {
        if (self.dictPics) {
            
             // -MIMEType strips any parameters, strips leading or trailer whitespace, and lower cases
            // the string, so we can just use -isEqual: on the result.
            contentTypeHeader = [httpResponse MIMEType];
            if (contentTypeHeader == nil) {
                [self stopReceiveWithStatus:@"No Content-Type!"];
            } else if ( ! [contentTypeHeader isEqual:@"image/jpeg"]
                       && ! [contentTypeHeader isEqual:@"image/png"]
                       && ! [contentTypeHeader isEqual:@"image/gif"]
                       && ! [contentTypeHeader isEqual:@"image/jpg"] ) {
                [self stopReceiveWithStatus:[NSString stringWithFormat:@"Unsupported Content-Type (%@)", contentTypeHeader]];
        //                self.getOrCancel.title = @"Get";
            } else {
        //                self.lbStatus.text = @"Response img OK.";
                int i = 0;
                for (LPicsRecord *record in self.listPics) {
                    if (theConnection == record.connPic) {
                        NSLog(@"response index[%d][%@] ok", record.index, record.timestamp);
                        break;
                    }
                    i++;
                }
                
            }
        }


    }
    
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
// A delegate method called by the NSURLConnection as data arrives.  We just
// write the data to the file.
{
#pragma unused(theConnection)
    // do nothing
    NSInteger dataLength = [data length];
    const uint8_t *dataBytes  = [data bytes];
    
    NSString *tmp = [[NSString alloc] initWithBytes:dataBytes length:dataLength encoding:NSASCIIStringEncoding]; // bytes2string
    
    // load history list to json dictionary.
    if (!_dictPics) {
        NSError *err;
        _dictPics = [NSJSONSerialization JSONObjectWithData:[tmp dataUsingEncoding:NSASCIIStringEncoding] options:NSJSONReadingMutableLeaves error:&err];
        NSLog(@"self.dictPics %@", _dictPics);
        

    }
    // every pictrues data
    else
    {
        //    NSInteger       dataLength;
        //    const uint8_t * dataBytes;
        NSInteger       bytesWritten;
        NSInteger       bytesWrittenSoFar;
        
        dataLength = [data length];
        dataBytes  = [data bytes];
        for (LPicsRecord *record in self.listPics) {
            if (theConnection == record.connPic) {
                bytesWrittenSoFar = 0;
                do {
                    bytesWritten = [record.fileStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
                    assert(bytesWritten != 0);
                    if (bytesWritten == -1) {
                        [self stopReceiveWithStatus:@"File write error"];
                        break;
                    } else {
                        bytesWrittenSoFar += bytesWritten;
                    }
                } while (bytesWrittenSoFar != dataLength);
                break;
            }
        }
        //    else if (theConnection == self.conn_ts){
        //        //        self.lbTime.text = [NSString stringWithFormat:@"%s", dataBytes];
        //        //        self.tvTimes.text = [NSString stringWithFormat:@"%s", dataBytes];
        //        self.tvTimes.text = [[NSString alloc] initWithBytes:dataBytes length:dataLength encoding:NSASCIIStringEncoding];
        //    }
    }

    

}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
// A delegate method called by the NSURLConnection if the connection fails.
// We shut down the connection and display the failure.  Production quality code
// would either display or log the actual error.
{
#pragma unused(theConnection)
#pragma  unused(error)
//    assert(theConnection == self.connection /*|| theConnection == self.conn_ts*/);
    
    [self stopReceiveWithStatus:@"Connection failed"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
// A delegate method called by the NSURLConnection when the connection has been
// done successfully.  We shut down the connection with a nil status, which
// causes the image to be displayed.
{
#pragma unused(theConnection)
    
    // list request DONE
    if (theConnection == self.connection) {
        
		if ([self.view isKindOfClass:[UIScrollView class]])
			[self LDidLoaded:(UIScrollView *)self.view];
		
        // init the listPics
        int i = 0;
        for (NSDictionary *item in self.dictPics) {
            
            NSLog(@"item is [%@]", item);
            LPicsRecord *record = [[LPicsRecord alloc] initWithTimestamp:[item valueForKey:@"timestamp"] index:self.dictPics.count - i - 1];
            [self.listPics insertObject:record atIndex:0];
//			if (3 == i) {
//				break;
//			}
            i++;
        }
        //        NSEnumerator *em = [self.listPics reverseObjectEnumerator];
        
        if (self.dictPics) {
            NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
            [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        

        if (self.connection != nil) {
            [self.connection cancel];
            self.connection = nil;
        }
    }
    // EVERY pic request DONE
    else
    {
        for (LPicsRecord *record in self.listPics) {
            if (theConnection == record.connPic) {
                {
                    if (record.connPic != nil) {
                        [record.connPic cancel];
                        record.connPic = nil;
                    }
                    if (record.fileStream != nil) {
                        [record.fileStream close];
                        record.fileStream = nil;
                    }
                    
                    assert(record.filePath != nil);
                    
                    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:record.index inSection:0];
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];

                    
                    //        self.imageView.image = [UIImage imageWithContentsOfFile:self.filePath];
                    
                    //        self.lbStatus.text = @"Get img successfully";
                    
//                    self.filePath = nil;
                    
                    //        self.getOrCancel.title = @"Get";
                }
				break;
            }
			
        }
    }

//    else if (theConnection == self.conn_ts)
//    {
//        if (self.conn_ts != nil) {
//            [self.conn_ts cancel];
//            self.conn_ts = nil;
//        }
//        self.lbStatus.text = @"Get img successfully";
//    }
    [self stopReceiveWithStatus:nil];
}


- (void)stopReceiveWithStatus:(NSString *)statusString
// Shuts down the connection and displays the result (statusString == nil)
// or the error status (otherwise).
{
    
    NSLog(@"stop reason [%@]", statusString);
    [[NetworkManager sharedInstance] didStopNetworkOperation];
    
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
