//
//  RegisterView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct RegisterView: View {
    @State var key: String = ""
    @State private var reCAPTCHAPresented = false
    @State private var pageLoadingFinish = false
    var body: some View {
        Text("Key: \(key)")
            .onTapGesture {
                reCAPTCHAPresented = true
            }
            .fullScreenCover(isPresented: $reCAPTCHAPresented, content: {
                ReCAPTCHAPageView(presented: $reCAPTCHAPresented, key: $key)
            })
    }
}

extension RegisterView {
    private struct ReCAPTCHAPageView: View {
        @Binding var presented: Bool
        @Binding var key: String
        @State private var pageLoadingFinish = false
        
        var body: some View {
            VStack {
                Button(action: {
                    withAnimation {
                        presented = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.plainButton)
                        .padding(.bottom)
                }
                .leading()
                ReCAPTCHAWebView(onFinishLoading: {
                    withAnimation {
                        pageLoadingFinish = true
                    }
                }, successHandler: { key in
                    withAnimation {
                        self.key = key
                        presented = false
                    }
                })
                .onAppear {
                    pageLoadingFinish = false
                }
                Text(LocalizedStringKey("reCAPTCHA verification needed"))
                    .font(.footnote)
                    .padding(.bottom, 5)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .overlay(Group {
                if !pageLoadingFinish {
                    Spinner(color: .buttonGradient1, desiredWidth: 30)
                }
            })

        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
