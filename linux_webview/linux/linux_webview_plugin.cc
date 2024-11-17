#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <webkit2/webkit2.h>
#include "include/linux_webview/linux_webview_plugin.h"
#include <map>
#include <memory>
#include <string>

struct _LinuxWebviewPlugin {
  GObject parent_instance;
  FlMethodChannel* channel;
  std::map<int, WebKitWebView*> views;
  int next_view_id;
};

G_DEFINE_TYPE(LinuxWebviewPlugin, linux_webview_plugin, G_TYPE_OBJECT)

static void linux_webview_plugin_dispose(GObject* object) {
  LinuxWebviewPlugin* self = LINUX_WEBVIEW_PLUGIN(object);
  g_clear_object(&self->channel);
  G_OBJECT_CLASS(linux_webview_plugin_parent_class)->dispose(object);
}

static void linux_webview_plugin_class_init(LinuxWebviewPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = linux_webview_plugin_dispose;
}

static void linux_webview_plugin_init(LinuxWebviewPlugin* self) {
  self->next_view_id = 0;
}

static void update_navigation_state(LinuxWebviewPlugin* plugin, WebKitWebView* web_view) {
  g_autoptr(FlValue) nav_args = fl_value_new_map();
  fl_value_set_string_take(nav_args, "canGoBack",
                           fl_value_new_bool(webkit_web_view_can_go_back(web_view)));
  fl_value_set_string_take(nav_args, "canGoForward",
                           fl_value_new_bool(webkit_web_view_can_go_forward(web_view)));
  
  g_autoptr(GError) error = nullptr;
  fl_method_channel_invoke_method(plugin->channel, "onNavigationStateChanged",
                                nav_args, nullptr,
                                [](GObject* object, GAsyncResult* result, gpointer user_data) {
                                  g_autoptr(GError) error = nullptr;
                                  g_autoptr(FlMethodResponse) response =
                                      fl_method_channel_invoke_method_finish(FL_METHOD_CHANNEL(object), result, &error);
                                  if (error != nullptr) {
                                    g_warning("Failed to invoke onNavigationStateChanged: %s", error->message);
                                  }
                                }, nullptr);
}

static void on_load_changed(WebKitWebView* web_view, WebKitLoadEvent load_event, LinuxWebviewPlugin* plugin) {
  if (load_event == WEBKIT_LOAD_FINISHED) {
    GTlsCertificate* certificate;
    GTlsCertificateFlags flags;
    webkit_web_view_get_tls_info(web_view, &certificate, &flags);
    gboolean is_secure = certificate != nullptr && flags == 0;
    
    g_autoptr(FlValue) args = fl_value_new_map();
    fl_value_set_string_take(args, "isSecure", fl_value_new_bool(is_secure));
    
    g_autoptr(GError) error = nullptr;
    fl_method_channel_invoke_method(plugin->channel, "onSecurityStateChanged",
                                  args, nullptr,
                                  [](GObject* object, GAsyncResult* result, gpointer user_data) {
                                    g_autoptr(GError) error = nullptr;
                                    g_autoptr(FlMethodResponse) response =
                                        fl_method_channel_invoke_method_finish(FL_METHOD_CHANNEL(object), result, &error);
                                    if (error != nullptr) {
                                      g_warning("Failed to invoke onSecurityStateChanged: %s", error->message);
                                    }
                                  }, nullptr);

    update_navigation_state(plugin, web_view);
  }
}

