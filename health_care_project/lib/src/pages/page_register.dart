import '../../imports.dart';

class PageRegister extends StatefulWidget {
  const PageRegister({Key? key}) : super(key: key);

  static const routeName = 'register';

  @override
  State<PageRegister> createState() => _PageRegisterState();
}

class _PageRegisterState extends State<PageRegister> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(context.tr.register),
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
            controller: nameController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(border: const OutlineInputBorder(), labelText: context.tr.name),
          ),
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
            obscureText: true,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(border: const OutlineInputBorder(), labelText: context.tr.password),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () async {
              try {
                await appSate.createUserWithEmailAndPassword(nameController.text, emailController.text, passController.text);
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed(PageHome.routeName);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr.registrationFailedPleaseTryAgain)));
              }
            },
            child: Text(context.tr.register),
          ),
          const SizedBox(height: 15),
          TextButton(
            onPressed: () => Navigator.of(context).pushReplacementNamed(PageLogin.routeName),
            child: Text(context.tr.login),
          ),
        ],
      ),
    );
  }
}
