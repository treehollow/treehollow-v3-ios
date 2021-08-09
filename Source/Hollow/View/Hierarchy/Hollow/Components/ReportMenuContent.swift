//
//  ReportMenuContent.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/4.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults
import HollowCore

struct ReportMenuContent: View {
    @ObservedObject var store: HollowDetailStore
    var permissions: [PostPermissionType]
    var commentId: Int?
    @State var reason: String = ""
    
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
                            showConfirm(
                                type: .fold,
                                reason: tag,
                                title: String(format: NSLocalizedString("REPORT_MENU_ALERT_CONFIRM_FOLD_TITLE%@", comment: ""), tag)
                            )
                        }
                    }
                }, label: {
                    Label(text, systemImage: "tag")
                })
            }
            if showReportDelete {
                let text = NSLocalizedString("REPORT_MENU_REPORT_DELETE", comment: "")
                button(text: text, systemImageName: "exclamationmark.bubble", action: {
                    showTextField(
                        type: .report,
                        title: NSLocalizedString("REPORT_MENU_ALERT_REPORT_DELETE_ENTER_MSG_TITLE", comment: ""),
                        message: NSLocalizedString("REPORT_MENU_ALERT_REPORT_DELETE_ENTER_MSG_MSG", comment: "")
                        
                    )
                })
            }
            
            if showRemove {
                let text = NSLocalizedString("REPORT_MENU_DELETE", comment: "")
                button(text: text, systemImageName: "arrow.uturn.backward", action: {
                    showConfirm(
                        type: .delete,
                        reason: "",
                        title: NSLocalizedString("REPORT_MENU_ALERT_CONFIRM_REPORT_DELETE_TITLE", comment: "")
                    )
                })
            }
            if showAdminSetTag {
                let text = NSLocalizedString("REPORT_MENU_ADMIN_SET_TAG", comment: "")
                Menu(content: {
                    Menu(NSLocalizedString("REPORT_MENU_ADMIN_SET_TAG_EXISTED", comment: "")) {
                        ForEach(reportableTags, id: \.self) { tag in
                            Button(tag) {
                                showConfirm(
                                    type: .setTag,
                                    reason: tag,
                                    title: NSLocalizedString("REPORT_MENU_ALERT_CONFIRM_ADMIN_SET_TAG_TITLE", comment: "")
                                )
                            }
                        }
                    }
                    Button(NSLocalizedString("REPORT_MENU_ADMIN_SET_TAG_CUSTOM", comment: "")) {
                        showTextField(
                            type: .setTag,
                            title: NSLocalizedString("REPORT_MENU_ALERT_ADMIN_SET_TAG_CUSTOM_ENTER_MSG_TITLE", comment: ""),
                            message: NSLocalizedString("REPORT_MENU_ALERT_ADMIN_SET_TAG_CUSTOM_ENTER_MSG_MSG", comment: "")
                        )
                    }
                    Button(NSLocalizedString("REPORT_MENU_ADMIN_SET_TAG_REMOVE", comment: "")) {
                        showConfirm(
                            type: .setTag,
                            reason: "",
                            title: NSLocalizedString("REPORT_MENU_ALERT_CONFIRM_ADMIN_SET_TAG_REMOVE_TITLE", comment: "")
                        )
                    }
                } , label: {
                    Label(text, systemImage: "tag.fill")
                })
            }
            if showAdminRemove {
                let text = NSLocalizedString("REPORT_MENU_ADMIN_REMOVE", comment: "")
                button(text: text, systemImageName: "trash.fill", action: {
                    showTextField(
                        type: .delete,
                        title: NSLocalizedString("REPORT_MENU_ALERT_ADMIN_REMOVE_ENTER_MSG_TITLE", comment: ""),
                        message: NSLocalizedString("REPORT_MENU_ALERT_ADMIN_REMOVE_ENTER_MSG_MSG", comment: "")
                    )
                })
            }
            
            if showAdminDeleteBan {
                let text = NSLocalizedString("REPORT_MENU_ADMIN_DELETE_BAN", comment: "")
                button(text: text, systemImageName: "mic.slash.fill", action: {
                    showTextField(
                        type: .deleteBan,
                        title: NSLocalizedString("REPORT_MENU_ALERT_ADMIN_DELETE_BAN_ENTER_MSG_TITLE", comment: ""),
                        message: NSLocalizedString("REPORT_MENU_ALERT_ADMIN_DELETE_BAN_ENTER_MSG_MSG", comment: "")
                    )
                })
            }
            
            if showAdminUndeleteUnban {
                let text = NSLocalizedString("REPORT_MENU_ADMIN_UNDELETE_UNBAN", comment: "")
                button(text: text, systemImageName: "mic.fill", action: {
                    showTextField(
                        type: .undeleteUnban,
                        title: NSLocalizedString("REPORT_MENU_ALERT_ADMIN_UNDELETE_UNBAN_ENTER_MSG_TITLE", comment: ""),
                        message: NSLocalizedString("REPORT_MENU_ALERT_ADMIN_UNDELETE_UNBAN_ENTER_MSG_MSG", comment: "")
                    )
                })
            }
            
            if showAdminUnban {
                let text = NSLocalizedString("REPORT_MENU_ADMIN_UNBAN", comment: "")
                button(text: text, systemImageName: "trash.slash.fill", action: {
                    showTextField(
                        type: .unban,
                        title: NSLocalizedString("REPORT_MENU_ALERT_ADMIN_UNBAN_ENTER_MSG_TITLE", comment: ""),
                        message: NSLocalizedString("REPORT_MENU_ALERT_ADMIN_UNBAN_ENTER_MSG_MSG", comment: "")

                    )
                })
            }
        }
    }
    
    private func button(text: String, systemImageName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(text, systemImage: systemImageName)
        }
    }
    
    private func showConfirm(type: PostPermissionType, reason: String, title: String) {
        let alertView = StyledAlert(presented: .constant(true), selfDismiss: true, title: title, message: nil, buttons: [
            .init(text: NSLocalizedString("REPORT_MENU_ALERT_CONFIRM", comment: ""), style: .default, action: {
                store.report(commentId: commentId, type: type, reason: reason)
            }),
            .cancel
        ])
        
        IntegrationUtilities.presentView(presentationStyle: .overFullScreen, transitionStyle: .crossDissolve, content: { alertView })
    }
    
    private func showTextField(type: PostPermissionType, title: String, message: String?) {
        let alertView = AccessoryStyledAlert(presented: .constant(true), selfDismiss: true, title: title, message: message, buttons: [
            .init(text: NSLocalizedString("REPORT_MENU_ALERT_CONFIRM", comment: ""), style: .default, action: {
                store.report(commentId: commentId, type: type, reason: reason)
                self.reason = ""
            }),
            .cancel(action: { self.reason = "" })
        ], accessoryView: {
            TextEditor(text: $reason)
                .multilineTextAlignment(.leading)
                .frame(maxHeight: 100)
                .padding(7)
                .background(Color.uiColor(.secondarySystemFill))
                .roundedCorner(10)
                .accentColor(.tint)
        })

        IntegrationUtilities.presentView(presentationStyle: .overFullScreen, transitionStyle: .crossDissolve, content: { alertView })
    }
}
