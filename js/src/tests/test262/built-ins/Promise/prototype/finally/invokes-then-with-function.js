// |reftest| skip -- Promise.prototype.finally is not supported
// Copyright (C) 2017 Jordan Harband. All rights reserved.
// This code is governed by the BSD license found in the LICENSE file.
/*---
author: Jordan Harband
description: Promise.prototype.finally invokes `then` method
esid: sec-promise.prototype.finally
features: [Promise.prototype.finally]
---*/

var target = new Promise(function () {});
var returnValue = {};
var callCount = 0;
var thisValue = null;
var argCount = null;
var firstArg = null;
var secondArg = null;

target.then = function(a, b) {
  callCount += 1;

  thisValue = this;
  argCount = arguments.length;
  firstArg = a;
  secondArg = b;

  return returnValue;
};

var originalFinallyHandler = function () {};

var result = Promise.prototype.finally.call(target, originalFinallyHandler, 2, 3);

assert.sameValue(callCount, 1, 'Invokes `then` method exactly once');
assert.sameValue(
  thisValue,
  target,
  'Invokes `then` method with the instance as the `this` value'
);
assert.sameValue(argCount, 2, 'Invokes `then` method with exactly two single arguments');
assert.sameValue(
  typeof firstArg,
  'function',
  'Invokes `then` method with a function as the first argument'
);
assert.notSameValue(firstArg, originalFinallyHandler, 'Invokes `then` method with a different fulfillment handler');
assert.sameValue(
  typeof secondArg,
  'function',
  'Invokes `then` method with a function as the second argument'
);
assert.notSameValue(secondArg, originalFinallyHandler, 'Invokes `then` method with a different fulfillment handler');

assert.sameValue(result, returnValue, 'Returns the result of the invocation of `then`');

reportCompare(0, 0);
