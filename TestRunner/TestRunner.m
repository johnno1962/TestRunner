//
//  TestRunner.m
//  TestRunner
//
//  Created by John Holdsworth on 04/04/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//

#import "TestRunner.h"

#import <dlfcn.h>
#import <regex.h>

void callMethodsMatchingPattern( id object, const char *pattern ) {

    struct ClassMetadata *swiftClass = *(struct ClassMetadata **)(__bridge void *)object;

    if ( !(swiftClass->Data & 0x1) ) {
        NSLog( @"Object is not instance of Swift class" );
        return;
    }
    
    regex_t regex;
    int error = regcomp( &regex, pattern, REG_EXTENDED|REG_ENHANCED );
    if ( error != 0 ) {
        char errbuff[PATH_MAX];
        regerror( error, &regex, errbuff, sizeof errbuff );
        NSLog( @"Regex %s compile error %s", pattern, errbuff );
        return;
    }

    // locate method distpatch table in ClassMetadata
    SIMP *sym_start = swiftClass->dispatch,
        *sym_end = (SIMP *)((char *)swiftClass - swiftClass->ClassAddressPoint + swiftClass->ClassSize);

    Dl_info info;
    for ( SIMP *sym_ptr = sym_start ; sym_ptr < sym_end ; sym_ptr++ )
        if ( dladdr( *sym_ptr, &info ) && info.dli_sname ) {
            printf( "symbol: %s\n", info.dli_sname );
            // if method symbol contains pattern, call it
            if ( regexec( &regex, info.dli_sname, 0, NULL, 0 ) == 0 ) {
                void (*test)( id ) = (void (*)( id ))*sym_ptr;
                test( object );
            }
        }

    regfree( &regex );
}
