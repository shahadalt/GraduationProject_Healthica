import 'package:flutter_animate/flutter_animate.dart';

import '../../imports.dart';

class PageHome extends StatefulWidget {
  const PageHome({Key? key}) : super(key: key);

  static const routeName = 'home';

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  @override
  void initState() {
    super.initState();

    appSate.medicancesStream.listen((event) {
      for (var doc in event.docs) {
        // doc.reference.delete();
        Map<String, dynamic> data = doc.data();

        String name = data['name'] ?? '';

        List timesList = (data['times'] ?? []);
        List<DateTime> times = timesList.map((e) {
          final format = DateFormat.jm('en_US');

          var t = format.parse(e);
          return DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            t.hour,
            t.minute,
          );
        }).toList();

        // print(times);
        for (var time in times) {
          // print(time.isBefore(DateTime.now()));
          if (time.isBefore(DateTime.now())) continue;
          // print(time);
          Alarm.set(
            alarmDateTime: time,
            assetAudio: "assets/sounds/alarm.mp3",
            onRing: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  scrollable: true,
                  content: Center(child: MedicaneCard(doc: doc, showDelete: false)),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Alarm.stop();
                        Navigator.pop(context);
                      },
                      child: Text(context.tr.cancel),
                    ),
                  ],
                ),
              );
            },
            loopAudio: true,
            notifTitle: name,
            notifBody: context.tr.timeToTakeYourMedicine,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 25),
        child: DrawerWidget(),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text(context.tr.home),
        automaticallyImplyLeading: true,
        leading: Builder(builder: (context) {
          return IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const UserAvatar(size: 30),
          );
        }),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(PageSettings.routeName);
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20), children: [
        //latest announcement
        Text(context.tr.latestAnnouncement, style: Theme.of(context).textTheme.titleLarge),
        latestAnnouncement().animate().fadeIn().slide(),
        const SizedBox(height: 20),
        //todays medications
        Text(context.tr.todaysMedications, style: Theme.of(context).textTheme.titleLarge),
        todaysMedications().animate().shake(),
        //
        //latest friends invitation
        Text(context.tr.friendsInvitation, style: Theme.of(context).textTheme.titleLarge),
        latestInvitation().animate().slide(),
        //
        const SizedBox(height: 20),

        const SizedBox(height: 50),
      ]),
    );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> latestAnnouncement() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: appSate.announcementsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(context.tr.somethingWentWrong));
        }

        if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(child: Text(context.tr.noAnnouncementsYet));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnnouncementCard(doc: docs.first, showDelete: false),
              //show more button
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pushNamed(PageAnnouncements.routeName),
                  child: Text(context.tr.showMore),
                ),
              ),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> latestInvitation() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: appSate.myInvitionsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(context.tr.somethingWentWrong));
        }

        if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                child: Text(context.tr.noInvitationsYet),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InvitationCard(doc: docs.first, showDelete: false),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> todaysMedications() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: appSate.medicancesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
            child: Text(context.tr.somethingWentWrong),
          ));
        }

        if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                child: Text(context.tr.noMedicancesYet),
              ),
            );
          }

          String today = weekdayToString(DateTime.now().weekday, context);
          Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> todaysDocs = docs.where((QueryDocumentSnapshot<Map<String, dynamic>> element) {
            Map<String, dynamic> data = element.data();
            List days = data['days'];
            return days.contains(today);
          });

          return Column(
            children: [
              ...todaysDocs.map((doc) => MedicaneCard(doc: doc, showDelete: false)),
              //
              if (todaysDocs.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                    child: Text(context.tr.noMedicancesForYoday),
                  ),
                ),

              //show more button
              if (todaysDocs.isNotEmpty)
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pushNamed(PageMedicances.routeName),
                    child: Text(context.tr.showAll),
                  ),
                ),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }
}

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: appSate,
        builder: (context, child) {
          return Drawer(
            child: ListView(children: [
              const SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: () {
                    if (appSate.isLoggedIn) {
                      Navigator.of(context).pushNamed(PageProfile.routeName);
                    }
                  },
                  child: const UserAvatar(size: 100),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                appSate.userName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 15),
              if (!appSate.isLoggedIn)
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(context.tr.login),
                  onTap: () => Navigator.of(context).pushNamed(PageLogin.routeName),
                ),
              if (appSate.isLoggedIn) ...[
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(context.tr.profile),
                  onTap: () => Navigator.of(context).pushNamed(PageProfile.routeName),
                ),
                ListTile(
                  leading: const Icon(Icons.announcement),
                  title: Text(context.tr.announcements),
                  onTap: () => Navigator.of(context).pushNamed(PageAnnouncements.routeName),
                ),
                ListTile(
                  leading: const Icon(Icons.health_and_safety),
                  title: Text(context.tr.medicances),
                  onTap: () => Navigator.of(context).pushNamed(PageMedicances.routeName),
                ),
                ListTile(
                  leading: const Icon(Icons.people),
                  title: Text(context.tr.friends),
                  onTap: () => Navigator.of(context).pushNamed(PageFriends.routeName),
                ),
                ListTile(
                    leading: const Icon(Icons.share),
                    title: Text(context.tr.share),
                    onTap: () {
                      Share.share('Check out this amazing app, you can download it for Play store using this url: https://play.google.com/store/apps/details?id=com.app', subject: 'Health App');
                    }),
              ],
              if (appSate.isLoggedIn) ...[
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text(context.tr.logout),
                  onTap: () {
                    appSate.logout();
                    Navigator.of(context).pushReplacementNamed(PageLogin.routeName);
                  },
                ),
              ],
            ]),
          );
        });
  }
}
