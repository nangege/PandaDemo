//
//  WBFeedHelper.h
//  YYKitExample
//
//  Created by ibireme on 15/9/5.
//  Copyright (c) 2015 ibireme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBModel.h"

/// 卡片类型 (这里随便写的，只适配了微博中常见的类型)
typedef NS_ENUM(NSUInteger, WBStatusCardType) {
  WBStatusCardTypeNone = 0, ///< 没卡片
  WBStatusCardTypeNormal,   ///< 一般卡片布局
  WBStatusCardTypeVideo,    ///< 视频
};

/// 最下方Tag类型，也是随便写的，微博可能有更多类型同时存在等情况
typedef NS_ENUM(NSUInteger, WBStatusTagType) {
  WBStatusTagTypeNone = 0, ///< 没Tag
  WBStatusTagTypeNormal,   ///< 文本
  WBStatusTagTypePlace,    ///< 地点
};

/**
 很多都写死单例了，毕竟只是 Demo。。
 */
@interface WBStatusHelper : NSObject

/// 微博图片资源 bundle
+ (NSBundle *)bundle;

/// 微博表情资源 bundle
+ (NSBundle *)emoticonBundle;

/// 微博表情 Array<WBEmotionGroup> (实际应该做成动态更新的)
+ (NSArray<WBEmoticonGroup *> *)emoticonGroups;

+ (UIImage *)imageNamed:(NSString *)name;
/// 从path创建图片 (有缓存)
+ (UIImage *)imageWithPath:(NSString *)path;

/// 将 date 格式化成微博的友好显示
+ (NSString *)stringWithTimelineDate:(NSDate *)date;

/// 将微博API提供的图片URL转换成可用的实际URL
+ (NSURL *)defaultURLForImageURL:(id)imageURL;

/// 缩短数量描述，例如 51234 -> 5万
+ (NSString *)shortedNumberDesc:(NSUInteger)number;

/// At正则 例如 @王思聪
+ (NSRegularExpression *)regexAt;

/// 话题正则 例如 #暖暖环游世界#
+ (NSRegularExpression *)regexTopic;

/// 表情正则 例如 [偷笑]
+ (NSRegularExpression *)regexEmoticon;

/// 表情字典 key:[偷笑] value:ImagePath
+ (NSDictionary *)emoticonDic;

/// 用户名称
+ (NSAttributedString *)attributedNameFor:(WBUser *)user;

/// 时间和来源
+ (NSAttributedString *)sourceFor:(WBStatus *)status;

+ (NSMutableAttributedString *)textWithStatus:(WBStatus *)status
                                     isRetweet:(BOOL)isRetweet
                                      fontSize:(CGFloat)fontSize
                                     textColor:(UIColor *)textColor;

@end
