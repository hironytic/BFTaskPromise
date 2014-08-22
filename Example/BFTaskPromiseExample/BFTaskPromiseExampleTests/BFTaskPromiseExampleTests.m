//
// BFTaskPromiseExampleTests.m
// BFTaskPromiseExampleTests
//
// Copyright (c) 2014 Hironori Ichimiya <hiron@hironytic.com>
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

#define MY_ERROR_DOMAIN  @"MyErrorDomain"

@interface BFTaskPromiseExampleTests : XCTestCase

@end

@implementation BFTaskPromiseExampleTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThenShouldRunWhenSucceeded {
    XCTestExpectation *expectation = [self expectationWithDescription:@"finish task"];
    [BFTask taskWithResult:@30].then(^id(BFTask *task){
        NSNumber *result = task.result;
        XCTAssertEqual([result intValue], 30, "previous value should be passed.");
        [expectation fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testThenShouldNotRunWhenError {
    XCTestExpectation *expectation = [self expectationWithDescription:@"finish task"];
    __block BOOL ran = NO;
    [BFTask taskWithError:[NSError errorWithDomain:MY_ERROR_DOMAIN code:0 userInfo:nil]].then(^id(BFTask *task){
        ran = YES;
        return nil;
    }).finally(^BFTask *(){
        [expectation fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    XCTAssertFalse(ran, @"then should not ran");
}

// TODO:
#if 0
testThenShouldNotRunWhenException
testThenShouldNotRunWhenCancelled
#endif

- (void)testCatchShouldNotRunWhenSucceeded {
    XCTestExpectation *expectation = [self expectationWithDescription:@"finish task"];
    __block BOOL ran = NO;
    [BFTask taskWithResult:@30].catch(^id(BFTask *task){
        ran = YES;
        return nil;
    }).finally(^BFTask *(){
        [expectation fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    XCTAssertFalse(ran, @"catch should not ran");
}

- (void)testCatchShouldRunWhenError {
    XCTestExpectation *expectation = [self expectationWithDescription:@"finish task"];
    [BFTask taskWithError:[NSError errorWithDomain:MY_ERROR_DOMAIN code:0 userInfo:nil]].catch(^id(BFTask *task){
        NSError *error = task.error;
        XCTAssertEqualObjects(error.domain, MY_ERROR_DOMAIN, "error should be passed.");
        [expectation fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

// TODO:
#if 0
testCatchShouldRunWhenException
testCatchShouldNotRunWhenCancelled
#endif


- (void)testFinallyShouldRunWhenSucceeded {
    XCTestExpectation *expectation = [self expectationWithDescription:@"finish task"];
    [BFTask taskWithResult:@30].finally(^BFTask *(){
        [expectation fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testFinallyShouldRunWhenFailed {
    XCTestExpectation *expectation = [self expectationWithDescription:@"finish task"];
    [BFTask taskWithError:[NSError errorWithDomain:MY_ERROR_DOMAIN code:0 userInfo:nil]].finally(^BFTask *(){
        [expectation fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

// TODO:
#if 0
testFinallyShouldRunWhenException
testFinallyShouldRunWhenCancelled
#endif


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
    [BFTask taskWithResult:@30].finally(^BFTask *() {
        return [self delayAsyncAfter:100 callback:^{
            v = 100;
        }];
    }).then(^id(BFTask *task) {
        XCTAssertEqual(v, 100, @"called after the task returnd from finally");
        [expectation fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testFinallyShouldNotChangeResultValue {
    XCTestExpectation *expectation = [self expectationWithDescription:@"finish task"];
    [BFTask taskWithResult:@30].finally(^BFTask *() {
        return nil;
    }).then(^id(BFTask *task) {
        NSNumber *result = [task result];
        XCTAssertEqual([result intValue], 30, @"result value should not change");
        [expectation fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

// TODO:
#if 0
func testFinallyShouldNotChangeErrorValue() {
    let expectation = expectationWithDescription("finish task");
    HNTask.reject(MyError(message: "error1")).finally {
        return nil
    }.continueWith { context in
        XCTAssertTrue(context.isError(), "error should remain")
        if let error = context.error as? MyError {
            XCTAssertEqual(error.message, "error1", "error value should not change")
        } else {
            XCTFail("error value shoule be MyError")
        }
        expectation.fulfill()
        return (nil, nil)
    }
    waitForExpectationsWithTimeout(5.0, handler: nil)
}

testFinallyShouldNotChangeExceptionValue

func testFinallyShouldNotChangeResultValueAfterReturnedTasksCompletion() {
    let expectation = expectationWithDescription("finish task");
    HNTask.resolve(30).finally {
        return self.delayAsync(100) { }
    }.continueWith { context in
        XCTAssertFalse(context.isError(), "error should not occured")
        if let value = context.result as? Int {
            XCTAssertEqual(value, 30, "result value should not change")
        } else {
            XCTFail("result value shoule be Int")
        }
        expectation.fulfill()
        return (nil, nil)
    }
    waitForExpectationsWithTimeout(5.0, handler: nil)
}

func testFinallyShouldNotChangeErrorValueAfterReturnedTasksCompletion() {
    let expectation = expectationWithDescription("finish task");
    HNTask.reject(MyError(message: "error1")).finally {
        return self.delayAsync(100) { }
    }.continueWith { context in
        XCTAssertTrue(context.isError(), "error should remain")
        if let error = context.error as? MyError {
            XCTAssertEqual(error.message, "error1", "error value should not change")
        } else {
            XCTFail("error value shoule be MyError")
        }
        expectation.fulfill()
        return (nil, nil)
    }
    waitForExpectationsWithTimeout(5.0, handler: nil)
}

testFinallyShouldNotChangeExceptionValueAfterReturnedTasksCompletion


#endif

@end
