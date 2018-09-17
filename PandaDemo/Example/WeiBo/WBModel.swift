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
  
  var name: String = ""
  var titleAttributeText: NSAttributedString? = nil
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
  
  init(status: WBStatus) {

    name = nameFor(status: status)
    
    let attributeTitle = WBStatusHelper.text(with: status, isRetweet: false, fontSize: 17, textColor: UIColor(hex6: 0x333333))
    titleAttributeText = attributeTitle
    
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
      updateFor(pageInfo: pageInfo)
    }
  }
  
  func nameFor(status: WBStatus) -> String{
    var name = status.user!.remark
    if name == nil || name!.count == 0{
      name = status.user!.screenName
    }
    
    if name == nil || name!.count == 0{
      name = status.user!.name
    }
    return name ?? ""
  }
  
  func updateFor(pageInfo: WBPageInfo){
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
    }
    cardText = attributePage
  }
}
