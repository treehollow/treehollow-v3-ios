//
//  GenericRequests.swift
//  GenericRequests
//
//  Created by liang2kl on 2021/9/14.
//  Copyright © 2021 treehollow. All rights reserved.
//

import HollowCore

typealias PostListRequest = PostListGenericRequest<HollowCore.PostListRequest>

typealias SystemMessageRequest = DefaultGenericRequest<HollowCore.SystemMessageRequest>

typealias AttentionListRequest = PostListGenericRequest<HollowCore.AttentionListRequest>

typealias RandomListRequest = PostListGenericRequest<HollowCore.RandomListRequest>

typealias AttentionListSearchRequest = PostListGenericRequest<HollowCore.AttentionListSearchRequest>

typealias GetConfigRequest = DefaultGenericRequest<HollowCore.GetConfigRequest>

typealias GetPushRequest = DefaultGenericRequest<HollowCore.GetPushRequest>

typealias SetPushRequest = DefaultGenericRequest<HollowCore.SetPushRequest>

typealias LogoutRequest = DefaultGenericRequest<HollowCore.LogoutRequest>

typealias EmailCheckRequest = DefaultGenericRequest<HollowCore.EmailCheckRequest>

typealias DeviceListRequest = DefaultGenericRequest<HollowCore.DeviceListRequest>

typealias UpdateDeviceTokenRequest = DefaultGenericRequest<HollowCore.UpdateDeviceTokenRequest>

typealias DeviceTerminationRequest = DefaultGenericRequest<HollowCore.DeviceTerminationRequest>

typealias ChangePasswordRequest = DefaultGenericRequest<HollowCore.ChangePasswordRequest>

typealias UnregisterCheckEmailRequest = DefaultGenericRequest<HollowCore.UnregisterCheckEmailRequest>

typealias UnregisterRequest = DefaultGenericRequest<HollowCore.UnregisterRequest>

typealias ReportPostRequest = DefaultGenericRequest<HollowCore.ReportPostRequest>

typealias ReportCommentRequest = DefaultGenericRequest<HollowCore.ReportCommentRequest>

typealias EditAttentionRequest = DefaultGenericRequest<HollowCore.EditAttentionRequest>

typealias SendPostRequest = DefaultGenericRequest<HollowCore.SendPostRequest>

typealias SendCommentRequest = DefaultGenericRequest<HollowCore.SendCommentRequest>

typealias PostListRequestGroup = PostListGenericRequest<HollowCore.PostListRequestGroup>

typealias ReportRequestGroup = DefaultGenericRequest<HollowCore.ReportRequestGroup>
