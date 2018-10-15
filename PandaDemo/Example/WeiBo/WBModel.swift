//
//  WBModel.swift
//  PandaDemo
//
//  Created by nangezao on 2018/7/31.
//  Copyright © 2018 Tang Nan. All rights reserved.
//

import Foundation
import Kingfisher
import Panda
import Layoutable

struct WBImageResource: Resource {
  
  public let cacheKey: String

  public let downloadURL: URL
  
  public let keepSize: Bool
  
  public let size: CGSize
  
  public init(downloadURL: URL, cacheKey: String? = nil, keepSize: Bool = false,size: CGSize = .zero) {
    self.downloadURL = downloadURL
    self.cacheKey = cacheKey ?? downloadURL.absoluteString
    self.keepSize = keepSize
    self.size = size
  }
}

class WBStatusViewModel{
  
  var name: NSAttributedString? = nil
  var title: String? = nil
  var textAttributeText: NSAttributedString? = nil
  var retweetAttributeText: NSAttributedString? = nil
  var sourceAttributeText: NSAttributedString = NSAttributedString(string: "")
  var avatarImageUrl: URL? = nil
  var avatarBadge: UIImage? = nil
  var height: CGFloat = 0
  var images: [WBImageResource]? = nil
  var picBackground: URL? = nil
  var cardText: NSAttributedString? = nil
  var cardImage: URL? = nil
  var layoutValues: LayoutValues? = nil
  var commentText: String = "评论"
  var repostText: String = "转发"
  var likeText: String = "点赞"
  var tag: WBTag?
  var cardType: WBStatusCardType = .none
  var pagPic: URL? = nil
  
  init(status: WBStatus) {

    name = WBStatusHelper.attributedName(for: status.user)
    
    if let title = status.title?.text{
      self.title = title
    }
    
    let attributeTitle = WBStatusHelper.text(with: status, isRetweet: false, fontSize: 17, textColor: UIColor(hex6: 0x333333))
    textAttributeText = attributeTitle
    
    var pics: [WBPicture]? = nil
    if let retweeted = status.retweeted{
      let attributeRetweet = WBStatusHelper.text(with: retweeted, isRetweet: true, fontSize: 16, textColor: UIColor(hex6: 0x5d5d5d))
      retweetAttributeText = attributeRetweet
      
      pics = retweeted.pics
      
    }else{
      pics = status.pics
    }
    
    images = pics?.map{  (pict) in
      return WBImageResource(downloadURL: pict.bmiddle.url,
                             keepSize: pict.keepSize,
                             size: CGSize(width: CGFloat(pict.bmiddle.width),
                                          height: CGFloat(pict.bmiddle.height)))
    }
    
    sourceAttributeText = WBStatusHelper.source(for: status)
    
    switch status.user.userVerifyType {
    case .standard:
      avatarBadge = UIImage(named: "avatar_vip")
    case .club:
      avatarBadge = UIImage(named: "avatar_grassroot")
    default:
      avatarBadge = nil
    }
    
    avatarImageUrl = status.user.profileImageURL
    
    if let url = status.picBg{
      picBackground = URL(string: url.replacingOccurrences(of: "_y.png", with: "_os7.png"))
    }
    
    if let imageURL = status.pageInfo?.pagePic{
      cardImage = imageURL
    }
    
    if let pageInfo = status.pageInfo{
      if pageInfo.type == 11 && pageInfo.objectType == "video"{
        cardType = .video
        pagPic = pageInfo.pagePic
      }else{
        cardType = .normal
        cardText = cardTextFrom(pageInfo)
      }
    }
    
    if let tags = status.tagStruct{
      tag = tags.first
    }
    repostText = shortedDescForCount(status.repostsCount,"转发")
    commentText = shortedDescForCount(status.commentsCount,"评论")
    likeText = shortedDescForCount(status.attitudesCount,"点赞")
  }
  
  func shortedDescForCount(_ count: Int32,_ defaultText: String = "") -> String{
    if count <= 0{
      return defaultText
    }
    if count < 9999{
      return "\(count)"
    }
    
    if count < 999999{
      return "\(count/10000)万"
    }
    
    return "\(count/10000000)千万"
  }
  
  func cardTextFrom(_ pageInfo: WBPageInfo) -> NSAttributedString{
    let attributePage = NSMutableAttributedString()
    if let title = pageInfo.pageTitle{
      let attributeTitle = NSMutableAttributedString(string: title,
                                                     attributes:
        [.font: UIFont.systemFont(ofSize: 16),
         .foregroundColor: UIColor.init(hex6: 0x333333)])
      attributePage.append(attributeTitle)
    }
    
    if let desc = pageInfo.pageDesc{
      attributePage.append(NSAttributedString(string: "\n"))
      let attributeDesc = NSMutableAttributedString(string: desc,
                                                    attributes:
        [.font: UIFont.systemFont(ofSize: 12),
         .foregroundColor: UIColor.init(hex6: 0x333333)])
      attributePage.append(attributeDesc)
    }else if let content = pageInfo.content2{
      attributePage.append(NSAttributedString(string: "\n"))
      let attributeDesc = NSMutableAttributedString(string: content,
                                                    attributes:
        [.font: UIFont.systemFont(ofSize: 12),
         .foregroundColor: UIColor.init(hex6: 0x333333)])
      attributePage.append(attributeDesc)
    } else if let content = pageInfo.content3 {
      attributePage.append(NSAttributedString(string: "\n"))
      let attributeDesc = NSMutableAttributedString(string: content,
                                                    attributes:
        [.font: UIFont.systemFont(ofSize: 12),
         .foregroundColor: UIColor.init(hex6: 0x333333)])
      attributePage.append(attributeDesc)
    }
    
    if let tips = pageInfo.tips {
      attributePage.append(NSAttributedString(string: "\n"))
      let attributeDesc = NSMutableAttributedString(string: tips,
                                                    attributes:
        [.font: UIFont.systemFont(ofSize: 12),
         .foregroundColor: UIColor.init(hex6: 0x333333)])
      attributePage.append(attributeDesc)
    }
    let paraStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
    paraStyle.lineBreakMode = .byTruncatingTail
    paraStyle.maximumLineHeight = 20
    paraStyle.minimumLineHeight = 20
    attributePage.addAttribute(.paragraphStyle, value: paraStyle, range: NSRange(location: 0, length: attributePage.length))
    
    return attributePage
  }
}
