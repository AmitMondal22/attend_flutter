import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _events = {};
  bool _showLeaveRequest = false;
  final TextEditingController _leaveReasonController = TextEditingController();
  DateTime? _leaveStartDate;
  DateTime? _leaveEndDate;
  bool _isMultipleDays = false;
  List<MapEntry<DateTime, List<dynamic>>> _monthlyHolidays = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
    _updateMonthlyHolidays();
  }

  void _loadEvents() {
    // Indian Festivals and Holidays for 2025-2028
    _events = {
      // 2025 Holidays
      // January
      DateTime(2025, 1, 1): ['New Year\'s Day', 'Holiday', 'All India', 'Observance'],
      DateTime(2025, 1, 23): ['Netaji Subhas Chandra Bose Jayanti', 'Holiday', 'West Bengal', 'Regional'],
      DateTime(2025, 1, 26): ['Republic Day', 'Holiday', 'All India', 'National'],
      
      // February
      DateTime(2025, 2, 2): ['Saraswati Puja', 'Holiday', 'West Bengal', 'Religious'],
      
      // March
      DateTime(2025, 3, 14): ['Holi', 'Holiday', 'All India', 'Religious'],
      DateTime(2025, 3, 30): ['Eid al-Fitr', 'Holiday', 'All India', 'Religious'],
      
      // April
      DateTime(2025, 4, 14): ['Pohela Boishakh', 'Holiday', 'West Bengal', 'Regional'],
      DateTime(2025, 4, 18): ['Good Friday', 'Holiday', 'All India', 'Religious'],
      
      // May
      DateTime(2025, 5, 1): ['May Day', 'Holiday', 'All India', 'Observance'],
      DateTime(2025, 5, 8): ['Rabindra Jayanti', 'Holiday', 'West Bengal', 'Regional'],
      
      // June
      DateTime(2025, 6, 7): ['Eid al-Adha', 'Holiday', 'All India', 'Religious'],
      
      // July
      DateTime(2025, 7, 5): ['Muharram', 'Holiday', 'All India', 'Religious'],
      
      // August
      DateTime(2025, 8, 15): ['Independence Day', 'Holiday', 'All India', 'National'],
      
      // September
      DateTime(2025, 9, 22): ['Mahalaya', 'Holiday', 'West Bengal', 'Religious'],
      DateTime(2025, 9, 30): ['Durga Puja Saptami', 'Holiday', 'West Bengal', 'Religious'],
      
      // October
      DateTime(2025, 10, 1): ['Durga Puja Ashtami', 'Holiday', 'West Bengal', 'Religious'],
      DateTime(2025, 10, 2): ['Durga Puja Navami', 'Holiday', 'West Bengal', 'Religious'],
      DateTime(2025, 10, 2): ['Gandhi Jayanti', 'Holiday', 'All India', 'National'],
      DateTime(2025, 10, 3): ['Durga Puja Dashami', 'Holiday', 'West Bengal', 'Religious'],
      DateTime(2025, 10, 10): ['Lakshmi Puja', 'Holiday', 'West Bengal', 'Religious'],
      DateTime(2025, 10, 20): ['Kali Puja', 'Holiday', 'West Bengal', 'Religious'],
      DateTime(2025, 10, 20): ['Diwali', 'Holiday', 'All India', 'Religious'],
      DateTime(2025, 10, 22): ['Bhai Phonta', 'Holiday', 'West Bengal', 'Cultural'],
      DateTime(2025, 10, 28): ['Chhath Puja', 'Holiday', 'West Bengal', 'Religious'],
      
      // December
      DateTime(2025, 12, 25): ['Christmas Day', 'Holiday', 'All India', 'Religious'],

      // 2026 Holidays
      DateTime(2026, 1, 1): ['New Year\'s Day', 'Holiday', 'All India', 'Observance'],
      DateTime(2026, 1, 26): ['Republic Day', 'Holiday', 'All India', 'National'],
      DateTime(2026, 3, 6): ['Holi', 'Holiday', 'All India', 'Religious'],
      DateTime(2026, 4, 3): ['Good Friday', 'Holiday', 'All India', 'Religious'],
      DateTime(2026, 5, 1): ['May Day', 'Holiday', 'All India', 'Observance'],
      DateTime(2026, 8, 15): ['Independence Day', 'Holiday', 'All India', 'National'],
      DateTime(2026, 10, 2): ['Gandhi Jayanti', 'Holiday', 'All India', 'National'],
      DateTime(2026, 10, 20): ['Diwali', 'Holiday', 'All India', 'Religious'],
      DateTime(2026, 12, 25): ['Christmas Day', 'Holiday', 'All India', 'Religious'],

      // 2027 Holidays
      DateTime(2027, 1, 1): ['New Year\'s Day', 'Holiday', 'All India', 'Observance'],
      DateTime(2027, 1, 26): ['Republic Day', 'Holiday', 'All India', 'National'],
      DateTime(2027, 3, 22): ['Holi', 'Holiday', 'All India', 'Religious'],
      DateTime(2027, 4, 2): ['Good Friday', 'Holiday', 'All India', 'Religious'],
      DateTime(2027, 5, 1): ['May Day', 'Holiday', 'All India', 'Observance'],
      DateTime(2027, 8, 15): ['Independence Day', 'Holiday', 'All India', 'National'],
      DateTime(2027, 10, 2): ['Gandhi Jayanti', 'Holiday', 'All India', 'National'],
      DateTime(2027, 10, 29): ['Diwali', 'Holiday', 'All India', 'Religious'],
      DateTime(2027, 12, 25): ['Christmas Day', 'Holiday', 'All India', 'Religious'],

      // 2028 Holidays
      DateTime(2028, 1, 1): ['New Year\'s Day', 'Holiday', 'All India', 'Observance'],
      DateTime(2028, 1, 26): ['Republic Day', 'Holiday', 'All India', 'National'],
      DateTime(2028, 3, 11): ['Holi', 'Holiday', 'All India', 'Religious'],
      DateTime(2028, 4, 14): ['Good Friday', 'Holiday', 'All India', 'Religious'],
      DateTime(2028, 5, 1): ['May Day', 'Holiday', 'All India', 'Observance'],
      DateTime(2028, 8, 15): ['Independence Day', 'Holiday', 'All India', 'National'],
      DateTime(2028, 10, 2): ['Gandhi Jayanti', 'Holiday', 'All India', 'National'],
      DateTime(2028, 10, 17): ['Diwali', 'Holiday', 'All India', 'Religious'],
      DateTime(2028, 12, 25): ['Christmas Day', 'Holiday', 'All India', 'Religious'],
    };
  }

  void _updateMonthlyHolidays() {
    try {
      final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
      
      // Filter events to only include holidays for the current month
      _monthlyHolidays = _events.entries
          .where((entry) {
            try {
              if (entry.value.isEmpty) return false;
              
              final entryDate = DateTime(entry.key.year, entry.key.month, entry.key.day);
              final isInMonth = entryDate.year == _focusedDay.year && 
                               entryDate.month == _focusedDay.month;
              return isInMonth;
            } catch (e) {
              return false;
            }
          })
          .toList();
          
      // Sort by date
      _monthlyHolidays.sort((a, b) => a.key.compareTo(b.key));
      
      // Debug print to verify holidays
      print('Monthly Holidays for ${_focusedDay.month}/${_focusedDay.year}:');
      for (var entry in _monthlyHolidays) {
        print('${entry.key}: ${entry.value}');
      }
    } catch (e) {
      print('Error updating monthly holidays: $e');
      _monthlyHolidays = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildCalendarCard(),
                const SizedBox(height: 20),
                _buildEventsList(),
                if (_showLeaveRequest) _buildLeaveRequestForm(),
              ],
            ),
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
          'Calendar',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.filter_list,
            color: Colors.grey[800],
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                  _updateMonthlyHolidays();
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              eventLoader: (day) {
                // Normalize dates to avoid time part messing up comparison
                final normalizedDay = DateTime(day.year, day.month, day.day);
                
                // Check if there are events for this day
                final matchingEvents = _events.entries
                    .where((entry) => 
                        DateTime(entry.key.year, entry.key.month, entry.key.day).isAtSameMomentAs(normalizedDay))
                    .map((entry) => entry.value)
                    .toList();
                
                if (matchingEvents.isNotEmpty) {
                  return matchingEvents.first;
                }
                return [];
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                todayDecoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    width: 1.5,
                  ),
                ),
                weekendTextStyle: GoogleFonts.poppins(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
                holidayTextStyle: GoogleFonts.poppins(
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
                outsideDaysVisible: false,
                defaultTextStyle: GoogleFonts.poppins(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
                selectedTextStyle: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                todayTextStyle: GoogleFonts.poppins(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
                disabledTextStyle: GoogleFonts.poppins(
                  color: Colors.grey[400],
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                holidayDecoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                titleTextStyle: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: Colors.grey[800],
                  size: 28,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: Colors.grey[800],
                  size: 28,
                ),
                headerMargin: const EdgeInsets.only(bottom: 16),
                headerPadding: const EdgeInsets.symmetric(vertical: 8),
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                formatButtonTextStyle: GoogleFonts.poppins(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  // Normalize date to compare properly
                  final normalizedDay = DateTime(day.year, day.month, day.day);
                  
                  // Find matching events
                  final matchingEntries = _events.entries.where((entry) => 
                    DateTime(entry.key.year, entry.key.month, entry.key.day).isAtSameMomentAs(normalizedDay));
                  
                  // Check if the day has a holiday event
                  if (matchingEntries.isNotEmpty) {
                    final events = matchingEntries.first.value;
                    if (events.isNotEmpty) {
                      final event = events.first;
                      if (event is String) {
                        // Extract event info - assuming format like "Event Name, Holiday, Region, Type"
                        final eventParts = event.toString().split(', ');
                        
                        // Determine if it's a holiday
                        final isHoliday = eventParts.length > 1 && eventParts[1] == 'Holiday';
                        
                        if (isHoliday) {
                          // Get holiday category
                          String category = 'Observance';
                          if (eventParts.length > 3) {
                            category = eventParts[3];
                          }
                          
                          // Determine color based on category
                          Color holidayColor;
                          switch (category) {
                            case 'National':
                              holidayColor = Colors.blue;
                              break;
                            case 'Religious':
                              holidayColor = Colors.purple;
                              break;
                            case 'Regional':
                              holidayColor = Colors.green;
                              break;
                            case 'Cultural':
                              holidayColor = Colors.pink;
                              break;
                            case 'Observance':
                              holidayColor = Colors.orange;
                              break;
                            default:
                              holidayColor = Colors.orange;
                          }
                          
                          // Build special holiday cell
                          return Container(
                            margin: const EdgeInsets.all(4),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: holidayColor.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: holidayColor,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: holidayColor.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              '${day.day}',
                              style: GoogleFonts.poppins(
                                color: holidayColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }
                      }
                    }
                  }
                  
                  // Mark Sundays
                  if (day.weekday == DateTime.sunday) {
                    return Container(
                      margin: const EdgeInsets.all(4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '${day.day}',
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }
                  return null;
                },
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    // Determine if it's a holiday or leave
                    final event = events.first;
                    bool isHoliday = false;
                    bool isLeave = false;
                    Color markerColor = Colors.green;
                    
                    if (event is String) {
                      isHoliday = event.contains('Holiday');
                      isLeave = event.contains('Leave:');
                      
                      if (isHoliday) {
                        final eventParts = event.split(', ');
                        final category = eventParts.length > 3 ? eventParts[3] : 'Observance';
                        
                        // Color based on category
                        switch (category) {
                          case 'National':
                            markerColor = Colors.blue;
                            break;
                          case 'Religious':
                            markerColor = Colors.purple;
                            break;
                          case 'Regional':
                            markerColor = Colors.green;
                            break;
                          case 'Cultural':
                            markerColor = Colors.pink;
                            break;
                          case 'Observance':
                            markerColor = Colors.orange;
                            break;
                          default:
                            markerColor = Colors.orange;
                        }
                      } else if (isLeave) {
                        markerColor = Colors.red;
                      }
                    }
                    
                    return Positioned(
                      bottom: 1,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: markerColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => _showLeaveRequestDialog(),
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                label: Text(
                  'Request Leave',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLeaveRequestDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Leave Request',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey[600],
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(
                      'Start Date',
                      _leaveStartDate,
                      (date) => setState(() => _leaveStartDate = date),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_isMultipleDays)
                    Expanded(
                      child: _buildDatePicker(
                        'End Date',
                        _leaveEndDate,
                        (date) => setState(() => _leaveEndDate = date),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isMultipleDays,
                    onChanged: (value) => setState(() => _isMultipleDays = value ?? false),
                    activeColor: AppTheme.lightTheme.colorScheme.primary,
                  ),
                  Text(
                    'Multiple Days',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _leaveReasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Leave Reason',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey[600],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (_leaveStartDate != null && _leaveReasonController.text.isNotEmpty) {
                      final leaveEvent = 'Leave: ${_leaveReasonController.text}';
                      if (_isMultipleDays && _leaveEndDate != null) {
                        var currentDate = _leaveStartDate!;
                        while (currentDate.isBefore(_leaveEndDate!) || currentDate.isAtSameMomentAs(_leaveEndDate!)) {
                          _events[currentDate] = [leaveEvent];
                          currentDate = currentDate.add(const Duration(days: 1));
                        }
                      } else {
                        _events[_leaveStartDate!] = [leaveEvent];
                      }
                      
                      setState(() {
                        _leaveReasonController.clear();
                        _leaveStartDate = null;
                        _leaveEndDate = null;
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: Text(
                    'Submit Request',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    final events = _events[_selectedDay] ?? [];
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Events',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            if (events.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No events for this day',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return _buildEventItem(events[index]);
                },
              ),
            const SizedBox(height: 24),
            Text(
              'Monthly Holidays',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            if (_monthlyHolidays.isEmpty)
              Center(
                child: Text(
                  'No holidays this month',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _monthlyHolidays.length,
                itemBuilder: (context, index) {
                  try {
                    final entry = _monthlyHolidays[index];
                    if (entry.value.isNotEmpty && entry.value.first is String) {
                      final event = entry.value.first as String;
                      if (event.contains('Holiday')) {
                        return _buildHolidayItem(entry.key, event);
                      }
                    }
                    return const SizedBox.shrink();
                  } catch (e) {
                    print('Error building holiday item: $e');
                    return const SizedBox.shrink();
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHolidayItem(DateTime date, String event) {
    try {
      // Split the event string and ensure we have enough parts
      final eventParts = event.split(', ');
      if (eventParts.length < 4) {
        print('Invalid event format: $event');
        return const SizedBox.shrink();
      }

      final eventName = eventParts[0];
      final eventType = eventParts[1];
      final eventRegion = eventParts[2];
      final eventCategory = eventParts[3];
      
      Color getCategoryColor() {
        switch (eventCategory) {
          case 'National':
            return Colors.blue;
          case 'Religious':
            return Colors.purple;
          case 'Regional':
            return Colors.green;
          case 'Cultural':
            return Colors.pink;
          case 'Observance':
            return Colors.orange;
          default:
            return Colors.orange;
        }
      }

      final categoryColor = getCategoryColor();

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: categoryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: categoryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.celebration,
                    color: categoryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eventName,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}/${date.month}/${date.year}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    eventRegion,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: categoryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    eventCategory,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: categoryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error building holiday item UI: $e');
      return const SizedBox.shrink();
    }
  }

  Color _getEventColor(String event) {
    if (event.contains('Holiday')) {
      final eventParts = event.split(', ');
      if (eventParts.length > 3) {
        final category = eventParts[3];
        switch (category) {
          case 'National':
            return Colors.blue;
          case 'Religious':
            return Colors.purple;
          case 'Regional':
            return Colors.green;
          case 'Cultural':
            return Colors.pink;
          case 'Observance':
            return Colors.orange;
          default:
            return Colors.orange;
        }
      }
      return Colors.orange;
    }
    return Colors.green;
  }

  Widget _buildEventItem(String event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getEventColor(event).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getEventIcon(event),
              color: _getEventColor(event),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              event,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEventIcon(String event) {
    if (event.contains('Holiday')) return Icons.beach_access;
    if (event.contains('Festival')) return Icons.celebration;
    return Icons.event;
  }

  Widget _buildLeaveRequestForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Leave Request',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    setState(() {
                      _showLeaveRequest = false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker(
                    'Start Date',
                    _leaveStartDate,
                    (date) => setState(() => _leaveStartDate = date),
                  ),
                ),
                const SizedBox(width: 12),
                if (_isMultipleDays)
                  Expanded(
                    child: _buildDatePicker(
                      'End Date',
                      _leaveEndDate,
                      (date) => setState(() => _leaveEndDate = date),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isMultipleDays,
                  onChanged: (value) => setState(() => _isMultipleDays = value ?? false),
                  activeColor: AppTheme.lightTheme.colorScheme.primary,
                ),
                Text(
                  'Multiple Days',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _leaveReasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Leave Reason',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey[600],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (_leaveStartDate != null && _leaveReasonController.text.isNotEmpty) {
                    // Add the leave request to events
                    final leaveEvent = 'Leave: ${_leaveReasonController.text}';
                    if (_isMultipleDays && _leaveEndDate != null) {
                      // Add events for each day in the range
                      var currentDate = _leaveStartDate!;
                      while (currentDate.isBefore(_leaveEndDate!) || currentDate.isAtSameMomentAs(_leaveEndDate!)) {
                        _events[currentDate] = [leaveEvent];
                        currentDate = currentDate.add(const Duration(days: 1));
                      }
                    } else {
                      _events[_leaveStartDate!] = [leaveEvent];
                    }
                    
                    setState(() {
                      _showLeaveRequest = false;
                      _leaveReasonController.clear();
                      _leaveStartDate = null;
                      _leaveEndDate = null;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: Text(
                  'Submit Request',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, Function(DateTime) onDateSelected) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          final selectedDate = await showDatePicker(
            context: context,
            initialDate: date ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (selectedDate != null) {
            onDateSelected(selectedDate);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date != null
                    ? '${date.day}/${date.month}/${date.year}'
                    : label,
                style: GoogleFonts.poppins(
                  color: date != null ? Colors.grey[800] : Colors.grey[600],
                ),
              ),
              Icon(
                Icons.calendar_today,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 