import '../../imports.dart';

class PageMedicances extends StatefulWidget {
  const PageMedicances({Key? key}) : super(key: key);

  static const routeName = 'medicances';

  @override
  State<PageMedicances> createState() => _PageMedicancesState();
}

class _PageMedicancesState extends State<PageMedicances> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(context.tr.medicances),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return SimpleDialog(
                      title: Text(context.tr.addMedicance),
                      contentPadding: const EdgeInsets.all(15),
                      children: const [AddMedicaneWidget()],
                    );
                  });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: appSate.medicancesStream,
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(context.tr.somethingWentWrong));
          }

          if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(child: Text(context.tr.noMedicancesYet));
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            child: ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) => MedicaneCard(doc: docs[index]),
            ),
          );
        },
      ),
    );
  }
}

class MedicaneCard extends StatelessWidget {
  const MedicaneCard({super.key, required this.doc, this.showDelete = true});
  final bool showDelete;

  final QueryDocumentSnapshot<Map<String, dynamic>> doc;

  String frequencyToString(int frequency, BuildContext context) {
    switch (frequency) {
      case 1:
        return context.tr.onceADay;
      case 2:
        return context.tr.twiceADay;
      case 3:
        return context.tr.threeTimesADay;
      default:
        return '';
    }
  }

  Widget dayWidget(String day, bool check) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (check) const Icon(Icons.check, color: Colors.green),
        if (!check) const Icon(Icons.close, color: Colors.red),
        Builder(builder: (context) => Text(translateWeekDays(day, context))),
        const SizedBox(width: 15),
      ],
    );
  }

  List<Widget> daysToWidget(List days) {
    List<Widget> daysWidget = [];

    for (var i = 0; i < allDays.length; i++) {
      if (days.contains(allDays[i])) {
        daysWidget.add(dayWidget(allDays[i], true));
      } else {
        daysWidget.add(dayWidget(allDays[i], false));
      }
    }
    return daysWidget;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = doc.data();
    String name = data['name'] ?? '';
    String image = data['image'] ?? '';
    String frequency = frequencyToString(data['frequency'], context);
    List<Widget> days = daysToWidget(data['days']);

    List timesList = (data['times'] ?? []);
    List<String> times = timesList.map((e) {
      final format = DateFormat.jm();
      return TimeOfDay.fromDateTime(format.parse(e)).format(context);
    }).toList();

    return Stack(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(frequency),
                const SizedBox(height: 10),
                if (times.isNotEmpty) ...[
                  Text(times.join(' - ')),
                  const SizedBox(height: 10),
                ],
                if (image.isNotEmpty) ...[
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          child: Image.memory(
                            base64Decode(image),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                    child: Image.memory(
                      base64Decode(image),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Wrap(children: days),
                const SizedBox(height: 10),
                if (showDelete)
                  Align(
                    alignment: AlignmentDirectional.bottomEnd,
                    child: TextButton(
                      onPressed: () async => await doc.reference.delete(),
                      child: Text(context.tr.delete),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Positioned.directional(
          textDirection: Directionality.of(context),
          top: 10,
          end: 10,
          child: const Opacity(
            opacity: 0.1,
            child: Icon(Icons.medication_liquid, size: 60),
          ),
        )
      ],
    );
  }
}

class AddMedicaneWidget extends StatefulWidget {
  const AddMedicaneWidget({super.key});

  @override
  State<AddMedicaneWidget> createState() => _AddMedicaneWidgetState();
}

class _AddMedicaneWidgetState extends State<AddMedicaneWidget> {
  TextEditingController nameController = TextEditingController();
  TextEditingController frequencyController = TextEditingController(text: '1');
  List days = [];
  List<TimeOfDay> times = [];
  String image = '';
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: nameController,
          decoration: InputDecoration(border: const OutlineInputBorder(), labelText: context.tr.name),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.tr.image),
            Row(
              children: [
                IconButton(
                  onPressed: () async {
                    final XFile? file = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 40);

                    if (file != null) {
                      image = base64Encode(await file.readAsBytes());
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.camera_alt),
                ),
                IconButton(
                  onPressed: () async {
                    final XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 40);

                    if (file != null) {
                      image = base64Encode(await file.readAsBytes());
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.image),
                ),
              ],
            ),
          ],
        ),
        if (image.trim().isNotEmpty)
          Image.memory(
            base64Decode(image),
            height: 100,
            fit: BoxFit.cover,
          ),
        const SizedBox(height: 15),
        DropdownButtonFormField(
          decoration: InputDecoration(border: const OutlineInputBorder(), labelText: context.tr.frequency),
          value: frequencyController.text,
          items: [
            DropdownMenuItem(value: '1', child: Text(context.tr.onceADay)),
            DropdownMenuItem(value: '2', child: Text(context.tr.twiceADay)),
            DropdownMenuItem(value: '3', child: Text(context.tr.threeTimesADay)),
          ],
          onChanged: (value) {
            frequencyController.text = value.toString();
            setState(() => times.clear());
          },
        ),
        const SizedBox(height: 15),
        ...List.generate(
          int.parse(frequencyController.text),
          (i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: TextField(
              controller: TextEditingController(text: (times.length >= i + 1) ? times[i].format(context) : ""),
              decoration: InputDecoration(border: const OutlineInputBorder(), labelText: context.tr.time),
              onTap: () {
                showTimePicker(context: context, initialTime: TimeOfDay.now()).then((value) {
                  if (value != null) {
                    setState(() {
                      times.insert(i, value);
                    });
                  }
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 15),
        ...allDays.map(
          (day) => CheckboxListTile(
              title: Text(translateWeekDays(day, context)),
              value: days.contains(day),
              onChanged: (v) {
                if (v == true) {
                  setState(() => days.add(day));
                } else {
                  setState(() => days.remove(day));
                }
              }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr.cancel),
            ),
            TextButton(
              onPressed: () async {
                await appSate.medicancesAdd(
                  context,
                  nameController.text,
                  int.tryParse(frequencyController.text) ?? 1,
                  days,
                  image,
                  times,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text(context.tr.add),
            ),
          ],
        ),
      ],
    );
  }
}

//dont translate this
String weekdayToString(int weekday, BuildContext context) {
  switch (weekday) {
    case 1:
      return 'Monday';
    case 2:
      return 'Tuesday';
    case 3:
      return 'Wednesday';
    case 4:
      return 'Thursday';
    case 5:
      return 'Friday';
    case 6:
      return 'Saturday';
    case 7:
      return 'Sunday';
    default:
      return '';
  }
}

String translateWeekDays(String enDay, BuildContext context) {
  switch (enDay) {
    case 'Monday':
      return context.tr.monday;
    case 'Tuesday':
      return context.tr.tuesday;
    case 'Wednesday':
      return context.tr.wednesday;
    case 'Thursday':
      return context.tr.thursday;
    case 'Friday':
      return context.tr.friday;
    case 'Saturday':
      return context.tr.saturday;
    case 'Sunday':
      return context.tr.sunday;
    default:
      return '';
  }
}
