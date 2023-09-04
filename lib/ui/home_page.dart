import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:plantpulse/data/IoT/repositories/telemetry_data_repository.dart';
import 'package:plantpulse/data/user/repositories/user_repository.dart';
import 'package:plantpulse/ui/bottom_navigation_bar/tab_icon_data.dart';
import 'package:plantpulse/ui/devices/screen/devices_screen.dart';
import 'package:plantpulse/ui/diseases/disease_detection_page.dart';
import 'package:plantpulse/ui/farm/farm_management_page.dart';
import 'package:plantpulse/ui/profile/user_profile_page.dart';
import 'package:plantpulse/utils/message_handler.dart';

class HomePage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => HomePage());
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UserRepository _userRepository = UserRepository();
  late MessageHandler _messageHandler;
  List<TabIconData> _tabIconsList = TabIconData.tabIconsList;
  PersistentTabController _controller = PersistentTabController(initialIndex: 0);
  List<Widget> _tabList = [
    FarmManagementPage(
      pageTitle: 'Farm Management',
      key: ValueKey(1),
    ),

    DevicesScreen(
      pageTitle: 'Devices',
      key: ValueKey(2),
    ),

    // IoTMonitoringPage(
    //   pageTitle: 'IoT Monitoring',
    //   key: ValueKey(2),
    // ),
    DiseaseDetectionPage(
      pageTitle: 'Disease Detection',
      key: ValueKey(3),
    ),

    UserProfilePage(
      pageTitle: 'My Profile',
      key: ValueKey(4),
    ),
  ];
  void printToken() async {
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
  }

  @override
  void initState() {
    printToken();
    _messageHandler = MessageHandler(_userRepository)..generateToken();
    _tabIconsList.forEach((TabIconData tab) {
      tab.isSelected = false;
    });
    _tabIconsList[0].isSelected = true;

    _controller.addListener(() {
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserRepository>.value(
          value: _userRepository,
        ),
        RepositoryProvider<MessageHandler>.value(
          value: _messageHandler,
        ),
        RepositoryProvider<TelemetryDataRepository>(
          create: (_) => TelemetryDataRepository(),
        ),
      ],
      child: PersistentTabView(
        context,
        screens: _tabList,
        navBarHeight: 70,
        hideNavigationBar: false,
        items: _tabIconsList.map((TabIconData tab) {
          return PersistentBottomNavBarItem(
            activeColorPrimary:
                _controller.index == tab.index ? Theme.of(context).primaryColor : Colors.grey,
            icon: _controller.index == tab.index
                ? Image.asset(
                    tab.selectedImagePath,
                    width: 24,
                    height: 24,
                  )
                : Image.asset(
                    tab.imagePath,
                    width: 24,
                    height: 24,
                  ),
            title: tab.label,
            textStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          );
        }).toList(),
        controller: _controller,
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(20.0),
          colorBehindNavBar: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, 0), // changes position of shadow
            ),
          ],
        ),
        navBarStyle: NavBarStyle.style6, // Choose the nav bar style with this property.
      ),
    );
  }
}
