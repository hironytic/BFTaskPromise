//
// BFTask+PromiseLike.m
// BFTaskPromise
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

#import "BFTask+PromiseLike.h"

@implementation BFTask (PromiseLike)

- (BFTask *(^)(BFContinuationBlock))then {
    return ^BFTask *(BFContinuationBlock block) {
        return [self continueWithBlock:^id(BFTask *task) {
            if ([task error] != nil || [task exception] != nil || [task isCancelled]) {
                return task;
            } else {
                return block(task);
            }
        }];
    };
}

- (BFTask *(^)(BFContinuationBlock))catch {
    return ^BFTask *(BFContinuationBlock block) {
        return [self continueWithBlock:^id(BFTask *task) {
            if ([task error] != nil || [task exception] != nil) {
                return block(task);
            } else {
                return task;
            }
        }];
    };
}

- (BFTask *(^)(BFPFinallyBlock))finally; {
    return ^BFTask *(BFPFinallyBlock block) {
        return [self continueWithBlock:^id(BFTask *task) {
            block();
            return task;
        }];
    };
}

- (BFTask *(^)(BFExecutor *, BFContinuationBlock))thenOn {
    return ^BFTask *(BFExecutor *executor, BFContinuationBlock block) {
        return [self continueWithExecutor:executor withBlock:^id(BFTask *task) {
            if ([task error] != nil || [task exception] != nil || [task isCancelled]) {
                return task;
            } else {
                return block(task);
            }
        }];
    };
}

- (BFTask *(^)(BFExecutor *, BFContinuationBlock))catchOn {
    return ^BFTask *(BFExecutor *executor, BFContinuationBlock block) {
        return [self continueWithExecutor:executor withBlock:^id(BFTask *task) {
            if ([task error] != nil || [task exception] != nil) {
                return block(task);
            } else {
                return task;
            }
        }];
    };
}

- (BFTask *(^)(BFExecutor *, BFPFinallyBlock))finallyOn {
    return ^BFTask *(BFExecutor *executor, BFPFinallyBlock block) {
        return [self continueWithExecutor:executor withBlock:^id(BFTask *task) {
            block();
            return task;
        }];
    };
}

@end
