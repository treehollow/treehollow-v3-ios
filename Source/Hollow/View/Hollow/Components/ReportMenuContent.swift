//
//  ReportMenuContent.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/4.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults

struct ReportMenuContent: View {
    @ObservedObject var store: HollowDetailStore
    var data: KeyPath<HollowDetailStore, [PostPermissionType]>
    var commentId: Int?
    @Binding var reportCommentId: Int?
    @Binding var showConfirm: Bool
    @Binding var textFieldPresented: Bool
    @Binding var reportType: PostPermissionType?
    
    private var permissions: [PostPermissionType] { store[keyPath: data] }
    private var showReportTag: Bool { permissions.contains(.fold) && !permissions.contains(.setTag) }
    private var showReportDelete: Bool {
        permissions.contains(.report) &&
            !permissions.contains(.delete) &&
            !permissions.contains(.undeleteUnban)
    }
    private var showRemove: Bool {
        permissions.contains(.delete) &&
            !permissions.contains(.deleteBan)
    }
    private var showAdminSetTag: Bool { permissions.contains(.setTag) }
    var showAdminRemove: Bool {
        permissions.contains(.delete) &&
            permissions.contains(.deleteBan)
    }
    private var showAdminDeleteBan: Bool { permissions.contains(.deleteBan) }
    private var showAdminUndeleteUnban: Bool { permissions.contains(.undeleteUnban) }
    private var showAdminUnban: Bool { permissions.contains(.unban) }
    private var reportableTags: [String] { Defaults[.hollowConfig]?.reportableTags ?? [] }
    
    // Use filled icon for admin actions
    @ViewBuilder var body: some View {
        Group {
            if showReportTag {
                let text = NSLocalizedString("REPORT_MENU_REPORT_TAG", comment: "")
                Menu(content: {
                    ForEach(reportableTags, id: \.self) { tag in
                        Button(tag) {
                            showConfirm(type: .fold, reason: tag)
                        }
                    }
                }, label: {
                    Label(text, systemImage: "tag")
                })
            }
            if showReportDelete {
                let text = NSLocalizedString("REPORT_MENU_REPORT_DELETE", comment: "")
                button(text: text, systemImageName: "exclamationmark.bubble", action: {
                    showTextField(type: .report)
                })
            }
            
            if showRemove {
                let text = NSLocalizedString("REPORT_MENU_DELETE", comment: "")
                button(text: text, systemImageName: "arrow.uturn.backward", action: {
                    showConfirm(type: .delete, reason: "")
                })
            }
            if showAdminSetTag {
                let text = NSLocalizedString("REPORT_MENU_ADMIN_SET_TAG", comment: "")
                Menu(content: {
                    Menu(NSLocalizedString("REPORT_MENU_ADMIN_SET_TAG_EXISTED", comment: "")) {
                        ForEach(reportableTags, id: \.self) { tag in
                            Button(tag) {
                                showConfirm(type: .fold, reason: tag)
                            }
                        }
                    }
                    Button(NSLocalizedString("REPORT_MENU_ADMIN_SET_TAG_CUSTOM", comment: "")) {
                        showTextField(type: .setTag)
                    }
                } , label: {
                    Label(text, systemImage: "tag.fill")
                })
            }
            if showAdminRemove {
                let text = NSLocalizedString("REPORT_MENU_ADMIN_REMOVE", comment: "")
                button(text: text, systemImageName: "trash.fill", action: {
                    showTextField(type: .delete)
                })
            }
            
            if showAdminDeleteBan {
                let text = NSLocalizedString("REPORT_MENU_ADMIN_DELETE_BAN", comment: "")
                button(text: text, systemImageName: "mic.slash.fill", action: {
                    showTextField(type: .deleteBan)
                })
            }
            
            if showAdminUndeleteUnban {
                let text = NSLocalizedString("REPORT_MENU_ADMIN_UNDELETE_UNBAN", comment: "")
                button(text: text, systemImageName: "mic.fill", action: {
                    showTextField(type: .undeleteUnban)
                })
            }
            
            if showAdminUnban {
                let text = NSLocalizedString("REPORT_MENU_ADMIN_UNBAN", comment: "")
                button(text: text, systemImageName: "trash.slash.fill", action: {
                    showTextField(type: .unban)
                })
            }
        }
    }
    
    private func button(text: String, systemImageName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(text, systemImage: systemImageName)
        }
    }
    
    private func showConfirm(type: PostPermissionType, reason: String) {
        reportCommentId = commentId
        reportType = type
        store.reportReason = reason
        showConfirm = true
    }
    
    private func showTextField(type: PostPermissionType) {
        reportCommentId = commentId
        reportType = type
        textFieldPresented = true
    }
}
