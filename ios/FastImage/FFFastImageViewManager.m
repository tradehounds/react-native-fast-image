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

RCT_EXPORT_METHOD(preload:(nonnull NSArray<FFFastImageSource *> *)sources)
{
    NSMutableArray *urls = [NSMutableArray arrayWithCapacity:sources.count];

    [sources enumerateObjectsUsingBlock:^(FFFastImageSource * _Nonnull source, NSUInteger idx, BOOL * _Nonnull stop) {
        [source.headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString* header, BOOL *stop) {
            [[SDWebImageDownloader sharedDownloader] setValue:header forHTTPHeaderField:key];
        }];
        [urls setObject:source.url atIndexedSubscript:idx];
    }];

    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:urls];
}

RCT_EXPORT_METHOD(clearMemoryCache)
{
    [SDImageCache.sharedImageCache clearMemory];
}

RCT_EXPORT_METHOD(clearDiskCache)
{
    [SDImageCache.sharedImageCache clearDiskOnCompletion:^(){}];
}

RCT_EXPORT_METHOD(enableDiskCaching)
{
    NSUInteger m1 = [NSProcessInfo processInfo].physicalMemory;
    NSLog(@"Physical memory available: %lu bytes", m1);
    SDImageCache *cache = [SDImageCache sharedImageCache];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    cache.config.maxMemoryCost = m1 / 2;
    NSUInteger m2 = cache.config.maxMemoryCost;
    NSLog(@"SDWebImage cache size: %lu bytes", m2);
    
    cache.config.maxDiskAge = 3600 * 24 * 7; // 1 Week
    cache.config.shouldCacheImagesInMemory = NO; // Disable memory cache, may cause cell-reusing flash because disk query is async
    cache.config.shouldUseWeakMemoryCache = NO; // Disable weak cache, may see blank when return from background because memory cache is purged under pressure
    cache.config.diskCacheReadingOptions = NSDataReadingMappedIfSafe;
    manager.optionsProcessor = [SDWebImageOptionsProcessor optionsProcessorWithBlock:^SDWebImageOptionsResult * _Nullable(NSURL * _Nullable url, SDWebImageOptions options, SDWebImageContext * _Nullable context) {
         // Disable Force Decoding in global, may reduce the frame rate
         options |= SDWebImageAvoidDecodeImage;
         return [[SDWebImageOptionsResult alloc] initWithOptions:options context:context];
     }];
    NSLog(@"Disk caching enabled!");
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

