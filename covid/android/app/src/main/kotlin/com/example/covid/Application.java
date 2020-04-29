package com.example.covid;

import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.embedding.engine.FlutterEngine;
import com.transistorsoft.flutter.backgroundgeolocation.FLTBackgroundGeolocationPlugin;

public class Application extends FlutterApplication implements PluginRegistry.PluginRegistrantCallback {
  @Override
  public void onCreate() {
    super.onCreate();
    FLTBackgroundGeolocationPlugin.setPluginRegistrant(this);
  }

  @Override
  public void registerWith(PluginRegistry registry) {
    GeneratedPluginRegistrant.registerWith(registry);
  }
}