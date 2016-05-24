//
//  FeedOverlay.swift
//  Tyes
//
//  Created by Weien Wang on 9/10/15.
//  Copyright (c) 2015 Research Data Group. All rights reserved.
//

import UIKit

struct ScreenSize
{
    static let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width
    static let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height
    static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS =  UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5 = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6 = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
}

class FeedOverlay: UIButton {
    
    var closeButton: UIButton = UIButton()
    
    required init(parentVC:UIViewController) {
        super.init(frame: CGRectZero)
        
        self.adjustsImageWhenHighlighted = false
        
        let navBarHeight = CGRectGetMaxY(parentVC.navigationController!.navigationBar.frame)
        let overlayFrame = CGRectMake(0, 0, CGRectGetWidth(parentVC.view.frame), CGRectGetHeight(parentVC.view.frame)+navBarHeight)
        self.frame = overlayFrame;
        
        self.closeButton.frame = CGRectMake(0, CGRectGetHeight(parentVC.view.frame)/2+10, CGRectGetWidth(parentVC.view.frame), 50)
        self.addSubview(self.closeButton)
        
        if (DeviceType.IS_IPHONE_6P) {
            self.setImage(UIImage(named: "Overlay-Feed-4-1242x2208"), forState:UIControlState.Normal)
        }
        else if (DeviceType.IS_IPHONE_6) {
            self.setImage(UIImage(named: "Overlay-Feed-3-750x1334"), forState:UIControlState.Normal)
        }
        else if (DeviceType.IS_IPHONE_5) {
            self.setImage(UIImage(named: "Overlay-Feed-2-640x1136"), forState:UIControlState.Normal)
        }
        else { //DeviceType.IS_IPHONE_4_OR_LESS
            self.closeButton.frame = CGRectMake(0, CGRectGetHeight(parentVC.view.frame)/2+40, CGRectGetWidth(parentVC.view.frame), 50)
            self.setImage(UIImage(named: "Overlay-Feed-1-640x960"), forState:UIControlState.Normal)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
