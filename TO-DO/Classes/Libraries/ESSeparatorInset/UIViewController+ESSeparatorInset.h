// The MIT License (MIT)
//
// Copyright (c) 2015 EnjoySR ( https://github.com/EnjoySR/ESSeparatorInset )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

//
//  UIViewController+ESSeparatorInset.h
//  TableViewSeparatorInset
//
//  Created by 尹桥印 on 15/7/18.
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//



#import <UIKit/UIKit.h>

@interface UIViewController (ESSeparatorInset)


- (void)setSeparatorInsetZeroWithTableView:(UITableView *)tableView;

- (void)setSeparatorInsetWithTableView:(UITableView *)tableView inset:(UIEdgeInsets)inset;

/*
 If you want to implement 'tableView:willDisplayCell:forRowAtIndexPath:' for 
 tableview delegate,you should use this method.
 */
- (void)es_tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

@end
