#!/usr/bin/env xcrun swift

import Foundation

private struct ClassMetadataSwift {

    let MetaClass = UnsafePointer<ClassMetadataSwift>(nil), SuperClass = UnsafePointer<ClassMetadataSwift>(nil);
    let CacheData1 = UnsafePointer<Void>(nil), CacheData2 = UnsafePointer<Void>(nil)

    let Data: uintptr_t = 0

    /// Swift-specific class flags.
    let Flags: UInt32 = 0

    /// The address point of instances of this type.
    let InstanceAddressPoint: UInt32 = 0

    /// The required size of instances of this type.
    /// 'InstanceAddressPoint' bytes go before the address point;
    /// 'InstanceSize - InstanceAddressPoint' bytes go after it.
    let InstanceSize: UInt32 = 0

    /// The alignment mask of the address point of instances of this type.
    let InstanceAlignMask: UInt16 = 0

    /// Reserved for runtime use.
    let Reserved: UInt16 = 0

    /// The total size of the class object, including prefix and suffix
    /// extents.
    let ClassSize: UInt32 = 0

    /// The offset of the address point within the class object.
    let ClassAddressPoint: UInt32 = 0

    /// An out-of-line Swift-specific description of the type, or null
    /// if this is an artificial subclass.  We currently provide no
    /// supported mechanism for making a non-artificial subclass
    /// dynamically.
    let Description = UnsafePointer<Void>(nil)

    /// A function for destroying instance variables, used to clean up
    /// after an early return from a constructor.
    var dispatch = UnsafePointer<Void>(nil)
}

struct Dl_info {
    let dli_fname = UnsafePointer<Int8>(nil)
    let dli_fbase = UnsafePointer<Void>(nil)
    let dli_sname = UnsafePointer<Int8>(nil)
    let dli_saddr = UnsafePointer<Void>(nil)
}

@_silgen_name("dladdr")
func dladdr( ptr: UnsafePointer<Void>, _ info: UnsafeMutablePointer<Dl_info> ) -> CInt

func callMethodsMatchingPatternPureSwift( object: AnyObject, _ pattern: UnsafePointer<Int8> ) {
    let id = UnsafePointer<UnsafeMutablePointer<ClassMetadataSwift>>( Unmanaged.passUnretained(object).toOpaque() )

    if (id.memory.memory.Data & 0x1) == 0 {
        print("Object is not instance of Swift class")
        return
    }

    var regex = regex_t()
    let error = regcomp(&regex, pattern, REG_EXTENDED)
    if error != 0 {
        var errbuff = [Int8]( count:1000, repeatedValue: 0 )
        regerror(error, &regex, &errbuff, errbuff.count)
        print("Regex \(String.fromCString(pattern)) compile error \(String.fromCString(errbuff))")
        return
    }

    withUnsafePointer(&id.memory.memory.dispatch) {
        (sym_start) in
        let sym_end = UnsafePointer<UnsafePointer<Void>>(UnsafePointer<Int8>(id.memory) +
            -Int(id.memory.memory.ClassAddressPoint) + Int(id.memory.memory.ClassSize))

        var info = Dl_info()
        for i in 0..<(sym_end-sym_start) {
            if sym_start[i] != nil {
                let vptr = UnsafePointer<Int8>(bitPattern: unsafeBitCast(sym_start[i], UInt.self))
                if dladdr(vptr, &info) != 0 && info.dli_sname != nil {
                    print("symbol: \(String.fromCString(info.dli_sname)!)")
                    if regexec(&regex, info.dli_sname, 0, nil, 0) == 0 {
                        typealias SIMP = @convention(c) ( AnyObject! ) -> Void
                        let sptr = unsafeBitCast(sym_start[i], SIMP.self)
                        sptr(object)
                    }
                }
            }
        }
    }

    regfree( &regex )
}

class Tests {

    var ivar = 999

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
