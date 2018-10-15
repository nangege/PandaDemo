//
//  WBFeedHelper.m
//  YYKitExample
//
//  Created by ibireme on 15/9/5.
//  Copyright (c) 2015 ibireme. All rights reserved.
//

#import "WBStatusHelper.h"
#import "NSObject+YYModel.h"
#import "NSBundle+YYAdd.h"
#import "WBModel.h"
#import "PandaDemo-Swift.h"

/**
 Get the `AppleColorEmoji` font's ascent with a specified font size.
 It may used to create custom emoji.
 
 @param fontSize  The specified font size.
 @return The font ascent.
 */
static inline CGFloat YYEmojiGetAscentWithFontSize(CGFloat fontSize) {
  if (fontSize < 16) {
    return 1.25 * fontSize;
  } else if (16 <= fontSize && fontSize <= 24) {
    return 0.5 * fontSize + 12;
  } else {
    return fontSize;
  }
}

/**
 Get the `AppleColorEmoji` font's glyph bounding rect with a specified font size.
 It may used to create custom emoji.
 
 @param fontSize  The specified font size.
 @return The font glyph bounding rect.
 */
static inline CGRect YYEmojiGetGlyphBoundingRectWithFontSize(CGFloat fontSize) {
  CGRect rect;
  rect.origin.x = 0.75;
  rect.size.width = rect.size.height = YYEmojiGetAscentWithFontSize(fontSize);
  if (fontSize < 16) {
    rect.origin.y = -0.2525 * fontSize;
  } else if (16 <= fontSize && fontSize <= 24) {
    rect.origin.y = 0.1225 * fontSize -6;
  } else {
    rect.origin.y = -0.1275 * fontSize;
  }
  return rect;
}


@implementation NSMutableArray(YY)

- (void)insertObjects:(NSArray *)objects atIndex:(NSUInteger)index {
  NSUInteger i = index;
  for (id obj in objects) {
    [self insertObject:obj atIndex:i++];
  }
}

@end

@implementation NSAttributedString(YY)

+ (NSAttributedString *)attachmentStringWithEmojiImage:(UIImage *)image
                                                     fontSize:(CGFloat)fontSize {
  if (!image || fontSize <= 0) return nil;

  CGRect bounding = YYEmojiGetGlyphBoundingRectWithFontSize(fontSize);
  
  NSTextAttachment *imageAttatchment = [[NSTextAttachment alloc] init];
  imageAttatchment.image = image;
  imageAttatchment.bounds = bounding;
  NSAttributedString *attributedText = [NSAttributedString attributedStringWithAttachment:imageAttatchment];
  return attributedText;
}

@end

@implementation WBStatusHelper

+ (NSCache *)imageCache {
  static NSCache *cache;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    cache = [NSCache new];
    cache.name = @"TwitterImageCache";
  });
  return cache;
}

+ (NSBundle *)bundle {
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"ResourceWeibo" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:path];
    });
    return bundle;
}

+ (NSBundle *)emoticonBundle {
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"EmoticonWeibo" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:bundlePath];
    });
    return bundle;
}


+ (NSString *)stringWithTimelineDate:(NSDate *)date {
    if (!date) return @"";
    
    static NSDateFormatter *formatterYesterday;
    static NSDateFormatter *formatterSameYear;
    static NSDateFormatter *formatterFullDate;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatterYesterday = [[NSDateFormatter alloc] init];
        [formatterYesterday setDateFormat:@"昨天 HH:mm"];
        [formatterYesterday setLocale:[NSLocale currentLocale]];
        
        formatterSameYear = [[NSDateFormatter alloc] init];
        [formatterSameYear setDateFormat:@"M-d"];
        [formatterSameYear setLocale:[NSLocale currentLocale]];
        
        formatterFullDate = [[NSDateFormatter alloc] init];
        [formatterFullDate setDateFormat:@"yy-M-dd"];
        [formatterFullDate setLocale:[NSLocale currentLocale]];
    });
    
    NSDate *now = [NSDate new];
    NSTimeInterval delta = now.timeIntervalSince1970 - date.timeIntervalSince1970;
    if (delta < -60 * 10) { // 本地时间有问题
        return [formatterFullDate stringFromDate:date];
    } else if (delta < 60 * 10) { // 10分钟内
        return @"刚刚";
    } else if (delta < 60 * 60) { // 1小时内
        return [NSString stringWithFormat:@"%d分钟前", (int)(delta / 60.0)];
    } else if (delta < 60 * 60 * 24) {
        return [NSString stringWithFormat:@"%d小时前", (int)(delta / 60.0 / 60.0)];
    } else if (delta < 60 * 60 * 48) {
        return [formatterYesterday stringFromDate:date];
    } else if (delta < 60 * 60 * 24 * 365) {
        return [formatterSameYear stringFromDate:date];
    } else {
        return [formatterFullDate stringFromDate:date];
    }
}

