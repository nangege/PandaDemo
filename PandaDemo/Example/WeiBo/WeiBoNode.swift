//
//  WeiBoNode.swift
//  Cassowary
//
//  Created by Tang,Nan(MAD) on 2018/2/26.
//  Copyright © 2018年 nange. All rights reserved.
//

import UIKit
import Panda
import Layoutable

import Kingfisher

class StatusNode: ViewNode{
  let titleNode = TitleNode()
  let vipBackground = ImageNode()
  let topBackground = ViewNode()
  let bottomBackground = ViewNode()
  
  let menuButton: ButtonNode = {
    let button = ButtonNode()
    button.setImage(UIImage(named: "timeline_icon_more"), for: .normal)
    button.setImage(UIImage(named: "timeline_icon_more_highlighted"), for: .highlighted)
    return button
  }()
  
  let imageViews: [ImageNode] = (0..<9)
    .map{ index in
      let node = ImageNode()
      node.addAction(for: .touchUpInside) { (node, event) in
        print("ImageNode \(index) \(event)")
      }
      return node
  }
  
  let imageContainer = FlowLayoutNode()
  
  let textNode = TextNode()
  let profileNode = ProfileNode()
  let toolBarNode = ToolBarNode()
  let retweetBackground = ViewNode()
  let retweetTextNode = TextNode()
  let cardNode = CardNode()

  var retYAxisConstraint: [LayoutConstraint]!
  
  override init() {
    super.init()
    initNodes()
    layout()
  }
  
  func initNodes(){
    let bgColor = UIColor(white: 0, alpha: 0.08)
    topBackground.backgroundColor = bgColor
    bottomBackground.backgroundColor = bgColor
    
    textNode.numberOfLines = -1
    textNode.userInteractionEnabled = true
    
    vipBackground.contentMode = .scaleAspectToFit
    
    retweetTextNode.numberOfLines = -1
    retweetBackground.backgroundColor = UIColor(hex6: 0xf7f7f7)
    
    addSubnodes([topBackground,titleNode,profileNode,vipBackground,
                 menuButton,textNode,retweetBackground,imageContainer,
                 cardNode,toolBarNode,bottomBackground])
    
    retweetBackground.addSubnode(retweetTextNode)
    imageContainer.addSubnodes(imageViews)
  }
  
  func layout(){
    
    let sideInset: CGFloat = 10.0
    let topInset: CGFloat = 8.0
    let bottomInset: CGFloat = 2.0
    
    [self,topBackground].equal(.left,.right,.top)
    topBackground.height == topInset
    
    [titleNode,vipBackground].forEach{ $0.top == top + topInset}
    [self,titleNode,vipBackground].equal(.left,.right)
    
    profileNode.xSide == self
    profileNode.top == titleNode.bottom
    
    vipBackground.height == 14
    
    textNode.xSide == xSide.insets(sideInset)
    textNode.top == profileNode.bottom
    
    menuButton.size == (30,30)
    menuButton.topRight == topRight.offset((3, -5))
    
    retweetBackground.xSide == self + sideInset
    retweetBackground.top == textNode.bottom + 10
    
    retweetTextNode.xSide == retweetBackground
    retYAxisConstraint = retweetTextNode.ySide == retweetBackground + 5
    
    imageContainer.xSide == self + sideInset
    imageContainer.top == retweetBackground.bottom
    
    cardNode.xSide == xSide.insets(sideInset)
    cardNode.top == imageContainer.bottom
    
    toolBarNode.top == cardNode.bottom + 10
    toolBarNode.bottom == bottom - bottomInset
    toolBarNode.xSide == self
    toolBarNode.height == 35
    [self,bottomBackground].equal(.left,.right,.bottom)
    bottomBackground.height == bottomInset
  }
  
