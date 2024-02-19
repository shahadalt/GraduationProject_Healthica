import '../../imports.dart';

class PageLogin extends StatefulWidget {
  const PageLogin({Key? key}) : super(key: key);

  static const routeName = 'login';

  @override
  State<PageLogin> createState() => _PageLoginState();
}

class _PageLoginState extends State<PageLogin> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(context.tr.login),
        actions: [
          //settings page
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).pushNamed(PageSettings.routeName);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(25),
        children: [
          const SizedBox(height: 10),
          const Center(child: Icon(Icons.person, size: 100)),
          const SizedBox(height: 15),
          TextField(
            controller: emailController,
            textDirection: TextDirection.ltr,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(border: const OutlineInputBorder(), labelText: context.tr.email),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: passController,
            textDirection: TextDirection.ltr,
            obscureText: true,
            decoration: InputDecoration(border: const OutlineInputBorder(), labelText: context.tr.password),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () async {
              try {
                await appSate.signInWithEmailAndPassword(emailController.text, passController.text);
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed(PageHome.routeName);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr.loginFailedPleaseTryAgain)));
              }
            },
            child: Text(context.tr.login),
          ),
          const SizedBox(height: 15),
          TextButton(
            onPressed: () => Navigator.of(context).pushReplacementNamed(PageRegister.routeName),
            child: Text(context.tr.register),
          ),
        ],
      ),
    );
  }
}
