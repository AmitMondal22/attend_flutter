import 'package:attend_master/utils/colorful_log.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:attend_master/screens/calendar/calendar_screen.dart';
import 'package:attend_master/screens/reports/reports_screen.dart';
import 'package:attend_master/screens/settings/settings_screen.dart';

import '../../data/preference_controller.dart';
import '../../theme/app_theme.dart';
import '../../utils/common_utils.dart';
import 'home_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final controller = Get.find<HomeController>();
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    _HomeContent(),
    const CalendarScreen(),
    const ReportsScreen(),
    SettingsScreen(),
  ];

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
      backgroundColor: Colors.grey[50],
      body: _screens[_selectedIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.lightTheme.colorScheme.primary,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
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

class _HomeContent extends StatelessWidget {
  final PreferenceController _prefs = Get.find<PreferenceController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildUserInfo(),
              const SizedBox(height: 20),
              _buildClockInOutCard(),
              const SizedBox(height: 20),
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'HR Exon',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.notifications_none,
            color: Colors.grey[800],
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.person,
                size: 30,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${_prefs.fullName}',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClockInOutCard() {
    final controller = Get.find<HomeController>();
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Status',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Obx(() {
                  bool isClockedIn = false;
                  if (controller.clockInDataObj.value != null) {
                    isClockedIn =
                        controller.clockInDataObj.value!.clockInStatus;
                  }
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isClockedIn
                          ? Colors.green.withOpacity(0.15)
                          : Colors.grey.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isClockedIn
                            ? Colors.green.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isClockedIn
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          size: 16,
                          color: isClockedIn ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isClockedIn ? 'Clocked In' : 'Not Clocked In',
                          style: GoogleFonts.poppins(
                            color: isClockedIn ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => controller.clockInDataObj.value != null
                      ? _buildTimeCard(
                          'Clock In',
                          controller.clockInDataObj.value!.clockInStatus == true
                              ? controller
                                  .clockInDataObj.value!.clockInData!.inTime
                                  .toString()
                              : '--:--:--',
                        )
                      : _buildTimeCard('Clock In', '--:--:--'),
                ),
                Obx(
                  () => controller.clockOutDataObj.value != null
                      ? _buildTimeCard(
                          'Clock Out',
                          controller.clockOutDataObj.value!.clockOutStatus ==
                                  true
                              ? controller
                                  .clockOutDataObj.value!.clockOutData!.outTime
                                  .toString()
                              : '--:--:--',
                        )
                      : _buildTimeCard('Clock Out', '--:--:--'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Obx(() {
                  bool isClockedIn = false;
                  if (controller.clockInDataObj.value != null) {
                    isClockedIn =
                        controller.clockInDataObj.value!.clockInStatus;
                  }
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: isClockedIn
                              ? Colors.grey.withOpacity(0.2)
                              : AppTheme.lightTheme.colorScheme.primary
                                  .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (await controller.checkIsWithinCompanyRadius()) {
                          if (!isClockedIn) {
                            if (controller.autoInOutStatus.value == false) {
                              controller.clockIn();
                            } else {
                              Fluttertoast.showToast(
                                  msg: 'Automatic In Out Disabled !');
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isClockedIn
                            ? Colors.grey.withOpacity(0.5)
                            : AppTheme.lightTheme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        elevation: 0,
                      ),
                      icon: Icon(
                        isClockedIn ? Icons.brightness_1 : Icons.login,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        'Clock In',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }),
                Obx(() {
                  bool isClockedIn = false;
                  if (controller.clockInDataObj.value != null) {
                    isClockedIn =
                        controller.clockInDataObj.value!.clockInStatus;
                  }
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: isClockedIn
                              ? Colors.orange.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (isClockedIn) {
                          if (controller.autoInOutStatus.value == false) {
                            controller.clockOut();
                          } else {
                            Fluttertoast.showToast(
                                msg: 'Automatic In Out Disabled !');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isClockedIn
                            ? Colors.orange
                            : Colors.grey.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        elevation: 0,
                      ),
                      icon: Icon(
                        isClockedIn ? Icons.logout : Icons.brightness_1,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        'Clock Out',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard(String label, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            return _buildActionCard(actions[index]);
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(Map<String, dynamic> action) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: action['color'].withOpacity(0.1),
        border: Border.all(
          color: action['color'].withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  action['icon'],
                  color: action['color'],
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  action['title'],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
