//
//  HollowDetailView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI
import Defaults

struct HollowDetailView: View {
    @ObservedObject var store: HollowDetailStore
    
    var showHeader = true
    @State private var headerFrame: CGRect = .zero
    @State private var commentViewFrame: CGRect = .zero
    @State var inputPresented = false
    @State var jumpedToCommentId: Int?
    @State var jumpedFromCommentId: Int?
    @State private var showHeaderContent = Defaults[.useListInDetail]
    @State var reverseComments = false
    @State var showOnlyName: String?
    
    private let scrollToAnchor = UnitPoint(x: 0.5, y: 0.1)
    let scrollAnimation = Animation.spring(response: 0.3)
    
    @ScaledMetric(wrappedValue: 10) var headerVerticalPadding: CGFloat
    @ScaledMetric(wrappedValue: 16) var newCommentLabelSize: CGFloat
    @ScaledMetric var commentViewBottomPadding: CGFloat = 100
    
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    
    @Namespace var buttonAnimationNamespace
    
    @Default(.useListInDetail) var useListInDetail
    
    var body: some View {
        VStack(spacing: 0) {
            if showHeader {
                VStack(spacing: 0) {
                    HStack {
                        Button(action: dismissSelf) {
                            Image(systemName: "xmark")
                                .modifier(ImageButtonModifier())
                                .padding(.trailing, 5)
                        }
                        .padding(.trailing, 5)
                        
                        _HollowHeaderView(
                            postData: store.postDataWrapper.post,
                            compact: false,
                            // Show text on header when the text is not visible
                            showContent: true,
                            starAction: store.star,
                            isLoading: store.isLoading,
                            disableAttention: store.isEditingAttention || store.isLoading,
                            menuContent: { Group {
                                Button(action: store.requestDetail) {
                                    Label("DETAIL_MENU_REFRESH_LABEL", systemImage: "arrow.clockwise")
                                }
                                .disabled(store.isLoading)
                                
                                Divider()
                                
                                Button(action: {
                                    let inputStore = HollowInputStore(presented: .constant(true), selfDismiss: true, refreshHandler: nil)
                                    inputStore.text = "#\(store.postDataWrapper.post.postId.string)\n"
                                    IntegrationUtilities.presentView(modalInPresentation: true, content: { HollowInputView(inputStore: inputStore) })
                                }) {
                                    Label("DETAIL_MENU_QUOTE_LABEL", systemImage: "text.quote")
                                }
                                
                                Divider()
                                
                                ReportMenuContent(
                                    store: store,
                                    permissions: store.postDataWrapper.post.permissions,
                                    commentId: nil
                                )
                                .disabled(store.isLoading)
                            }}
                        )
                        .onTapGesture(count: 2, perform: store.requestDetail)
                        .disabled(store.noSuchPost)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, headerVerticalPadding)
                    Divider()
                }
            }
            
            if useListInDetail {
                List {
                    content
                        .listRowInsets(EdgeInsets())
                        .background(Color.hollowCardBackground)
                }
                .buttonStyle(BorderlessButtonStyle())

            } else {
                ScrollView { ScrollViewReader { proxy in
                    LazyVStack(spacing: 0) {
                        content
                    }
                    .padding([.horizontal, .bottom], UIDevice.isMac ? ViewConstants.macAdditionalPadding : 0)
                    .padding(.top, UIDevice.isMac ? 10 : 0)
                    .edgesIgnoringSafeArea(.bottom)

                    .onChange(of: store.replyToIndex) { index in
                        guard index != -2 else { return }
                        let id = index >= 0 ? store.postDataWrapper.post.comments[index].commentId : -1
                        withAnimation(scrollAnimation) {
                            proxy.scrollTo(id, anchor: scrollToAnchor)
                        }
                    }
                    .onChange(of: jumpedFromCommentId) { commentId in
                        if commentId != nil {
                            withAnimation(scrollAnimation) {
                                jumpedFromCommentId = nil
                                proxy.scrollTo(commentId, anchor: scrollToAnchor)
                                jumpedToCommentId = commentId
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                guard self.jumpedToCommentId == commentId else { return }
                                withAnimation(scrollAnimation) { jumpedToCommentId = nil }
                            }
                        }
                    }
                    // Jump to certain comment
                    .onChange(of: store.isLoading) { loading in
                        if !loading {
                            // Check if there is any comment to jump to
                            // when finish loading
                            if let jumpToCommentId = store.jumpToCommentId {
                                    withAnimation(scrollAnimation) {
                                        proxy.scrollTo(jumpToCommentId, anchor: scrollToAnchor)
                                        jumpedToCommentId = jumpToCommentId
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        guard self.jumpedToCommentId == jumpToCommentId else { return }
                                        withAnimation(scrollAnimation) {
                                            self.jumpedToCommentId = nil }
                                    }
                                store.jumpToCommentId = nil
                            }
                        }
                    }
                    
                }}
                .coordinateSpace(name: "detail.scrollview")
            }
            
        }
        
        .disabled(store.noSuchPost)
        
        .background(Color.hollowCardBackground.ignoresSafeArea())
        
        .overlay(Group { if store.replyToIndex < -1 && !store.noSuchPost {
            FloatButton(
                action: {
                    withAnimation(scrollAnimation) { store.replyToIndex = -1 }
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                },
                systemImageName: "text.bubble.fill",
                imageScaleFactor: 0.8,
                buttonAnimationNamespace: buttonAnimationNamespace
            )
//            .matchedGeometryEffect(id: "button", in: buttonAnimationNamespace)
            .edgesIgnoringSafeArea(.bottom)
            .bottom()
            .trailing()
            .padding()
            .padding(7)
            .padding(.bottom, 7)
            .disabled(store.isSendingComment || store.isLoading)
        }})
        .edgesIgnoringSafeArea(.bottom)
        
        .overlay(Group { if store.replyToIndex >= -1 {
            let post = store.postDataWrapper.post
            let name = store.replyToIndex == -1 ?
                NSLocalizedString("COMMENT_INPUT_REPLY_POST_SUFFIX", comment: "") :
                post.comments[store.replyToIndex].name
            HollowCommentInputView(
                store: store,
                buttonAnimationNamespace: UIDevice.isPad ? nil : buttonAnimationNamespace,
                transitionAnimation: scrollAnimation,
                replyToName: name
            )
            .edgesIgnoringSafeArea([])
            .bottom()
            .transition(UIDevice.isPad ? .move(edge: .bottom) : .opacity)
            
        }})
        
        .onChange(of: store.replyToIndex) { index in
            if index >= -1 {
                withAnimation(scrollAnimation) { inputPresented = true }
            }
        }
        .onChange(of: inputPresented) { presented in
            if !presented { withAnimation(scrollAnimation) { store.replyToIndex = -2 }}
        }
        
        .onDisappear {
            store.bindingCancellable?.cancel()
        }
        
        .modifier(ErrorAlert(errorMessage: $store.errorMessage))
        
    }
}

