//
//  QHotelAutoLayoutCell.swift
//  Cassowary
//
//  Created by nangezao on 2017/12/4.
//  Copyright © 2017年 nange. All rights reserved.
//

import UIKit
import Panda
import Layoutable

class AutoLayoutCell: UITableViewCell {

    let imageV = UIImageView()
    let titleLabel = UILabel()
    let addressLabel = UILabel()
    let priceLabel = UILabel()
    let scoreLabel = UILabel()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(imageV)
    contentView.addSubview(titleLabel)
    contentView.addSubview(scoreLabel)
    contentView.addSubview(addressLabel)
    contentView.addSubview(priceLabel)
    systemLayout()
    //pandaLayout()
  }
  
  func pandaLayout(){
    measureTime(desc: "Panda Layout init") {
      imageV.size == (120, 120)
      imageV.topLeft == contentView
      contentView.width == UIScreen.main.bounds.width
      titleLabel.preferredMaxLayoutWidth = 210
      titleLabel.top == contentView.top + 10
      
      [titleLabel,scoreLabel, addressLabel, priceLabel].forEach {
        $0.right == contentView.right - 20
        $0.left >= imageV.right + 20
        $0.height == 30
      }
      
      [titleLabel,scoreLabel, addressLabel, priceLabel].space(10)
      contentView.layoutIfEnabled()
    }
  }
  
  func systemLayout(){
    
    measureTime(desc: "add constraint") {
      imageV.translatesAutoresizingMaskIntoConstraints = false
      titleLabel.translatesAutoresizingMaskIntoConstraints = false
      scoreLabel.translatesAutoresizingMaskIntoConstraints = false
      addressLabel.translatesAutoresizingMaskIntoConstraints = false
      priceLabel.translatesAutoresizingMaskIntoConstraints = false
      
      imageV.widthAnchor.constraint(equalToConstant: 120).isActive = true
      imageV.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
      imageV.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
      imageV.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
      
      titleLabel.numberOfLines = 0
      titleLabel.leftAnchor.constraint(equalTo: imageV.rightAnchor, constant: 20).isActive = true
      titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
      titleLabel.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor, constant: -20).isActive = true
      
      scoreLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true
      scoreLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
      scoreLabel.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor, constant: -20).isActive = true
      
      addressLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true
      addressLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 20).isActive = true
      addressLabel.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor, constant: -20).isActive = true
      addressLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
      
      priceLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
      priceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40).isActive = true
      contentView.layoutIfNeeded()
    }
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func updateConstraints() {
    measureTime(desc: "updateConstraints") {
      super.updateConstraints()
    }
  }
  
  override func updateConstraintsIfNeeded() {
    measureTime(desc: "updateConstraintsIfNeeded") {
      super.updateConstraintsIfNeeded()
    }
  }
    
    override func layoutIfNeeded() {
      measureTime(desc: "layoutIfNeeded") {
//        print("Before Layout: \(titleLabel.preferredMaxLayoutWidth)" )
        super.layoutIfNeeded()
//        print("After Layout: \(titleLabel.preferredMaxLayoutWidth)" )
      }
    }
   
    
  func update(_ hotel: QHotel){
    measureTime(desc: "updateContentTime") {
      imageV.image = UIImage(named: hotel.imageName)
      titleLabel.text = hotel.hotelName
      addressLabel.text = hotel.address
      priceLabel.text = hotel.price
      scoreLabel.text = hotel.score
      
      
//      [titleLabel,addressLabel,priceLabel,scoreLabel].forEach{
//        $0.manager.layoutNeedsUpdate = true
//      }
//      imageV.autolayout()
    }
  }

}
