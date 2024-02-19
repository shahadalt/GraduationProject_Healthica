import '../../imports.dart';

class PageAnnouncements extends StatefulWidget {
  const PageAnnouncements({Key? key}) : super(key: key);

  static const routeName = 'announcements';

  @override
  State<PageAnnouncements> createState() => _PageAnnouncementsState();
}

class _PageAnnouncementsState extends State<PageAnnouncements> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(context.tr.announcements),
        actions: [
          //add announcement button only for admin
          if (appSate.isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    TextEditingController titleController = TextEditingController();
                    TextEditingController contentController = TextEditingController();

                    return AlertDialog(
                      title: Text(context.tr.addAnnouncement),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: titleController,
                            decoration: InputDecoration(labelText: context.tr.title),
                          ),
                          const SizedBox(height: 5),
                          TextField(
                            controller: contentController,
                            maxLines: 2,
                            decoration: InputDecoration(labelText: context.tr.content),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(context.tr.cancel),
                        ),
                        TextButton(
                          onPressed: () async {
                            await appSate.announcementsAdd(titleController.text, contentController.text);
                            if (context.mounted) {
                              // getData();
                              Navigator.pop(context);
                            }
                          },
                          child: Text(context.tr.add),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: appSate.announcementsStream,
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(context.tr.somethingWentWrong));
          }

          if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(child: Text(context.tr.noAnnouncementsYet));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            itemCount: docs.length,
            itemBuilder: (context, index) => AnnouncementCard(doc: docs[index]),
          );
        },
      ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    super.key,
    required this.doc,
    this.showDelete = true,
  });

  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final bool showDelete;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = doc.data();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['title'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(data['content']),
            const SizedBox(height: 10),
            //delete button only for admin
            if (appSate.isAdmin && showDelete)
              Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: TextButton(
                  onPressed: () async {
                    await doc.reference.delete();
                  },
                  child: Text(context.tr.delete),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
