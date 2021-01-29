//
//  LoginView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI
import Defaults

struct WelcomeView: View {
    @ObservedObject var viewModel: Welcome = .init()
    @State private var selection: Int? = nil
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                PrimaryBackgroundShape()
                    .edgesIgnoringSafeArea(.all)
                    .frame(maxHeight: 170)
                    .foregroundColor(.loginBackgroundPrimary)
                VStack(spacing: 20) {
                    Text(LocalizedStringKey("Select Hollow of School"))
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(Color("hollow.content.text.other"))
                        .padding(.top, 70)
                        .padding(.bottom, 20)
                    NavigationLink(
                        destination: Text(selection?.string ?? ""),
                        tag: 1,
                        selection: $selection) {
                        MyButton(action: {
                            Defaults[.hollowType] = .thu
                            selection = 1
                        }, gradient: .vertical(gradient: .init(colors: [Color("hollow.card.background.other")]))) {
                            Text("T大树洞")
                                .selectHollowButton()
                        }
                        }
                    NavigationLink(
                        destination: Text(selection?.string ?? ""),
                        tag: 2,
                        selection: $selection) {
                        MyButton(action: {
                            Defaults[.hollowType] = .pku
                            selection = 2
                        }, gradient: .vertical(gradient: .init(colors: [Color("hollow.card.background.other")]))) {
                            Text("未名树洞")
                                .selectHollowButton()
                        }
                        }

                    NavigationLink(
                        destination: Text(selection?.string ?? ""),
                        tag: 3,
                        selection: $selection) {
                        MyButton(action: {
                            Defaults[.hollowType] = .other
                            selection = 3
                        }, gradient: .vertical(gradient: .init(colors: [Color("hollow.card.background.other")]))) {
                            Text(LocalizedStringKey("Others"))
                                .selectHollowButton()
                        }
                        }
                    Spacer()
                    Text(LocalizedStringKey("Email authentication is required"))
                        .font(.footnote)
                        .padding(.vertical, 5)
                        .layoutPriority(1)
                }
            }
            .background(Color("background.other").edgesIgnoringSafeArea(.all))
            .navigationTitle(LocalizedStringKey("Welcome"))
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

extension View {
    fileprivate func selectHollowButton() -> some View {
        return self
            .foregroundColor(Color("hollow.content.text.other"))
            .padding(.vertical, 5)
            .font(.system(size: 14, weight: .medium))
            .frame(width: 150)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
