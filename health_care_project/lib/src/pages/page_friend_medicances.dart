import '../../imports.dart';

class PageFriendMedicances extends StatefulWidget {
  const PageFriendMedicances({Key? key}) : super(key: key);

  static const routeName = 'friendMedicances';

  @override
  State<PageFriendMedicances> createState() => _PageFriendMedicancesState();
}

class _PageFriendMedicancesState extends State<PageFriendMedicances> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;

    String uid = args['uid'] as String;
    String name = args['name'] as String;
    String image = (args['image'] as String?) ?? '';

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (image.isNotEmpty) ...[
              ClipOval(
                child: Image.memory(
                  base64Decode(image),
                  width: 25,
                  height: 25,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10)
            ],
            Text(name),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: appSate.friendMedicancesStream(uid),
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
              itemBuilder: (context, index) => MedicaneCard(doc: docs[index], showDelete: false),
            ),
          );
        },
      ),
    );
  }
}
