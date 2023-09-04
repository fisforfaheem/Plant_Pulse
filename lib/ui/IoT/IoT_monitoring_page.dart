import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plantpulse/data/IoT/models/telemetry_data.dart';
import 'package:plantpulse/data/IoT/repositories/telemetry_data_repository.dart';
import 'package:plantpulse/ui/IoT/reload_bar.dart';
import 'package:plantpulse/ui/IoT/reload_time.dart';
import 'package:plantpulse/ui/IoT/telemetry_data_card.dart';
import 'package:plantpulse/ui/IoT/telemetry_data_card_item.dart';
import 'package:plantpulse/ui/devices/repository/devices_repository.dart';
import 'package:plantpulse/ui/widgets/tab_page.dart';
import 'package:provider/provider.dart';

class IoTMonitoringPage extends TabPage {
  const IoTMonitoringPage({required String pageTitle, this.hostname}) : super(pageTitle: pageTitle);

  final String? hostname;

  @override
  _IoTMonitoringPageState createState() => _IoTMonitoringPageState();
}

class _IoTMonitoringPageState extends TabPageState<IoTMonitoringPage> {
  final List<TelemetryDataCardItem> _cardItems = TelemetryDataCardItem.cardItems;
  final ReloadTime _reloadTime = ReloadTime();

  @override
  void initState() {
    tabListView.add(ReloadBar());
    _cardItems.forEach((i) {
      tabListView.add(
        TelemetryDataCard(
          cardItem: i,
          reloadTime: _reloadTime,
        ),
      );
    });
    super.initState();
    DevicesRepository().getFullDeviceData(widget.hostname!);
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<TelemetryDataRepository>(
      create: (_) => TelemetryDataRepository(),
      child: ChangeNotifierProvider<ReloadTime>.value(
        value: _reloadTime,
        child: super.build(context),
      ),
    );
  }

  @override
  Widget buildTabListView() {
    return Provider(
      create: (_) => TelemetryData(
        timestamp: DateTime.now(),
        value: '0',
      ),
      child: RefreshIndicator(
        color: Colors.black,
        backgroundColor: Colors.white,
        onRefresh: () async {
          await Future.delayed(Duration(seconds: 2));
          setState(() {});
        },
        child: SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.only(
            top: AppBar().preferredSize.height + MediaQuery.of(context).padding.top + 24,
            bottom: 70 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(children: tabListView),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:plantpulse/data/IoT/models/telemetry_data.dart';
// import 'package:plantpulse/data/IoT/repositories/telemetry_data_repository.dart';
// import 'package:plantpulse/ui/IoT/reload_time.dart';
// import 'package:plantpulse/ui/IoT/telemetry_data_card.dart';
// import 'package:plantpulse/ui/IoT/telemetry_data_card_item.dart';
// import 'package:plantpulse/ui/devices/repository/devices_repository.dart';
// import 'package:provider/provider.dart';

// class IoTMonitoringPage extends StatefulWidget {
//   const IoTMonitoringPage({required this.hostName});
//   final String hostName;

//   @override
//   _IoTMonitoringPageState createState() => _IoTMonitoringPageState();
// }

// class _IoTMonitoringPageState extends State<IoTMonitoringPage> {
//   final List<TelemetryDataCardItem> _cardItems = TelemetryDataCardItem.cardItems;
//   final ReloadTime _reloadTime = ReloadTime();

//   @override
//   void initState() {
//     // tabListView.add(ReloadBar());
//     // _cardItems.forEach((i) {
//     //   tabListView.add(
//     //     TelemetryDataCard(
//     //       cardItem: i,
//     //       reloadTime: _reloadTime,
//     //     ),
//     //   );
//     // });
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: FutureBuilder(
//             future: DevicesRepository().getFullDeviceData(widget.hostName),
//             builder: (context, snapshot) {
//               if (snapshot.hasData) {
//                 if (snapshot.data?.data?.isNotEmpty == true) {
//                   return ListView.builder(
//                     itemCount: snapshot.data!.data!.length,
//                     itemBuilder: (context, index) {
//                       final record = snapshot.data!.data![index];
//                       final item = TelemetryDataCardItem(
//                         title: 'Title',
//                         description: 'Discription',
//                         unit: '%',
//                         imagePath:
//                             getImagePath(record.moisture, record.temperature, record.humidity),
//                         color1: Colors.yellow,
//                         color2: Colors.orange,
//                         data: 'data',
//                         lowerBoundary: 2.4,
//                         upperBoundary: 1.4,
//                         lowerThreshold: 1.3,
//                         upperThreshold: 4.2,
//                       );

//                       return RepositoryProvider<TelemetryDataRepository>(
//                         create: (_) => TelemetryDataRepository(),
//                         child: Provider<TelemetryData>(
//                           create: (_) => TelemetryData(timestamp: DateTime.now(), value: '0'),
//                           child: TelemetryDataCard(
//                             cardItem: item,
//                             reloadTime: ReloadTime(),
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 }
//                 return Center(child: Text('No data found'));
//               } else {
//                 return Center(child: CircularProgressIndicator());
//               }
//             }),
//       ),
//     );
//   }

//   String getImagePath(num? moisture, num? temperature, num? humidity) {
//     if (moisture != null && moisture != 0) return 'assets/images/soil_moisture.png';
//     if (temperature != null && temperature != 0) return 'assets/images/air_temperature.png';
//     if (humidity != null && humidity != 0) return 'assets/images/air_humidity.png';
//     return 'assets/images/soil_moisture.png';
//   }
// }
