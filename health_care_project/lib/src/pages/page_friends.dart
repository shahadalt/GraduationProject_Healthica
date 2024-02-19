import '../../imports.dart';

class PageFriends extends StatefulWidget {
  const PageFriends({Key? key}) : super(key: key);

  static const routeName = 'friends';

  @override
  State<PageFriends> createState() => _PageFriendsState();
}

class _PageFriendsState extends State<PageFriends> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(context.tr.friends),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    TextEditingController emailController = TextEditingController();

                    return AlertDialog(
                      title: Text(context.tr.inviteFriend),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(labelText: context.tr.email),
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
                            await appSate.inviteFriend(emailController.text);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invitation sent successfully')));

                              Navigator.pop(context);
                            }
                          },
                          child: Text(context.tr.invite),
                        ),
                      ],
                    );
                  });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: appSate.friendsStream,
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(context.tr.somethingWentWrong));
          }

          if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(child: Text(context.tr.noFriendsYet));
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            child: ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) => FriendCard(doc: docs[index]),
            ),
          );
        },
      ),
    );
  }
}

class InvitationCard extends StatelessWidget {
  const InvitationCard({
    super.key,
    required this.doc,
    this.showDelete = true,
  });

  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final bool showDelete;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = doc.data();
    //
    String senderUid = data['SenderUid'] ?? "";
    String senderName = data['SenderName'] ?? "";
    String senderEmail = data['SenderEmail'] ?? "";
    String senderImage = data['SenderImage'] ?? "";

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipOval(
                  child: Image.memory(
                    base64Decode(senderImage),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(senderName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(senderEmail),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),
            //delete button only for admin
            Align(
              alignment: AlignmentDirectional.bottomEnd,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      await doc.reference.set({'accepted': true}, SetOptions(merge: true));
                      await appSate.addFriend(senderUid, senderName, senderEmail, senderImage);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Friend added successfully')));
                      }
                    },
                    child: Text(context.tr.accept),
                  ),
                  TextButton(
                    onPressed: () async {
                      await doc.reference.set({'accepted': false}, SetOptions(merge: true));
                    },
                    child: Text(context.tr.reject),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FriendCard extends StatelessWidget {
  const FriendCard({super.key, required this.doc, this.showDelete = true});

  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final bool showDelete;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = doc.data();
    //
    String uid = data['uid'] ?? "";
    String name = data['name'] ?? "";
    String email = data['email'] ?? "";
    String image = data['image'] ?? "";

    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(PageFriendMedicances.routeName, arguments: {'uid': uid, 'name': name, 'image': image});
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: Image.memory(
                      base64Decode(image),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(email),
                    ],
                  ),
                  if (showDelete) ...[
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        appSate.deleteFriend(uid);
                      },
                      child: Text(context.tr.delete),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 10),
              //delete button only for admin
            ],
          ),
        ),
      ),
    );
  }
}
