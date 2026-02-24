//
//  ContentView.swift
//  Gotcha
//
//  Created by Rajahiresh Kalva on 7/29/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome to Gotcha App!")
                    .font(.largeTitle)
                    .frame(width: 300, height: 100)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 100)
                
                NavigationLink(destination: ResultView()) {
                    Text("Get Started")
                        .font(.headline)
                        .frame(width: 300, height: 50)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .padding(.top, 300)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
