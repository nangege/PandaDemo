//
//  QHotelFrameCell.swift
//  Cassowary
//
//  Created by Tang,Nan(MAD) on 2018/1/29.
//  Copyright © 2018年 nange. All rights reserved.
//

import UIKit
import Panda
import Layoutable

class PureFrameCell: UITableViewCell {

  let hotelView = ImageTextView()
  
  override func awakeFromNib() {
    super.awakeFromNib()

        // Initialization code
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(hotelView)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
  }
  
  func updateHotel(_ hotel: QHotel, layout: LayoutValues){
    hotelView.update(hotel: hotel)
    hotelView.update(layout)
  }

}
