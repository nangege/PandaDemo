//
//  KingfishedNode.swift
//  PandaDemo
//
//  Created by nangezao on 2018/8/5.
//  Copyright © 2018 Tang Nan. All rights reserved.
//

import Panda
import Kingfisher

import UIKit

extension ImageNode: KingfisherCompatible{}

// MARK: - Extension methods.
/**
 *    Set image to use from web.
 */
extension Kingfisher where Base: ImageNode {

  @discardableResult
  public func setImage(with resource: Resource?,
                       placeholder: UIImage? = nil,
                       options: KingfisherOptionsInfo? = nil,
                       progressBlock: DownloadProgressBlock? = nil,
                       completionHandler: CompletionHandler? = nil) -> RetrieveImageTask
  {
    guard let resource = resource ,Thread.isMainThread else {
      self.placeholder = placeholder
      setWebURL(nil)
      completionHandler?(nil, nil, .none, nil)
      return .empty
    }
    
    var options = KingfisherManager.shared.defaultOptions + (options ?? KingfisherOptionsInfo())
    let noImageOrPlaceholderSet = base.image == nil && self.placeholder == nil
    
    if !options.keepCurrentImageWhileLoading || noImageOrPlaceholderSet { 
      self.placeholder = placeholder
    }
    
    cancelDownloadTask()
    setWebURL(resource.downloadURL)
    
    if base.shouldPreloadAllAnimation() {
      options.append(.preloadAllAnimationData)
    }
    
    let task = KingfisherManager.shared.retrieveImage(
      with: resource,
      options: options,
      progressBlock: { receivedSize, totalSize in
        guard resource.downloadURL == self.webURL else {
          return
        }
        if let progressBlock = progressBlock {
          progressBlock(receivedSize, totalSize)
        }
    },
      completionHandler: {[weak base] image, error, cacheType, imageURL in
        DispatchQueue.main.async {
          
          guard let strongBase = base, imageURL == self.webURL else {
            completionHandler?(image, error, cacheType, imageURL)
            return
          }
          
          self.setImageTask(nil)
          guard let image = image else {
            completionHandler?(nil, error, cacheType, imageURL)
            return
          }
          
          strongBase.image = image
        }
    })
    
    setImageTask(task)
    
    return task
  }
  
  /**
   Cancel the image download task bounded to the image view if it is running.
   Nothing will happen if the downloading has already finished.
   */
  public func cancelDownloadTask() {
    imageTask?.cancel()
  }
}

// MARK: - Associated Object
private var lastURLKey: Void?
private var indicatorKey: Void?
private var indicatorTypeKey: Void?
private var placeholderKey: Void?
private var imageTaskKey: Void?

extension Kingfisher where Base: ImageNode {
  /// Get the image URL binded to this image view.
  public var webURL: URL? {
    return objc_getAssociatedObject(base, &lastURLKey) as? URL
  }
  
  fileprivate func setWebURL(_ url: URL?) {
    objc_setAssociatedObject(base, &lastURLKey, url, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
  }
  
  fileprivate var imageTask: RetrieveImageTask? {
    return objc_getAssociatedObject(base, &imageTaskKey) as? RetrieveImageTask
  }
  
  fileprivate func setImageTask(_ task: RetrieveImageTask?) {
    objc_setAssociatedObject(base, &imageTaskKey, task, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
  }
  
  public fileprivate(set) var placeholder: UIImage? {
    get {
      return objc_getAssociatedObject(base, &placeholderKey) as? UIImage
    }
    
    set {
      if let newPlaceholder = newValue {
        base.image = newPlaceholder
      } else {
        base.image = nil
      }
      
      objc_setAssociatedObject(base, &placeholderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
}


@objc extension ImageNode {
  func shouldPreloadAllAnimation() -> Bool { return true }
}


