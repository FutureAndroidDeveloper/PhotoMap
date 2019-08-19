//
//  SignUpViewController.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/16/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SkyFloatingLabelTextField

class SignUpViewController: UIViewController, StoryboardInitializable {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var repeatPasswordTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var showPasswordButton: UIButton!
    
    var viewModel: SignUpViewModel!
    private let bag = DisposeBag()
    private let tapGesture = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        showPasswordButton.rx.tap
            .subscribe(onNext: { _ in
                self.showPasswordButton.isSelected = !self.showPasswordButton.isSelected
                self.passwordTextField.isSecureTextEntry = !self.showPasswordButton.isSelected
                self.repeatPasswordTextField.isSecureTextEntry = !self.showPasswordButton.isSelected
            })
            .disposed(by: bag)
        
        tapGesture.rx.event
            .subscribe(onNext: { _ in
                self.emailTextField.endEditing(true)
                self.passwordTextField.endEditing(true)
                self.repeatPasswordTextField.endEditing(true)
            })
            .disposed(by: bag)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.willDisappear.onNext(Void())
    }
    
    private func setupView() {
        let navigationController = self.navigationController
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = .white
        
        createButton.layer.cornerRadius = createButton.bounds.width / 8
        view.addGestureRecognizer(tapGesture)
        
        // Show/Hide password button
        showPasswordButton.setImage(UIImage(named: "hide"), for: .normal)
        showPasswordButton.setImage(UIImage(named: "show"), for: .selected)
    }
}
