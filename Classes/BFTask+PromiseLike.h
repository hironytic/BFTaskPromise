//
// BFTask+PromiseLike.h
// BFTaskPromise
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

#import <Bolts/BFTask.h>

extern NSString *const BFPTaskErrorDomain;
extern NSString *const BFPUnderlyingExceptionKey;
typedef NS_ENUM(NSInteger, BFPTaskErrorCode) {
    BFPTaskErrorException   = 1,
};

typedef id (^BFPSuccessResultBlock)(id result);
typedef id (^BFPErrorResultBlock)(NSError *error);
typedef BFTask *(^BFPFinallyBlock)();

@interface BFTask (PromiseLike)

- (BFTask *)thenWithExecutor:(BFExecutor *)executor withBlock:(BFPSuccessResultBlock)block;
- (BFTask *)catchWithExecutor:(BFExecutor *)executor withBlock:(BFPErrorResultBlock)block;
- (BFTask *)finallyWithExecutor:(BFExecutor *)executor withBlock:(BFPFinallyBlock)block;


- (BFTask *(^)(BFContinuationBlock))continueWith;
- (BFTask *(^)(BFPSuccessResultBlock))then;
- (BFTask *(^)(BFPErrorResultBlock))catch;
- (BFTask *(^)(BFPErrorResultBlock))catchWith;  // for Objective-C++
- (BFTask *(^)(BFPFinallyBlock))finally;

- (BFTask *(^)(BFExecutor *, BFContinuationBlock))continueOn;
- (BFTask *(^)(BFExecutor *, BFPSuccessResultBlock))thenOn;
- (BFTask *(^)(BFExecutor *, BFPErrorResultBlock))catchOn;
- (BFTask *(^)(BFExecutor *, BFPFinallyBlock))finallyOn;

- (BFTask *(^)(BFContinuationBlock))continueOnMain;
- (BFTask *(^)(BFPSuccessResultBlock))thenOnMain;
- (BFTask *(^)(BFPErrorResultBlock))catchOnMain;
- (BFTask *(^)(BFPFinallyBlock))finallyOnMain;

@end
