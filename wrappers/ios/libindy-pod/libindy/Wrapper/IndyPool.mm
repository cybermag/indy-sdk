#import <Foundation/Foundation.h>
#import "IndyCallbacks.h"
#import "IndyPool.h"
#import "indy_core.h"
#import "NSError+IndyError.h"

@implementation IndyPool

+ (NSError *)createPoolLedgerConfigWithPoolName:(NSString *)name
                                     poolConfig:(NSString *)config
                                     completion:(void (^)(NSError *error)) handler
{
    indy_error_t ret;
    
    indy_handle_t handle = [[IndyCallbacks sharedInstance] createCommandHandleFor: (void*) handler];
    
    ret = indy_create_pool_ledger_config(handle,
                                           [name UTF8String],
                                           [config UTF8String],
                                           IndyWrapperCommon2PCallback
                                          );
    if( ret != Success )
    {
        [[IndyCallbacks sharedInstance] deleteCommandHandleFor: handle];
    }
    
    return [NSError errorFromIndyError: ret];
}

+ (NSError *)openPoolLedgerWithName:(NSString *)name
                         poolConfig:(NSString *)config
                         completion:(void (^)(NSError *error, IndyHandle handle)) handler
{
    indy_error_t ret;
    
    indy_handle_t handle = [[IndyCallbacks sharedInstance] createCommandHandleFor: (void*) handler];
    
    ret = indy_open_pool_ledger(handle,
                                  [name UTF8String],
                                  [config UTF8String],
                                  IndyWrapperCommon3PHCallback
                                 );
    if( ret != Success )
    {
        [[IndyCallbacks sharedInstance] deleteCommandHandleFor: handle];
    }
    
    return [NSError errorFromIndyError: ret];
}

+ (NSError *)refreshPoolLedgerWithHandle:(IndyHandle)poolHandle
                              completion:(void (^)(NSError *error)) handler
{
    indy_error_t ret;
    
    indy_handle_t handle = [[IndyCallbacks sharedInstance] createCommandHandleFor: (void*) handler];
    
    ret = indy_refresh_pool_ledger(handle,
                                     (indy_handle_t) poolHandle,
                                     IndyWrapperCommon2PCallback
                                    );
    if( ret != Success )
    {
        [[IndyCallbacks sharedInstance] deleteCommandHandleFor: handle];
    }
    
    return [NSError errorFromIndyError: ret];
}

+ (NSError *)closePoolLedgerWithHandle:(IndyHandle)IndyHandle
                            completion:(void (^)(NSError *error)) handler
{
    indy_error_t ret;
    
    indy_handle_t handle = [[IndyCallbacks sharedInstance] createCommandHandleFor: (void*) handler];
    
    ret = indy_close_pool_ledger(handle,
                                   (indy_handle_t) IndyHandle,
                                   IndyWrapperCommon2PCallback
                                  );
    if( ret != Success )
    {
        [[IndyCallbacks sharedInstance] deleteCommandHandleFor: handle];
    }
    
    return [NSError errorFromIndyError: ret];
}

+ (NSError *)deletePoolLedgerConfigWithName:(NSString *)name
                                 completion:(void (^)(NSError *error)) handler
{
    indy_error_t ret;
    
    indy_handle_t handle = [[IndyCallbacks sharedInstance] createCommandHandleFor: (void*) handler];
    
    ret = indy_delete_pool_ledger_config(handle,
                                           [name UTF8String],
                                           IndyWrapperCommon2PCallback
                                          );
    if( ret != Success )
    {
        [[IndyCallbacks sharedInstance] deleteCommandHandleFor: handle];
    }
    
    return [NSError errorFromIndyError: ret];
}

@end