+ (NSURL *)defaultURLForImageURL:(id)imageURL {
    /*
     微博 API 提供的图片 URL 有时并不能直接用，需要做一些字符串替换：
     http://u1.sinaimg.cn/upload/2014/11/04/common_icon_membership_level6.png //input
     http://u1.sinaimg.cn/upload/2014/11/04/common_icon_membership_level6_default.png //output
     
     http://img.t.sinajs.cn/t6/skin/public/feed_cover/star_003_y.png?version=2015080302 //input
     http://img.t.sinajs.cn/t6/skin/public/feed_cover/star_003_os7.png?version=2015080302 //output
     */
    
    if (!imageURL) return nil;
    NSString *link = nil;
    if ([imageURL isKindOfClass:[NSURL class]]) {
        link = ((NSURL *)imageURL).absoluteString;
    } else if ([imageURL isKindOfClass:[NSString class]]) {
        link = imageURL;
    }
    if (link.length == 0) return nil;
    
    if ([link hasSuffix:@".png"]) {
        // add "_default"
        if (![link hasSuffix:@"_default.png"]) {
            NSString *sub = [link substringToIndex:link.length - 4];
            link = [sub stringByAppendingFormat:@"_default.png"];
        }
    } else {
        // replace "_y.png" with "_os7.png"
        NSRange range = [link rangeOfString:@"_y.png?version"];
        if (range.location != NSNotFound) {
            NSMutableString *mutable = link.mutableCopy;
            [mutable replaceCharactersInRange:NSMakeRange(range.location + 1, 1) withString:@"os7"];
            link = mutable;
        }
    }
    
    return [NSURL URLWithString:link];
}

+ (NSString *)shortedNumberDesc:(NSUInteger)number {
    // should be localized
    if (number <= 9999) return [NSString stringWithFormat:@"%d", (int)number];
    if (number <= 9999999) return [NSString stringWithFormat:@"%d万", (int)(number / 10000)];
    return [NSString stringWithFormat:@"%d千万", (int)(number / 10000000)];
}

+ (NSRegularExpression *)regexAt {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 微博的 At 只允许 英文数字下划线连字符，和 unicode 4E00~9FA5 范围内的中文字符，这里保持和微博一致。。
        // 目前中文字符范围比这个大
        regex = [NSRegularExpression regularExpressionWithPattern:@"@[-_a-zA-Z0-9\u4E00-\u9FA5]+" options:kNilOptions error:NULL];
    });
    return regex;
}

+ (NSRegularExpression *)regexTopic {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"#[^@#]+?#" options:kNilOptions error:NULL];
    });
    return regex;
}

+ (NSRegularExpression *)regexEmoticon {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"\\[[^ \\[\\]]+?\\]" options:kNilOptions error:NULL];
    });
    return regex;
}

+ (NSDictionary *)emoticonDic {
    static NSMutableDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *emoticonBundlePath = [[NSBundle mainBundle] pathForResource:@"EmoticonWeibo" ofType:@"bundle"];
        dic = [self _emoticonDicFromPath:emoticonBundlePath];
    });
    return dic;
}

