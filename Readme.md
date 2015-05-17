BFTaskPromise
=============
[![Build Status](https://travis-ci.org/hironytic/BFTaskPromise.svg?branch=master)](https://travis-ci.org/hironytic/BFTaskPromise)
[![Coverage Status](https://coveralls.io/repos/hironytic/BFTaskPromise/badge.svg?branch=master)](https://coveralls.io/r/hironytic/BFTaskPromise?branch=master)

## About

An Objective-C category for BFTask class in [Bolts-iOS](https://github.com/BoltsFramework/Bolts-iOS).

With this category, you can:

* chain tasks with dot-notation as JavaScript Promise-like syntax. (no more counting brackets!)
* write a catch block which will be called in error case only.
* write a finally block which won't change the result value unless the block fails.

### Example

```objc
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
```

### Executors

If you want to specify the executor, use `continueOn`, `thenOn`, `catchOn` and `finallyOn`.
You can also use `continueOnMain`, `thenOnMain`, `catchOnMain` and `finallyOnMain`, they use `mainThreadExecutor`.

```objc
[User findAllAsync].catchOn([BFExecutor mainThreadExecutor], ^id (NSError *error) {
    [self showAlert:error];
});

// same as above
[User findAllAsync].catchOnMain(^id (NSError *error) {
    [self showAlert:error];
});
```

### Handling Exceptions

If the task holds an exception, it is converted to `NSError` on passing it as a parameter of the `catch`-block.
In this case, the domain of the converted error is `BFPTaskErrorDomain` and its code is `BFPTaskErrorException`.
The original exception object can be retrieved from user info dictionary like this:

```objc
[self doSomethingAsync].catch( ^id (NSError *error) {
    if ([BFPTaskErrorDomain isEqualToString:error.domain]
        && error.code == BFPTaskErrorException) {
        NSException *ex = [error.userInfo objectForKey:BFPUnderlyingExceptionKey];
    }
});
```

### Not a Promise

To be exact, Bolts' task is not a Promise. So this is not a Promise too.
The purpose of this project is to make task-chains much readable.

### Hate Dot-Notation?

If you don't think dot-notation is preferable but do want `catch` and/or `finally`, you can still use `catchWithExecutor:withBlock:` and `finallyWithExecutor:withBlock:`. They are normal methods.

To tell the truth, I hate dot-notation for methods basically. I want to use it for only properties. I prefer to use bracket-notation for usual methods.
But the task-chaining is a special case for me. It's unusual. I feel the task-chaining is not a nested method call, but a flow control.


## Install

### Using CocoaPods

Write the following line to your Podfile:

```
pod 'BFTaskPromise', '~> 2.0'
```
### Manually

Add `BFTask+PromiseLike.h` and `BFTask+PromiseLike.m` in `Classes` folder to your project.


## Migrating from 1.x to 2.0

The parameter of the block passed to `then`/`catch` is changed in 2.0.
A `then`-block takes a result value and a `catch`-block takes an error value.

In prior to 2.0, the block parameter of both `then` and `catch` was a `BFTask` value.
So if you have a code for 1.X like:

```objc
[foo loadAsync].then(^id (BFTask *task) {
    bar.title = (NSString *)task.result;
}
```

you must rewrite it to:

```objc
[foo loadAsync].then(^id (NSString *result) {
    bar.title = result;
}
```


## License

The MIT License.
