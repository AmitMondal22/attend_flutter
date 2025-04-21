import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/common_utils.dart';
import 'home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final controller = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    controller.onInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 10),
                _buildUserInfo(),
                const SizedBox(height: 20),
                _buildClockInOutCard(),
                const SizedBox(height: 20),
                _buildQuickActions(),
                const SizedBox(height: 20),
                _buildLogoutButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Attend Master',
          style: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Icon(Icons.notifications_none),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey.withOpacity(0.1),
      ),
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.withOpacity(0.5),
            radius: 25,
            child: const Text(
              'AM',
              style: TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Amit Mondal',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              Text('Software Engineer', style: TextStyle(fontSize: 14)),
            ],
          ),
          const Spacer(),
          Column(
            children: [
              Text(getFormattedDate(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  )).marginOnly(bottom: 10),
              Obx(
                () => Text(
                  controller.currentTime.value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.deepOrangeAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClockInOutCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Clock In',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Clock Out',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => controller.clockInDataObj.value != null
                    ? Text(
                        controller.clockInDataObj.value!.clockInStatus == true
                            ? controller
                                .clockInDataObj.value!.clockInData!.inTime
                                .toString()
                            : '--:--:--',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black45,
                        ),
                      )
                    : const Text(
                        '--:--:--',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black45,
                        ),
                      ),
              ),
              Obx(
                () => controller.clockOutDataObj.value != null
                    ? Text(
                        controller.clockOutDataObj.value!.clockOutStatus == true
                            ? controller
                                .clockOutDataObj.value!.clockOutData!.outTime
                                .toString()
                            : '--:--:--',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black45,
                        ),
                      )
                    : const Text(
                        '--:--:--',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black45,
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() {
                bool isClockedIn = false;

                if (controller.clockInDataObj.value != null) {
                  isClockedIn = controller.clockInDataObj.value!.clockInStatus;
                }

                return ElevatedButton.icon(
                  onPressed: () async {
                    if (await controller.checkIsWithinCompanyRadius()) {
                      if (!isClockedIn) {
                        controller.clockIn();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isClockedIn
                        ? Colors.grey.withOpacity(0.5)
                        : Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    elevation: 0,
                  ),
                  icon: Icon(isClockedIn ? Icons.brightness_1 : Icons.login,
                      color: Colors.white, size: 18),
                  label: const Text(
                    'Clock In',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                );
              }),
              Obx(() {
                bool isClockedIn = false;

                if (controller.clockInDataObj.value != null) {
                  isClockedIn = controller.clockInDataObj.value!.clockInStatus;
                }

                return ElevatedButton.icon(
                  onPressed: () async {
                    if (isClockedIn) {
                      controller.clockOut();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isClockedIn
                        ? Colors.amber
                        : Colors.grey.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    elevation: 0,
                  ),
                  icon: Icon(isClockedIn ? Icons.logout : Icons.brightness_1,
                      color: Colors.white, size: 18),
                  label: const Text(
                    'Clock Out',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    List<Map<String, dynamic>> actions = [
      {'title': 'Check In', 'icon': Icons.login, 'color': Colors.redAccent},
      {'title': 'Check Out', 'icon': Icons.logout, 'color': Colors.blue},
      {
        'title': 'Daily Attendance',
        'icon': Icons.calendar_today,
        'color': Colors.green
      },
      {
        'title': 'Attendance Report',
        'icon': Icons.insert_chart,
        'color': Colors.orange
      },
      {'title': 'Leave Requests', 'icon': Icons.work, 'color': Colors.purple},
      {
        'title': 'Overtime Requests',
        'icon': Icons.access_time,
        'color': Colors.pink
      },
      {'title': 'Late Arrivals', 'icon': Icons.warning, 'color': Colors.teal},
      {
        'title': 'Early Departures',
        'icon': Icons.arrow_back,
        'color': Colors.yellow
      },
      {'title': 'Work from Home', 'icon': Icons.home, 'color': Colors.red},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        return _buildActionCard(actions[index]);
      },
    );
  }

  Widget _buildActionCard(Map<String, dynamic> action) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: action['color'].withOpacity(0.2),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action['icon'], color: action['color'], size: 30),
            const SizedBox(height: 5),
            Text(
              action['title'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Center(
        child: ElevatedButton.icon(
          onPressed: () {
            controller.logout();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            elevation: 0,
          ),
          icon: const Icon(Icons.logout, color: Colors.white),
          label: const Text(
            'Logout',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Get.delete<HomeController>();
    super.dispose();
  }
}
