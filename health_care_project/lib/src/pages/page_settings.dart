import '../../imports.dart';

/// Displays the various settings that can be customized by the user.
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class PageSettings extends StatelessWidget {
  const PageSettings({super.key});

  static const routeName = 'settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(context.tr.settings),
      ),
      body: AnimatedBuilder(
        animation: appSate,
        builder: (context, child) {
          setSystemUIOverlayStyle(context);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text(context.tr.theme, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 8),
                RadioListTile<ThemeMode>(
                  title: Text(context.tr.systemTheme),
                  value: ThemeMode.system,
                  groupValue: appSate.themeMode,
                  onChanged: (t) => appSate.updateThemeMode(t),
                ),
                RadioListTile<ThemeMode>(
                  title: Text(context.tr.lightTheme),
                  value: ThemeMode.light,
                  groupValue: appSate.themeMode,
                  onChanged: (t) => appSate.updateThemeMode(t),
                ),
                RadioListTile<ThemeMode>(
                  title: Text(context.tr.darkTheme),
                  value: ThemeMode.dark,
                  groupValue: appSate.themeMode,
                  onChanged: (t) => appSate.updateThemeMode(t),
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                Text(context.tr.language, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 8),
                RadioListTile<Locale>(
                  title: Text(context.tr.english),
                  value: const Locale('en'),
                  groupValue: appSate.locale,
                  onChanged: (t) => appSate.updateLocale(t),
                ),
                RadioListTile<Locale>(
                  title: Text(context.tr.arabic),
                  value: const Locale('ar'),
                  groupValue: appSate.locale,
                  onChanged: (t) => appSate.updateLocale(t),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
