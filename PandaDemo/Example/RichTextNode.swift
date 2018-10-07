//
//  RichTextNode.swift
//  PandaDemo
//
//  Created by nangezao on 2018/10/5.
//  Copyright © 2018 Tang Nan. All rights reserved.
//

import Panda
import Layoutable

class RichTextNode: TextNode{
  
  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    if let point = touches.first?.location(in: view){
      let textRender = TextRender.render(for: textHolder.textAttributes, constrainedSize: bounds.size)
      var highlightedRange = NSRange()
      textRender.textContext.performBlockWithLockedComponent { (manager, container, storage) in
        let index = manager.glyphIndex(for: point, in: container)
        let range = manager.range(ofNominallySpacedGlyphsContaining: index)
        let startIndex = range.location
      }
      
      highlightedTapAction?(highlightedRange)
    }
  }
  
  override func contentSizeFor(maxWidth: CGFloat) -> CGSize {
    return super.contentSizeFor(maxWidth: maxWidth)
  }
}

extension NSAttributedString.Key{
  public static let highlightedTextColor = NSAttributedString.Key("highlightedTextColor")
}
