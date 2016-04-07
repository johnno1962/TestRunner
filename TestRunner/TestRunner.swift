//
//  TestRunner.swift
//  TestRunner
//
//  Created by John Holdsworth on 07/04/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//

import Foundation

func callMethodsMatchingPatternSwift( object: AnyObject, _ pattern: UnsafePointer<Int8> ) {
    let id = UnsafePointer<UnsafeMutablePointer<ClassMetadata>>( Unmanaged.passUnretained(object).toOpaque() )

    if (id.memory.memory.Data & 0x1) == 0 {
        print("Object is not instance of Swift class")
        return
    }

    var regex = regex_t()
    let error = regcomp(&regex, pattern, REG_EXTENDED|REG_ENHANCED)
    if error != 0 {
        var errbuff = [Int8]( count:1000, repeatedValue: 0 )
        regerror(error, &regex, &errbuff, errbuff.count)
        print("Regex \(String.fromCString(pattern)) compile error \(String.fromCString(errbuff))")
        return
    }

    withUnsafePointer(&id.memory.memory.dispatch.0) {
        (sym_start) in
        let sym_end = UnsafePointer<SIMP?>(UnsafePointer<Int8>(id.memory) +
            -Int(id.memory.memory.ClassAddressPoint) + Int(id.memory.memory.ClassSize))

        var info = Dl_info()
        for i in 0..<(sym_end-sym_start) {
            if let fptr = sym_start[i] {
                let vptr = UnsafePointer<Void>(bitPattern: unsafeBitCast(fptr, UInt.self))
                if dladdr(vptr, &info) != 0 && info.dli_sname != nil {
                    print("symbol: \(String.fromCString(info.dli_sname)!)")
                    if regexec(&regex, info.dli_sname, 0, nil, 0) == 0 {
                        fptr(object)
                    }
                }
            }
        }
    }

    regfree( &regex )
}
