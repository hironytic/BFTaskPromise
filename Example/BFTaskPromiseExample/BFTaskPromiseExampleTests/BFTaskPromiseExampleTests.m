//
// BFTaskPromiseExampleTests.m
// BFTaskPromiseExampleTests
//
// Copyright (c) 2014-2016 Hironori Ichimiya <hiron@hironytic.com>
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

#import <XCTest/XCTest.h>
#import "XCTestExpectation+OHRetroCompat.h"
#import "BFTask+PromiseLike.h"
#import "BFTaskCompletionSource.h"

#define MY_ERROR_DOMAIN @"MyErrorDomain"
#define MY_EXCEPTION    @"MyException"

@interface BFTaskPromiseExampleTests : XCTestCase

@end

@implementation BFTaskPromiseExampleTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThenShouldRunWhenSucceeded {
    XCTestExpectation *expectation = [self expectationWithDescription:@"finish task"];
    [BFTask taskWithResult:@30].then( ^id (NSNumber *result) {
        XCTAssertEqual([result intValue], 30, "previous value should be passed.");
        [expectation fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testThenShouldNotRunWhenError {
    XCTestExpectation *expectation = [self expectationWithDescription:@"finish task"];
    __block BOOL ran = NO;
    [BFTask taskWithError:[NSError errorWithDomain:MY_ERROR_DOMAIN code:0 userInfo:nil]].then( ^id (BFTask *task) {
        ran = YES;
        return nil;
    }).finally( ^BFTask *() {
        [expectation fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    XCTAssertFalse(ran, @"then should not ran");
}

- (void)testThenShouldNotRunWhenExceptionOccured {
    XCTestExpectation *expectation = [self expectationWithDescription:@"finish task"];
    __block BOOL ran = NO;
    [BFTask taskWithException:[NSException exceptionWithName:MY_EXCEPTION reason:@"" userInfo:nil]].then( ^id (BFTask *task) {
        ran = YES;
        return nil;
    }).finally( ^BFTask *() {
        [expectation fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    XCTAssertFalse(ran, @"then should not ran");
}

- (void)testThenShouldNotRunWhenCancelled {
    XCTestExpectation *expectation = [self expectationWithDescription:@"finish task"];
    __block BOOL ran = NO;
    [BFTask cancelledTask].then( ^id (BFTask *task) {
        ran = YES;
        return nil;
    }).finally( ^BFTask *() {
        [expectation fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    XCTAssertFalse(ran, @"then should not ran");
}

- (void)testCatchShouldNotRunWhenSucceeded {
    XCTestExpectation *expectation = [self expectationWithDescription:@"finish task"];
    __block BOOL ran = NO;
    [BFTask taskWithResult:@30].catch( ^id (NSError *error) {
        ran = YES;
        return nil;
    }).finally( ^BFTask *() {
        [expectation fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    XCTAssertFalse(ran, @"catch should not ran");
}

- (void)testCatchShouldRunWhenError {
    XCTestExpectation *expectation = [self expectationWithDescription:@"finish task"];
    [BFTask taskWithError:[NSError errorWithDomain:MY_ERROR_DOMAIN code:0 userInfo:nil]].catch( ^id (NSError *error) {
        XCTAssertEqualObjects([error domain], MY_ERROR_DOMAIN, "error should be passed.");
        [expectation fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testCatchShouldRunWhenExceptionOccured {
    XCTestExpectation *expectation = [self expectationWithDescription:@"finish task"];
    [BFTask taskWithException:[NSException exceptionWithName:MY_EXCEPTION reason:@"reason" userInfo:nil]].catch( ^id (NSError *error) {
        XCTAssertEqualObjects(error.domain, BFPTaskErrorDomain);
        XCTAssertEqual(error.code, BFPTaskErrorException);
        XCTAssertEqualObjects(error.userInfo[NSLocalizedDescriptionKey], @"reason");
        NSException *exception = [error.userInfo objectForKey:BFPUnderlyingExceptionKey];
        XCTAssertEqualObjects(exception.name, MY_EXCEPTION, "exception should be passed.");
        [expectation fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testCatchShouldNotRunWhenCancelled {
    XCTestExpectation *expectation = [self expectationWithDescription:@"finish task"];
    __block BOOL ran = NO;
    [BFTask cancelledTask].catch( ^id (NSError *error) {
        ran = YES;
        return nil;
    }).finally( ^BFTask *() {
        [expectation fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    XCTAssertFalse(ran, @"catch should not ran");
}

- (void)testFinallyShouldRunWhenSucceeded {
    XCTestExpectation *expectation = [self expectationWithDescription:@"finish task"];
    [BFTask taskWithResult:@30].finally( ^BFTask *() {
        [expectation fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testFinallyShouldRunWhenFailed {
    XCTestExpectation *expectation = [self expectationWithDescription:@"finish task"];
    [BFTask taskWithError:[NSError errorWithDomain:MY_ERROR_DOMAIN code:0 userInfo:nil]].finally( ^BFTask *() {
        [expectation fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testFinallyShouldRunWhenExceptionOccured {
    XCTestExpectation *expectation = [self expectationWithDescription:@"finish task"];
    [BFTask taskWithException:[NSException exceptionWithName:MY_EXCEPTION reason:@"" userInfo:nil]].finally( ^BFTask *() {
        [expectation fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testFinallyShouldRunWhenCancelled {
    XCTestExpectation *expectation = [self expectationWithDescription:@"finish task"];
    [BFTask cancelledTask].finally( ^BFTask *() {
        [expectation fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (BFTask *)delayAsyncAfter:(int64_t)milliseconds callback:(void (^)())callback {
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    int64_t delta = milliseconds * NSEC_PER_MSEC;
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delta);
    dispatch_after(time, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        callback();
        [source setResult:[NSNumber numberWithLongLong:milliseconds]];
    });
    return [source task];
}

- (void)testFinallyShouldCompleteAfterReturnedTasksCompletion {
    XCTestExpectation *expectation = [self expectationWithDescription:@"finish task"];
    __block int v = 0;
    [BFTask taskWithResult:@30].finally( ^BFTask *() {
        return [self delayAsyncAfter:100 callback: ^{
            v = 100;
        }];
    }).then( ^id (BFTask *task) {
        XCTAssertEqual(v, 100, @"called after the task returnd from finally");
        [expectation fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testFinallyShouldNotChangeResultValue {
    XCTestExpectation *expectation = [self expectationWithDescription:@"finish task"];
    [BFTask taskWithResult:@30].finally( ^BFTask *() {
        return nil;
    }).then( ^id (NSNumber *result) {
        XCTAssertEqual([result intValue], 30, @"result value should not change");
        [expectation fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testFinallyShouldNotChangeErrorValue {
    XCTestExpectation *expectation = [self expectationWithDescription:@"finish task"];
    [BFTask taskWithError:[NSError errorWithDomain:MY_ERROR_DOMAIN code:0 userInfo:nil]].finally( ^BFTask *() {
        return nil;
    }).catch( ^id (NSError *error) {
        XCTAssertEqualObjects([error domain], MY_ERROR_DOMAIN, "error should not be changed.");
        [expectation fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testFinallyShouldNotChangeExceptionValue {
    XCTestExpectation *expectation = [self expectationWithDescription:@"finish task"];
    [BFTask taskWithException:[NSException exceptionWithName:MY_EXCEPTION reason:@"" userInfo:nil]].finally( ^BFTask *() {
        return nil;
    }).catch( ^id (NSError *error) {
        XCTAssertEqualObjects(error.domain, BFPTaskErrorDomain);
        XCTAssertEqual(error.code, BFPTaskErrorException);
        NSException *exception = [error.userInfo objectForKey:BFPUnderlyingExceptionKey];
        XCTAssertEqualObjects(exception.name, MY_EXCEPTION, "exception should not be changed.");
        [expectation fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testFinallyShouldNotChangeResultValueAfterReturnedTasksCompletion {
    XCTestExpectation *expectation = [self expectationWithDescription:@"finish task"];
    [BFTask taskWithResult:@30].finally( ^BFTask *() {
        return [self delayAsyncAfter:100 callback: ^{}];
    }).then( ^id (NSNumber *result) {
        XCTAssertEqual([result intValue], 30, @"result value should not change");
        [expectation fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testFinallyShouldNotChangeErrorValueAfterReturnedTasksCompletion {
    XCTestExpectation *expectation = [self expectationWithDescription:@"finish task"];
    [BFTask taskWithError:[NSError errorWithDomain:MY_ERROR_DOMAIN code:0 userInfo:nil]].finally( ^BFTask *() {
        return [self delayAsyncAfter:100 callback: ^{}];
    }).catch( ^id (NSError *error) {
        XCTAssertEqualObjects([error domain], MY_ERROR_DOMAIN, "error should not be changed.");
        [expectation fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testFinallyShouldNotChangeExceptionValueAfterReturnedTasksCompletion {
    XCTestExpectation *expectation = [self expectationWithDescription:@"finish task"];
    [BFTask taskWithException:[NSException exceptionWithName:MY_EXCEPTION reason:@"" userInfo:nil]].finally( ^BFTask *() {
        return [self delayAsyncAfter:100 callback: ^{}];
    }).catch( ^id (NSError *error) {
        XCTAssertEqualObjects(error.domain, BFPTaskErrorDomain);
        XCTAssertEqual(error.code, BFPTaskErrorException);
        NSException *exception = [error.userInfo objectForKey:BFPUnderlyingExceptionKey];
        XCTAssertEqualObjects(exception.name, MY_EXCEPTION, "exception should not be changed.");
        [expectation fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testFinallyShouldChangeResultValueToErrorValueWhenErrorIsReturned {
    XCTestExpectation *expectation = [self expectationWithDescription:@"finish task"];
    [BFTask taskWithResult:@30].finally( ^BFTask *() {
        return [BFTask taskWithError:[NSError errorWithDomain:MY_ERROR_DOMAIN code:0 userInfo:nil]];
    }).then( ^id (BFTask *task) {
        XCTAssert(NO, "this code is not called because an error should be occured.");
        [expectation fulfill];
        return nil;
    }).catch( ^id (NSError *error) {
        XCTAssertEqualObjects([error domain], MY_ERROR_DOMAIN, "error should not be changed.");
        [expectation fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testFinallyShouldChangeResultValueToErrorValueAfterReturnedTaskReturnsError {
    XCTestExpectation *expectation = [self expectationWithDescription:@"finish task"];
    [BFTask taskWithResult:@30].finally( ^BFTask *() {
        return [self delayAsyncAfter:100 callback: ^{}].then( ^id (BFTask *task) {
            return [BFTask taskWithError:[NSError errorWithDomain:MY_ERROR_DOMAIN code:0 userInfo:nil]];
        });
    }).then( ^id (BFTask *task) {
        XCTAssert(NO, "this code is not called because an error should be occured.");
        [expectation fulfill];
        return nil;
    }).catch( ^id (NSError *error) {
        XCTAssertEqualObjects([error domain], MY_ERROR_DOMAIN, "error should not be changed.");
        [expectation fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

@end
