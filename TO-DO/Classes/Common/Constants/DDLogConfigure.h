//
//  DDLogLevel.h
//  TO-DO
//
//  Created by Siegrain on 16/6/1.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#ifndef DDLogConfigure_h
#define DDLogConfigure_h

#import <CocoaLumberjack.h>

#ifdef DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
static const DDLogLevel ddLogLevel = DDLogLevelOff;
#endif

#endif
