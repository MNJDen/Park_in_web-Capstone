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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    QuerySnapshot snapshot =
        await _firestore.collection('Incident Report').get();
    setState(() {
      reports = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      reports.sort((a, b) {
        DateTime dateA = (a['timestamp'] as Timestamp).toDate();
        DateTime dateB = (b['timestamp'] as Timestamp).toDate();
        return dateA.compareTo(dateB);
      });
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: ListView(
        children: [
          const NavbarDesktop(),
          const SizedBox(height: 28),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            // height: MediaQuery.of(context).size.height * 0.8,
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.1),
            // decoration: BoxDecoration(
            //   borderRadius: BorderRadius.circular(10),
            //   boxShadow: [
            //     BoxShadow(
            //       color: Colors.black.withOpacity(0.1),
            //       blurRadius: 8,
            //       offset: const Offset(0, 4),
            //     ),
            //   ],
            // ),
            child: Theme(
              data: Theme.of(context).copyWith(
                dataTableTheme: DataTableThemeData(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: whiteColor,
                  ),
                  dividerThickness: 0.3,
                  headingRowColor:
                      WidgetStateColor.resolveWith((states) => whiteColor),
                  dataRowColor:
                      WidgetStateColor.resolveWith((states) => whiteColor),
                  headingTextStyle: const TextStyle(
                      color: blackColor, fontWeight: FontWeight.w500),
                  dataTextStyle: const TextStyle(
                    color: blackColor,
                  ),
                ),
              ),
              child: PaginatedDataTable(
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
                rowsPerPage: 11,
                showCheckboxColumn: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

    final formattedDate = DateFormat('MM/dd/yyyy').format(timestamp);
    final formattedTime = DateFormat('hh:mm a').format(timestamp);
    final formattedDateTime = '$formattedDate at $formattedTime';

    final imageUrl = report['image_url'] ?? '';

    return DataRow(
      cells: [
        DataCell(Text('${index + 1}')),
        DataCell(Text(reporterName)),
        DataCell(Text(reportDescription)),
        DataCell(Text(formattedDateTime)),
      ],
      onSelectChanged: (selected) {
        if (selected ?? false) {
          _modal(
            context,
            reporterName,
            reportDescription,
            formattedDateTime,
            imageUrl,
          );
        }
      },
    );
  }

  @override
  int get rowCount => reports.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
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
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    spacing: 4,
                    children: [
                      const Text(
                        'Reported By: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        reporterName,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    timestamp,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: blackColor.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 4,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                  const Text(
                    "Description:",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
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
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.width * 0.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
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
