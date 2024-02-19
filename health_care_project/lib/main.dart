import 'imports.dart';

void main() async {
  //initialize widgets
  WidgetsFlutterBinding.ensureInitialized();

  await Alarm.init();

  //initialize firebase
  await Firebase.initializeApp();

  // Set up the AppState, which will glue user settings to multiple
  // Flutter Widgets.

  // Load app state while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await appSate.loadSate();

  // Run the app and pass in the AppState. The app listens to the
  // AppState for changes, then passes it further down to the all pages
  runApp(App(appState: appSate));
}
