import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:park_in_web/components/fields/search_field.dart';
import 'package:park_in_web/components/navbar/navbar_desktop.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';
import 'package:park_in_web/components/ui/icon_btn.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
  bool isExporting = false;

  // Tracking sorted column and sort order (ascending/descending)
  int _sortColumnIndex = 0;
  bool _isAscending = true;

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

  late pw.MemoryImage logoImage;

  Future<void> preloadAssets() async {
    final ByteData imageData =
        await rootBundle.load('assets/images/adnu_logo.png');
    logoImage = pw.MemoryImage(imageData.buffer.asUint8List());
  }

  int get totalPages => (_totalItems / _rowsPerPage).ceil();

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
      backgroundColor: bgColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Row(
          children: [
            const NavbarDesktop(),
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
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
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Incident Reports",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: blackColor,
                                ),
                              ),
                              SizedBox(
                                height: 40,
                                width: 210,
                                child: PRKSearchField(
                                  hintText: "Search",
                                  prefixIcon: Icons.search_rounded,
                                  controller: _searchCtrl,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 12,
                                children: [
                                  const Text(
                                    "Filters",
                                    style: TextStyle(
                                      color: blackColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      width: 120,
                                      height: 16,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10)
                                          // shape: BoxShape.circle,
                                          ),
                                    ),
                                  ),
                                  Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      width: 120,
                                      height: 16,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10)
                                          // shape: BoxShape.circle,
                                          ),
                                    ),
                                  ),
                                  Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      width: 120,
                                      height: 16,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10)
                                          // shape: BoxShape.circle,
                                          ),
                                    ),
                                  )
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
                                            filteredReports,
                                            'Incident Reports');
                                        setState(() {
                                          isExporting = false;
                                        });
                                      },
                              )
                            ],
                          )
                        ],
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
                            duration: const Duration(milliseconds: 250)),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Expanded(
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  dataTableTheme: DataTableThemeData(
                                    dividerThickness: 0.2,
                                    headingRowColor:
                                        WidgetStateColor.resolveWith(
                                            (states) => whiteColor),
                                    dataRowColor: WidgetStateColor.resolveWith(
                                        (states) => whiteColor),
                                    headingTextStyle: const TextStyle(
                                        color: blackColor,
                                        fontWeight: FontWeight.w500),
                                    dataTextStyle: const TextStyle(
                                      color: blackColor,
                                    ),
                                  ),
                                ),
                                child: DataTable(
                                  columns: [
                                    DataColumn(
                                      label: const Text("Report ID"),
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
                                              (report) => (report['timestamp']
                                                      as Timestamp)
                                                  .toDate(),
                                              columnIndex,
                                              ascending),
                                    ),
                                  ],
                                  dataRowMinHeight:
                                      MediaQuery.of(context).size.height * 0.03,
                                  dataRowMaxHeight:
                                      MediaQuery.of(context).size.height * 0.06,
                                  sortColumnIndex: _sortColumnIndex,
                                  sortAscending: _isAscending,
                                  rows: _buildReportRows(
                                      filteredReports, context),
                                  showCheckboxColumn: false,
                                ),
                              ),
                            ),
                          ],
                        ),
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
                            duration: const Duration(milliseconds: 450)),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Container(
                      padding: const EdgeInsets.all(20),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Showing ${min((_currentPage + 1) * _rowsPerPage, _totalItems)} out of $_totalItems",
                                style: TextStyle(
                                    color: blackColor.withOpacity(0.5),
                                    fontSize: 12),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: List.generate(
                              totalPages,
                              (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: TextButton(
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                        index == _currentPage
                                            ? blueColor
                                            : whiteColor,
                                      ),
                                      shape: WidgetStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                        ],
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
                            duration: const Duration(milliseconds: 650)),
                  ],
                ),
              ),
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
                          color: blackColor,
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
      cursor: SystemMouseCursors.click,
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
                        width: MediaQuery.of(context).size.width * 0.3,
                      ),
                    ),
                  AnimatedOpacity(
                    opacity: _opacity,
                    duration: const Duration(milliseconds: 500),
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: MediaQuery.of(context).size.width * 0.3,
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
  bool _isLoading = true;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
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
