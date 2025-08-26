import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/attendance.dart';
import '../services/hive_database_helper.dart';

class AttendanceReportScreen extends StatefulWidget {
  const AttendanceReportScreen({Key? key}) : super(key: key);

  @override
  _AttendanceReportScreenState createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  late HiveDatabaseHelper _databaseHelper;
  List<AttendanceRecord> _attendanceRecords = [];
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  bool _isLoading = true;
  Map<String, int> _attendanceStats = {'present': 0, 'absent': 0};

  @override
  void initState() {
    super.initState();
    _databaseHelper = Provider.of<HiveDatabaseHelper>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAttendanceData();
    });
  }

  Future<void> _loadAttendanceData() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    
    try {
      // Get records for the selected date range
      final startDate = _dateRange.start;
      final endDate = _dateRange.end;
      
      // Get all records in date range
      final records = await _databaseHelper.getAttendanceInDateRange(
        startDate,
        endDate.add(const Duration(days: 1)),
      );
      
      // Calculate stats
      int present = 0;
      int absent = 0;
      
      for (var record in records) {
        if (record.isPresent) {
          present++;
        } else {
          absent++;
        }
      }
      
      if (mounted) {
        setState(() {
          _attendanceRecords = records;
          _attendanceStats = {
            'present': present,
            'absent': absent,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading attendance data: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _dateRange,
    );

    if (picked != null && picked != _dateRange) {
      setState(() {
        _dateRange = picked;
      });
      _loadAttendanceData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDateRangeHeader(),
                  const SizedBox(height: 24),
                  _buildSummaryCards(),
                  const SizedBox(height: 32),
                  _buildPieChart(),
                  const SizedBox(height: 32),
                  _buildAttendanceList(),
                ],
              ),
            ),
    );
  }

  Widget _buildDateRangeHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${_formatDate(_dateRange.start)} - ${_formatDate(_dateRange.end)}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          'Total: ${_attendanceRecords.length} records',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    final total = _attendanceStats['present']! + _attendanceStats['absent']!;
    final presentPercentage = total > 0 
        ? (_attendanceStats['present']! / total * 100).toStringAsFixed(1)
        : '0.0';

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Present',
            _attendanceStats['present']!.toString(),
            Colors.green,
            Icons.check_circle,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Absent',
            _attendanceStats['absent']!.toString(),
            Colors.red,
            Icons.cancel,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Percentage',
            '$presentPercentage%',
            Colors.blue,
            Icons.percent,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    final total = _attendanceStats['present']! + _attendanceStats['absent']!;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attendance Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: total > 0 
                ? PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: _attendanceStats['present']!.toDouble(),
                          title: '${((_attendanceStats['present']! / total) * 100).toStringAsFixed(1)}%',
                          color: Colors.green,
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        
                        PieChartSectionData(
                          value: _attendanceStats['absent']!.toDouble(),
                          title: '${((_attendanceStats['absent']! / total) * 100).toStringAsFixed(1)}%',
                          color: Colors.red,
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                    ),
                  )
                : const Center(
                    child: Text('No attendance data available'),
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend(Colors.green, 'Present'),
                const SizedBox(width: 16),
                _buildLegend(Colors.red, 'Absent'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  Widget _buildAttendanceList() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Attendance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_attendanceRecords.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No attendance records found'),
                ),
              )
            else
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1),
                },
                border: TableBorder.all(color: Colors.grey.shade300),
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                    ),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Date',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Status',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  ..._attendanceRecords.take(5).map((record) => TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(_formatDate(record.date)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              record.isPresent ? 'Present' : 'Absent',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: record.isPresent ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }
}
