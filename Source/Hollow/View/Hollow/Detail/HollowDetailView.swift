//
//  HollowDetailView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct HollowDetailView: View {
    @ObservedObject var store: HollowDetailStore
    
    @State private var commentRect: CGRect = .zero
    @State private var scrollViewOffset: CGFloat? = 0
    @State var inputPresented = false
    @State var jumpedToIndex: Int?
    
    @State var reportTextFieldPresented = false
    @State var reportType: PostPermissionType?
    // Managed by ReportMenu and must be restored after presenting
    // text field
    @State var reportCommentId: Int?
    @State var showReportConfirmAlert = false
    
    @ScaledMetric(wrappedValue: 10) var headerVerticalPadding: CGFloat
    @ScaledMetric(wrappedValue: 16) var newCommentLabelSize: CGFloat
    
    var body: some View {
        // FIXME: Handlers
        ZStack {
            Color.hollowDetailBackground.edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                // Header
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
                            showContent: (scrollViewOffset ?? 0) > commentRect.minY,
                            starAction: store.star,
                            disableAttention: store.isEditingAttention || store.isLoading,
                            menuContent: {
                                ReportMenuContent(
                                    store: store,
                                    data: \.postDataWrapper.post.permissions,
                                    reportCommentId: .constant(nil),
                                    showConfirm: $showReportConfirmAlert,
                                    textFieldPresented: $reportTextFieldPresented,
                                    reportType: $reportType
                                )
                            }
                        )
                        
                    }
                    .padding(.horizontal)
                    .padding(.vertical, headerVerticalPadding)
                    Divider()
                }
                // Contents
                CustomScrollView(offset: $scrollViewOffset) { proxy in
                    VStack(spacing: 13) {
                        Spacer(minLength: 5)
                            .fixedSize()
                        HollowContentView(
                            postDataWrapper: store.postDataWrapper,
                            options: [.displayVote, .displayImage, .displayCitedPost, .revealFoldTags],
                            voteHandler: store.vote,
                            imageReloadHandler: { _ in store.loadPostImage() }
                        )
                        .fixedSize(horizontal: false, vertical: true)
                        .id(-1)
                        
                        Spacer().frame(height: 0)
                            // Get the frame of the comment view.
                            .modifier(GetFrame(frame: $commentRect, coordinateSpace: .named("detail.scrollview.content")))
                        
                        commentView
                            .onChange(of: store.replyToIndex) { index in
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    proxy.scrollTo(index, anchor: .top)
                                }
                            }
                            // Jump to certain comment
                            .onChange(of: store.isLoading) { loading in
                                if !loading {
                                    // Check if there is any comment to jump to
                                    // when finish loading
                                    if let jumpToCommentId = store.jumpToCommentId {
                                        if let index = store.postDataWrapper.post.comments.firstIndex(where: { $0.commentId == jumpToCommentId }) {
                                            withAnimation {
                                                proxy.scrollTo(index, anchor: .center)
                                                jumpedToIndex = index
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                withAnimation { jumpedToIndex = nil }
                                            }
                                        }
                                        store.jumpToCommentId = nil
                                    }
                                }
                            }
                    }
                    .padding(.horizontal)
                    .background(Color.hollowDetailBackground)
                    .coordinateSpace(name: "detail.scrollview.content")
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
        .overlay(Group {
            if store.replyToIndex >= -1 {
                let post = store.postDataWrapper.post
                let name = store.replyToIndex == -1 ?
                    NSLocalizedString("COMMENT_INPUT_REPLY_POST_SUFFIX", comment: "") :
                    post.comments[store.replyToIndex].name
                let animation: Animation = .easeInOut(duration: 0.25)
                // FIXME: Recreated store
                HollowCommentInputView(
                    store: store,
                    transitionAnimation: animation,
                    replyToName: name
                )
                .bottom()
                .transition(.move(edge: .bottom))
            }
        })

        .onChange(of: store.replyToIndex) { index in
            if index >= -1 {
                withAnimation { inputPresented = true }
            }
        }
        .onChange(of: inputPresented) { presented in
            if !presented { withAnimation { store.replyToIndex = -2 }}
        }
        
        .styledAlert(
            presented: $showReportConfirmAlert,
            title: NSLocalizedString("REPORT_MENU_REPORT_REASON_ALERT_TITLE", comment: ""),
            message: nil,
            buttons: [
                .init(text: NSLocalizedString("REPORT_MENU_ALERT_CONFIRM", comment: ""), style: .default, action: report),
                .cancel(action: { store.reportReason = "" })
            ]
        )
        
        .styledAlert(
            presented: $reportTextFieldPresented,
            title: NSLocalizedString("REPORT_MENU_REPORT_REASON_ALERT_TITLE", comment: ""),
            message: NSLocalizedString("REPORT_MENU_REPORT_REASON_ALERT_MESSAGE", comment: ""),
            buttons: [
                .init(text: NSLocalizedString("REPORT_MENU_ALERT_CONFIRM", comment: ""), style: .default, action: report),
                .cancel(action: { store.reportReason = "" })
            ], accessoryView: {
                CustomTextEditor(text: $store.reportReason, editing: .constant(true), modifiers: { $0 })
                    .multilineTextAlignment(.leading)
                    .frame(maxHeight: 100)
                    .padding(7)
                    .background(Color.uiColor(.secondarySystemFill))
                    .roundedCorner(10)
                    .accentColor(.hollowContentText)
            })

        .modifier(ErrorAlert(errorMessage: $store.errorMessage))
        .modifier(AppModelBehaviour(state: store.appModelState))
    }
    
    private func report() {
        let reason = store.reportReason
        let reportCommentId = self.reportCommentId
        self.reportCommentId = nil
        store.reportReason = ""
        guard let type = reportType else { return }
        store.report(commentId: reportCommentId, type: type, reason: reason)
    }
    
}

