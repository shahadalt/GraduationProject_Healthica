import '../../imports.dart';

class PageSplash extends StatefulWidget {
  const PageSplash({Key? key}) : super(key: key);

  static const routeName = 'spalsh';

  @override
  State<PageSplash> createState() => _PageSplashState();
}

class _PageSplashState extends State<PageSplash> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    Timer(const Duration(seconds: 3), route);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setSystemUIOverlayStyle(context);
  }

  route() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    FirebaseAuth auth = FirebaseAuth.instance;

    if (auth.currentUser != null) {
      Navigator.pushReplacementNamed(context, PageHome.routeName);
    } else {
      Navigator.pushReplacementNamed(context, PageLogin.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Lottie.asset('assets/animation/healthcare.json')),
    );
  }
}
