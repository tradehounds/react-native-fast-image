package com.dylanvann.fastimage;

import androidx.annotation.Nullable;
import android.app.Activity;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.DataSource;
import com.bumptech.glide.load.engine.GlideException;
import com.bumptech.glide.load.model.GlideUrl;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.RequestOptions;
import com.bumptech.glide.request.target.Target;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.views.imagehelper.ImageSource;
import java.io.File;

import android.util.Log;

class FastImagePreloaderModule extends ReactContextBaseJavaModule {

    private static final String REACT_CLASS = "FastImagePreloaderManager";
    private int preloaders = 0;

    FastImagePreloaderModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @ReactMethod
    public void createPreloader(Promise promise) {
        promise.resolve(preloaders++);
    }

    @ReactMethod
    public void preload(final int preloaderId, final ReadableArray sources) {
        final Activity activity = getCurrentActivity();
        if (activity == null) return;
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                FastImagePreloaderListener preloader = new FastImagePreloaderListener(getReactApplicationContext(), preloaderId, sources.size());
                for (int i = 0; i < sources.size(); i++) {
                    final ReadableMap source = sources.getMap(i);
                    final FastImageSource imageSource = FastImageViewConverter.getImageSource(activity, source);

                    Glide
                            .with(activity.getApplicationContext())
                            .downloadOnly()
                            // This will make this work for remote and local images. e.g.
                            //    - file:///
                            //    - content://
                            //    - res:/
                            //    - android.resource://
                            //    - data:image/png;base64
                            .load(
                                    imageSource.isBase64Resource() ? imageSource.getSource() :
                                    imageSource.isResource() ? imageSource.getUri() : imageSource.getGlideUrl()
                            )
                            .listener(preloader)
                            .apply(FastImageViewConverter.getOptions(activity, imageSource, source))
                            .preload();
                }
            }
        });
    }

    @ReactMethod
    public void clearMemoryCache() {
        final Activity activity = getCurrentActivity();
        if (activity == null) return;

        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Glide.get(activity.getApplicationContext()).clearMemory();
                Log.i("GLIDE", "Memory cache cleared");
            }
        });
    }

    @ReactMethod
    public void limitMemory() {
    }

    @ReactMethod
    public void clearDiskCache() {
        final Activity activity = getCurrentActivity();
        if (activity == null) return;

        Glide.get(activity.getApplicationContext()).clearDiskCache();
        Log.i("GLIDE", "Disk cache cleared");
    }

    /*@ReactMethod(isBlockingSynchronousMethod = true)
    public void getCachePath(final ReadableMap source) {
        final Activity activity = getCurrentActivity();
        if (activity == null) return;
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                final FastImageSource imageSource = FastImageViewConverter.getImageSource(activity, source);
                RequestOptions options = new RequestOptions()
                        .onlyRetrieveFromCache(true);
                Glide
                        .with(activity.getApplicationContext())
                        .asFile()
                        .load(
                                imageSource.isBase64Resource() ? imageSource.getSource() :
                                        imageSource.isResource() ? imageSource.getUri() : imageSource.getGlideUrl()
                        )
                        .apply(options)
                        .listener(new RequestListener<File>() {
                            @Override
                            public String onLoadFailed(@Nullable GlideException e, Object model, Target<File> target, boolean isFirstResource) {
                                return null;
                            }
                            @Override
                            public String onResourceReady(File resource, Object model, Target<File> target, DataSource dataSource, boolean isFirstResource) {
                                return resource.getAbsolutePath();
                            }
                        })
                        .submit();
            }
        });
    }*/
}
