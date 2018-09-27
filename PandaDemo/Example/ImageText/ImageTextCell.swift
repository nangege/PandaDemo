//
//  QHotelCell.swift
//  Cassowary
//
//  Created by nangezao on 2017/10/29.
//  Copyright © 2017年 nange. All rights reserved.
//

import UIKit
import Panda
import Layoutable

class ImageTextCell: UITableViewCell {
  
  let hotelRender = ImageTextNode()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    hotelRender.width == Double(UIScreen.main.bounds.width)

    contentView.addSubview(hotelRender.view)
  }
  
  func updateHotel(_ hotel: QHotel, layout: LayoutValues){
    hotelRender.update(hotel)
    hotelRender.apply(layout)
  }
  
  func update(_ hotel: QHotel){
    measureTime(desc: "Cassowary update") {
      hotelRender.update(hotel)
      hotelRender.layoutIfEnabled()
    }

  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }

}
