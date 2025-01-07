import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:park_in_web/components/fields/search_field.dart';
import 'package:park_in_web/components/navbar/navbar_mobile.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';
import 'package:park_in_web/components/ui/icon_btn.dart';
import 'package:park_in_web/components/ui/primary_btn.dart';
import 'package:park_in_web/services/Auth/Auth_Service.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportsMobileScreen extends StatefulWidget {
  const ReportsMobileScreen({super.key});

  @override
  State<ReportsMobileScreen> createState() => _ReportsMobileScreenState();
}

class _ReportsMobileScreenState extends State<ReportsMobileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedPage = '';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchCtrl = TextEditingController();

  List<Map<String, dynamic>> reports = [];
  List<Map<String, dynamic>> filteredReports = [];
  bool _isLoading = true;

  // Tracking sorted column and sort order (ascending/descending)
  int _sortColumnIndex = 0;
  bool _isAscending = true;
  bool isExporting = false;

  @override
  void initState() {
    super.initState();
    _listenForTicketUpdates();
    _searchCtrl.addListener(_applySearchFilter);
    fetchTotalItems();
    preloadAssets();
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

        _totalItems = reports.length;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    String? currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != null) {
      setState(() {
        _selectedPage = currentRoute;
      });
    }
  }

  void _onItemTap(String page) {
    String targetRoute = '/${page.toLowerCase().replaceAll(' ', '-')}';
    if (_selectedPage != targetRoute) {
      setState(() {
        _selectedPage = targetRoute;
      });

      Navigator.pushNamed(context, targetRoute).then((_) {
        setState(() {});
      });
    }
  }

  int _currentPage = 0; // Track current page
  int _rowsPerPage = 10; // Rows per page
  int _totalItems = 0;
  bool isLoading = false;

  Future<void> fetchTotalItems() async {
    setState(() {
      isLoading = true;
    });
    try {
      final querySnapshot =
          await _firestore.collection('Incident Report').get();

      _totalItems = querySnapshot.docs.length;
    } catch (e) {
      print('Error fetching total items: $e'); // Print error message
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  int get totalPages => (_totalItems / _rowsPerPage).ceil();

  void logout(BuildContext context) async {
    final authService = AuthService();
    bool _isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Text(
            'Confirm Sign Out',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: blackColor,
            ),
          ),
          content: const SizedBox(
            height: 40,
            child: Text('Are you sure you want to exit?'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: blueColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(color: whiteColor),
              ),
              onPressed: () async {
                try {
                  await authService.signOut();

                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isLoggedIn', false);
                  await prefs.remove('userType');

                  // Navigate to SignInMain and update URL
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/sign-in',
                    (Route<dynamic> route) => false,
                  );
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  late pw.MemoryImage logoImage;

  Future<void> preloadAssets() async {
    final ByteData imageData =
        await rootBundle.load('assets/images/adnu_logo.png');
    logoImage = pw.MemoryImage(imageData.buffer.asUint8List());
  }

  Future<void> saveDataTableToPDF(
      List<Map<String, dynamic>> data, String fileName) async {
    final tableRows = data.map((item) {
      return [
        item['docID'] ?? '',
        item['reporterName'] ?? '',
        item['reportDescription'] ?? '',
        (item['timestamp'] != null && item['timestamp'] is Timestamp)
            ? DateFormat('dd MMM yyyy, HH:mm')
                .format(item['timestamp'].toDate())
            : 'N/A',
      ];
    }).toList();

    final pdf = pw.Document();
    final now = DateTime.now();
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(now);

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          orientation: pw.PageOrientation.landscape,
          pageFormat: PdfPageFormat.legal.landscape,
        ),
        build: (context) => [
          // Header
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Image(
                logoImage,
                width: 50,
                height: 50,
                fit: pw.BoxFit.contain,
              ),
              pw.SizedBox(width: 10),
              // Text on the right
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Ateneo de Naga University',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Administrative Office',
                    style: const pw.TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  pw.Text(
                    'Ateneo Ave, Naga, 4400 Camarines Sur',
                    style: const pw.TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                fileName,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                '  as of $formattedDate',
                style: const pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(
              width: 1.0,
              color: const PdfColor.fromInt(0xFF9E9E9E),
            ),
            children: [
              // Header row
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('Report ID',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 12)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('Reported By',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 12)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('Report Description',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 12)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('Date',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
              // Data rows
              for (final row in tableRows)
                pw.TableRow(
                  children: row
                      .map((cell) => pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(cell.toString(),
                                style: const pw.TextStyle(fontSize: 10)),
                          ))
                      .toList(),
                ),
            ],
          ),
        ],
      ),
    );

    // Preview the PDF before downloading
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );

    //Download the PDF
    // final bytes = await pdf.save();
    // final blob = html.Blob([bytes], 'application/pdf');
    // final url = html.Url.createObjectUrlFromBlob(blob);
    // final anchor = html.document.createElement('a') as html.AnchorElement
    //   ..href = url
    //   ..style.display = 'none'
    //   ..download = '$fileName.pdf';
    // html.document.body?.children.add(anchor);
    // anchor.click();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgColor,
      drawer: Drawer(
        backgroundColor: bgColor,
        child: Column(
          children: <Widget>[
            Flexible(
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      _onItemTap("Dashboard");
                      _selectedPage == '/dashboard';
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 40),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.start,
                        spacing: 20,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 2),
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: blueColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Image.asset(
                                "assets/images/Logo.png",
                                width: 18,
                                color: whiteColor,
                              ),
                            ),
                          ),
                          const Text(
                            "Park-in",
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 24,
                              fontFamily: "Hiruko Pro",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.dashboard_outlined,
                      color: whiteColor,
                    ),
                    title: const Text(
                      'Dashboard',
                      style: TextStyle(
                        color: whiteColor,
                      ),
                    ),
                    onTap: () {
                      _onItemTap('Dashboard');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.flag_outlined,
                      color: whiteColor,
                    ),
                    title: const Text(
                      'Reports',
                      style: TextStyle(
                        color: whiteColor,
                      ),
                    ),
                    onTap: () {
                      _onItemTap('Reports');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.receipt_long_outlined,
                      color: whiteColor,
                    ),
                    title: const Text(
                      'Tickets Issued',
                      style: TextStyle(
                        color: whiteColor,
                      ),
                    ),
                    onTap: () {
                      _onItemTap('Tickets Issued');
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.tv_rounded,
                color: whiteColor,
              ),
              title: const Text(
                'Live View',
                style: TextStyle(
                  color: whiteColor,
                ),
              ),
              onTap: () {
                _onItemTap('View');
              },
            ),
            const Divider(
              color: whiteColor,
              thickness: 0.5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: PRKPrimaryBtn(
                label: "Sign Out",
                onPressed: () {
                  logout(context);
                },
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: ListView(
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    NavbarMobile(
                      onMenuPressed: () =>
                          _scaffoldKey.currentState?.openDrawer(),
                    ),
                    const Text(
                      "Incident Reports",
                      style: TextStyle(
                        fontSize: 20,
                        color: whiteColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 46,
              width: double.infinity,
              child: PRKSearchField(
                hintText: "Search",
                prefixIcon: Icons.search_rounded,
                controller: _searchCtrl,
              ),
            )
                .animate()
                .fade(
                  delay: const Duration(
                    milliseconds: 100,
                  ),
                )
                .moveY(
                  begin: 10,
                  end: 0,
                  curve: Curves.fastEaseInToSlowEaseOut,
                  duration: const Duration(milliseconds: 250),
                ),
            const SizedBox(
              height: 12,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: blackColor.withOpacity(0.1),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: blackColor.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        children: [
                          Text(
                            "Filters",
                            style: TextStyle(
                              color: blackColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      PRKIconButton(
                        title: isExporting ? "Exporting..." : "Export",
                        icon: isExporting
                            ? Icons.hourglass_empty_rounded
                            : Icons.file_upload_outlined,
                        onTap: isExporting
                            ? () {}
                            : () async {
                                setState(() {
                                  isExporting = true;
                                });
                                await saveDataTableToPDF(
                                    filteredReports, 'Incident Reports');
                                setState(() {
                                  isExporting = false;
                                });
                              },
                      )
                    ],
                  ),
                )
                    .animate()
                    .fade(
                      delay: const Duration(
                        milliseconds: 200,
                      ),
                    )
                    .moveY(
                      begin: 10,
                      end: 0,
                      curve: Curves.fastEaseInToSlowEaseOut,
                      duration: const Duration(milliseconds: 450),
                    ),
                const SizedBox(
                  height: 12,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: blackColor.withOpacity(0.1),
                        width: 0.5,
                      ),
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
                          headingRowColor: WidgetStateColor.resolveWith(
                              (states) => whiteColor),
                          dataRowColor: WidgetStateColor.resolveWith(
                              (states) => whiteColor),
                          headingTextStyle: const TextStyle(
                              color: blackColor, fontWeight: FontWeight.w500),
                          dataTextStyle: const TextStyle(
                            color: blackColor,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: [
                                DataColumn(
                                  label: const Text(
                                    "Report ID",
                                    softWrap: true,
                                  ),
                                  onSort: (columnIndex, ascending) =>
                                      _sort<String>(
                                          (report) => report['docID'] ?? 0,
                                          columnIndex,
                                          ascending),
                                ),
                                DataColumn(
                                  label: const Text("Reported By"),
                                  onSort: (columnIndex, ascending) =>
                                      _sort<String>(
                                          (report) =>
                                              report['reporterName']
                                                  ?.toString() ??
                                              '',
                                          columnIndex,
                                          ascending),
                                ),
                                DataColumn(
                                  label: const Text("Report Description"),
                                  onSort: (columnIndex, ascending) =>
                                      _sort<String>(
                                          (report) =>
                                              report['reportDescription']
                                                  ?.toString() ??
                                              '',
                                          columnIndex,
                                          ascending),
                                ),
                                DataColumn(
                                  label: const Text("Date"),
                                  onSort: (columnIndex, ascending) =>
                                      _sort<DateTime>(
                                          (report) =>
                                              (report['timestamp'] as Timestamp)
                                                  .toDate(),
                                          columnIndex,
                                          ascending),
                                ),
                              ],
                              dataRowMinHeight:
                                  MediaQuery.of(context).size.height * 0.02,
                              dataRowMaxHeight:
                                  MediaQuery.of(context).size.height * 0.066,
                              sortColumnIndex: _sortColumnIndex,
                              sortAscending: _isAscending,
                              rows: _buildReportRows(filteredReports, context),
                              showCheckboxColumn: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fade(
                      delay: const Duration(
                        milliseconds: 300,
                      ),
                    )
                    .moveY(
                      begin: 10,
                      end: 0,
                      curve: Curves.fastEaseInToSlowEaseOut,
                      duration: const Duration(milliseconds: 650),
                    ),
                const SizedBox(
                  height: 12,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: blackColor.withOpacity(0.1),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: blackColor.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: List.generate(
                      totalPages,
                      (index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                index == _currentPage ? blueColor : whiteColor,
                              ),
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: index == _currentPage
                                        ? Colors.transparent
                                        : blueColor,
                                  ),
                                ),
                              ),
                              fixedSize: WidgetStateProperty.all(
                                const Size(30, 40),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            child: Text(
                              "${index + 1}",
                              style: TextStyle(
                                color: index == _currentPage
                                    ? whiteColor
                                    : blueColor,
                                fontWeight: index == _currentPage
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
                    .animate()
                    .fade(
                      delay: const Duration(
                        milliseconds: 400,
                      ),
                    )
                    .moveY(
                      begin: 10,
                      end: 0,
                      curve: Curves.fastEaseInToSlowEaseOut,
                      duration: const Duration(milliseconds: 850),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<DataRow> _buildReportRows(
      List<Map<String, dynamic>> reports, BuildContext context) {
    return reports
        .sublist(
      _currentPage * _rowsPerPage,
      min(_currentPage * _rowsPerPage + _rowsPerPage, reports.length),
    )
        .map((report) {
      final int index = reports.indexOf(report);
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
        color: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.hovered)) {
              return blackColor.withOpacity(0.05);
            }
            return Colors.transparent;
          },
        ),
      );
    }).toList();
  }
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
          width: MediaQuery.of(context).size.width * 0.9,
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
                          color: blackColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Wrap(
                    spacing: 4,
                    children: [
                      const Text(
                        'Date & Time: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        timestamp,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          color: blackColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 4,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                  const Text(
                    "Plate Number:",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    reportedPlateNumber,
                    style: const TextStyle(
                      color: blackColor,
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
                      color: blackColor,
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
                HoverableImage(imageUrl: attachmentUrls)
              else
                const Text(
                  'No attachment available.',
                  style: TextStyle(color: Colors.grey),
                ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
  bool _isLoading = true;
  double _opacity = 0.0;
  bool _hasError = false;

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
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: blackColor.withOpacity(0.15),
                width: 0.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  if (_isLoading)
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        color: Colors.white,
                        height: MediaQuery.of(context).size.height * 0.3,
                        width: MediaQuery.of(context).size.width * 0.9,
                      ),
                    ),
                  AnimatedOpacity(
                    opacity: _opacity,
                    duration: const Duration(milliseconds: 500),
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: MediaQuery.of(context).size.width * 0.9,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          Future.microtask(() {
                            setState(() {
                              _isLoading = false;
                              _opacity = 1.0;
                            });
                          });
                          return child;
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                      errorBuilder: (context, error, stackTrace) {
                        Future.microtask(() {
                          setState(() {
                            _hasError = true;
                            _isLoading = false;
                          });
                        });
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  if (_hasError)
                    Center(
                      child: Text(
                        'Failed to load image',
                        style: TextStyle(color: blackColor.withOpacity(0.5)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ImageViewer extends StatefulWidget {
  final String imageUrl;

  const ImageViewer({required this.imageUrl, super.key});

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  @override
  Widget build(BuildContext context) {
    bool _isLoading = true;
    bool _hasError = false;

    return Scaffold(
      backgroundColor: blackColor,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Stack(
                children: [
                  if (_isLoading)
                    LoadingAnimationWidget.waveDots(
                      color: blueColor,
                      size: 50,
                    ),
                  Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        Future.microtask(() {
                          setState(() {
                            _isLoading = false;
                          });
                        });
                        return child;
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                    errorBuilder: (context, error, stackTrace) {
                      setState(() {
                        _hasError = true;
                        _isLoading = false;
                      });
                      return Center(
                        child: Text(
                          'Failed to load image',
                          style: TextStyle(color: whiteColor.withOpacity(0.5)),
                        ),
                      );
                    },
                  ),
                  if (_hasError)
                    Center(
                      child: Text(
                        'Failed to load image',
                        style: TextStyle(color: whiteColor.withOpacity(0.5)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
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
        ],
      ),
    );
  }
}