+ (NSMutableDictionary *)_emoticonDicFromPath:(NSString *)path {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    WBEmoticonGroup *group = nil;
    NSString *jsonPath = [path stringByAppendingPathComponent:@"info.json"];
    NSData *json = [NSData dataWithContentsOfFile:jsonPath];
    if (json.length) {
        group = [WBEmoticonGroup modelWithJSON:json];
    }
    if (!group) {
        NSString *plistPath = [path stringByAppendingPathComponent:@"info.plist"];
        NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        if (plist.count) {
            group = [WBEmoticonGroup modelWithJSON:plist];
        }
    }
    for (WBEmoticon *emoticon in group.emoticons) {
        if (emoticon.png.length == 0) continue;
        NSString *pngPath = [path stringByAppendingPathComponent:emoticon.png];
        if (emoticon.chs) dic[emoticon.chs] = pngPath;
        if (emoticon.cht) dic[emoticon.cht] = pngPath;
    }
    
    NSArray *folders = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    for (NSString *folder in folders) {
        if (folder.length == 0) continue;
        NSDictionary *subDic = [self _emoticonDicFromPath:[path stringByAppendingPathComponent:folder]];
        if (subDic) {
            [dic addEntriesFromDictionary:subDic];
        }
    }
    return dic;
}

/// 时间和来源
+ (NSAttributedString *)sourceFor:(WBStatus *)status {
  NSMutableAttributedString *sourceText = [NSMutableAttributedString new];
  NSString *createTime = [WBStatusHelper stringWithTimelineDate:status.createdAt];
  
  // 时间
  if (createTime.length) {
    NSMutableAttributedString *timeText = [[NSMutableAttributedString alloc] initWithString:[createTime stringByAppendingString:@"  "]];
    [timeText addAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithHex:0x828282],NSFontAttributeName: [UIFont systemFontOfSize:12]} range:NSMakeRange(0, timeText.length)];
    [sourceText appendAttributedString:timeText];
  }
  
  // 来自 XXX
  if (status.source.length) {
    // <a href="sinaweibo://customweibosource" rel="nofollow">iPhone 5siPhone 5s</a>
    static NSRegularExpression *hrefRegex, *textRegex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      hrefRegex = [NSRegularExpression regularExpressionWithPattern:@"(?<=href=\").+(?=\" )" options:kNilOptions error:NULL];
      textRegex = [NSRegularExpression regularExpressionWithPattern:@"(?<=>).+(?=<)" options:kNilOptions error:NULL];
    });
    NSTextCheckingResult *hrefResult, *textResult;
    NSString *href = nil, *text = nil;
    hrefResult = [hrefRegex firstMatchInString:status.source options:kNilOptions range:NSMakeRange(0, status.source.length)];
    textResult = [textRegex firstMatchInString:status.source options:kNilOptions range:NSMakeRange(0, status.source.length)];
    if (hrefResult && textResult && hrefResult.range.location != NSNotFound && textResult.range.location != NSNotFound) {
      href = [status.source substringWithRange:hrefResult.range];
      text = [status.source substringWithRange:textResult.range];
    }
    if (href.length && text.length) {
      NSMutableAttributedString *from = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"来自 %@", text]];
//
      [from addAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithHex:0x828282],NSFontAttributeName: [UIFont systemFontOfSize:12]} range:NSMakeRange(0, from.length)];

      if (status.sourceAllowClick > 0) {
        NSRange range = NSMakeRange(3, text.length);
        [from addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHex:0x527ead] range:range];
//        [from setColor:kWBCellTextHighlightColor range:range];
//        YYTextBackedString *backed = [YYTextBackedString stringWithString:href];
//        [from setTextBackedString:backed range:range];

//        YYTextBorder *border = [YYTextBorder new];
//        border.insets = UIEdgeInsetsMake(-2, 0, -2, 0);
//        border.fillColor = kWBCellTextHighlightBackgroundColor;
//        border.cornerRadius = 3;
//        YYTextHighlight *highlight = [YYTextHighlight new];
//        if (href) highlight.userInfo = @{kWBLinkHrefName : href};
//        [highlight setBackgroundBorder:border];
//        [from setTextHighlight:highlight range:range];
      }
      
      [sourceText appendAttributedString:from];
    }
  }
  return sourceText;
}

