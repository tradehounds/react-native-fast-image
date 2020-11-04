package com.dylanvann.fastimage;

import android.content.Context;
import android.util.Log;

import com.bumptech.glide.annotation.GlideModule;
import com.bumptech.glide.module.AppGlideModule;
import com.bumptech.glide.module.LibraryGlideModule;
import com.bumptech.glide.GlideBuilder;
import com.bumptech.glide.load.engine.bitmap_recycle.LruBitmapPool;
import com.bumptech.glide.load.engine.cache.LruResourceCache;
import com.bumptech.glide.load.engine.cache.MemorySizeCalculator;

// We need an AppGlideModule to be present for progress events to work.
@GlideModule
public final class FastImageGlideModule extends AppGlideModule {
  @Override
  public void applyOptions(Context context, GlideBuilder builder) {
    builder.setLogLevel(Log.VERBOSE);
    // https://github.com/bumptech/glide/issues/2011
    MemorySizeCalculator calculator = new MemorySizeCalculator.Builder(context).build();
    builder.setMemoryCache(new LruResourceCache(calculator.getMemoryCacheSize() / 2));
    builder.setBitmapPool(new LruBitmapPool(calculator.getBitmapPoolSize() / 2));
    Log.i("GLIDE", String.valueOf(calculator.getMemoryCacheSize() / 2));
  }
}
