//
//  LCtrlTableViewController.m
//  IOTDemo1
//
//  Created by linfeng on 14-9-25.
//  Copyright (c) 2014年 ___SHARPFF___. All rights reserved.
//

#import "LCtrlTableViewController.h"

#import "NetworkManager.h"
//#include <sys/socket.h>
//#include <unistd.h>

#include <CFNetwork/CFNetwork.h>

@interface LCtrlTableViewController ()
{
    CGFloat orignalTop;
    int devId;
    int senIdSwitcher;
    int senIdGeneric;
    BOOL isLoading;
    

}

@property (nonatomic, strong, readwrite) NSURLConnection *  connection;
@property (nonatomic, strong, readonly) NSTimer *timer;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *aiv;

@end

@implementation LCtrlTableViewController

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
    NSLog(@"viewDidLoad [%f, %f, %f, %f", self.view.bounds.origin.x, self.view.bounds.origin.y,
          self.view.bounds.size.height, self.view.bounds.size.width);
    self->orignalTop = 0.0f;
    
    // config
    devId = 14437;
    senIdSwitcher = 24202;
    self->senIdGeneric = 24241;
    
    isLoading = NO;

    
    _aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    [self.view addSubview:_aiv];
    
    NSLog(@"start ScrollView original.y is [%f]", self.view.bounds.origin.y);
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return [super numberOfSectionsInTableView:tableView];
//    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [super tableView:tableView numberOfRowsInSection:section];
    return 0;
}

- (IBAction)onSwitched:(id)sender {
    if (sender == _swLight)
    {
        if (nil != self.connection) {
            return;
        }
        NSLog(@"switcher state [%d]", _swLight.on);

        
        NSString *body = [NSString stringWithFormat:@"{\"value\":%u}", _swLight.on];
        self.connection = [[NetworkManager sharedInstance] genericData:@"POST" APIKey:nil deviceID:self->devId sensorID:self->senIdSwitcher data:[body UTF8String] photo:nil id:self];
        [[NetworkManager sharedInstance] didStartNetworkOperation];
        _tfGenericData.text = nil;
    }
}
- (IBAction)onGenericSend:(id)sender {
    if (sender == _btnSend)
    {
        if (self.connection != nil)
            return;
        NSString *str = _tfGenericData.text;
//        NSLog(@"sent data %@", str);
//        int dev_id = 14437;
//		int sen_id = 24241;

        NSString *body = [NSString stringWithFormat:@"{\"key\":\"%s\",\"value\":{\"data1\":\"%@\",\"data2\":\"%@\"}}", "110adc3949ba59abbe56e037f20f884e", str, str];
        
        self.connection = [[NetworkManager sharedInstance] genericData:@"POST" APIKey:nil deviceID:self->devId sensorID:self->senIdGeneric data:[body UTF8String] photo:nil id:self];
        [[NetworkManager sharedInstance] didStartNetworkOperation];
        _tfGenericData.text = nil;
    }
}


- (void)dealloc
{
    // Because NSURLConnection retains its delegate until the connection finishes, and
    // any time the connection finishes we call -stopSendWithStatus: to clean everything
    // up, we can't be deallocated with a connection in progress.
    assert(self->_connection == nil);
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
        self.tfGenericData.text = @"Response OK.";
        [self.tfGenericData setText:@"Response OK."];
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
    if (self->isLoading) {
        const char *buf = (const char *)[data bytes];
        int len = [data length];
        const char *find = strnstr(buf, "\"value\":", len);
        if (find)
        {
            int value = atoi(find + strlen("\"value\":"));
            self.swLight.on = value;
        }
    }
    // do nothing
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
    if (self->isLoading) {
		if ([self.view isKindOfClass:[UIScrollView class]])
			[self LDidLoaded:(UIScrollView *)self.view];
        self->isLoading = NO;
        [_aiv stopAnimating];
    }
    [self stopSendWithStatus:nil];
}

- (void)stopSendWithStatus:(NSString *)statusString
{
    if (self.connection != nil) {
        [self.connection cancel];
        self.connection = nil;
    }
    if (statusString != nil)
    {
        self.tfGenericData.text = statusString;
    }

    [[	NetworkManager sharedInstance] didStopNetworkOperation];
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

#pragma mark Internal Methodsd

- (void)LDidLoading:(UIScrollView *)scrollView {
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
    NSLog(@"LDidLoad [%f, %f, %f, %f", self.view.bounds.origin.x, self.view.bounds.origin.y,
          self.view.bounds.size.height, self.view.bounds.size.width);
    
	[scrollView setContentInset:UIEdgeInsetsMake((CGFloat)abs(self->orignalTop) + self.view.bounds.size.height / 8, 0.0f, 0.0f, 0.0f)];
    
//    [NSTimer scheduledTimerWithTimeInterval:5.1f target:self selector:@selector(timeoutHandler:) userInfo:scrollView repeats:NO];
    
    self.connection = [[NetworkManager sharedInstance] genericData:@"GET" APIKey:nil deviceID:self->devId sensorID:self->senIdSwitcher data:"" photo:nil id:self];
    
    [[NetworkManager sharedInstance] didStartNetworkOperation];
    
    self->isLoading = YES;
//    _aiv.frame = CGRectMake(self.view.bounds.size.width / 2 - 10, self->orignalTop + 20, 20.0f, 20.0f);
    [_aiv startAnimating];
    
//    [_timer fire];
	[UIView commitAnimations];
    
}

//- (void)timeoutHandler:(NSTimer *)timer
//{
//    UIScrollView *sv = (UIScrollView *)timer.userInfo;
//    [self LDidLoaded:sv];
//}

- (void)LDidLoaded:(UIScrollView *)scrollView {

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    [scrollView setContentInset:UIEdgeInsetsMake((CGFloat)abs(self->orignalTop), 0.0f, 0.0f, 0.0f)];
    NSLog(@"restore self->orignalTop[%f]", self->orignalTop);
    [UIView commitAnimations];
//    self->isLoading = NO;
}


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
