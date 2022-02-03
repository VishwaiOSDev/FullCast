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
    @State private var contentHeight: CGFloat?
    @State private var showSignUpSheet = false
    
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
            SecureField("Password", text: $password)
        }
        .frame(height : 150)
        .background(.black)
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
    }
    
    func loginButtonPressed() {
        print("Login Button Pressed.")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .preferredColorScheme(.dark)
    }
}
