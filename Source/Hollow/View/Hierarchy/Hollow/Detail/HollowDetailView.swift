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
    @State var reverseComments = false
    @State var showOnlyName: String?
    
    let scrollAnimation = Animation.spring(response: 0.3)
    
    @ScaledMetric(wrappedValue: 8) var headerVerticalPadding: CGFloat
    @ScaledMetric(wrappedValue: 16) var newCommentLabelSize: CGFloat
    @ScaledMetric var commentViewBottomPadding: CGFloat = 100
    
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.popHandler) var popHandler
    
    @Namespace var buttonAnimationNamespace
    
    var body: some View {
        VStack(spacing: 0) {
            if showHeader {
                VStack(spacing: 0) {
                    HStack {
                        Button(action: popHandler ?? dismissSelf) {
                            Image(systemName: popHandler == nil ? "xmark" : "chevron.left")
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
            
            ScrollViewReader { proxy in
                List {
                    VStack(spacing: 0) {
                        let spacing: CGFloat = UIDevice.isMac ? 20 : 13
                        
                        if store.noSuchPost {
                            HollowTextView(text: NSLocalizedString("DETAILVIEW_NO_SUCH_POST_PLACEHOLDER", comment: ""), highlight: false)
                                .padding(.bottom, spacing)
                                .padding(.horizontal)
#if targetEnvironment(macCatalyst)
                                .textSelection(.enabled)
#endif

                        } else {
                            HollowContentView(
                                postDataWrapper: store.postDataWrapper,
                                options: [.displayVote, .displayImage, .displayCitedPost, .revealFoldTags],
                                voteHandler: store.vote,
                                imageReloadHandler: { _ in store.loadPostImage() }
                            )
                            .padding(.bottom, spacing)
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: spacing).fixedSize()
                        
                    }
                    .padding(.top)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listSectionSeparator(.hidden)
                    .id(-1)
                    
                    if !store.noSuchPost {
                        commentView
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listSectionSeparator(.hidden)
                    }
                    
                }
                .listStyle(PlainListStyle())
                .background(Color.hollowCardBackground)
                .coordinateSpace(name: "detail.scrollview")
                .buttonStyle(BorderlessButtonStyle())
                .onChange(of: store.replyToId) { id in
                    guard id != -2 else { return }
                    withAnimation(scrollAnimation) {
                        proxy.scrollTo(id, anchor: .top)
                    }
                }
                .onChange(of: jumpedFromCommentId) { commentId in
                    if commentId != nil {
                        withAnimation(scrollAnimation) {
                            jumpedFromCommentId = nil
                            proxy.scrollTo(commentId, anchor: .top)
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
                                proxy.scrollTo(jumpToCommentId, anchor: .top)
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
                
            }
            .proposedCornerRadius()
        }
        
        .disabled(store.noSuchPost)
        .background(
            Color.hollowCardBackground
                .proposedCornerRadius()
                .proposedIgnoringSafeArea()
        )
        
        .overlay(Group { if store.replyToId < -1 && !store.noSuchPost {
            FloatButton(
                action: {
                    withAnimation(scrollAnimation) { store.replyToId = -1 }
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                },
                systemImageName: "text.bubble.fill",
                imageScaleFactor: 0.8,
                buttonAnimationNamespace: buttonAnimationNamespace
            )
            .proposedIgnoringSafeArea(edges: .bottom)
            .bottom()
            .trailing()
            .padding()
            .padding(7)
            .padding(.bottom, 7)
            .disabled(store.isSendingComment || store.isLoading)
        }})
        
        .proposedIgnoringSafeArea(edges: .bottom)

        .overlay(Group { if store.replyToId >= -1 {
            let post = store.postDataWrapper.post
            let name = store.replyToId == -1 ?
                NSLocalizedString("COMMENT_INPUT_REPLY_POST_SUFFIX", comment: "") :
                post.comments.first(where: { $0.commentId == store.replyToId })?.name ?? ""
            HollowCommentInputView(
                store: store,
                buttonAnimationNamespace: UIDevice.isPad ? nil : buttonAnimationNamespace,
                transitionAnimation: scrollAnimation,
                replyToName: name
            )
            .edgesIgnoringSafeArea([])
            .bottom()
            .transition(UIDevice.isPad ? .move(edge: .bottom) : .floatButton)
            
        }})
        
        .onChange(of: store.replyToId) { id in
            if id >= -1 {
                withAnimation(scrollAnimation) { inputPresented = true }
            }
        }
        .onChange(of: inputPresented) { presented in
            if !presented { withAnimation(scrollAnimation) { store.replyToId = -2 }}
        }
        
        .onDisappear {
            store.bindingCancellable?.cancel()
        }
        
        .modifier(ErrorAlert(errorMessage: $store.errorMessage))
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
