//
//  WConfig.h
//  Wilddog
//
//  Created by junpengwang on 15/7/20.
//  Copyright (c) 2015年 Wilddog. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
   为 Wilddog 配置对象。您可以通过 [Wilddog defaultConfig] 方法获取默认 WConfig 对象并修改它。
   在创建第一个 Wilddog 实例之前，你必须先对它做出更改。
 */
@interface WConfig : NSObject


/**
 * 默认情况下，在你的应用程序正在运行时，Wilddog 客户端会将数据保存在内存中，当应用被重新启动时数据就没有了。
   把这个值设置为 YES 时，数据将被保存到设备，并且当应用程序重新启动时（即使在重新启动程序时没有网络连接），
   这些存储的数据也是可以用的。请注意，此属性必须在创建第一个Wilddog 引用之前设置，并且每次启用应用程序只需
   要调用一次即可。
 
   如果你的应用使用了 Wilddog 认证，客户端将自动保存用户的身份验证 token ，即使没有启用数据持久化。但是，
   如果身份验证令牌在离线的时候过期，并且你打开了数据持久化，客户端将暂停写入操作，直到你成功地重新进行身份
   验证。这样做是因为防止写入的数据被发送给未经验证的用户和因安全规则的改变造成写入数据失败。
 */
@property (nonatomic) BOOL persistenceEnabled;


/**
 * 默认情况下，Wilddog 将占用最大10MB的磁盘空间去缓存数据。如果缓存大小超出此空间，Wilddog 将开始移除最
   近未使用的数据。如果你发现你的应用程序缓存太少或有过多的数据，调用此方法来更改缓存空间的大小。此属性必
   须在创建第一个 Wilddog 引用之前设置，并且每次启用应用程序只需要调用一次即可。
   请注意，指定缓存大小只是一个近似值，并在磁盘上的大小有时候可能会暂时超过它。
 */
@property (nonatomic) NSUInteger persistenceCacheSizeBytes;

/**
 *  设置所有被触发事件的队列。默认队列为主队列。
 */
@property (nonatomic, strong) dispatch_queue_t callbackQueue;

@end
