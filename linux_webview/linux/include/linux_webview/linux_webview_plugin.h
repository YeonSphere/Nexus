#ifndef FLUTTER_PLUGIN_LINUX_WEBVIEW_PLUGIN_H_
#define FLUTTER_PLUGIN_LINUX_WEBVIEW_PLUGIN_H_

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __attribute__((visibility("default")))
#else
#define FLUTTER_PLUGIN_EXPORT
#endif

#define LINUX_WEBVIEW_TYPE_PLUGIN (linux_webview_plugin_get_type())

FLUTTER_PLUGIN_EXPORT G_DECLARE_FINAL_TYPE(LinuxWebviewPlugin, linux_webview_plugin,
                                       LINUX_WEBVIEW, PLUGIN,
                                       GObject)

FLUTTER_PLUGIN_EXPORT void linux_webview_plugin_register_with_registrar(
    FlPluginRegistrar* registrar);

G_END_DECLS

#endif  // FLUTTER_PLUGIN_LINUX_WEBVIEW_PLUGIN_H_
