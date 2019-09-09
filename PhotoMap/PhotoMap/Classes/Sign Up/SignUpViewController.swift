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
            .bind(to: viewModel.tappedShowPassword)
            .disposed(by: bag)
        
        viewModel.isPasswordHidden
            .bind(onNext: { [weak self] isHidden in
                guard let self = self else { return }
                self.showPasswordButton.isSelected = !isHidden
                self.passwordTextField.isSecureTextEntry = isHidden
                self.repeatPasswordTextField.isSecureTextEntry = isHidden
            })
            .disposed(by: bag)

        emailTextField.rx
            .controlEvent(.editingDidEnd)
            .map { [weak self] _ -> String in
                guard let self = self,
                    let email = self.emailTextField.text else { return String() }
                return email
            }
            .bind(to: viewModel.emailEditingDidEnd)
            .disposed(by: bag)
        
        emailTextField.rx.text.orEmpty
            .bind(to: viewModel.email)
            .disposed(by: bag)
        
        viewModel.emailError
            .subscribe(onNext: { [weak self] errorMessage in
                guard let self = self else { return }
                self.emailTextField.errorMessage = errorMessage
            })
            .disposed(by: bag)
        
        passwordTextField.rx
            .controlEvent(.editingDidEnd)
            .map { [weak self] _ -> String in
                guard let self = self,
                    let password = self.passwordTextField.text else { return String() }
                return password
            }
            .bind(to: viewModel.passwordEditingDidEnd)
            .disposed(by: bag)
        
        passwordTextField.rx.text.orEmpty
            .bind(to: viewModel.password)
            .disposed(by: bag)
        
        viewModel.passwordError
            .subscribe(onNext: { [weak self] errorMessage in
                guard let self = self else { return }
                self.passwordTextField.errorMessage = errorMessage
            })
            .disposed(by: bag)
        
        repeatPasswordTextField.rx
            .controlEvent(.editingDidEnd)
            .map { [weak self] _ -> String in
                guard let self = self,
                    let password = self.repeatPasswordTextField.text else { return String() }
                return password
            }
            .bind(to: viewModel.repeatPasswordEditingDidEnd)
            .disposed(by: bag)
        
        repeatPasswordTextField.rx.text.orEmpty
            .bind(to: viewModel.repeatPassword)
            .disposed(by: bag)
        
        viewModel.repeatPasswordError
            .subscribe(onNext: { [weak self] errorMessage in
                guard let self = self else { return }
                self.repeatPasswordTextField.errorMessage = errorMessage
            })
            .disposed(by: bag)
        
        tapGesture.rx.event
            .subscribe(onNext: { [weak self ] _ in
                guard let self = self else { return }
                self.emailTextField.endEditing(true)
                self.emailTextField.resignFirstResponder()
                self.passwordTextField.endEditing(true)
                self.passwordTextField.resignFirstResponder()
                self.repeatPasswordTextField.endEditing(true)
                self.repeatPasswordTextField.resignFirstResponder()
            })
            .disposed(by: bag)
        
        createButton.rx.tap
            .bind(to: viewModel.createTapped)
            .disposed(by: bag)
        
        viewModel.error
            .subscribe(onNext: { [weak self] message in
                guard let self = self else { return }
                self.showSigInError(message: message)
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
        
        let passwordClearButton = passwordTextField.value(forKey: "_clearButton") as? UIButton
        passwordClearButton?.setImage(R.image.authentication.clear(), for: .normal)
        passwordTextField.placeholder = R.string.localizable.passwordPlaceholder()
        passwordTextField.title = R.string.localizable.passwordTitle()
        
        let repeatPasswordClearButton = repeatPasswordTextField.value(forKey: "_clearButton") as? UIButton
        repeatPasswordClearButton?.setImage(R.image.authentication.clear(), for: .normal)
        repeatPasswordTextField.placeholder = R.string.localizable.repeatPasswordPlaceholder()
        repeatPasswordTextField.title = R.string.localizable.repeatPasswordTitle()
        
        let emailClearButton = emailTextField.value(forKey: "_clearButton") as? UIButton
        emailClearButton?.setImage(R.image.authentication.clear(), for: .normal)
        emailTextField.placeholder = R.string.localizable.emailPlaceholder()
        emailTextField.title = R.string.localizable.emailTitle()
        
        // Show/Hide password button
        showPasswordButton.setImage(R.image.authentication.hide(), for: .normal)
        showPasswordButton.setImage(R.image.authentication.show(), for: .selected)
        
        createButton.layer.cornerRadius = createButton.bounds.width / 8
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Private Methods
    private func showSigInError(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: R.string.localizable.ok(), style: .default, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
