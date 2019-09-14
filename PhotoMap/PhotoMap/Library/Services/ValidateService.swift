//
//  ValidateService.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 9/6/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation

class ValidateService {
    func isPasswordValid(_ password: String?) -> Bool {
        // Minimum 8 characters at least 1 Alphabet and 1 Number:
        let passwordRegEx = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
        let passwordPred = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordPred.evaluate(with: password)
    }
    
    func isEmailValid(_ email: String?) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isAccaoutDataValid(_ email: String, _ password: String) -> Bool {
        return isEmailValid(email) && isPasswordValid(password)
    }
    
    func isAccaoutDataValid(_ email: String, _ password: String, _ repeatPassword: String) -> Bool {
        return isEmailValid(email) && isPasswordValid(password)
            && repeatPassword == password
    }
    
    func isHexColor(_ hex: String) -> Bool {
        let hexColorRegEx = "^#([A-Fa-f0-9]{6})$"
        let hexColorPred = NSPredicate(format:"SELF MATCHES %@", hexColorRegEx)
        return hexColorPred.evaluate(with: hex)
        
    }
    
    func isRussian(text: String) -> Bool {
        let inRussianRegEx = "^[а-яА-Я0-9_ ]*$"
        let redicate = NSPredicate(format:"SELF MATCHES %@", inRussianRegEx)
        return redicate.evaluate(with: text)
    }
    
    func isEnglish(text: String) -> Bool {
        let inEnglishRegEx = "^[a-zA-Z0-9_ ]*$"
        let redicate = NSPredicate(format:"SELF MATCHES %@", inEnglishRegEx)
        return redicate.evaluate(with: text)
    }
}
