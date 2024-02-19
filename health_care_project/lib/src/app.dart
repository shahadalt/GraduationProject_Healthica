import '../imports.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The AnimatedBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return AnimatedBuilder(
      animation: appState,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          showSemanticsDebugger: false,
          debugShowCheckedModeBanner: false,
          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.
          restorationScopeId: 'app',

          // Provide the generated AppLocalizations to the MaterialApp. This
          // allows descendant Widgets to display the correct translations
          // depending on the user's locale.
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: appState.locale,

          // Use AppLocalizations to configure the correct application title
          // depending on the user's locale.
          //
          // The appTitle is defined in .arb files found in the localization
          // directory.
          onGenerateTitle: (BuildContext context) => AppLocalizations.of(context)!.home,

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.pink,
          ),
          darkTheme: ThemeData.dark(
            useMaterial3: true,
          ),
          themeMode: appState.themeMode,

          // Define a function to handle named routes in order to support
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case PageHome.routeName:
                    return const PageHome();

                  case PageLogin.routeName:
                    return const PageLogin();

                  case PageRegister.routeName:
                    return const PageRegister();

                  case PageProfile.routeName:
                    return const PageProfile();

                  case PageAnnouncements.routeName:
                    return const PageAnnouncements();

                  case PageMedicances.routeName:
                    return const PageMedicances();

                  case PageFriends.routeName:
                    return const PageFriends();

                  case PageFriendMedicances.routeName:
                    return const PageFriendMedicances();

                  case PageSettings.routeName:
                    return const PageSettings();

                  case PageSplash.routeName:
                  default:
                    return const PageSplash();
                }
              },
            );
          },
        );
      },
    );
  }
}
