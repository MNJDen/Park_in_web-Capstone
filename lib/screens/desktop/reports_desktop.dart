import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:park_in_web/components/fields/search_field.dart';
import 'package:park_in_web/components/navbar/navbar_desktop.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';

class ReportsDesktopScreen extends StatefulWidget {
  const ReportsDesktopScreen({super.key});

  @override
  State<ReportsDesktopScreen> createState() => _ReportsDesktopScreenState();
}

class _ReportsDesktopScreenState extends State<ReportsDesktopScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchCtrl = TextEditingController();

  List<Map<String, dynamic>> reports = [];
  List<Map<String, dynamic>> filteredReports = [];
  bool _isLoading = true;

  // Tracking sorted column and sort order (ascending/descending)
  int _sortColumnIndex = 0;
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _listenForTicketUpdates();
    _searchCtrl.addListener(_applySearchFilter);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_applySearchFilter);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _listenForTicketUpdates() {
    _firestore.collection('Incident Report').snapshots().listen((snapshot) {
      setState(() {
        reports = snapshot.docs.map((doc) {
          Map<String, dynamic> reportData = doc.data() as Map<String, dynamic>;
          reportData['docID'] = doc.id;
          return reportData;
        }).toList();

        // Sorting tickets by timestamp
        reports.sort((a, b) {
          DateTime dateA = (a['timestamp'] as Timestamp).toDate();
          DateTime dateB = (b['timestamp'] as Timestamp).toDate();
          return dateA.compareTo(dateB); // Sort in ascending order
        });

        // Initialize filteredReports to display all tickets initially
        filteredReports = List.from(reports);
        _isLoading = false;
      });
    });
  }

  void _applySearchFilter() {
    final query = _searchCtrl.text.toLowerCase();
    final DateFormat dateFormatter = DateFormat('MM/dd/yyyy');

    setState(() {
      if (query.isEmpty) {
        // If search field is empty, show all tickets
        filteredReports = List.from(reports);
      } else {
        // Filter reports based on the search term
        filteredReports = reports.where((report) {
          final docID = report['docID']?.toString().toLowerCase() ?? '';
          final reportedPlateNumber =
              report['reportedPlateNumber']?.toString().toLowerCase() ?? '';
          final reportDescription =
              report['reportDescription']?.toString().toLowerCase() ?? '';
          final reporterName =
              report['reporterName']?.toString().toLowerCase() ?? '';
          final timestamp = report['timestamp'] as Timestamp?;
          String reportDate = '';
          if (timestamp != null) {
            reportDate = dateFormatter.format(timestamp.toDate()).toLowerCase();
          }

          // // Debugging print statements
          // print('Searching for: $query');
          // print('Plate Number: $ticketedTo');
          // print('Vehicle Type: $vehicleType');
          // print('Violation: $violation');

          return docID.contains(query) ||
              reportedPlateNumber.contains(query) ||
              reportDescription.contains(query) ||
              reporterName.contains(query) ||
              reportDate.contains(query);
        }).toList();
      }
    });
  }

  // Sorting function for the columns
  void _sort<T>(Comparable<T> Function(Map<String, dynamic> report) getField,
      int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _isAscending = ascending;

      filteredReports.sort((a, b) {
        final fieldA = getField(a);
        final fieldB = getField(b);
        return ascending
            ? Comparable.compare(fieldA, fieldB)
            : Comparable.compare(fieldB, fieldA);
      });
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
              horizontal: MediaQuery.of(context).size.width * 0.1,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: blackColor.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                dataTableTheme: DataTableThemeData(
                  dividerThickness: 0.2,
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
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: blackColor,
                  ),
                ),
                actions: [
                  SizedBox(
                    height: 40,
                    width: 170,
                    child: PRKSearchField(
                        hintText: "Search",
                        suffixIcon: Icons.search_rounded,
                        controller: _searchCtrl),
                  ),
                ],
                columns: [
                  DataColumn(
                    label: const Text("Report ID"),
                    onSort: (columnIndex, ascending) => _sort<String>(
                        (report) => report['docID'] ?? 0,
                        columnIndex,
                        ascending),
                  ),
                  DataColumn(
                    label: const Text("Reported By"),
                    onSort: (columnIndex, ascending) => _sort<String>(
                        (report) => report['reporterName']?.toString() ?? '',
                        columnIndex,
                        ascending),
                  ),
                  DataColumn(
                    label: const Text("Report Description"),
                    onSort: (columnIndex, ascending) => _sort<String>(
                        (report) =>
                            report['reportDescription']?.toString() ?? '',
                        columnIndex,
                        ascending),
                  ),
                  DataColumn(
                    label: const Text("Date"),
                    onSort: (columnIndex, ascending) => _sort<DateTime>(
                        (report) => (report['timestamp'] as Timestamp).toDate(),
                        columnIndex,
                        ascending),
                  ),
                ],
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _isAscending,
                source: ReportDataSource(filteredReports, context),
                rowsPerPage: 11,
                showCheckboxColumn: false,
                arrowHeadColor: blueColor,
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
    final docID = report['docID'] ?? 'NaN';
    final reporterName = report['reporterName'] ?? 'Anonymous';
    final reportDescription = report['reportDescription'] ?? '';
    final reportedPlateNumber = report['reportedPlateNumber'] ?? '';
    final timestamp =
        (report['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

    final formattedDate = DateFormat('MM/dd/yyyy').format(timestamp);
    final formattedTime = DateFormat('hh:mm a').format(timestamp);
    final formattedDateTime = '$formattedDate at $formattedTime';

    final imageUrl = report['image_url'] ?? '';

    return DataRow(
      cells: [
        // DataCell(Text('${index + 1}')),
        DataCell(Text(docID)),
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
            reportedPlateNumber,
            formattedDateTime,
            imageUrl,
          );
        }
      },
      color: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.hovered)) {
            return blackColor.withOpacity(0.05);
          } else {
            return Colors.transparent;
          }
        },
      ),
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
    String reportedPlateNumber, String timestamp, String attachmentUrls) {
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
                    "Reported Plate Number:",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    reportedPlateNumber,
                    style: const TextStyle(
                      color: Colors.black,
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
                'Attachment:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              if (attachmentUrls.isNotEmpty)
                HoverableImage(imageUrl: attachmentUrls)
              else
                const Text(
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

class HoverableImage extends StatefulWidget {
  final String imageUrl;

  const HoverableImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  _HoverableImageState createState() => _HoverableImageState();
}

class _HoverableImageState extends State<HoverableImage> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageViewer(imageUrl: widget.imageUrl),
            ),
          );
        },
        child: AnimatedScale(
          scale: _isHovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.width * 0.3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ImageViewer extends StatelessWidget {
  final String imageUrl;

  const ImageViewer({required this.imageUrl, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackColor,
      body: Stack(
        children: [
          Positioned(
            top: 10,
            left: 10,
            child: IconButton.filled(
              style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(whiteColor)),
              icon: const Icon(
                Icons.close_rounded,
                color: blackColor,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Image.network(imageUrl),
            ),
          ),
        ],
      ),
    );
  }
}
