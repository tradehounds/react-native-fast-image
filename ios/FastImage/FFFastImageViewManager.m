#import "FFFastImageViewManager.h"
#import "FFFastImageView.h"

#import <SDWebImage/SDImageCache.h>
#import <SDWebImage/SDWebImagePrefetcher.h>

@implementation FFFastImageViewManager

RCT_EXPORT_MODULE(FastImageView)

- (FFFastImageView*)view {
  return [[FFFastImageView alloc] init];
}

RCT_EXPORT_VIEW_PROPERTY(source, FFFastImageSource)
RCT_EXPORT_VIEW_PROPERTY(resizeMode, RCTResizeMode)
RCT_EXPORT_VIEW_PROPERTY(onFastImageLoadStart, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onFastImageProgress, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onFastImageError, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onFastImageLoad, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onFastImageLoadEnd, RCTDirectEventBlock)
RCT_REMAP_VIEW_PROPERTY(tintColor, imageColor, UIColor)

RCT_EXPORT_METHOD(clearMemoryCache)
{
    [SDImageCache.sharedImageCache clearMemory];
    NSLog(@"Memory cache cleared");
}

RCT_EXPORT_METHOD(clearDiskCache)
{
    [SDImageCache.sharedImageCache clearDiskOnCompletion:^(){}];
    NSLog(@"Disk cache cleared");
}

RCT_EXPORT_METHOD(limitMemory)
{
    NSUInteger m1 = [NSProcessInfo processInfo].physicalMemory;
    NSLog(@"Physical memory available: %fgB", m1/1000000000.0f);
    SDImageCache *cache = [SDImageCache sharedImageCache];
    cache.config.maxMemoryCost = m1 / 2;
    NSLog(@"SDWebImage cache size set to %fgB", cache.config.maxMemoryCost/1000000000.0f);
    
//    SDWebImageManager *manager = [SDWebImageManager sharedManager];
//    cache.config.maxDiskAge = 3600 * 24 * 7; // 1 Week
//    cache.config.shouldCacheImagesInMemory = NO; // Disable memory cache, may cause cell-reusing flash because disk query is async
//    cache.config.shouldUseWeakMemoryCache = NO; // Disable weak cache, may see blank when return from background because memory cache is purged under pressure
//    cache.config.diskCacheReadingOptions = NSDataReadingMappedIfSafe;
//    manager.optionsProcessor = [SDWebImageOptionsProcessor optionsProcessorWithBlock:^SDWebImageOptionsResult * _Nullable(NSURL * _Nullable url, SDWebImageOptions options, SDWebImageContext * _Nullable context) {
//         // Disable Force Decoding in global, may reduce the frame rate
//         options |= SDWebImageAvoidDecodeImage;
//         return [[SDWebImageOptionsResult alloc] initWithOptions:options context:context];
//     }];
//    NSLog(@"Disk caching enabled!");
}


RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(getCachePath:(NSURL *)url)
{
    NSString *cacheKey = [[SDWebImageManager sharedManager] cacheKeyForURL:url];
    BOOL isCached = [[SDImageCache sharedImageCache] diskImageDataExistsWithKey:cacheKey];
    if( isCached )
    {
        return [[SDImageCache sharedImageCache] cachePathForKey:cacheKey];
    }
    else
    {
        return [NSNull null];
    }
}

@end

