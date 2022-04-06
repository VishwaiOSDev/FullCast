//
//  ContentView.swift
//  FullCast
//
//  Created by Vishwa  R on 03/02/22.
//

import SwiftUI

struct LoginView: View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUpSheet = false
    @EnvironmentObject private var viewModel : AuthenticationViewModel
    
    init() {
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        VStack {
            header
            Spacer()
            formFields
            PrimaryButton(action: loginButtonPressed, label: "Sign in with email")
            signUpSheet
            Spacer()
            footer
        }
    }
    
    var header : some View {
        Image("FullCast Logo")
            .resizable()
            .scaledToFit()
            .frame(width: 200, alignment: .center)
    }
    
    var formFields : some View {
        Form {
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
            SecureField("Password", text: $password)
                .textContentType(.newPassword)
        }
        .disableAutocorrection(true)
        .frame(height : 150)
        .background(Color(UIColor(.black)))
    }
    
    var signUpSheet : some View {
        HStack {
            Text("Don't have an account?")
            Text("Sign Up")
                .foregroundColor(.yellow)
        }
        .onTapGesture {
            showSignUpSheet.toggle()
        }
        .sheet(isPresented: $showSignUpSheet) {
            SignUpView()
        }
    }
    
    var footer : some View {
        HStack {
            Text("By signing in you agress to")
            Text("Terms & Privacy")
                .underline()
        }
        .padding()
    }
    
    func loginButtonPressed() {
        viewModel.performLogin(for: email, password)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .preferredColorScheme(.dark)
    }
}
