//
// SampleViewController.m
// BFTaskPromiseExample
//
// Copyright (c) 2015,2016 Hironori Ichimiya <hiron@hironytic.com>
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "SampleViewController.h"
#import "Bolts.h"
#import "BFTask+PromiseLike.h"

@interface SampleViewController ()

@end

@implementation SampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Button" forState:UIControlStateNormal];
    [button setFrame:CGRectMake(8, 32, 120, 32)];
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)buttonTapped:(id)sender {
    [self countUsersAsync].continueWith(^id (BFTask *task) {
        // this block is called regardless of the success or failure
        NSNumber *count = task.result;
        if ([count intValue] <= 0) {
            return [BFTask taskWithError:[NSError errorWithDomain:@"MyDomain"
                                                             code:-1
                                                         userInfo:nil]];
        } else {
            return [self makeTotalUserStringAsync:count];
        }
    }).then(^id (NSString *totalUserString) {
        // this block is skipped when the previous task is failed.
        [self showMessage:totalUserString];
        return nil;
    }).catch(^id (NSError *error) {
        // this block is called in error case.
        [self showErrorMessage:error];
        return nil;
    }).finally(^BFTask * (){
        [self updateList];
        return nil;
    });
}

- (BFTask *)countUsersAsync {
    return [BFTask taskWithResult:@10];
}

- (BFTask *)makeTotalUserStringAsync:(NSNumber *)count {
    return [BFTask taskWithResult:[NSString stringWithFormat:@"Total User: %@", count]];
}

- (void)showMessage:(NSString *)string {
    NSLog(@"message: %@", string);
}

- (void)showErrorMessage:(NSError *)error {
    NSLog(@"error: %@", error);
}

- (void)updateList {
    NSLog(@"list updated");
}

@end