  func update(_ status: WBStatusViewModel, needLayout: Bool = true){
    
    titleNode.title = status.title
    textNode.attributeText = status.textAttributeText
    retweetTextNode.attributeText = status.retweetAttributeText
    profileNode.updateFor(status)
    
    let showCard = !layoutImages(status.images)
    
    if status.retweetAttributeText == nil{
      imageContainer.backgroundColor = .white
    }else{
      imageContainer.backgroundColor = UIColor(hex6: 0xf7f7f7)
    }
    
    if let url = status.picBackground{
      vipBackground.kf.setImage(with: ImageResource(downloadURL: url))
      vipBackground.hidden = false
    }else{
      vipBackground.hidden = true
    }
    
    if showCard,let cardText = status.cardText{
      cardNode.textNode.attributeText = cardText
      cardNode.hidden = false
    
      if let url = status.cardImage{
        cardNode.imageNode.hidden = false
        cardNode.imageNode.kf.setImage(with: ImageResource(downloadURL: url))
      }else{
        cardNode.imageNode.hidden = true
      }
    }else{
      cardNode.hidden = true
    }
    
    if needLayout{
      if let retweet = status.retweetAttributeText ,retweet.length > 0{
        retYAxisConstraint[0].constant = 5
        retYAxisConstraint[1].constant = -5
      }else{
        retYAxisConstraint[0].constant = 0
        retYAxisConstraint[1].constant = 0
      }
      imageContainer.invalidateIntrinsicContentSize()
    }
  }
  
  func layoutImages(_ images: [WBImageResource]?) -> Bool{
    
    var showImage = false
    
    if let images = images{
      
      if images.count == 1{
        let image = images[0]
        if image.keepSize || image.size.width < 1 || image.size.height < 1{
          imageContainer.columnCount = 2
          imageContainer.lineSpace = 0
          imageContainer.aspectRatio = 1
        }else{
          imageContainer.columnCount = 2
          imageContainer.lineSpace = 0
          imageContainer.itemSpace = 0
          imageContainer.aspectRatio = image.size.height/image.size.width
        }
      }else{
        imageContainer.columnCount = 3
        imageContainer.lineSpace = 4
        imageContainer.itemSpace = 4
        imageContainer.aspectRatio = 1
      }
      
      showImage = true
      imageContainer.hidden = false
      for (index,node) in imageViews.enumerated(){
        
        if index < images.count{
          let url = images[index]
          node.hidden = false
          node.kf.setImage(with: url)
        }else{
          node.hidden = true
        }
      }
    }else{
      imageContainer.hidden = true
      imageViews.forEach{ $0.hidden = true}
    }
    return showImage
  }
}

class TitleNode: ViewNode{
  
  let titleNode: TextNode = {
    let node = TextNode()
    node.font = UIFont.systemFont(ofSize: 14)
    node.textColor = UIColor(hex6: 0x929292)
    return node
  }()
  
  let titleLine: ViewNode = {
    let node = ViewNode()
    node.backgroundColor = UIColor(hex6: 0xe8e8e8)
    return node
  }()
  
  var title: String?{
    didSet{
      invalidateIntrinsicContentSize()
      titleNode.text = title ?? ""
    }
  }
  
  override init() {
    super.init()
    addSubnodes([ titleNode, titleLine])
    
    titleNode.left == left + 12
    titleNode.right <= right - 88
    titleNode.centerY == centerY
    
    [self,titleLine].equal(.left,.right,.bottom)
    titleLine.height == 1/UIScreen.main.scale
  }
  
  override var itemIntrinsicContentSize: CGSize{
    if title != nil{
      return CGSize(width: InvalidIntrinsicMetric,height: 38)
    }else{
      return CGSize(width: InvalidIntrinsicMetric,height: 0)
    }
  }
}

class ProfileNode: ViewNode{
  
  let nameNode: TextNode = {
    let nameNode = TextNode()
    nameNode.font = UIFont.systemFont(ofSize: 16)
    nameNode.textColor = UIColor(hex6: 0x333333)
    return nameNode
  }()
  
  let avatarNode = ImageNode()
  let badgeNode = ImageNode()

  let sourceNode = TextNode()
  
  let background = ImageNode()
  let arrowNode = ButtonNode()
  let followNode = ButtonNode()
  
  override init() {
    super.init()
    addSubnode(avatarNode)
    addSubnode(badgeNode)
    addSubnode(nameNode)
    addSubnode(sourceNode)
    
    avatarNode.topLeft == topLeft.offset((12,15))
    avatarNode.size == (40, 40)
    
    avatarNode.processor = Panda.RoundImageProcessor(radius: 20)
    avatarNode.image = UIImage(named: "avatar")
    
    badgeNode.size == (14, 14)
    badgeNode.center == avatarNode.bottomRight.offset((-6,-6))

    nameNode.top == 15
    nameNode.left == avatarNode.right + 14
    nameNode.right <= right
    
    sourceNode.topLeft == nameNode.bottomLeft + (4,0)
    sourceNode.bottom == bottom - 10
    
    arrowNode.right == right - 20
    arrowNode.top == 10
  }
  
