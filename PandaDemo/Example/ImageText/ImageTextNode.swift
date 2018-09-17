//
//  QHotelRender.swift
//  Cassowary
//
//  Created by Tang,Nan(MAD) on 2017/10/30.
//  Copyright © 2017年 nange. All rights reserved.
//

import UIKit
import Panda
import Layoutable

class ImageTextNode: ViewNode {
  let imageView = ImageNode()
  let nameLabel = TextNode()
  let scoreLabel = TextNode()
  let addressLabel = TextNode()
  let priceLabel = TextNode()
  
  override init() {
    super.init()
    
    addSubnode(imageView)
    addSubnode(nameLabel)
    addSubnode(scoreLabel)
    addSubnode(addressLabel)
    addSubnode(priceLabel)
    
    imageView.topLeft == topLeft
    imageView.height == 120
    imageView.width == imageView.height
    
    nameLabel.top == top + 10
    nameLabel.left == imageView.right + 20
    nameLabel.right <= right - 20
    
    nameLabel.numberOfLines = 0
    nameLabel.truncationMode = .byTruncatingTail
  
    scoreLabel.top == nameLabel.bottom + 20
    scoreLabel.left == nameLabel.left
    scoreLabel.right <= right - 20
    
    addressLabel.left == imageView.right + 20
    addressLabel.top == scoreLabel.bottom + 20
    addressLabel.right <= right - 20
    addressLabel.bottom == bottom - 10
    
    priceLabel.bottom == bottom - 25
    priceLabel.right == right - 20
  }
  
  func update(_ hotel: QHotel){

    imageView.image = UIImage(named: hotel.imageName)
    nameLabel.text = hotel.hotelName
    addressLabel.text = hotel.address
    priceLabel.text = hotel.price
    scoreLabel.text = hotel.score
  }

}