static void on_progress_changed(WebKitWebView* web_view, GParamSpec* pspec, LinuxWebviewPlugin* plugin) {
  double progress = webkit_web_view_get_estimated_load_progress(web_view);
  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "progress", fl_value_new_float(progress));
  
  g_autoptr(GError) error = nullptr;
  fl_method_channel_invoke_method(plugin->channel, "onProgress",
                                args, nullptr,
                                [](GObject* object, GAsyncResult* result, gpointer user_data) {
                                  g_autoptr(GError) error = nullptr;
                                  g_autoptr(FlMethodResponse) response =
                                      fl_method_channel_invoke_method_finish(FL_METHOD_CHANNEL(object), result, &error);
                                  if (error != nullptr) {
                                    g_warning("Failed to invoke onProgress: %s", error->message);
                                  }
                                }, nullptr);
}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  LinuxWebviewPlugin* plugin = LINUX_WEBVIEW_PLUGIN(user_data);
  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  if (strcmp(method, "createWebView") == 0) {
    FlValue* url_value = fl_value_lookup_string(args, "initialUrl");
    const char* url = fl_value_get_string(url_value);

    WebKitWebView* web_view = WEBKIT_WEB_VIEW(webkit_web_view_new());
    webkit_web_view_load_uri(web_view, url);

    g_signal_connect(web_view, "notify::estimated-load-progress",
                     G_CALLBACK(on_progress_changed), plugin);
    g_signal_connect(web_view, "load-changed",
                     G_CALLBACK(on_load_changed), plugin);

    int view_id = plugin->next_view_id++;
    plugin->views[view_id] = web_view;

    g_autoptr(FlValue) response = fl_value_new_map();
    fl_value_set_string_take(response, "viewId", fl_value_new_int(view_id));
    g_autoptr(FlMethodResponse) success = FL_METHOD_RESPONSE(
        fl_method_success_response_new(response));
    g_autoptr(GError) error = nullptr;
    fl_method_call_respond(method_call, success, &error);
    if (error != nullptr) {
      g_warning("Failed to send response: %s", error->message);
    }
  } else if (strcmp(method, "loadUrl") == 0) {
    int view_id = fl_value_get_int(fl_value_lookup_string(args, "viewId"));
    const char* url = fl_value_get_string(fl_value_lookup_string(args, "url"));
    
    auto it = plugin->views.find(view_id);
    if (it != plugin->views.end()) {
      webkit_web_view_load_uri(it->second, url);
      g_autoptr(FlMethodResponse) success = FL_METHOD_RESPONSE(
          fl_method_success_response_new(nullptr));
      g_autoptr(GError) error = nullptr;
      fl_method_call_respond(method_call, success, &error);
      if (error != nullptr) {
        g_warning("Failed to send response: %s", error->message);
      }
    } else {
      g_autoptr(FlMethodResponse) error_response = FL_METHOD_RESPONSE(
          fl_method_error_response_new("invalid_view_id",
                                       "View ID not found",
                                       nullptr));
      g_autoptr(GError) error = nullptr;
      fl_method_call_respond(method_call, error_response, &error);
      if (error != nullptr) {
        g_warning("Failed to send error response: %s", error->message);
      }
    }
  } else if (strcmp(method, "goBack") == 0) {
    int view_id = fl_value_get_int(fl_value_lookup_string(args, "viewId"));
    auto it = plugin->views.find(view_id);
    if (it != plugin->views.end()) {
      webkit_web_view_go_back(it->second);
      update_navigation_state(plugin, it->second);
      g_autoptr(FlMethodResponse) success = FL_METHOD_RESPONSE(
          fl_method_success_response_new(nullptr));
      g_autoptr(GError) error = nullptr;
      fl_method_call_respond(method_call, success, &error);
      if (error != nullptr) {
        g_warning("Failed to send response: %s", error->message);
      }
    } else {
      g_autoptr(FlMethodResponse) error_response = FL_METHOD_RESPONSE(
          fl_method_error_response_new("invalid_view_id",
                                       "View ID not found",
                                       nullptr));
      g_autoptr(GError) error = nullptr;
      fl_method_call_respond(method_call, error_response, &error);
      if (error != nullptr) {
        g_warning("Failed to send error response: %s", error->message);
      }
    }
  } else if (strcmp(method, "goForward") == 0) {
    int view_id = fl_value_get_int(fl_value_lookup_string(args, "viewId"));
    auto it = plugin->views.find(view_id);
    if (it != plugin->views.end()) {
      webkit_web_view_go_forward(it->second);
      update_navigation_state(plugin, it->second);
      g_autoptr(FlMethodResponse) success = FL_METHOD_RESPONSE(
          fl_method_success_response_new(nullptr));
      g_autoptr(GError) error = nullptr;
      fl_method_call_respond(method_call, success, &error);
      if (error != nullptr) {
        g_warning("Failed to send response: %s", error->message);
      }
    } else {
      g_autoptr(FlMethodResponse) error_response = FL_METHOD_RESPONSE(
          fl_method_error_response_new("invalid_view_id",
                                       "View ID not found",
                                       nullptr));
      g_autoptr(GError) error = nullptr;
      fl_method_call_respond(method_call, error_response, &error);
      if (error != nullptr) {
        g_warning("Failed to send error response: %s", error->message);
      }
    }
  } else if (strcmp(method, "reload") == 0) {
    int view_id = fl_value_get_int(fl_value_lookup_string(args, "viewId"));
    auto it = plugin->views.find(view_id);
    if (it != plugin->views.end()) {
      webkit_web_view_reload(it->second);
      g_autoptr(FlMethodResponse) success = FL_METHOD_RESPONSE(
          fl_method_success_response_new(nullptr));
      g_autoptr(GError) error = nullptr;
      fl_method_call_respond(method_call, success, &error);
      if (error != nullptr) {
        g_warning("Failed to send response: %s", error->message);
      }
    } else {
      g_autoptr(FlMethodResponse) error_response = FL_METHOD_RESPONSE(
          fl_method_error_response_new("invalid_view_id",
                                       "View ID not found",
                                       nullptr));
      g_autoptr(GError) error = nullptr;
      fl_method_call_respond(method_call, error_response, &error);
      if (error != nullptr) {
        g_warning("Failed to send error response: %s", error->message);
      }
    }
  } else {
    g_autoptr(FlMethodResponse) not_implemented = FL_METHOD_RESPONSE(
        fl_method_not_implemented_response_new());
    g_autoptr(GError) error = nullptr;
    fl_method_call_respond(method_call, not_implemented, &error);
    if (error != nullptr) {
      g_warning("Failed to send not implemented response: %s", error->message);
    }
  }
}

void linux_webview_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  LinuxWebviewPlugin* plugin = LINUX_WEBVIEW_PLUGIN(
      g_object_new(linux_webview_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "linux_webview",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel,
                                            method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  plugin->channel = FL_METHOD_CHANNEL(g_object_ref(channel));
  g_object_unref(plugin);
}
