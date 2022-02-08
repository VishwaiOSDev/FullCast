//
//  SignUpView.swift
//  FullCast
//
//  Created by Vishwa  R on 03/02/22.
//

import SwiftUI

struct SignUpView: View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @EnvironmentObject private var viewModel : AuthenticationViewModel
    
    init() {
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        VStack(alignment : .center) {
            header
            Spacer()
            Text("Create an account")
                .font(.title)
                .fontWeight(.medium)
            formFields
            PrimaryButton(action: signUpButtonPressed, label: "Sign up with email")
            Spacer()
            footer
        }.background(Color.black)
    }
    
    var header : some View {
        VStack {
            Image("FullCast Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 350, height: 68)
            Text(#""Your daily podcast on your pocket.""#)
                .font(.subheadline)
                .padding()
        }
    }
    
    var formFields : some View {
        Form {
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
            SecureField("Password", text: $password)
                .textContentType(.newPassword)
            SecureField("Confirm Password", text: $confirmPassword)
                .textContentType(.newPassword)
        }
        .disableAutocorrection(true)
        .background(Color(UIColor(.black)))
        .frame(height : 200)
    }
    
    var footer : some View {
        HStack {
            Text("By signing up you agress to")
            Text("Terms & Privacy")
                .underline()
        }
        .padding()
    }
    
    private func signUpButtonPressed() {
        viewModel.performSignUp(for: email, password, confirmPassword)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .preferredColorScheme(.dark)
    }
}
