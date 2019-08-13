//
//  Help.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/12/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

// AdaptiveScrollView.swift
import UIKit

class AdaptiveScrollView: UIScrollView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardDidShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
                return
        }
        let keyboardSize = frame.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0,
                                         bottom: keyboardSize.height / 1.5, right: 0.0)
        adjustContentInsets(contentInsets)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        adjustContentInsets(.zero)
    }
    
    private func adjustContentInsets(_ contentInsets: UIEdgeInsets) {
        
        contentInset = contentInsets
        setContentOffset(CGPoint(x: 0, y: contentInsets.bottom / 1.2), animated: false)
        scrollIndicatorInsets = contentInsets
    }
}
