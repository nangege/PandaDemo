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

class WBStatusCardNode: ViewNode{
  let imageNode = ImageNode()
  let buttonNode = ButtonNode()
  let textNode = TextNode()
  let badgeNode = ImageNode()
  
  override init() {
    super.init()
    backgroundColor = UIColor(hex6: 0xf7f7f7)
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
}

class StatusNode: ViewNode{
  let contentNode = ViewNode()
  let vipBackground = ImageNode()
  let menuButton = ButtonNode()
  let titleNode = TextNode()
  let profileNode = ProfileNode()
  let toolBarNode = ToolBarNode()
  let retweetBackground = ViewNode()
  let retweetTextNode = TextNode()
  let cardNode = WBStatusCardNode()
  
  var imageViews = [ImageNode]()
  var imageContainer = FlowLayoutNode()
  
  var cardHeightConstraint: LayoutConstraint!
  var retTop: LayoutConstraint!
  var retBottom:LayoutConstraint!
  
  override init() {
    super.init()
    addSubnode(profileNode)
    addSubnode(vipBackground)
    addSubnode(toolBarNode)
    addSubnode(menuButton)
    
    addSubnode(titleNode)
    addSubnode(retweetBackground)
    addSubnode(imageContainer)
    addSubnode(cardNode)
    
    titleNode.numberOfLines = -1
    
    menuButton.setImage(UIImage(named: "timeline_icon_more"), for: .normal)
    menuButton.setImage(UIImage(named: "timeline_icon_more_highlighted"), for: .highlighted)

    retweetBackground.addSubnode(retweetTextNode)
    
    for _ in 0..<9 {
      imageViews.append(ImageNode())
    }
    
    imageViews.forEach{ imageContainer.addSubnode($0) }
    
    [self,profileNode,vipBackground].equal(.top,.left,.right)
    
    vipBackground.contentMode = .scaleAspectToFit
    vipBackground.height == 44
    
    titleNode.xSide == xSide.insets(10)
    titleNode.top == profileNode.bottom + 10
    
    menuButton.size == (30,30)
    menuButton.topRight == topRight.offset((3, -5))
    
    retweetBackground.xSide == self + 10
    retweetBackground.top == titleNode.bottom + 10
    
    retweetTextNode.xSide == retweetBackground
    let topBottomConstraint = retweetTextNode.ySide == retweetBackground + 5
    retTop = topBottomConstraint[0]
    retBottom = topBottomConstraint[1]
    retweetTextNode.numberOfLines = -1
    retweetBackground.backgroundColor = UIColor(hex6: 0xf7f7f7)
    
    imageContainer.xSide == self + 10
    imageContainer.top == retweetBackground.bottom
    
    cardNode.xSide == self + 10
    cardNode.top == imageContainer.bottom
    cardHeightConstraint = cardNode.height == 70
    
    toolBarNode.top == cardNode.bottom + 10
    [toolBarNode, self].equal(.left,.right,.bottom)
    toolBarNode.height == 35
  }
  
  func update(_ status: WBStatusViewModel, needLayout: Bool = true){
    
    profileNode.nameNode.text = status.name
    
    titleNode.attributeText = status.titleAttributeText
    retweetTextNode.attributeText = status.retweetAttributeText
    profileNode.sourceNode.attributeText = status.sourceAttributeText
    
    if let image = status.avatarBadge{
      profileNode.badgeNode.image = image
      profileNode.badgeNode.hidden = false
    }else{
      profileNode.badgeNode.hidden = true
    }

    profileNode.avatarNode.kf.setImage(with: ImageResource(downloadURL: status.avatarImageUrl!))
    
    var showCard = true
    
    if let images = status.images{
      
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
      
      showCard = false
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
        retTop.constant = 5
        retBottom.constant = -5
      }else{
        retTop.constant = 0
        retBottom.constant = 0
      }
      imageContainer.invalidateIntrinsicContentSize()
      cardHeightConstraint?.constant = cardNode.hidden ? 0 : 70
    }
  }
  
}

class ProfileNode: ViewNode{
  
  lazy var nameNode: TextNode = {
    let nameNode = TextNode()
    nameNode.font = UIFont.systemFont(ofSize: 16)
    nameNode.textColor = UIColor(hex6: 0x333333)
    nameNode.text = "hehe"
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

    nameNode.top == top + 15
    nameNode.left == avatarNode.right + 14
    nameNode.right <= right
    
    sourceNode.topLeft == nameNode.bottomLeft + (10,0)
    sourceNode.bottom == bottom - 10
    
    arrowNode.right == right - 20
    arrowNode.top == top + 10
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
  let repostButton = ButtonNode()
  let commonButton = ButtonNode()
  let likeButton = ButtonNode()
  let vertical1 = ViewNode()
  let vertical2 = ViewNode()
  let topLine = ViewNode()
  let bottomLine = ViewNode()
  
  private let container = StackLayoutNode()
  
  override init() {
    super.init()
    container.distribution = .fillEqually
    container.alignment = .fill
    container.axis = .horizontal
    container.space = 1
    
    addSubnode(container)
    
    container.edge == self
    
    let lineColor = UIColor(hex6: 0xe8e8e8)
    
    container.addArrangedSubnode(repostButton)
    container.addArrangedSubnode(commonButton)
    container.addArrangedSubnode(likeButton)
    repostButton.addSubnode(vertical1)
    commonButton.addSubnode(vertical2)
    addSubnode(topLine)
    addSubnode(bottomLine)
    
    [vertical1,vertical2].forEach { (node) in
      node.backgroundColor = lineColor
      let superNode = node.superNode!
      node.centerY == superNode.centerY
      node.left == superNode.right
      node.size == (1,15)
    }
    
    repostButton.setTitle("转发", for: .normal)
    repostButton.setImage(UIImage(named: "timeline_icon_retweet"), for: .normal)
    
    commonButton.setTitle("评论", for: .normal)
    commonButton.setImage(UIImage(named: "timeline_icon_comment"), for: .normal)

    likeButton.setTitle("点赞", for: .normal)
    likeButton.setImage(UIImage(named: "timeline_icon_unlike"), for: .normal)
    
    [repostButton,commonButton,likeButton].forEach { (button) in
      button.layoutAxis = .horizontal
      button.textNode.font = UIFont.systemFont(ofSize: 14)
      button.textNode.textColor = UIColor(hex6: 0x929292)
      button.setBackgroundColor(color: UIColor(hex6: 0xf0f0f0), for: .highlighted)
      button.setBackgroundColor(color: .white, for: .normal)
      button.textFirst = false
      
      button.addAction(for: .touchDown, action: {_ in
        print("touch down")
      })
      
    }
    
    [topLine,bottomLine].forEach { (node) in
      node.backgroundColor = lineColor
      node.xSide == self
      node.height == Double(1/UIScreen.main.scale)
    }

    topLine.top == top
    bottomLine.bottom == bottom
  }
}
