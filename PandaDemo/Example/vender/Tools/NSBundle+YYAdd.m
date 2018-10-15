//
//  NSBundle+YYAdd.m
//  YYKit <https://github.com/ibireme/YYKit>
//
//  Created by ibireme on 14/10/20.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "NSBundle+YYAdd.h"
#import <UIKit/UIKit.h>

@implementation NSString(YYAdd)

- (void)enumerateRegexMatches:(NSString *)regex
                      options:(NSRegularExpressionOptions)options
                   usingBlock:(void (^)(NSString *match, NSRange matchRange, BOOL *stop))block {
  if (regex.length == 0 || !block) return;
  NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:nil];
  if (!regex) return;
  [pattern enumerateMatchesInString:self options:kNilOptions range:NSMakeRange(0, self.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
    block([self substringWithRange:result.range], result.range, stop);
  }];
}

- (CGFloat)pathScale {
  if (self.length == 0 || [self hasSuffix:@"/"]) return 1;
  NSString *name = self.stringByDeletingPathExtension;
  __block CGFloat scale = 1;
  [name enumerateRegexMatches:@"@[0-9]+\\.?[0-9]*x$" options:NSRegularExpressionAnchorsMatchLines usingBlock: ^(NSString *match, NSRange matchRange, BOOL *stop) {
    scale = [match substringWithRange:NSMakeRange(1, match.length - 2)].doubleValue;
  }];
  return scale;
}

- (NSString *)stringByAppendingNameScale:(CGFloat)scale {
  if (fabs(scale - 1) <= __FLT_EPSILON__ || self.length == 0 || [self hasSuffix:@"/"]) return self.copy;
  return [self stringByAppendingFormat:@"@%@x", @(scale)];
}

- (NSString *)stringByAppendingPathScale:(CGFloat)scale {
  if (fabs(scale - 1) <= __FLT_EPSILON__ || self.length == 0 || [self hasSuffix:@"/"]) return self.copy;
  NSString *ext = self.pathExtension;
  NSRange extRange = NSMakeRange(self.length - ext.length, 0);
  if (ext.length > 0) extRange.location -= 1;
  NSString *scaleStr = [NSString stringWithFormat:@"@%@x", @(scale)];
  return [self stringByReplacingCharactersInRange:extRange withString:scaleStr];
}

@end

@implementation NSBundle (YYAdd)

+ (NSArray *)preferredScales {
    static NSArray *scales;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat screenScale = [UIScreen mainScreen].scale;
        if (screenScale <= 1) {
            scales = @[@1,@2,@3];
        } else if (screenScale <= 2) {
            scales = @[@2,@3,@1];
        } else {
            scales = @[@3,@2,@1];
        }
    });
    return scales;
}

+ (NSString *)pathForScaledResource:(NSString *)name ofType:(NSString *)ext inDirectory:(NSString *)bundlePath {
    if (name.length == 0) return nil;
    if ([name hasSuffix:@"/"]) return [self pathForResource:name ofType:ext inDirectory:bundlePath];
    
    NSString *path = nil;
    NSArray *scales = [self preferredScales];
    for (int s = 0; s < scales.count; s++) {
        CGFloat scale = ((NSNumber *)scales[s]).floatValue;
        NSString *scaledName = ext.length ? [name stringByAppendingNameScale:scale]
        : [name stringByAppendingPathScale:scale];
        path = [self pathForResource:scaledName ofType:ext inDirectory:bundlePath];
        if (path) break;
    }
    
    return path;
}

- (NSString *)pathForScaledResource:(NSString *)name ofType:(NSString *)ext {
    if (name.length == 0) return nil;
    if ([name hasSuffix:@"/"]) return [self pathForResource:name ofType:ext];
    
    NSString *path = nil;
    NSArray *scales = [NSBundle preferredScales];
    for (int s = 0; s < scales.count; s++) {
        CGFloat scale = ((NSNumber *)scales[s]).floatValue;
        NSString *scaledName = ext.length ? [name stringByAppendingNameScale:scale]
        : [name stringByAppendingPathScale:scale];
        path = [self pathForResource:scaledName ofType:ext];
        if (path) break;
    }
    
    return path;
}

- (NSString *)pathForScaledResource:(NSString *)name ofType:(NSString *)ext inDirectory:(NSString *)subpath {
    if (name.length == 0) return nil;
    if ([name hasSuffix:@"/"]) return [self pathForResource:name ofType:ext];
    
    NSString *path = nil;
    NSArray *scales = [NSBundle preferredScales];
    for (int s = 0; s < scales.count; s++) {
        CGFloat scale = ((NSNumber *)scales[s]).floatValue;
        NSString *scaledName = ext.length ? [name stringByAppendingNameScale:scale]
        : [name stringByAppendingPathScale:scale];
        path = [self pathForResource:scaledName ofType:ext inDirectory:subpath];
        if (path) break;
    }
    
    return path;
}

@end