+ (NSAttributedString *)attributedNameFor:(WBUser *)user{
  
  NSString *nameStr = nil;
  if (user.remark.length) {
    nameStr = user.remark;
  } else if (user.screenName.length) {
    nameStr = user.screenName;
  } else {
    nameStr = user.name;
  }
  if (nameStr.length == 0) {
    return [[NSAttributedString alloc] initWithString:@""];
  }
  
  NSMutableAttributedString *nameText = [[NSMutableAttributedString alloc] initWithString:nameStr];
  
  // 蓝V
  if (user.userVerifyType == WBUserVerifyTypeOrganization) {
    UIImage *blueVImage = [WBStatusHelper imageNamed:@"avatar_enterprise_vip"];
    NSAttributedString *blueVText = [NSAttributedString attachmentStringWithEmojiImage:blueVImage fontSize:16];
    [nameText appendAttributedString:blueVText];
  }
  
  // VIP
  if (user.mbrank > 0) {
    UIImage *yelllowVImage = [WBStatusHelper imageNamed:[NSString stringWithFormat:@"common_icon_membership_level%d",user.mbrank]];
    if (!yelllowVImage) {
      yelllowVImage = [WBStatusHelper imageNamed:@"common_icon_membership"];
    }
    NSAttributedString *vipText = [NSAttributedString attachmentStringWithEmojiImage:yelllowVImage fontSize:14];
    [nameText appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [nameText appendAttributedString:vipText];
  }

  UIColor *color = [UIColor colorWithHex:user.mbrank > 0 ? 0x333333 : 0xf26220];
  [nameText addAttributes:@{NSForegroundColorAttributeName: color,NSFontAttributeName: [UIFont systemFontOfSize:16]} range:NSMakeRange(0, nameText.length)];
  
  
  
  return nameText;
}

+ (NSMutableAttributedString *)textWithStatus:(WBStatus *)status
                                     isRetweet:(BOOL)isRetweet
                                      fontSize:(CGFloat)fontSize
                                     textColor:(UIColor *)textColor {
  if (!status) return nil;
  
  UIColor *highlightedColor = [UIColor colorWithHex:0x527ead];
  
  NSMutableString *string = status.text.mutableCopy;
  if (string.length == 0) return nil;
  if (isRetweet) {
    NSString *name = status.user.name;
    if (name.length == 0) {
      name = status.user.screenName;
    }
    if (name) {
      NSString *insert = [NSString stringWithFormat:@"@%@:",name];
      [string insertString:insert atIndex:0];
    }
  }
  // 字体
  UIFont *font = [UIFont systemFontOfSize:fontSize];
  // 高亮状态的背景
//  YYTextBorder *highlightBorder = [YYTextBorder new];
//  highlightBorder.insets = UIEdgeInsetsMake(-2, 0, -2, 0);
//  highlightBorder.cornerRadius = 3;
//  highlightBorder.fillColor = kWBCellTextHighlightBackgroundColor;
  
  NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:string];
  [text addAttributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: textColor} range:NSMakeRange(0, text.length)];
