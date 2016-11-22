//
//  SSDynamicAttributedTextSizable.h
//  SSDynamicText
//
//  Created by Remigiusz Herba on 15/09/15.
//  Copyright (c) 2015 Splinesoft. All rights reserved. 
//

@import Foundation;

@protocol SSDynamicAttributedTextSizable <NSObject>

/**
 * TextView and TextField sometimes calls setAttributedText even when we work with normal text.
 * Framework is using it under the hood sometimes after layouts or even `-setText:` calls it. Because of that we cannot override
 * default attributeText setter to change font, sometimes it change font at random.
 *
 * This is used to set attributedText which will be dynamicaly changed with font size changes.
 * Updating this will change attributedText to dynamicAttributedText + font sizes changed with delta.
 * @return original dynamicAttributedText value. To check current attributedText font sizes use @property attributedText.
 *
 */
@property (nonatomic, copy) NSAttributedString *dynamicAttributedText;

@end
