import '../../imports.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    Key? key,
    this.size = 30,
  }) : super(key: key);

  final double? size;

  Widget emptyAvatar() {
    return ClipOval(
      child: Image.network(
        'https://abs.twimg.com/sticky/default_profile_images/default_profile_200x200.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!appSate.isLoggedIn) {
      return emptyAvatar();
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: appSate.userDataStream,
        builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> sn) {
          if (sn.hasError || sn.connectionState == ConnectionState.waiting) {
            return emptyAvatar();
          }
          Map<String, dynamic> data = sn.data?.data() ?? <String, dynamic>{};

          String? photo = data['photo'];
          if (photo == null || photo.isEmpty) {
            return emptyAvatar();
          }

          return ClipOval(
            child: Image.memory(
              base64Decode(photo),
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          );
        });
  }
}
