//
//  LoginView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI
import Defaults

/// View for selecting configuration of the hollow.
///
/// Color set for this view is fixed to `other`.
struct WelcomeView: View {
    @ObservedObject var viewModel: WelcomeStore = .init()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                PrimaryBackgroundShape()
                    .edgesIgnoringSafeArea(.all)
                    
                    .frame(maxHeight: UIScreen.main.bounds.height * (UIDevice.isPad ? 0.5 : 0.35))
                    .foregroundColor(.loginBackgroundPrimary)
                Spacer()

                VStack(spacing: 20) {

                    HStack {
                        Text("WELCOMEVIEW_SELECT_HOLLOW_TITLE")
                            .dynamicFont(size: 22, weight: .semibold)
                            .foregroundColor(Color("hollow.content.text.other"))

                        if viewModel.isLoadingConfig {
                            Spinner(color: Color("hollow.content.text.other"), desiredWidth: 16)
                        }
                    }
                    .padding(.top, 70)
                    .padding(.bottom, 20)

                    let buttonGradient = LinearGradient.verticalSingleColor(color: Color("hollow.card.background.other"))
                    
                    Menu {
                        
                        Button(String("T大树洞")) {
                            Defaults[.hollowType] = .thu
                            // Set to nil before request to avoid conflict
                            Defaults[.hollowConfig] = nil
                            viewModel.requestConfig(hollowType: .thu)
                        }

                        Button(String("未名树洞")) {
                            Defaults[.hollowType] = .pku
                            // Set to nil before request to avoid conflict
                            Defaults[.hollowConfig] = nil
                            viewModel.requestConfig(hollowType: .pku)
                        }

                        let configs = Constants.HollowConfig.otherConfigs
                        ForEach(Array(configs.keys), id: \.self) { key in
                            Button(key) {
                                Defaults[.hollowType] = .other
                                Defaults[.hollowConfig] = nil
                                viewModel.requestConfig(hollowType: .other, customConfigURL: configs[key]!, predifined: true)
                            }
                        }
                        Divider()

                    } label: {
                        // NavigationLink in label to push new view.
                        NavigationLink(
                            destination: LoginView(),
                            tag: 100,
                            selection: $viewModel.hollowSelection) {
                            MyButton(action: {}, gradient: buttonGradient) {
                                selectHollowButton(text: NSLocalizedString("WELCOMVIEW_SELECT_BUTTON", comment: ""))
                            }
                        }
                            .overlay(NavigationLink(
                                destination: LoginView(),
                                tag: HollowType.thu.rawValue,
                                selection: $viewModel.hollowSelection) {}
                            )
                            .overlay(NavigationLink(
                                destination: LoginView(),
                                tag: HollowType.pku.rawValue,
                                selection: $viewModel.hollowSelection) {}
                            )
                    }
                    
                    NavigationLink(
                        destination: CustomConfigConfigurationView(),
                        tag: HollowType.other.rawValue,
                        selection: $viewModel.hollowSelection) {
                        MyButton(action: {
                            Defaults[.hollowType] = .other
                            Defaults[.hollowConfig] = nil
                            viewModel.hollowSelection = HollowType.other.rawValue
                        }, gradient: buttonGradient) {
                            selectHollowButton(text: NSLocalizedString("WELCOMEVIEW_CUSTOM_BUTTON", comment: ""))
                        }
                    }
                }
                .padding(.bottom)
                .padding(.bottom)
                .layoutPriority(1)
            }
            // Disable the buttons when loading config
            .disabled(viewModel.isLoadingConfig)
            .background(Color("welcome.background").edgesIgnoringSafeArea(.all))
            .navigationTitle(NSLocalizedString("WELCOMEVIEW_NAV_TITLE", comment: ""))
            
            // Show alert on receiving error
            .modifier(ErrorAlert(errorMessage: $viewModel.errorMessage))
        }
        .accentColor(.tint)
        .navigationViewStyle(StackNavigationViewStyle())
        
    }
    
    func selectHollowButton(text: String) -> some View {
        return Text(text)
            .foregroundColor(Color("hollow.content.text.other"))
            .padding(.vertical, 5)
            .dynamicFont(size: 15, weight: .medium)
            .frame(width: 150)
    }
    
    struct CustomConfigConfigurationView: View {
        @ObservedObject var viewModel: WelcomeStore = .init()
        #if DEBUG
        @State var text: String = "https://cdn.jsdelivr.net/gh/treehollow/thuhole-config@master/config.txt"
        #else
        @State var text: String = ""
        #endif
        
        @ScaledMetric(wrappedValue: ViewConstants.navigationBarSpinnerWidth) var spinnerWidth
        
        var body: some View {
            VStack {
                MyTextField<EmptyView>(
                    text: $text,
                    placeHolder: NSLocalizedString("WELCOMEVIEW_CUSTOM_URL_TEXTFIELD_PLACEHOLDER", comment: ""),
                    title: NSLocalizedString("WELCOMEVIEW_CUSTOM_CONFIGURATION_SECTION_HEADER", comment: ""),
                    footer: NSLocalizedString("WELCOMEVIEW_CUSTOM_CONFIGURATION_SECTION_FOOTER", comment: "")
                )
                .keyboardType(.URL)
                .navigationBarItems(
                    trailing:
                        Group {
                            if viewModel.isLoadingConfig {
                                Spinner(color: .hollowContentText, desiredWidth: spinnerWidth)
                            } else {
                                Button(NSLocalizedString("WELCOMEVIEW_CUSTOM_NEXT_BUTTON", comment: ""), action: {
                                    viewModel.requestConfig(hollowType: .other, customConfigURL: text)
                                })
                                .disabled(text == "")
                            }
                        }
                )
                
                // Show alert if there's any error message provided
                .modifier(ErrorAlert(errorMessage: $viewModel.errorMessage))
                
                NavigationLink(
                    destination: LoginView(),
                    tag: HollowType.other.rawValue,
                    selection: $viewModel.hollowSelection, label: {})
                Spacer()
            }
            .padding()
            .padding(.horizontal)
            .background(Color.background.edgesIgnoringSafeArea(.all))
            
            .disabled(viewModel.isLoadingConfig)
            .navigationTitle(NSLocalizedString("WELCOMEVIEW_CUSTOM_CONFIG_NAV_TITLE", comment: ""))
        }
    }
    
    private struct PrimaryBackgroundShape: Shape {
        func path(in rect: CGRect) -> Path {
            let bottomY = rect.maxY - rect.height * 0.1
            let point1 = rect.origin
            let point2 = CGPoint(x: rect.minX, y: bottomY)
            let point3 = CGPoint(x: rect.midX, y: rect.maxY + rect.height * 0.1)
            let point4 = CGPoint(x: rect.maxX, y: bottomY)
            let point5 = CGPoint(x: rect.maxX, y: rect.minY)
            return Path { path in
                path.move(to: point1)
                path.addLine(to: point2)
                path.addQuadCurve(to: point4, control: point3)
                path.addLine(to: point5)
                path.closeSubpath()
            }
        }
    }
}
