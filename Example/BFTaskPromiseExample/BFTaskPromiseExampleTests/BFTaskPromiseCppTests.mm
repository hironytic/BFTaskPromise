//
// BFTaskPromiseCppTests.mm
// BFTaskPromiseExampleTests
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BFTask+PromiseLike.h"

#define MY_ERROR_DOMAIN @"MyErrorDomain"

@interface BFTaskPromiseCppTests : XCTestCase

@end

@implementation BFTaskPromiseCppTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCatchWithShouldRunWhenError {
    XCTestExpectation *expectation = [self expectationWithDescription:@"finish task"];
    [BFTask taskWithError:[NSError errorWithDomain:MY_ERROR_DOMAIN code:0 userInfo:nil]].catchWith( ^id (NSError *error) {
        XCTAssertEqualObjects([error domain], MY_ERROR_DOMAIN, "error should be passed.");
        [expectation fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

@end
