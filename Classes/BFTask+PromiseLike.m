//
// BFTask+PromiseLike.m
// BFTaskPromise
//
// Copyright (c) 2014,2015 Hironori Ichimiya <hiron@hironytic.com>
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

#import <Bolts/BFExecutor.h>
#import "BFTask+PromiseLike.h"

@implementation BFTask (PromiseLike)

- (BFTask *)thenWithExecutor:(BFExecutor *)executor withBlock:(BFContinuationBlock)block {
    return [self continueWithExecutor:executor withBlock:^id(BFTask *task) {
        if ([task error] != nil || [task exception] != nil || [task isCancelled]) {
            return task;
        } else {
            return block(task);
        }
    }];
}

- (BFTask *)catchWithExecutor:(BFExecutor *)executor withBlock:(BFContinuationBlock)block {
    return [self continueWithExecutor:executor withBlock:^id(BFTask *task) {
        if ([task error] != nil || [task exception] != nil) {
            return block(task);
        } else {
            return task;
        }
    }];
}

- (BFTask *)finallyWithExecutor:(BFExecutor *)executor withBlock:(BFPFinallyBlock)block {
    return [self continueWithExecutor:executor withBlock:^id(BFTask *task) {
        BFTask *resultTask = block();
        if (resultTask != nil) {
            return resultTask.then(^id(BFTask *task2) {
                return task;
            });
        } else {
            return task;
        }
    }];
}

- (BFTask *(^)(BFContinuationBlock))then {
    return ^BFTask *(BFContinuationBlock block) {
        return [self thenWithExecutor:[BFExecutor defaultExecutor] withBlock:block];
    };
}

- (BFTask *(^)(BFContinuationBlock))catch {
    return ^BFTask *(BFContinuationBlock block) {
        return [self catchWithExecutor:[BFExecutor defaultExecutor] withBlock:block];
    };
}

- (BFTask *(^)(BFContinuationBlock))catchWith {
    return [self catch];
}

- (BFTask *(^)(BFPFinallyBlock))finally {
    return ^BFTask *(BFPFinallyBlock block) {
        return [self finallyWithExecutor:[BFExecutor defaultExecutor] withBlock:block];
    };
}

- (BFTask *(^)(BFExecutor *, BFContinuationBlock))thenOn {
    return ^BFTask *(BFExecutor *executor, BFContinuationBlock block) {
        return [self thenWithExecutor:executor withBlock:block];
    };
}

- (BFTask *(^)(BFExecutor *, BFContinuationBlock))catchOn {
    return ^BFTask *(BFExecutor *executor, BFContinuationBlock block) {
        return [self catchWithExecutor:executor withBlock:block];
    };
}

- (BFTask *(^)(BFExecutor *, BFPFinallyBlock))finallyOn {
    return ^BFTask *(BFExecutor *executor, BFPFinallyBlock block) {
        return [self finallyWithExecutor:executor withBlock:block];
    };
}

- (BFTask *(^)(BFContinuationBlock))thenOnMain {
    return ^BFTask *(BFContinuationBlock block) {
        return [self thenWithExecutor:[BFExecutor mainThreadExecutor] withBlock:block];
    };
}

- (BFTask *(^)(BFContinuationBlock))catchOnMain {
    return ^BFTask *(BFContinuationBlock block) {
        return [self catchWithExecutor:[BFExecutor mainThreadExecutor] withBlock:block];
    };
}

- (BFTask *(^)(BFPFinallyBlock))finallyOnMain {
    return ^BFTask *(BFPFinallyBlock block) {
        return [self finallyWithExecutor:[BFExecutor mainThreadExecutor] withBlock:block];
    };
}

@end
