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

class AuthenticationViewController: UIViewController, StoryboardInitializable {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
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
        
        // TODO: - Handle forgot password (if it is possible)
        // TODO: - Change color of show/hide password button
        // TODO: - Handle sign Up

        // TODO: - Filter password and user name
        emailTextField.rx.text
            .compactMap { $0 }
            .bind(to: viewModel.name)
            .disposed(by: bag)
        
        passwordTextField.rx.text
            .compactMap { $0 }
            .bind(to: viewModel.password)
            .disposed(by: bag)
        
        signUpButton.rx.tap
            .bind(to: viewModel.signUpTapped)
            .disposed(by: bag)
        
        signInButton.rx.tap
            .bind(to: viewModel.signInTapped)
            .disposed(by: bag)
        
        showPasswordButton.rx.tap
            .subscribe(onNext: { _ in
                self.showPasswordButton.isSelected = !self.showPasswordButton.isSelected
                self.passwordTextField.isSecureTextEntry = !self.showPasswordButton.isSelected
            })
        .disposed(by: bag)
        
        tapGesture.rx.event
            .subscribe(onNext: { _ in
                self.emailTextField.endEditing(true)
                self.passwordTextField.endEditing(true)
            })
            .disposed(by: bag)
    }
    
    private func setupView() {
        let passwordClearButton = passwordTextField.value(forKey: "_clearButton") as? UIButton
        passwordClearButton?.setImage(UIImage(named: "clear"), for: .normal)
        
        let emailClearButton = emailTextField.value(forKey: "_clearButton") as? UIButton
        emailClearButton?.setImage(UIImage(named: "clear"), for: .normal)
        
        signInButton.layer.cornerRadius = signInButton.bounds.width / 8
        
        // Forgot Password
        let attrs = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.underlineStyle: 1] as [NSAttributedString.Key: Any]
        
        let attributedString = NSMutableAttributedString(string: "")
        let buttonTitle = NSMutableAttributedString(string: "Forgot Password?", attributes: attrs)
        attributedString.append(buttonTitle)
        forgotPasswordButton.setAttributedTitle(attributedString, for: .normal)
        
        // Sign Up
        let signUpAttrs = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .semibold) ]
        
        let formattedTitle = NSMutableAttributedString(string: "Sign Up", attributes: signUpAttrs)
        let signUpTitle = NSMutableAttributedString(string: "Don't have an account? ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        signUpTitle.append(formattedTitle)
        signUpButton.setAttributedTitle(signUpTitle, for: .normal)
        
        // Show/Hide password button
        showPasswordButton.setImage(UIImage(named: "hide"), for: .normal)
        showPasswordButton.setImage(UIImage(named: "show"), for: .selected)
        
        view.addGestureRecognizer(tapGesture)
    }
}
