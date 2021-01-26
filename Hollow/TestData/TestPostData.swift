//
//  TestPostData.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

#if DEBUG
import SwiftUI
let testText = """
树洞新功能投票
洞友们好，我们目前正在进行下一代树洞的开发。我们计划在新版树洞中新增用户性别展示功能，现就这一功能征求意见。该功能的具体描述如下：
每位用户可以设置一次自己的性别，设置后无法更改。性别选项有三个：男，女以及保密。
所有树洞和评论都会展示发布者的性别。
可在设置中关闭性别展示功能。关闭后，该终端将不展示任何内容的发布者性别。
支持新增该功能请回复1，反对新增该功能请回复2，其他观点请直接评论。投票有效时间为24h。支持和反对的洞友也可以留下评论，我们会认真考虑洞友们提出的意见和建议的，谢谢大家
"""

let testText2 = "第一次来音乐图书馆。在哪里开机呢？好尴尬呀"

let testText3 = """
甘肃通报敦煌防护林被毁调查：未发现林地大面积减少情况
据人民日报客户端消息 1月26日上午，甘肃省举行敦煌市阳关林场防护林被毁问题调查情况新闻发布会，调查组在会上通报：

经过历年卫星遥感资料比对分析，2000年以来，未发现林地大面积减少情况。2018年至2019年间卫星遥感数据显示，林场范围内有3处面积约42.98亩的疑似林地破坏图斑，经现场核查，主要是阳关林场进行基础设施改造，新修砂石道路和U型灌渠、铺设管线灌线造成的，未发现砍树开垦葡萄园地情况。根据最新的卫星遥感数据测算，阳关林场区域内现有防护林面积6979亩。

媒体反映的“2万多亩林地”实际上是林场经营管理面积，“1.3万亩生态林面积”实际上包括林场乔木林地、灌木林地、苗圃地、葡萄园地和部分未成林造林地，以及道路、水域、建设用地等林场生产生活用地。

阳关林场经营管理区域大致可分为西南和东北两大片，这1.33万亩林地实际上是西南方位的这一片区域，林场范围内长期以来只有6000余亩防护林，基本都位于林场西南片区。

根据调查，2006年林场承包改制时实有葡萄园地面积3304亩。通过卫星遥感资料比对，2006年至2011年间，葡萄园地面积没有发生变化。2012年，承租林地的敦煌葡萄酒业公司通过残次林改造，新建葡萄园地400亩。至此，林场实有葡萄园地面积3704亩。2013年以来，葡萄园面积再无增加。

同时，调查组还查阅了三次全国土地调查数据。1999年“一调”显示，阳关林场有水浇地1488亩，果园2688亩，共计4176亩；2009年“二调”显示，阳关林场有水浇地2亩，果园4452亩，共计4454亩；2019年“三调”显示，林场有水浇地19亩，果园4706亩，共计4725亩。从1999年至2019年，水浇地和果园面积增加549亩。扣除道路、沟渠、田埂等占地因素，土地调查数据和卫星遥感资料比对数据基本一致。

调查组通过现场调查还掌握到，阳关林场管理比较粗放，日常工作存在薄弱环节，导致媒体反映的一些问题的发生。一是林木抚育工作不够规范。二是林木更新采伐管理不够到位。三是水资源节约利用不够。四是存在违规承租和协调不力问题。其中，近年来，敦煌飞天公司自身发展利益与群众利益以及生态保护要求的分歧越发突出，并出现矛盾纠纷，省、市多次组织工作组调查并指导问题整改和矛盾化解工作，但因飞天公司诉求过高，导致矛盾无法彻底化解，问题仍未整改到位。

调查组表示，下一步将举一反三，继续严格排查，针对存在的问题，提出整改措施，压实整改责任，确保全面整改到位，同时对相关责任人依法依纪严肃处理。
"""

let testPostData: PostData = .init(attention: true, deleted: false, likeNumber: 21, permissions: [], postId: 198431, replyNumber: 12, tag: "", text: testText, type: .vote, hollowImage: .init(placeholder: (1760, 1152), image: UIImage(named: "test")), vote: .init(voted: true, votedOption: "不同意", voteData: [
    .init(title: "同意", voteCount: 24),
    .init(title: "不同意", voteCount: 154)
]), comments: testComments)

let testPostData2: PostData = .init(attention: true, deleted: false, likeNumber: 21, permissions: [], postId: 198432, replyNumber: 12, tag: "", text: testText2, type: .vote, hollowImage: .init(placeholder: (1760, 1152), image: UIImage(named: "test.long")), vote: .init(voted: true, votedOption: "不同意", voteData: [
    .init(title: "同意", voteCount: 24),
    .init(title: "不同意", voteCount: 154)
]), comments: testComments)

let testPostData3: PostData = .init(attention: true, deleted: false, likeNumber: 21, permissions: [], postId: 198433, replyNumber: 12, tag: "", text: testText3, type: .vote, hollowImage: .init(placeholder: (1760, 1152), image: UIImage(named: "test.phone")), vote: .init(voted: true, votedOption: "", voteData: [
    .init(title: "同意", voteCount: -1),
    .init(title: "不同意", voteCount: -1)
]), comments: testComments)


let testPosts = [
    testPostData,
    testPostData2,
    testPostData3
]
#endif
