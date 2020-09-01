//
//  ViewController.m
//  lab1_weather
//
//  Created by Clay Harper on 8/27/20.
//  Copyright © 2020 Mobile Sensing. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
//@property (strong, nonatomic) ViewController *viewController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Get data after load
//    dallas' id: 4684888
    NSString *url = @"https://api.openweathermap.org/data/2.5/forecast?id=4684888&appid=dd12273b23df1d19ad59652762894830";
    NSString *data = [self getDataFrom:url];
    NSLog(@"Data received: %@", data);
    
}
//taken from here: https://stackoverflow.com/questions/9404104/simple-objective-c-get-request
- (NSString *) getDataFrom:(NSString *)targetUrl{
    __block NSString *myString = nil;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:targetUrl]];

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data,
        NSURLResponse * _Nullable response,
        NSError * _Nullable error) {

          myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
          NSLog(@"Data received: %@", myString);
    }] resume];
    
    return myString;
}

// good links for weather apis
// https://openweathermap.org/forecast5
// https://openweathermap.org/guide



- (IBAction)apiTester:(UIButton *)sender {
//    get data on button click
    NSString *url = @"https://api.openweathermap.org/data/2.5/forecast?id=4684888&appid=dd12273b23df1d19ad59652762894830";
    
    NSString *data = [self getDataFrom:url];
    NSLog(@"Data received: %@", data);

}

@end
