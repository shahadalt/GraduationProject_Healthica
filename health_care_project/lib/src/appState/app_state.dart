import '../../imports.dart';

class AppState with ChangeNotifier {
  AppState(this._storageService);

  final StorageService _storageService;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //
  User? get _user => _auth.currentUser;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => userEmail == adminEmial;
  String get userUid => _user?.uid ?? "id";
  String get userName => _user?.displayName ?? "Hello";
  String get userEmail => _user?.email ?? "email";

  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }

  Future<UserCredential> signInWithEmailAndPassword(email, password) => _auth.signInWithEmailAndPassword(email: email, password: password);
  Future<UserCredential> createUserWithEmailAndPassword(name, email, password) async {
    UserCredential user = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await user.user?.updateDisplayName(name);
    await userDataUpdate({'name': name, 'email': email});
    notifyListeners();
    return user;
  }

  DocumentReference<Map<String, dynamic>> get _userDataDoc => FirebaseFirestore.instance.collection('users').doc(userUid);
  Future<DocumentSnapshot<Map<String, dynamic>>> get userDataGet => _userDataDoc.get();
  Future<void> userDataUpdate(Map<String, dynamic> data) async {
    String name = data['name'] ?? "";
    if (name.trim().isNotEmpty) {
      await _user?.updateDisplayName(name);
    }
    await _userDataDoc.set(data, SetOptions(merge: true));
    notifyListeners();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> get userDataStream => _userDataDoc.snapshots();
  //
  //
  CollectionReference<Map<String, dynamic>> get _medicancesCollection => _userDataDoc.collection('medicances');
  Stream<QuerySnapshot<Map<String, dynamic>>> get medicancesStream => _medicancesCollection.orderBy('date', descending: true).snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> friendMedicancesStream(String uid) =>
      FirebaseFirestore.instance.collection('users').doc(uid).collection('medicances').orderBy('date', descending: true).snapshots();

  Future<DocumentReference<Map<String, dynamic>>> medicancesAdd(
    BuildContext context,
    String name,
    int frequency,
    List days,
    String image,
    List<TimeOfDay> times,
  ) {
    return _medicancesCollection.add({
      'name': name,
      'frequency': frequency,
      'days': days,
      'image': image,
      'times': times.map((e) {
        return e.format(context).replaceAll("ص", "AM").replaceAll("م", "PM");
      }).toList(),
      'date': FieldValue.serverTimestamp(),
    });
  }

  CollectionReference<Map<String, dynamic>> get _friendsCollection => _userDataDoc.collection('friends');
  Stream<QuerySnapshot<Map<String, dynamic>>> get friendsStream => _friendsCollection.orderBy('date', descending: true).snapshots();

  CollectionReference<Map<String, dynamic>> get _invitionsCollection => FirebaseFirestore.instance.collection('invitions');
  Stream<QuerySnapshot<Map<String, dynamic>>> get myInvitionsStream =>
      FirebaseFirestore.instance.collection('invitions').where('email', isEqualTo: userEmail).where('accepted', isNull: true).snapshots();

  Future<DocumentReference<Map<String, dynamic>>> inviteFriend(String email) async {
    return _invitionsCollection.add({
      'SenderUid': userUid,
      'SenderName': userName,
      'SenderEmail': userEmail,
      'SenderImage': ((await userDataGet).data() ?? {})['photo'],
      //
      'email': email,
      'accepted': null,
      'date': FieldValue.serverTimestamp(),
    });
  }

  addFriend(String senderUid, String senderName, String senderEmail, String senderImage) async {
    // print(senderUid);
    // print(userUid);
    // print(senderEmail);
    // print(userEmail);

    await _friendsCollection.doc(senderUid).set({
      'uid': senderUid,
      'name': senderName,
      'email': senderEmail,
      'image': senderImage,
      'date': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance.collection('users').doc(senderUid).collection('friends').doc(userUid).set({
      'uid': userUid,
      'name': userName,
      'email': userEmail,
      'image': ((await userDataGet).data() ?? {})['photo'],
      'date': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  deleteFriend(String senderUid) {
    _friendsCollection.doc(senderUid).delete();
    FirebaseFirestore.instance.collection('users').doc(senderUid).collection('friends').doc(userUid).delete();
  }

  //
  //
  CollectionReference<Map<String, dynamic>> get _announcementsCollection => FirebaseFirestore.instance.collection('announcements');
  Stream<QuerySnapshot<Map<String, dynamic>>> get announcementsStream => _announcementsCollection.orderBy('date', descending: true).snapshots();
  // Future<QuerySnapshot<Map<String, dynamic>>> get announcementsGet => _announcementsCollection.get();
  Future<DocumentReference<Map<String, dynamic>>> announcementsAdd(String title, String content) {
    return _announcementsCollection.add({'title': title, 'content': content, 'date': FieldValue.serverTimestamp()});
  }

  //

  // Make ThemeMode a private variable so it is not updated directly without
  // also persisting the changes with the StorageService.
  late ThemeMode _themeMode;
  late Locale _locale;

  // Allow Widgets to read the user's preferred ThemeMode.
  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  /// Load the user's settings from the StorageService. It may load from a
  /// local database or the internet. The controller only knows it can load the
  /// settings from the service.
  Future<void> loadSate() async {
    _themeMode = await _storageService.themeMode();
    _locale = await _storageService.locale();

    // Important! Inform listeners a change has occurred.
    notifyListeners();
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;

    // Do not perform any work if new and old ThemeMode are identical
    // if (newThemeMode == _themeMode) return;

    // Otherwise, store the new ThemeMode in memory
    _themeMode = newThemeMode;

    // Important! Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    await _storageService.updateThemeMode(newThemeMode);
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateLocale(Locale? newLocale) async {
    if (newLocale == null) return;

    // Do not perform any work if new and old ThemeMode are identical
    // if (newLocale == _themeMode) return;

    // Otherwise, store the new ThemeMode in memory
    _locale = newLocale;

    // Important! Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    await _storageService.updateLocale(newLocale);
  }
}
