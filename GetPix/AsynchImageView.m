//
//  AsynchImageView.m
//  GetPix
//
//  Created by Darren Venn on 3/30/13.
//  Copyright (c) 2013 Darren Venn. All rights reserved.
//

#import "AsynchImageView.h"

@implementation AsynchImageView

// This class implements a "self-loading" UIImageView, with each image containing it's own NSURLConnection.
// When a new AsynchImageView is created, the frame etc. are set up, but the image itself is not loaded until
// the loadImageFromNetwork method is called.

- (id)initWithFrameURLStringAndTag:(CGRect)frame :(NSString*) urlString :(NSInteger) tag;
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.urlString = urlString;
        // image is grey tile before loading
        self.backgroundColor = [UIColor grayColor];
        // set the tag so we can find this image on the UI if we need to
        self.tag = tag;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrameURLStringAndTag:frame :@"" :0];
}

- (void)loadImageFromNetwork {
    
    // spawn a new thread to load the image in the background, from the network
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:MAX_TIME_TO_WAIT_FOR_IMAGE];
        NSURLResponse* response = nil;
        NSError* error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            // update the image and sent notification on the main thread
            self.image=[UIImage imageWithData:data];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.darrenvenn.completedImageLoad" object:nil];
        });
    });
    
    
}

@end
