import '../imports.dart';

//translate extension
extension StringExtension on BuildContext {
  String get locale => Localizations.localeOf(this).languageCode;
  AppLocalizations get tr => AppLocalizations.of(this)!;
}

//app state
final appSate = AppState(StorageService());

//admin email
String adminEmial = 'admin@email.com';

//dont translate this
List allDays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

//set system ui overlay style for Navigation Bar color
setSystemUIOverlayStyle(BuildContext context) async {
  await Future.delayed(const Duration(milliseconds: 300));
  if (context.mounted) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Theme.of(context).colorScheme.background,
      systemNavigationBarColor: Theme.of(context).colorScheme.background,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  }
}
