//
//  LoginView.swift
//  Gotcha
//
//  Created by Rajahiresh Kalva on 8/5/25.
//

import SwiftUI

struct LoginView: View {
    @State var username: String = ""
    @State var password: String = ""
    
    // State to satisfy ResultView's initializer
    @State var fileName: String = ""
    @State var searchText: String = ""
    @State var selectedImage: UIImage? = nil
    
    var body: some View {
        VStack{
            HStack{
                Text("Username:")
                    .font(.headline)
                TextField("Enter Username", text: $username)
                    .padding(10)
                    .background(.gray.opacity(0.1))
                    .cornerRadius(10)
            }.padding()
            HStack{
                Text("Password:")
                    .font(.headline)
                SecureField("Enter Password", text: $password)
                    .padding(10)
                    .background(.gray.opacity(0.1))
                    .cornerRadius(10)
            }.padding()
            
            NavigationLink(destination: ResultView(fileName: $fileName,
                                                   searchText: searchText,
                                                   selectedImage: $selectedImage)) {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 300, height: 50)
                    .background(.blue)
                    .cornerRadius(15)
            }.padding(30)
        }
    }
}

#Preview {
    LoginView()
}
