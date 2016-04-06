
### Swift TestRunner

An example of how methods can be called on the basis of their name using only Metatdata available at runtime.

Class has vtable (dispatch) for Swift methods. Symbol name for function can be determined from pointer and demangled to filter names.

Given test class in AppDelegate.swift:

```Swift
class Tests {

    let ivar = 999

    func setUp() {
        print( "setUp \(ivar)" )
    }

    func tearDown() {
        print( "tearDown \(ivar)" )
    }

    func testThing1() {
        print( "testThing1 \(ivar)" )
    }

    func someOtherMethod1() {
        print( "someOtherMethod1 \(ivar)" )
    }

    func testThing2() {
        print( "testThing2 \(ivar)" )
    }

    func someOtherMethod2() {
        print( "someOtherMethod2 \(ivar)" )
    }

    func testThing3() {
        print( "testThing3 \(ivar)" )
    }

}
```

Calling:
```Swift
    let test = Tests()
    test.setUp()
    callMethodsMatchingPattern( test, "^_TFC\\d+TestRunner\\d+Tests\\d+test" )
    test.tearDown()
```
    
Output is:

    setUp 999
    symbol: _TFC10TestRunner5Tests5setUpfT_T_
    symbol: _TFC10TestRunner5Tests8tearDownfT_T_
    symbol: _TFC10TestRunner5Tests10testThing1fT_T_
    testThing1 999
    symbol: _TFC10TestRunner5Tests16someOtherMethod1fT_T_
    symbol: _TFC10TestRunner5Tests10testThing2fT_T_
    testThing2 999
    symbol: _TFC10TestRunner5Tests16someOtherMethod2fT_T_
    symbol: _TFC10TestRunner5Tests10testThing3fT_T_
    testThing3 999
    symbol: _TFC10TestRunner5TestscfT_S0_
    tearDown 999

Should work on Linux, callMethodsMatchingPattern() would live in stdlib or xctest. MIT Licensed.
