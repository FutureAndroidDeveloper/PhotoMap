//
//  AuthenticationViewController.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/14/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SkyFloatingLabelTextField

class AuthenticationViewController: UIViewController, StoryboardInitializable {

    @IBOutlet weak var emailTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var showPasswordButton: UIButton!
    
    var viewModel: AuthenticationViewModel!
    private let bag = DisposeBag()
    private let tapGesture = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        emailTextField.rx.controlEvent(.editingDidEnd)
            .asObservable()
            .filter { [weak self] _ in
                guard let self = self else { return false }
                return self.isEmailValid(self.emailTextField.text) == false
            }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.emailTextField.errorMessage = R.string.localizable.invalidEmail()
            })
            .disposed(by: bag)
        
        emailTextField.rx.text.orEmpty
            .filter { [weak self] email in
                guard let self = self else { return false }
                return self.isEmailValid(email)
            }
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.emailTextField.errorMessage = ""
            })
            .bind(to: viewModel.email)
            .disposed(by: bag)
        
        passwordTextField.rx.controlEvent(.editingDidEnd)
            .asObservable()
            .filter { [weak self] _ in
                guard let self = self else { return false }
                return self.isPasswordValid(self.emailTextField.text) == false
            }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.passwordTextField.errorMessage = R.string.localizable.invalidPassword()
            })
            .disposed(by: bag)
        
        passwordTextField.rx.text.orEmpty
            .filter { [weak self] password in
                guard let self = self else { return false }
                return self.isPasswordValid(password)
            }
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.passwordTextField.errorMessage = ""
            })
            .bind(to: viewModel.password)
            .disposed(by: bag)
        
        signInButton.rx.tap
            .filter { [weak self] _ in
                guard let self = self else { return false }
                return self.isEmailValid(self.emailTextField.text) &&
                self.isPasswordValid(self.passwordTextField.text)
            }
            .bind(to: viewModel.signInTapped)
            .disposed(by: bag)
        
        signUpButton.rx.tap
            .bind(to: viewModel.signUpTapped)
            .disposed(by: bag)
        
        showPasswordButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.showPasswordButton.isSelected = !self.showPasswordButton.isSelected
                self.passwordTextField.isSecureTextEntry = !self.showPasswordButton.isSelected
            })
        .disposed(by: bag)
        
        tapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.emailTextField.endEditing(true)
                self.emailTextField.resignFirstResponder()
                self.passwordTextField.endEditing(true)
                self.passwordTextField.resignFirstResponder()
            })
            .disposed(by: bag)
        
        viewModel.error
            .subscribe(onNext: { [weak self] message in
                guard let self = self else { return }
                self.showSigInError(message: message)
            })
            .disposed(by: bag)
    }
    
    private func setupView() {
        let passwordClearButton = passwordTextField.value(forKey: "_clearButton") as? UIButton
        passwordClearButton?.setImage(R.image.authentication.clear(), for: .normal)
        passwordTextField.placeholder = R.string.localizable.passwordPlaceholder()
        passwordTextField.title = R.string.localizable.passwordTitle()
        
        let emailClearButton = emailTextField.value(forKey: "_clearButton") as? UIButton
        emailClearButton?.setImage(R.image.authentication.clear(), for: .normal)
        emailTextField.placeholder = R.string.localizable.emailPlaceholder()
        emailTextField.title = R.string.localizable.emailTitle()
        
        signInButton.layer.cornerRadius = signInButton.bounds.width / 8
        
        // Forgot Password
        let attrs = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.underlineStyle: 1] as [NSAttributedString.Key: Any]
        
        let attributedString = NSMutableAttributedString(string: "")
        let buttonTitle = NSMutableAttributedString(string: R.string.localizable.forgotPassword(), attributes: attrs)
        attributedString.append(buttonTitle)
        forgotPasswordButton.setAttributedTitle(attributedString, for: .normal)
        
        // Sign Up
        let signUpAttrs = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .semibold) ]
        let formattedTitle = NSMutableAttributedString(string: R.string.localizable.signUp(), attributes: signUpAttrs)
        let signUpTitle = NSMutableAttributedString(string: R.string.localizable.noAccount(),
                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        signUpTitle.append(formattedTitle)
        signUpButton.setAttributedTitle(signUpTitle, for: .normal)
        
        // Show/Hide password button
        showPasswordButton.setImage(R.image.authentication.hide(), for: .normal)
        showPasswordButton.setImage(R.image.authentication.show(), for: .selected)
        
        view.addGestureRecognizer(tapGesture)
    }
    
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
        present(alertController, animated: true, completion: nil)
    }
}
