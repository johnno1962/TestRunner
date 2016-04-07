
### Swift TestRunner

An example of how methods can be called on the basis of their name using only Metatdata available at runtime.

Class has vtable (dispatch) for Swift methods. Symbol name for function can be determined from pointer and demangled to filter names.

Pure Swift version tested and works on Linux...

    $ # on Linux remove eveything other than *.swift
    $ swift build -Xlinker -export-dyanmic
    $ ./build/debug/TestRunner
    setUp 0
    symbol: _TFC10TestRunner5Testsg4ivarSi
    symbol: _TFC10TestRunner5Testss4ivarSi
    symbol: _TFC10TestRunner5Testsm4ivarSi
    symbol: _TFC10TestRunner5Tests5setUpfT_T_
    symbol: _TFC10TestRunner5Tests8tearDownfT_T_
    symbol: _TFC10TestRunner5Tests10testThing1fT_T_
    testThing1 1
    symbol: _TFC10TestRunner5Tests16someOtherMethod1fT_T_
    symbol: _TFC10TestRunner5Tests10testThing2fT_T_
    testThing2 2
    symbol: _TFC10TestRunner5Tests16someOtherMethod2fT_T_
    symbol: _TFC10TestRunner5Tests10testThing3fT_T_
    testThing3 3
    symbol: _TFC10TestRunner5TestscfT_S0_
    tearDown 3

Given the test class in main.swift:

```Swift
class Tests {

    let ivar = 999

    func setUp() {
        ivar = 0
        print( "setUp \(ivar)" )
    }

    func tearDown() {
        print( "tearDown \(ivar)" )
    }

    func testThing1() {
        ivar += 1
        print( "testThing1 \(ivar)" )
    }

    func someOtherMethod1() {
        print( "someOtherMethod1 \(ivar)" )
    }

    func testThing2() {
        ivar += 1
        print( "testThing2 \(ivar)" )
    }

    func someOtherMethod2() {
        print( "someOtherMethod2 \(ivar)" )
    }

    func testThing3() {
        ivar += 1
        print( "testThing3 \(ivar)" )
    }

}

let test = Tests()

test.setUp()
callMethodsMatchingPatternPureSwift(test,
    "^_TFC[0-9]+TestRunner[0-9]+Tests[0-9]+test")
test.tearDown()
```

callMethodsMatchingPatternPureSwift() could live in stdlib or xctest. MIT Licensed.
