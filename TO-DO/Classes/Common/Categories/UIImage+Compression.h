//
//  UIImage+Compression.h
//  TO-DO
//
//  Created by Siegrain on 16/5/12.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Compression)
- (UIImage*)imageCompressForWidth:(CGFloat)defineWidth;
- (UIImage*)imageCompressForSize:(CGSize)size;
@end
