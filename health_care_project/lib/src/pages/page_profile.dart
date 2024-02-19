import '../../imports.dart';

class PageProfile extends StatefulWidget {
  const PageProfile({Key? key}) : super(key: key);

  static const routeName = 'profile';

  @override
  State<PageProfile> createState() => _PageProfileState();
}

class _PageProfileState extends State<PageProfile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController bloodTypeController = TextEditingController(text: "A");
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController genderController = TextEditingController(text: 'Male');

  bool loading = true;

  @override
  void initState() {
    super.initState();

    appSate.userDataGet.then((value) {
      Map<String, dynamic> data = value.data() ?? {};
      //
      nameController.text = data['name'] ?? "";
      bloodTypeController.text = data['bloodType'] ?? "A";
      heightController.text = data['height'] ?? "";
      weightController.text = data['weight'] ?? "";
      genderController.text = data['gender'] ?? "Male";
      setState(() => loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(centerTitle: true, title: Text(context.tr.profile)),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Builder(builder: (context) {
            if (loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              children: [
                const SizedBox(height: 10),
                Center(
                  child: GestureDetector(
                      onTap: () async {
                        // Pick an image
                        final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 40);

                        if (image != null) {
                          var photo = base64Encode(await image.readAsBytes());

                          await appSate.userDataUpdate({'photo': photo});

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr.yourAvatarUpdatedSuccessfully)));
                          }
                        }
                      },
                      child: const UserAvatar(size: 100)),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(border: const OutlineInputBorder(), labelText: context.tr.name),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(border: const OutlineInputBorder(), labelText: context.tr.weight),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(border: const OutlineInputBorder(), labelText: context.tr.height),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField(
                  decoration: InputDecoration(border: const OutlineInputBorder(), labelText: context.tr.bloodType),
                  value: bloodTypeController.text,
                  items: const [
                    DropdownMenuItem(value: 'A', child: Text('A')),
                    DropdownMenuItem(value: 'B', child: Text('B')),
                    DropdownMenuItem(value: 'AB', child: Text('AB')),
                    DropdownMenuItem(value: 'O', child: Text('O')),
                  ],
                  onChanged: (value) => bloodTypeController.text = value.toString(),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField(
                  decoration: InputDecoration(border: const OutlineInputBorder(), labelText: context.tr.gender),
                  value: genderController.text,
                  items: [
                    DropdownMenuItem(value: 'Male', child: Text(context.tr.male)),
                    DropdownMenuItem(value: 'Female', child: Text(context.tr.female)),
                  ],
                  onChanged: (value) => genderController.text = value.toString(),
                ),

                //
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () {
                    appSate.userDataUpdate({
                      'name': nameController.text,
                      'bloodType': bloodTypeController.text,
                      'height': heightController.text,
                      'weight': weightController.text,
                      'gender': genderController.text,
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr.profileUpdatedSuccessfully)));
                  },
                  child: Text(context.tr.save),
                ),
              ],
            );
          }),
        ));
  }
}