//  text.font = font;
//  text.color = textColor;
  
  // 根据 urlStruct 中每个 URL.shortURL 来匹配文本，将其替换为图标+友好描述
  for (WBURL *wburl in status.urlStruct) {
    if (wburl.shortURL.length == 0) continue;
    if (wburl.urlTitle.length == 0) continue;
    NSString *urlTitle = wburl.urlTitle;
    if (urlTitle.length > 27) {
      //urlTitle = [[urlTitle substringToIndex:27] stringByAppendingString:YYTextTruncationToken];
      urlTitle = [[urlTitle substringToIndex:27] stringByAppendingString:@"..."];
    }
    NSRange searchRange = NSMakeRange(0, text.string.length);
    do {
      NSRange range = [text.string rangeOfString:wburl.shortURL options:kNilOptions range:searchRange];
      if (range.location == NSNotFound) break;
      
      if (range.location + range.length == text.length) {
        if (status.pageInfo.pageID && wburl.pageID &&
            [wburl.pageID isEqualToString:status.pageInfo.pageID]) {
          if ((!isRetweet && !status.retweetedStatus) || isRetweet) {
            if (status.pics.count == 0) {
              [text replaceCharactersInRange:range withString:@""];
              break; // cut the tail, show with card
            }
          }
        }
      }
      
//      if ([text attribute:YYTextHighlightAttributeName atIndex:range.location] == nil) {

        // 替换的内容
        NSMutableAttributedString *replace = [[NSMutableAttributedString alloc] initWithString:urlTitle];
      [replace addAttributes:@{NSFontAttributeName: font,
                               NSForegroundColorAttributeName: highlightedColor} range:NSMakeRange(0, replace.length)];
//        if (wburl.urlTypePic.length) {
//          // 链接头部有个图片附件 (要从网络获取)
//          NSURL *picURL = [WBStatusHelper defaultURLForImageURL:wburl.urlTypePic];
//          UIImage *image = [[YYImageCache sharedCache] getImageForKey:picURL.absoluteString];
//          NSAttributedString *pic = (image && !wburl.pics.count) ? [self _attachmentWithFontSize:fontSize image:image shrink:YES] : [self _attachmentWithFontSize:fontSize imageURL:wburl.urlTypePic shrink:YES];
//          [replace insertAttributedString:pic atIndex:0];
//        }
//        replace.font = font;
//        replace.color = kWBCellTextHighlightColor;

        // 高亮状态
//        YYTextHighlight *highlight = [YYTextHighlight new];
//        [highlight setBackgroundBorder:highlightBorder];
//        // 数据信息，用于稍后用户点击
//        highlight.userInfo = @{kWBLinkURLName : wburl};
//        [replace setTextHighlight:highlight range:NSMakeRange(0, replace.length)];

        // 添加被替换的原始字符串，用于复制
//        YYTextBackedString *backed = [YYTextBackedString stringWithString:[text.string substringWithRange:range]];
//        [replace setTextBackedString:backed range:NSMakeRange(0, replace.length)];

        // 替换
        [text replaceCharactersInRange:range withAttributedString:replace];

        searchRange.location = searchRange.location + (replace.length ? replace.length : 1);
        if (searchRange.location + 1 >= text.length) break;
        searchRange.length = text.length - searchRange.location;
//      }
//      else {
//        searchRange.location = searchRange.location + (searchRange.length ? searchRange.length : 1);
//        if (searchRange.location + 1>= text.length) break;
//        searchRange.length = text.length - searchRange.location;
//      }
    } while (1);
  }
  
  // 根据 topicStruct 中每个 Topic.topicTitle 来匹配文本，标记为话题
  for (WBTopic *topic in status.topicStruct) {
    if (topic.topicTitle.length == 0) continue;
    NSString *topicTitle = [NSString stringWithFormat:@"#%@#",topic.topicTitle];
    NSRange searchRange = NSMakeRange(0, text.string.length);
    do {
      NSRange range = [text.string rangeOfString:topicTitle options:kNilOptions range:searchRange];
      if (range.location == NSNotFound) break;
      
//      if ([text attribute:YYTextHighlightAttributeName atIndex:range.location] == nil) {
//        [text setColor:highlightedColor range:range];
      [text addAttribute:NSForegroundColorAttributeName value:highlightedColor range:range];
        // 高亮状态
//        YYTextHighlight *highlight = [YYTextHighlight new];
//        [highlight setBackgroundBorder:highlightBorder];
//        // 数据信息，用于稍后用户点击
//        highlight.userInfo = @{kWBLinkTopicName : topic};
//        [text setTextHighlight:highlight range:range];
//      }
      searchRange.location = searchRange.location + (searchRange.length ? searchRange.length : 1);
      if (searchRange.location + 1>= text.length) break;
      searchRange.length = text.length - searchRange.location;
    } while (1);
  }
  
  // 匹配 @用户名
  NSArray *atResults = [[WBStatusHelper regexAt] matchesInString:text.string options:kNilOptions range:NSMakeRange(0, text.length)];
  for (NSTextCheckingResult *at in atResults) {
    if (at.range.location == NSNotFound && at.range.length <= 1) continue;
    [text addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHex:0x527ead] range:at.range];