  func updateFor(_ status: WBStatusViewModel){
    nameNode.text = status.name
    sourceNode.attributeText = status.sourceAttributeText
    
    if let image = status.avatarBadge{
      badgeNode.image = image
      badgeNode.hidden = false
    }else{
      badgeNode.hidden = true
    }
    
    avatarNode.kf.setImage(with: ImageResource(downloadURL: status.avatarImageUrl!))
  }
  
}


class CardNode: ViewNode{
  let imageNode = ImageNode()
  let buttonNode = ButtonNode()
  let textNode = TextNode()
  let badgeNode = ImageNode()
  
  override init() {
    super.init()
    backgroundColor = UIColor(hex6: 0xf7f7f7)
    textNode.numberOfLines = 3

    addSubnodes([imageNode,
                 textNode,
                 badgeNode,
                 buttonNode])

    [self,imageNode,badgeNode].equal(.left,.top)
    imageNode.size == (70, 70)
    badgeNode.size == (25, 25)

    textNode.left == imageNode.right + 10
    textNode.centerY == imageNode.centerY
    textNode.right <= right - 10
  }
  
  override var hidden: Bool{
    didSet{
        invalidateIntrinsicContentSize()
    }
  }
  
  override var itemIntrinsicContentSize: CGSize{
    if hidden{
      return CGSize(width: InvalidIntrinsicMetric,height: 0.0)
    }else{
      return CGSize(width: InvalidIntrinsicMetric,height: 70.0)
    }
  }
}


class TagNode: ViewNode{
  let button = ButtonNode()
  let textNode = TextNode()
  let imageNode = ImageNode()
  
  override init() {
    super.init()
    addSubnodes([button,textNode,imageNode])
  }
}

class ToolBarNode: ViewNode{
  var repostButton: ButtonNode!
  var commonButton: ButtonNode!
  var likeButton: ButtonNode!
  let vertical1 = ViewNode()
  let vertical2 = ViewNode()
  let topLine = ViewNode()
  let bottomLine = ViewNode()
  
  private let container: StackLayoutNode = {
    let container = StackLayoutNode()
    container.distribution = .fillEqually
    container.alignment = .fill
    container.axis = .horizontal
    container.space = 1
    return container
  }()
  
  private let buttons: [ButtonNode] = {
    let infos = [("转发","timeline_icon_retweet"),
                 ("评论","timeline_icon_comment"),
                 ("点赞","timeline_icon_unlike")]
    
    return infos.map { (title,image) -> ButtonNode in
      let button = ButtonNode()
      button.setTitle(title, for: .normal)
      button.setImage(UIImage(named: image), for: .normal)
      button.layoutAxis = .horizontal
      button.textNode.font = UIFont.systemFont(ofSize: 14)
      button.textNode.textColor = UIColor(hex6: 0x929292)
      button.setBackgroundColor(color: UIColor(hex6: 0xf0f0f0), for: .highlighted)
      button.setBackgroundColor(color: .white, for: .normal)
      button.textFirst = false
      
      button.addAction(for: .touchDown, action: {(button,action) in
        print("\(button) \(action)")
      })
      return button
    }
  }()
  
  override init() {
    super.init()
    
    repostButton = buttons[0]
    commonButton = buttons[1]
    likeButton = buttons[2]
    container.addArrangedSubnodes(buttons)
    addSubnode(container)
    
    container.edge == self
    
    repostButton.addSubnode(vertical1)
    commonButton.addSubnode(vertical2)
    addSubnode(topLine)
    addSubnode(bottomLine)
    
    let lineColor = UIColor(hex6: 0xe8e8e8)
    [vertical1,vertical2].forEach { (node) in
      node.backgroundColor = lineColor
      let superNode = node.superNode!
      node.centerY == superNode.centerY
      node.left == superNode.right
      node.size == (1,15)
    }
    
    [topLine,bottomLine].forEach { (node) in
      node.backgroundColor = lineColor
      node.xSide == self
      node.height == 1/UIScreen.main.scale
    }

    topLine.top == top
    bottomLine.bottom == bottom
  }
}
