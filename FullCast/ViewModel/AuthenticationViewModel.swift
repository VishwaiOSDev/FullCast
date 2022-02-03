//
//  AuthenticationViewModel.swift
//  FullCast
//
//  Created by Vishwa  R on 03/02/22.
//

import Foundation

final class AuthenticationViewModel : ObservableObject {
    
    private var model = Authentication()
    
    func performSignUp(for email : String, _ password : String, _ confirmPassword : String) {
        let signUpDictionary = ["email" : email, "password" : password, "confirm_password" : confirmPassword]
        model.sendSignUpRequestToServer(body : signUpDictionary)
    }
    
    func performLogin(for email : String, _ password : String) {
        let loginDictionary = ["email" : email, "password" : password]
        model.sendLoginRequestToServer(body: loginDictionary)
    }
    
}
