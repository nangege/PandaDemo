//
//  QHotelView.swift
//  Cassowary
//
//  Created by Tang,Nan(MAD) on 2018/1/29.
//  Copyright © 2018年 nange. All rights reserved.
//

import UIKit
import Panda
import Layoutable

class ImageTextView: UIView {
  
  let hotelImage = UIImageView()
  let titleLabel = UILabel()
  let addressLabel = UILabel()
  let priceLabel = UILabel()
  let scoreLabel = UILabel()
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(hotelImage)
    addSubview(titleLabel)
    addSubview(scoreLabel)
    addSubview(addressLabel)
    addSubview(priceLabel)
    titleLabel.numberOfLines = 0
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func update(hotel: QHotel){
    hotelImage.image = UIImage(named: hotel.imageName)
    titleLabel.text = hotel.hotelName
    addressLabel.text = hotel.address
    priceLabel.text = hotel.price
    scoreLabel.text = hotel.score
  }
}

extension UIView{
  func update(_ layout: LayoutValues){
    frame = layout.frame
    for (index, view) in subviews.enumerated(){
      view.update(layout.subLayout[index])
    }
  }
}