extension HollowDetailView {
    
    @ViewBuilder var content: some View {
        
        if useListInDetail {
            VStack(spacing: 0) {
                mainContent
            }
        } else {
            mainContent
        }
        
        if !store.noSuchPost {
            commentView
                .listRowInsets(EdgeInsets())
        }
    }
    
    @ViewBuilder var mainContent: some View {
        let spacing: CGFloat = UIDevice.isMac ? 20 : 13
        
        Color.hollowCardBackground
            .frame(height: 5)
            .id(-1)
        
        if store.noSuchPost {
            Text("DETAILVIEW_NO_SUCH_POST_PLACEHOLDER")
                .padding(.top, spacing)
                .padding(.horizontal)
                .modifier(HollowTextView.TextModifier(inDetail: true))
            
        } else {
            HollowContentView(
                postDataWrapper: store.postDataWrapper,
                options: [.displayVote, .displayImage, .displayCitedPost, .revealFoldTags, .showHyperlinks],
                voteHandler: store.vote,
                imageReloadHandler: { _ in store.loadPostImage() }
            )
            .padding(.top, spacing)
            .padding(.horizontal)
            .background(Color.hollowCardBackground)
        }
        
        Color.hollowCardBackground
            .frame(height: spacing * 2)
    }
}

extension HollowDetailView {
    @ViewBuilder static func conditionalDetailView(store: HollowDetailStore, push: Bool = UIDevice.isPad) -> some View {
        if push {
            HollowDetailView_iPad(store: store)
        } else {
            HollowDetailView(store: store)
        }
    }
}
