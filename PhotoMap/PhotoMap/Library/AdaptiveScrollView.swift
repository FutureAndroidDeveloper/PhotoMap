//
//  Help.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/12/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

// AdaptiveScrollView.swift
import UIKit
import RxSwift
import RxCocoa

class AdaptiveScrollView: UIScrollView {
    
    private let bag = DisposeBag()
    
    @IBInspectable var keyboardHeightDivisor: CGFloat = 1
    @IBInspectable var contentInsetsDivisor: CGFloat = 1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBindings()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupBindings()
    }
    
    private func setupBindings() {
        NotificationCenter.default.rx.notification(UIResponder.keyboardDidShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue }
            .subscribe(onNext: { [weak self] frame in
                guard let self = self else { return }
                let keyboardSize = frame.cgRectValue.size
                let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0,
                                                 bottom: keyboardSize.height / self.keyboardHeightDivisor, right: 0.0)
                self.adjustContentInsets(contentInsets)
            })
            .disposed(by: bag)

        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.adjustContentInsets(.zero)
            })
            .disposed(by: bag)
    }
    
    private func adjustContentInsets(_ contentInsets: UIEdgeInsets) {
        if contentSize.height > frame.size.height - contentInsets.bottom || contentInsets == .zero {
            contentInset = contentInsets
            setContentOffset(CGPoint(x: 0, y: contentInsets.bottom / contentInsetsDivisor), animated: false)
            scrollIndicatorInsets = contentInsets
        }
    }
}
