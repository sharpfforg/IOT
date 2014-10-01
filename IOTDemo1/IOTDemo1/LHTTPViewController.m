//
//  LHTTPViewController.m
//  IOTDemo1
//
//  Created by linfeng on 14-9-27.
//  Copyright (c) 2014年 ___SHARPFF___. All rights reserved.
//

#import "LHTTPViewController.h"
#import "NetworkManager.h"
//#import "NSStream.h"
//#include <sys/socket.h>
//#include <unistd.h>

#include <CFNetwork/CFNetwork.h>
#import <Foundation/NSFileManager.h>

@interface LHTTPViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *getOrCancel;
@property (nonatomic, strong, readwrite) NSURLConnection *  connection;
@property (nonatomic, strong, readwrite) NSURLConnection *  conn_ts;
@property (nonatomic, strong, readwrite) NSOutputStream *  fileStream;
@property (nonatomic, copy,   readwrite) NSString *  filePath;
@property (nonatomic, strong, readwrite) IBOutlet UIImageView * imageView;
@property (weak, nonatomic) IBOutlet UILabel *lbStatus;
@property (weak, nonatomic) IBOutlet UITextView *tvTimes;
@end

@implementation LHTTPViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.getOrCancel.possibleTitles = [NSSet setWithObjects:@"Get", @"Cancel", nil];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    

    self.imageView = nil;
    self.lbStatus = nil;
    self.getOrCancel = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onGetOrCancel:(id)sender {
    
    if ([self.getOrCancel.title  isEqual: @"Get"])
    {
        self.getOrCancel.title = @"Cancel";
     
        // img content
        int dev_id = 14437;
		int sen_id = 24331;
        
        NSString *body = @"";
        self.connection = [[NetworkManager sharedInstance] genericData:@"GET" APIKey:nil deviceID:dev_id sensorID:sen_id data:[body UTF8String] photo:@"photo/content" id:self];
        if (self.connection)
        {
            [[NetworkManager sharedInstance] didStartNetworkOperation];
            self.filePath = [[NetworkManager sharedInstance] pathForTemporaryFileWithPrefix:@"Get"];
            assert(self.filePath != nil);
            
            self.fileStream = [NSOutputStream outputStreamToFileAtPath:self.filePath append:NO];
            assert(self.fileStream != nil);
            
            
            // remove the subpath of tmp first
            NSString *folder = NSTemporaryDirectory();
            NSArray *subpaths = [[NSFileManager defaultManager] subpathsAtPath:folder];
            BOOL ret;
            NSError *err = [[NSError alloc] init];
            for (NSString *str in subpaths) {
                ret = [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", folder, str] error:&err];
            }



            [self.fileStream open];
        }
        
        // img info
        _conn_ts = [[NetworkManager sharedInstance] genericData:@"GET" APIKey:nil deviceID:dev_id sensorID:sen_id data:[body UTF8String] photo:@"photo/info" id:self];
        if (self.conn_ts) {
            [[NetworkManager sharedInstance] didStartNetworkOperation];
        }
        // Tell the UI we're receiving.
        

    }
    else if ([self.getOrCancel.title isEqual : @"Cancel"])
    {

        [self stopReceiveWithStatus:@"Canceled"];
        self.getOrCancel.title = @"Get";
        if (self.connection != nil) {
            [self.connection cancel];
            self.conn_ts = nil;
        }
        if (self.conn_ts != nil) {
            [self.conn_ts cancel];
            self.conn_ts = nil;
        }
    }
    
}


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
    } else {
        if (theConnection == self.connection)
        {
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
                self.getOrCancel.title = @"Get";
            } else {
                self.lbStatus.text = @"Response img OK.";
            }
        }
        else if (theConnection == self.connection){
            
            self.lbStatus.text = @"Response info OK.";
        }
    }

}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
// A delegate method called by the NSURLConnection as data arrives.  We just
// write the data to the file.
{
#pragma unused(theConnection)
    NSInteger       dataLength;
    const uint8_t * dataBytes;
    NSInteger       bytesWritten;
    NSInteger       bytesWrittenSoFar;
    
//    assert(theConnection == self.connection || theConnection == self.conn_ts);
    
    dataLength = [data length];
    dataBytes  = [data bytes];
    if (theConnection == self.connection) {
        bytesWrittenSoFar = 0;
        do {
            bytesWritten = [self.fileStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
            assert(bytesWritten != 0);
            if (bytesWritten == -1) {
                [self stopReceiveWithStatus:@"File write error"];
                self.getOrCancel.title = @"Get";
                break;
            } else {
                bytesWrittenSoFar += bytesWritten;
            }
        } while (bytesWrittenSoFar != dataLength);
    }
    else if (theConnection == self.conn_ts){
//        self.lbTime.text = [NSString stringWithFormat:@"%s", dataBytes];
//        self.tvTimes.text = [NSString stringWithFormat:@"%s", dataBytes];
        self.tvTimes.text = [[NSString alloc] initWithBytes:dataBytes length:dataLength encoding:NSASCIIStringEncoding];
    }
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
// A delegate method called by the NSURLConnection if the connection fails.
// We shut down the connection and display the failure.  Production quality code
// would either display or log the actual error.
{
#pragma unused(theConnection)
#pragma  unused(error)
    assert(theConnection == self.connection || theConnection == self.conn_ts);
    
    [self stopReceiveWithStatus:@"Connection failed"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
// A delegate method called by the NSURLConnection when the connection has been
// done successfully.  We shut down the connection with a nil status, which
// causes the image to be displayed.
{
#pragma unused(theConnection)
//    assert(theConnection == self.connection || theConnection == self.conn_ts);
    if (theConnection == self.connection) {
        if (self.connection != nil) {
            [self.connection cancel];
            self.connection = nil;
        }
        if (self.fileStream != nil) {
            [self.fileStream close];
            self.fileStream = nil;
        }
        
        assert(self.filePath != nil);
        self.imageView.image = [UIImage imageWithContentsOfFile:self.filePath];

        self.lbStatus.text = @"Get img successfully";
        
        self.filePath = nil;
    
        self.getOrCancel.title = @"Get";
    }
    else if (theConnection == self.conn_ts)
    {
        if (self.conn_ts != nil) {
            [self.conn_ts cancel];
            self.conn_ts = nil;
        }
        self.lbStatus.text = @"Get img successfully";
    }
    [self stopReceiveWithStatus:nil];
}


- (void)stopReceiveWithStatus:(NSString *)statusString
// Shuts down the connection and displays the result (statusString == nil)
// or the error status (otherwise).
{


    [[NetworkManager sharedInstance] didStopNetworkOperation];

}

- (void)dealloc
{
    // Because NSURLConnection retains its delegate until the connection finishes, and
    // any time the connection finishes we call -stopReceiveWithStatus: to clean everything
    // up, we can't be deallocated with a connection in progress.
    assert(self->_connection == nil);
}

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
