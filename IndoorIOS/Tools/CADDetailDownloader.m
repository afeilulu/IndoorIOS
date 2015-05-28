//
//  CADDetailDownloader.m
//  IndoorIOS
//
//  Created by 陈革非 on 15/5/28.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import "CADDetailDownloader.h"
#import "Constants.h"
#import "ParseStadiumDetail.h"

@implementation CADDetailDownloader

// -------------------------------------------------------------------------------
//	startDownload
// -------------------------------------------------------------------------------
- (void)startDownload
{
    self.activeDownload = [NSMutableData data];
    
    // 从服务器获取场馆详情
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kStadiumDetailJsonUrl]];
    [postRequest setHTTPMethod:@"POST"];
    NSString *params = [[NSString alloc] initWithFormat:@"jsonString={'sportSiteId':'%@'}",self.stadiumRecord.idString];
    [postRequest setHTTPBody: [params dataUsingEncoding:NSUTF8StringEncoding]];
    
    // alloc+init and start an NSURLConnection; release on completion/failure
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:postRequest delegate:self];
    
    self.imageConnection = conn;
}

// -------------------------------------------------------------------------------
//	cancelDownload
// -------------------------------------------------------------------------------
- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}


#pragma mark - NSURLConnectionDelegate

// -------------------------------------------------------------------------------
//	connection:didReceiveData:data
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

// -------------------------------------------------------------------------------
//	connection:didFailWithError:error
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
}

// -------------------------------------------------------------------------------
//	connectionDidFinishLoading:connection
// -------------------------------------------------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // create the queue to run our ParseOperation
    self.queue = [[NSOperationQueue alloc] init];
    
    ParseStadiumDetail *parser = [[ParseStadiumDetail alloc] initWithData:self.activeDownload];
    
    parser.errorHandler = ^(NSError *parseError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // run in background , do nothing here
        });
    };
    
    parser.completionBlock = ^(void) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // do nothing
        });
        // we are finished with the queue and our ParseOperation
        self.queue = nil;
    };
    
    [self.queue addOperation:parser]; // this will start the "ParseOperation"
    
    
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
    
    // call our delegate and tell it that our icon is ready for display
    if (self.completionHandler)
    {
        self.completionHandler();
    }
}

@end
