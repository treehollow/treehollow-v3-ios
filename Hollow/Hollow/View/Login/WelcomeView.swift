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
    @EnvironmentObject var appModel: AppModel
    
    @ObservedObject var viewModel: Welcome = .init()
    
    @ScaledMetric(wrappedValue: 22, relativeTo: .title) var title22: CGFloat
    @ScaledMetric(wrappedValue: 15, relativeTo: .body) var body15: CGFloat

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                PrimaryBackgroundShape()
                    .edgesIgnoringSafeArea(.all)
                    
                    .frame(maxHeight: UIScreen.main.bounds.height * 0.23)
                    .foregroundColor(.loginBackgroundPrimary)
                VStack(spacing: 20) {
                    Text(LocalizedStringKey("Select Hollow"))
                        .font(.system(size: title22, weight: .semibold))
                        .foregroundColor(Color("hollow.content.text.other"))
                        .padding(.top, 70)
                        .padding(.bottom, 20)
                    
                    let buttonGradient = LinearGradient.verticalSingleColor(color: Color("hollow.card.background.other"))
                    NavigationLink(
                        destination: LoginView(),
                        tag: HollowType.thu.rawValue,
                        selection: $viewModel.hollowSelection) {
                        MyButton(action: {
                            Defaults[.hollowType] = .thu
                            // Set to nil before request to avoid conflict
                            Defaults[.hollowConfig] = nil
                            viewModel.requestConfig(hollowType: .thu)
                        }, gradient: buttonGradient) {
                            // We are not localizing this
                            selectHollowButton(text: "T大树洞")
                        }}
                    NavigationLink(
                        destination: LoginView(),
                        tag: HollowType.pku.rawValue,
                        selection: $viewModel.hollowSelection) {
                        MyButton(action: {
                            Defaults[.hollowType] = .pku
                            // Set to nil before request to avoid conflict
                            Defaults[.hollowConfig] = nil
                            viewModel.requestConfig(hollowType: .pku)
                        }, gradient: buttonGradient) {
                            selectHollowButton(text: "未名树洞")
                        }}
                    
                    NavigationLink(
                        destination: CustomConfigConfigurationView(),
                        tag: HollowType.other.rawValue,
                        selection: $viewModel.hollowSelection) {
                        MyButton(action: {
                            Defaults[.hollowType] = .other
                            viewModel.hollowSelection = HollowType.other.rawValue
                        }, gradient: buttonGradient) {
                            selectHollowButton(text: String.othersLocalized.capitalized)
                        }}
                    Spacer()
                    if viewModel.isLoadingConfig {
                        Spinner(color: Color("hollow.content.text.other"), desiredWidth: 20)
                            .padding()
                    }
                    
                    let footnote = appModel.tokenExpired ? "Your access token has expired. Please login again." : "Email verification is required"
                    Text(footnote)
                        .font(.footnote)
                        .padding(.vertical, 5)
                        .layoutPriority(1)
                }
            }
            // Disable the buttons when loading config
            .disabled(viewModel.isLoadingConfig)
            .background(Color("background.other").edgesIgnoringSafeArea(.all))
            .navigationTitle(LocalizedStringKey("Welcome"))
            
            // Show alert on receiving error
            .modifier(ErrorAlert(errorMessage: $viewModel.errorMessage))
        }
        .accentColor(.hollowContentText)
        .navigationViewStyle(StackNavigationViewStyle())
        
        .onAppear {
            // Don't use AppModelBehaviour modifier on this view.
            if appModel.tokenExpired {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation { appModel.tokenExpired = false }
                }
            }
        }
    }
    
    func selectHollowButton(text: String) -> some View {
        return Text(text)
            .foregroundColor(Color("hollow.content.text.other"))
            .padding(.vertical, 5)
            .font(.system(size: body15, weight: .medium))
            .frame(width: 150)
    }
    
    struct CustomConfigConfigurationView: View {
        @ObservedObject var viewModel: Welcome = .init()
        @State var text: String = ""
        
        @ScaledMetric(wrappedValue: ViewConstants.navigationBarSpinnerWidth) var spinnerWidth
        
        var body: some View {
            VStack {
                MyTextField<EmptyView>(
                    text: $text,
                    placeHolder: NSLocalizedString("URL for custom configuration", comment: ""),
                    title: NSLocalizedString("Custom Configuration", comment: ""),
                    footer: NSLocalizedString("Get the URL for the configuration from the treehollow website.", comment: "")
                )
                .keyboardType(.URL)
                .navigationBarItems(
                    trailing:
                        Group {
                            if viewModel.isLoadingConfig {
                                Spinner(color: .hollowContentText, desiredWidth: spinnerWidth)
                            } else {
                                Button(LocalizedStringKey("Next"), action: {
                                    viewModel.requestConfig(hollowType: .other, customConfigURL: text)
                                })
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
            .navigationTitle(String.othersLocalized.capitalized)
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

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
#endif
