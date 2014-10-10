//
//  LOHMViewController.m
//  IOTDemo1
//
//  Created by linfeng on 14-9-29.
//  Copyright (c) 2014年 ___SHARPFF___. All rights reserved.
//

#import "LOHMViewController.h"
#import "NetworkManager.h"

@interface LOHMViewController ()
@property (nonatomic, strong, readwrite) NSURLConnection *  connection;
@property (weak, nonatomic) IBOutlet UITextView *tvOhm;
@property (weak, nonatomic) NSTimer* timer;

@end

@implementation LOHMViewController

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
    

    [self requestSenInfo];
//    _timer = [NSTimer timerWithTimeInterval:8.0 target:self selector:@selector(timerCB:) userInfo:nil repeats:YES];
//    [_timer fire];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
//    [self stopSendWithStatus:nil];
//    [_timer invalidate];
//    _timer = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    // Because NSURLConnection retains its delegate until the connection finishes, and
    // any time the connection finishes we call -stopSendWithStatus: to clean everything
    // up, we can't be deallocated with a connection in progress.
    assert(self->_connection == nil);
}

- (void)requestSenInfo
{
    int dev_id = 14437;
    int sen_id = 24937;
    
//    NSString *body = @""; // [body UTF8String] string2bytes
//    _connection = [[NetworkManager sharedInstance] genericData:@"GET" APIKey:nil deviceID:dev_id sensorID:sen_id data:[body UTF8String] photo:nil id:self];
    _connection = [[NetworkManager sharedInstance] historyDeviceID:dev_id sensorID:sen_id from:-3600.00*24 id:self];
    if (_connection != nil) {
        [[NetworkManager sharedInstance] didStartNetworkOperation];
    }
}

- (void)timerCB:(NSTimer *)timer
{
    if (_connection != nil)
    {
        [self requestSenInfo];
    }
}
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
    
//    char *p = (char *)&dataBytes[1];
//    char *q = p;
//    int subLen = 0, step = 1;
    
//    do
//    {
//        q = strstr(p, "},");
//        if (!q)
//        {
//            q = strstr(p, "}]");
//            if (!q) {
//                break;
//            }
//        }
//        subLen = q - p + 1;
//        // todo
//        NSString *log = [[NSString alloc] initWithBytes:p length:subLen encoding:NSASCIIStringEncoding];
//        NSLog(@"my log %@", log);
//        NSError *err;
//        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[tmp dataUsingEncoding:NSASCIIStringEncoding] options:NSJSONReadingMutableLeaves error:&err];
//        NSLog(@"json log %@", json);
//        step += subLen + 2;
//        p = q + 2;
//
//    } while (step < dataLength);
    
    NSError *err;

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[tmp dataUsingEncoding:NSASCIIStringEncoding] options:NSJSONReadingMutableLeaves error:&err];

    if (![json count]) {
        _tvOhm.text = @"Nothing...";
    }
    
//    NSLog(@"json log %@", json);
    for (NSDictionary *tmp in json) {
        NSLog(@"%@", [NSString stringWithFormat:@"%@ => %@", [tmp valueForKey:@"timestamp"], [tmp valueForKey:@"value" ]]);
        
        // enum the every record.
        NSString * record = [NSString stringWithFormat:@"%@ => %@", [tmp valueForKey:@"timestamp"], [tmp valueForKey:@"value" ]];
        
        // append to text view
        _tvOhm.text = [NSString stringWithFormat:@"%@\n%@", _tvOhm.text, record];
    }

    
    
    
    
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
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
