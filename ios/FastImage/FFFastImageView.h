#import <UIKit/UIKit.h>

#import <SDWebImage/SDAnimatedImageView+WebCache.h>
#import <SDWebImage/SDWebImageDownloader.h>

#import <React/RCTComponent.h>
#import <React/RCTResizeMode.h>

#import <SDWebImage/SDWebImageTransition.h>

#import "FFFastImageSource.h"

@interface FFFastImageView : SDAnimatedImageView

@property(nonatomic, copy) RCTDirectEventBlock onFastImageLoadStart;
@property(nonatomic, copy) RCTDirectEventBlock onFastImageProgress;
@property(nonatomic, copy) RCTDirectEventBlock onFastImageError;
@property(nonatomic, copy) RCTDirectEventBlock onFastImageLoad;
@property(nonatomic, copy) RCTDirectEventBlock onFastImageLoadEnd;
@property(nonatomic, assign) RCTResizeMode resizeMode;
@property(nonatomic, strong) FFFastImageSource *source;
@property(nonatomic, strong) UIColor *imageColor;
@property(nonatomic, strong) SDWebImageTransition *sd_imageTransition;

@end
