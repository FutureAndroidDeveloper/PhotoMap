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
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.showPasswordButton.isSelected = !self.showPasswordButton.isSelected
                self.passwordTextField.isSecureTextEntry = !self.showPasswordButton.isSelected
                self.repeatPasswordTextField.isSecureTextEntry = !self.showPasswordButton.isSelected
            })
            .disposed(by: bag)

        emailTextField.rx.controlEvent(.editingDidEnd)
            .asObservable()
            .filter { [weak self] _ in
                guard let self = self else { return true }
                return self.isEmailValid(self.emailTextField.text) == false
            }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.emailTextField.errorMessage = R.string.localizable.invalidEmail()
            })
            .disposed(by: bag)
        
        emailTextField.rx.text.orEmpty
            .filter { [weak self] email in
                guard let self = self else { return true }
                return self.isEmailValid(email) }
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.emailTextField.errorMessage = ""
            })
            .bind(to: viewModel.email)
            .disposed(by: bag)
        
        passwordTextField.rx.controlEvent(.editingDidEnd)
            .asObservable()
            .filter { [weak self] _ in
                guard let self = self else { return true }
                return self.isPasswordValid(self.passwordTextField.text) == false
            }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.passwordTextField.errorMessage = R.string.localizable.invalidPassword()
            })
            .disposed(by: bag)
        
        passwordTextField.rx.text.orEmpty
            .filter { [weak self] password in
                guard let self = self else { return true }
                return self.isPasswordValid(password) }
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.passwordTextField.errorMessage = ""
            })
            .bind(to: viewModel.password)
            .disposed(by: bag)
        
        repeatPasswordTextField.rx.controlEvent(.editingDidEnd)
            .asObservable()
            .filter { [weak self] _ in
                guard let self = self else { return false }
                return self.passwordTextField.text != self.repeatPasswordTextField.text }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.repeatPasswordTextField.errorMessage = R.string.localizable.notMatch()
            })
            .disposed(by: bag)
        
        repeatPasswordTextField.rx.text.orEmpty
            .filter { [weak self] repeatPassword in
                guard let self = self else { return true }
                return self.passwordTextField.text == repeatPassword
            }
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.repeatPasswordTextField.errorMessage = ""
            })
            .bind(to: viewModel.repeatPassword)
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
            .filter { [weak self] _ in
                guard let self = self else { return true }
                return self.isEmailValid(self.emailTextField.text) &&
                    self.isPasswordValid(self.passwordTextField.text) &&
                    self.repeatPasswordTextField.text == self.passwordTextField.text
            }
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
    
    private func isPasswordValid(_ password: String?) -> Bool {
        // Minimum 8 characters at least 1 Alphabet and 1 Number:
        let passwordRegEx = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
        let passwordPred = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordPred.evaluate(with: password)
    }
    
    private func isEmailValid(_ email: String?) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func showSigInError(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: R.string.localizable.ok(), style: .default, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
