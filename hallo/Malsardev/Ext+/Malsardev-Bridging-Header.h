//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import "CoreServices.h"
#import "vm_unaligned_copy_switch_race.h"
#import "grant_full_disk_access.h"
#import "TSUtil.h"
#import <objc/runtime.h>

#import "vm_unaligned_copy_switch_race.h"

void invoke(SEL selector, id target, void *arg);
void invokeInt(SEL selector, id target, long long arg);
void invokeDouble(SEL selector, id target, double arg);
void invokeAny(SEL selector, id target, id arg);
