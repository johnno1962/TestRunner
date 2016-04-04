//
//  TestRunner.m
//  TestRunner
//
//  Created by John Holdsworth on 04/04/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//

#import "TestRunner.h"

#import <objc/runtime.h>
#import <stdint.h>
#import <dlfcn.h>

// Thanks to Jay Freeman's https://www.youtube.com/watch?v=Ii-02vhsdVk
// actual version of struct is in "include/swift/Runtime/Metadata.h"

struct ClassMetadata {

    Class MetaClass, SuperClass;
    void *CacheData[2];
    uintptr_t Data;

    /// Swift-specific class flags.
    uint32_t Flags;

    /// The address point of instances of this type.
    uint32_t InstanceAddressPoint;

    /// The required size of instances of this type.
    /// 'InstanceAddressPoint' bytes go before the address point;
    /// 'InstanceSize - InstanceAddressPoint' bytes go after it.
    uint32_t InstanceSize;

    /// The alignment mask of the address point of instances of this type.
    uint16_t InstanceAlignMask;

    /// Reserved for runtime use.
    uint16_t Reserved;

    /// The total size of the class object, including prefix and suffix
    /// extents.
    uint32_t ClassSize;

    /// The offset of the address point within the class object.
    uint32_t ClassAddressPoint;

    /// An out-of-line Swift-specific description of the type, or null
    /// if this is an artificial subclass.  We currently provide no
    /// supported mechanism for making a non-artificial subclass
    /// dynamically.
    const struct NominalTypeDescriptor *Description;

    /// A function for destroying instance variables, used to clean up
    /// after an early return from a constructor.
    IMP dispatch[1];
};

void callMethodsMatchingPattern( id object, const char *pattern ) {

    struct ClassMetadata *swiftClass = (__bridge struct ClassMetadata *)object_getClass( object );

    // locate method distaptch table in ClassMetadata
    IMP *sym_start = swiftClass->dispatch,
        *sym_end = (IMP *)((char *)swiftClass + swiftClass->ClassSize - 2*sizeof(IMP));

    Dl_info info;
    for ( IMP *sym_ptr = sym_start ; sym_ptr < sym_end ; sym_ptr++ )
        if ( dladdr( *sym_ptr, &info ) && info.dli_sname ) {
            printf( "symbol: %s\n", info.dli_sname );
            // if method symbol contains pattern, call it
            if ( strstr( info.dli_sname, pattern ) != 0 ) {
                void (*test)( id ) = (void (*)( id ))*sym_ptr;
                test( object );
            }
        }
}
