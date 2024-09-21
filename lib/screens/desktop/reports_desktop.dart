import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:park_in_web/components/navbar/navbar_desktop.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';

class ReportsDesktopScreen extends StatefulWidget {
  const ReportsDesktopScreen({super.key});

  @override
  State<ReportsDesktopScreen> createState() => _ReportsDesktopScreenState();
}

class _ReportsDesktopScreenState extends State<ReportsDesktopScreen> {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List to hold fetched reports
  List<Map<String, dynamic>> reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReports(); // Fetch data when the screen is initialized
  }

  // Fetch reports from Firestore
  Future<void> _fetchReports() async {
    QuerySnapshot snapshot =
        await _firestore.collection('Incident Report').get();
    setState(() {
      reports = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // Sorting tickets
      reports.sort((a, b) {
        DateTime dateA = (a['timestamp'] as Timestamp).toDate();
        DateTime dateB = (b['timestamp'] as Timestamp).toDate();
        return dateA.compareTo(dateB); // Sort in ascending order
      });

      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          const NavbarDesktop(),
          const SizedBox(height: 28),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(30),
              margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * .1,
              ),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : PaginatedDataTable(
                      header: const Text(
                        "Incident Reports",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: blackColor,
                        ),
                      ),
                      columns: const [
                        DataColumn(label: Text("Report ID")),
                        DataColumn(label: Text("Reported By")),
                        DataColumn(label: Text("Report Description")),
                        DataColumn(label: Text("Date")),
                      ],
                      source: ReportDataSource(reports, context),
                      rowsPerPage: 5,
                    ),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

// DataTable source class to display data in the table
class ReportDataSource extends DataTableSource {
  final List<Map<String, dynamic>> reports;
  final BuildContext context;

  ReportDataSource(this.reports, this.context);

  @override
  DataRow getRow(int index) {
    final report = reports[index];
    final reporterName = report['reporterName'] ?? 'Anonymous';
    final reportDescription = report['reportDescription'] ?? '';
    final timestamp =
        (report['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    final imageUrl = report['image_url'] ?? '';

    final formattedDate = DateFormat('MM/dd/yyyy').format(timestamp);
    final formattedTime = DateFormat('hh:mm a').format(timestamp);
    final formattedDateTime = '$formattedDate at $formattedTime';

    return DataRow(cells: [
      DataCell(Text('${index + 1}')),
      // DataCell(Text(reporterName)),
      DataCell(
        GestureDetector(
          onTap: () {
            _modal(context, reporterName, reportDescription, formattedDateTime,
                imageUrl);
          },
          child: Container(
            constraints: BoxConstraints(maxWidth: 250),
            child: Text(
              reporterName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
      DataCell(
        GestureDetector(
          onTap: () {
            _modal(context, reporterName, reportDescription, formattedDateTime,
                imageUrl);
          },
          child: Container(
            constraints: BoxConstraints(maxWidth: 250),
            child: Text(
              reportDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
      // DataCell(Text(formattedDateTime)),
      DataCell(
        GestureDetector(
          onTap: () {
            _modal(context, reporterName, reportDescription, formattedDateTime,
                imageUrl);
          },
          child: Container(
            constraints: BoxConstraints(maxWidth: 250),
            child: Text(
              formattedDateTime,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    ]);
  }

  void _modal(BuildContext context, String reporterName, String description,
      String timestamp, String attachmentUrls) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: whiteColor,
          scrollable: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Container(
            padding: const EdgeInsets.only(bottom: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 0.2, color: blackColor),
              ),
            ),
            child: const Text(
              "Report Information",
              style: TextStyle(
                color: blackColor,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.35,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reported By: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      reporterName,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      timestamp,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Attachment/s:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                if (attachmentUrls.isNotEmpty)
                  Container(
                    height: 160,
                    width: 215,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.5),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        attachmentUrls,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Text(
                    'No attachment available.',
                    style: TextStyle(color: Colors.grey),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Close",
                style: TextStyle(
                  color: blueColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => reports.length;

  @override
  int get selectedRowCount => 0;
}