//    if ([text attribute:YYTextHighlightAttributeName atIndex:at.range.location] == nil) {
//      [text setColor:kWBCellTextHighlightColor range:at.range];
      
      // 高亮状态
//      YYTextHighlight *highlight = [YYTextHighlight new];
//      [highlight setBackgroundBorder:highlightBorder];
//      // 数据信息，用于稍后用户点击
//      highlight.userInfo = @{kWBLinkAtName : [text.string substringWithRange:NSMakeRange(at.range.location + 1, at.range.length - 1)]};
//      [text setTextHighlight:highlight range:at.range];
//    }
  }
  
  // 匹配 [表情]
  NSArray<NSTextCheckingResult *> *emoticonResults = [[WBStatusHelper regexEmoticon] matchesInString:text.string options:kNilOptions range:NSMakeRange(0, text.length)];
  NSUInteger emoClipLength = 0;
  for (NSTextCheckingResult *emo in emoticonResults) {
    if (emo.range.location == NSNotFound && emo.range.length <= 1) continue;
    NSRange range = emo.range;
    range.location -= emoClipLength;
//    if ([text attribute:YYTextHighlightAttributeName atIndex:range.location]) continue;
//    if ([text attribute:YYTextAttachmentAttributeName atIndex:range.location]) continue;
    NSString *emoString = [text.string substringWithRange:range];
    NSString *imagePath = [WBStatusHelper emoticonDic][emoString];
    UIImage *image = [WBStatusHelper imageWithPath:imagePath];
    if (!image) continue;

    NSAttributedString *emoText = [NSAttributedString attachmentStringWithEmojiImage:image fontSize:fontSize];
    [text replaceCharactersInRange:range withAttributedString:emoText];
    emoClipLength += range.length - 1;
  }
  NSMutableParagraphStyle * style = [[NSMutableParagraphStyle alloc] init];
  style.lineSpacing = 3;
  [text addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
  
  return text;
}

+ (UIImage *)imageWithPath:(NSString *)path{
  if (!path) return nil;
  UIImage *image = [[self imageCache] objectForKey:path];
  if (image) return image;
  if (path.pathScale == 1) {
    // 查找 @2x @3x 的图片
    NSArray *scales = [NSBundle preferredScales];
    for (NSNumber *scale in scales) {
      image = [UIImage imageWithContentsOfFile:[path stringByAppendingPathScale:scale.floatValue]];
      if (image) break;
    }
  } else {
    image = [UIImage imageWithContentsOfFile:path];
  }
  if (image) {
    [[self imageCache] setObject:image forKey:path];
  }
  return image;
}

+ (UIImage *)imageNamed:(NSString *)name {
  if (!name) return nil;
  UIImage *image = [[self imageCache] objectForKey:name];
  if (image) return image;
  NSString *ext = name.pathExtension;
  if (ext.length == 0) ext = @"png";
  NSString *path = [[self bundle] pathForScaledResource:name ofType:ext];
  if (!path) return nil;
  image = [UIImage imageWithContentsOfFile:path];
  if (!image) return nil;
  [[self imageCache] setObject:image forKey:name];
  return image;
}

