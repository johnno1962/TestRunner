
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
    test.setupTests()
    callMethodsMatchingPattern( test, "test" )
```
    
Output is:

    setUp 999
    testThing1 999
    testThing2 999
    testThing3 999
    tearDown 999

Should work Linux. callMethodsMatchingPattern would live in stdlib somewhere. MIT Licensed.