+ (NSArray<WBEmoticonGroup *> *)emoticonGroups {
    static NSMutableArray *groups;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *emoticonBundlePath = [[NSBundle mainBundle] pathForResource:@"EmoticonWeibo" ofType:@"bundle"];
        NSString *emoticonPlistPath = [emoticonBundlePath stringByAppendingPathComponent:@"emoticons.plist"];
        NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:emoticonPlistPath];
        NSArray *packages = plist[@"packages"];
        groups = (NSMutableArray *)[NSArray modelArrayWithClass:[WBEmoticonGroup class] json:packages];
      
        NSMutableDictionary *groupDic = [NSMutableDictionary new];
        for (int i = 0, max = (int)groups.count; i < max; i++) {
            WBEmoticonGroup *group = groups[i];
            if (group.groupID.length == 0) {
                [groups removeObjectAtIndex:i];
                i--;
                max--;
                continue;
            }
            NSString *path = [emoticonBundlePath stringByAppendingPathComponent:group.groupID];
            NSString *infoPlistPath = [path stringByAppendingPathComponent:@"info.plist"];
            NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:infoPlistPath];
            [group modelSetWithDictionary:info];
            if (group.emoticons.count == 0) {
                i--;
                max--;
                continue;
            }
            groupDic[group.groupID] = group;
        }
      
        NSArray<NSString *> *additionals = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[emoticonBundlePath stringByAppendingPathComponent:@"additional"] error:nil];
        for (NSString *path in additionals) {
            WBEmoticonGroup *group = groupDic[path];
            if (!group) continue;
            NSString *infoJSONPath = [[[emoticonBundlePath stringByAppendingPathComponent:@"additional"] stringByAppendingPathComponent:path] stringByAppendingPathComponent:@"info.json"];
            NSData *infoJSON = [NSData dataWithContentsOfFile:infoJSONPath];
            WBEmoticonGroup *addGroup = [WBEmoticonGroup modelWithJSON:infoJSON];
            if (addGroup.emoticons.count) {
                for (WBEmoticon *emoticon in addGroup.emoticons) {
                    emoticon.group = group;
                }
                [((NSMutableArray *)group.emoticons) insertObjects:addGroup.emoticons atIndex:0];
            }
        }
    });
    return groups;
}


/*
 weibo.app 里面的正则，有兴趣的可以参考下：
 
 HTTP链接 (例如 http://www.weibo.com ):
 ([hH]ttp[s]{0,1})://[a-zA-Z0-9\.\-]+\.([a-zA-Z]{2,4})(:\d+)?(/[a-zA-Z0-9\-~!@#$%^&*+?:_/=<>.',;]*)?
 ([hH]ttp[s]{0,1})://[a-zA-Z0-9\.\-]+\.([a-zA-Z]{2,4})(:\d+)?(/[a-zA-Z0-9\-~!@#$%^&*+?:_/=<>]*)?
 (?i)https?://[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)+([-A-Z0-9a-z_\$\.\+!\*\(\)/,:;@&=\?~#%]*)*
 ^http?://[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+(\/[\w-. \/\?%@&+=\u4e00-\u9fa5]*)?$
 
 链接 (例如 www.baidu.com/s?wd=test ):
 ^[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)+([-A-Z0-9a-z_\$\.\+!\*\(\)/,:;@&=\?~#%]*)*
 
 邮箱 (例如 sjobs@apple.com ):
 \b([a-zA-Z0-9%_.+\-]{1,32})@([a-zA-Z0-9.\-]+?\.[a-zA-Z]{2,6})\b
 \b([a-zA-Z0-9%_.+\-]+)@([a-zA-Z0-9.\-]+?\.[a-zA-Z]{2,6})\b
 ([a-zA-Z0-9%_.+\-]+)@([a-zA-Z0-9.\-]+?\.[a-zA-Z]{2,6})
 
 电话号码 (例如 18612345678):
 ^[1-9][0-9]{4,11}$
 
 At (例如 @王思聪 ):
 @([\x{4e00}-\x{9fa5}A-Za-z0-9_\-]+)
 
 话题 (例如 #奇葩说# ):
 #([^@]+?)#
 
 表情 (例如 [呵呵] ):
 \[([^ \[]*?)]
 
 匹配单个字符 (中英文数字下划线连字符)
 [\x{4e00}-\x{9fa5}A-Za-z0-9_\-]
 
 匹配回复 (例如 回复@王思聪: ):
 \x{56de}\x{590d}@([\x{4e00}-\x{9fa5}A-Za-z0-9_\-]+)(\x{0020}\x{7684}\x{8d5e})?:
 
 */

@end
