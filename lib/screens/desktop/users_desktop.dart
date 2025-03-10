import 'dart:math';
// import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:park_in_web/components/fields/search_field.dart';
import 'package:park_in_web/components/navbar/navbar_desktop.dart';
import 'package:park_in_web/components/snackbar/success_snackbar.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';
import 'package:intl/intl.dart';
import 'package:park_in_web/components/ui/icon_btn.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shimmer/shimmer.dart';

class UsersDesktopScreen extends StatefulWidget {
  const UsersDesktopScreen({super.key});

  @override
  State<UsersDesktopScreen> createState() => _UsersDesktopScreenState();
}

class _UsersDesktopScreenState extends State<UsersDesktopScreen> {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchCtrl = TextEditingController();

  // List to hold fetched users
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  bool _isLoading = true;
  bool isExporting = false;

  // Tracking sorted column and sort order (ascending/descending)
  int _sortColumnIndex = 0;
  bool _isAscending = true;
  bool isVerified = false;
  bool isNonVerified = false;

  @override
  void initState() {
    super.initState();
    _listenForUserUpdates(); // Fetch data when the screen is initialized
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

  // Fetch reports from Firestore
  void _listenForUserUpdates() {
    _firestore.collection('User').snapshots().listen((snapshot) {
      setState(() {
        users = snapshot.docs.map((doc) {
          Map<String, dynamic> userData = doc.data();
          userData['docID'] = doc.id;
          return userData;
        }).toList();

        _totalItems = users.length;

        // Initialize filteredusers to display all users initially
        filteredUsers = List.from(users);

        _isLoading = false;
      });
    });
  }

  void _applySearchFilter() {
    final query = _searchCtrl.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        // If search field is empty, show all tickets
        filteredUsers = List.from(users);
      } else {
        // Filter tickets based on the search term
        filteredUsers = users.where((user) {
          final userNumber = user['userNumber']?.toString().toLowerCase() ?? '';
          final name = user['name']?.toString().toLowerCase() ?? '';
          final email = user['email']?.toString().toLowerCase() ?? '';
          final userType = user['userType']?.toString().toLowerCase() ?? '';
          final status =
              user['status']?.toString().toLowerCase() ?? 'non-verified';

          return userNumber.contains(query) ||
              name.contains(query) ||
              email.contains(query) ||
              status.contains(query) ||
              userType.contains(query) ||
              status.contains(query);
        }).toList();
      }

      if (isVerified && isNonVerified) {
        filteredUsers = filteredUsers
            .where((user) =>
                user['status'] == 'verified' ||
                user['status'] == 'non-verified')
            .toList();
      } else if (isVerified) {
        filteredUsers = filteredUsers
            .where((user) => user['status'] == 'verified')
            .toList();
      } else if (isNonVerified) {
        filteredUsers = filteredUsers
            .where((user) => user['status'] == 'non-verified')
            .toList();
      }

      // set the number of total items to the length of filtered tickets
      _totalItems = filteredUsers.length;

      // reset current page para dae mag out of bounds
      _currentPage = 0;
    });
  }

  // Sorting function for the columns
  void _sort<T>(Comparable<T> Function(Map<String, dynamic> user) getField,
      int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _isAscending = ascending;

      filteredUsers.sort((a, b) {
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
  int get totalPages => (_totalItems / _rowsPerPage).ceil();

  Future<void> fetchTotalItems() async {
    setState(() {
      isLoading = true; // Start loading
    });
    try {
      final querySnapshot = await _firestore.collection('User').get();

      _totalItems = querySnapshot.docs.length;
    } catch (e) {
      print('Error fetching total items: $e'); // Print error message
    } finally {
      setState(() {
        isLoading = false; // End loading
      });
    }
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
        item['userNumber'] ?? '',
        item['userType'] ?? '',
        pw.Container(
          width: 350,
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(
            item['name'] ?? '',
          ),
        ),
        item['status'] ?? '',
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
              // Image on the left
              pw.Image(
                logoImage,
                width: 50,
                height: 50,
                fit: pw.BoxFit.contain,
              ),
              pw.SizedBox(width: 10),

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
                    child: pw.Text('Doc ID',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('User Number',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('User Type',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('Name',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('Status',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
              // Data rows
              for (final row in tableRows)
                pw.TableRow(
                  children: row.map((cell) {
                    if (cell is String) {
                      return pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(cell),
                      );
                    } else if (cell is pw.Widget) {
                      return cell;
                    }
                    return pw.Text('');
                  }).toList(),
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
                                "User Details",
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
                                  Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Transform.scale(
                                        scale: 0.9,
                                        child: Checkbox(
                                          value: isVerified,
                                          activeColor: parkingOrangeColor,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              isVerified = value!;
                                              if (isVerified) {
                                                isNonVerified = false;
                                              }
                                              _applySearchFilter();
                                            });
                                          },
                                        ),
                                      ),
                                      const Text(
                                        "Verified",
                                        style: TextStyle(
                                          color: blackColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      )
                                    ],
                                  ),
                                  Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Transform.scale(
                                        scale: 0.9,
                                        child: Checkbox(
                                          value: isNonVerified,
                                          activeColor: parkingOrangeColor,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              isNonVerified = value!;
                                              if (isNonVerified) {
                                                isVerified = false;
                                              }
                                              _applySearchFilter();
                                            });
                                          },
                                        ),
                                      ),
                                      const Text(
                                        "Non-Verified",
                                        style: TextStyle(
                                          color: blackColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      )
                                    ],
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
                                            filteredUsers, 'Users');
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
                                    dataTextStyle:
                                        const TextStyle(color: blackColor),
                                  ),
                                ),
                                child: DataTable(
                                  columns: [
                                    DataColumn(
                                      label: const Text("User ID"),
                                      onSort: (columnIndex, ascending) =>
                                          _sort<String>(
                                              (user) => user['docID'] ?? 0,
                                              columnIndex,
                                              ascending),
                                    ),
                                    DataColumn(
                                      label: const Text("User Number"),
                                      onSort: (columnIndex, ascending) =>
                                          _sort<String>(
                                              (user) => user['userNumber'] ?? 0,
                                              columnIndex,
                                              ascending),
                                    ),
                                    DataColumn(
                                      label: const Text("Name"),
                                      onSort: (columnIndex, ascending) =>
                                          _sort<String>(
                                              (user) => user['name'] ?? 0,
                                              columnIndex,
                                              ascending),
                                    ),
                                    DataColumn(
                                      label: const Text("Mobile Number"),
                                      onSort: (columnIndex, ascending) =>
                                          _sort<String>(
                                              (user) => user['mobileNo'] ?? 0,
                                              columnIndex,
                                              ascending),
                                    ),
                                    DataColumn(
                                      label: const Text("User Type"),
                                      onSort: (columnIndex, ascending) =>
                                          _sort<String>(
                                              (user) => user['userType'] ?? 0,
                                              columnIndex,
                                              ascending),
                                    ),
                                    DataColumn(
                                      label: const Text("Status"),
                                      onSort: (columnIndex, ascending) =>
                                          _sort<String>(
                                              (report) => report['status'] ?? 0,
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
                                  rows: _buildUserRows(filteredUsers, context),
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
                            // crossAxisAlignment: CrossAxisAlignment.center,
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

  List<DataRow> _buildUserRows(
      List<Map<String, dynamic>> users, BuildContext context) {
    return users
        .sublist(
      _currentPage * _rowsPerPage,
      min(_currentPage * _rowsPerPage + _rowsPerPage, users.length),
    )
        .map((user) {
      final int index = users.indexOf(user);
      final docID = user['docID'] ?? '';
      final userNumber = user['userNumber'] ?? '';
      final name = user['name'] ?? '';
      final mobileNo = user['mobileNo'] ?? '';
      final userType = user['userType'] ?? '';
      final plateNo = user['plateNo'] ?? '';
      final stickerNo = user['stickerNumber'] ?? '';
      final email = user['email'] ?? '';
      final status = user['status'] ?? 'non-verified';
      final imageUrl1 = user['attachment'] ?? '';

      // final formattedDate = DateFormat('MM/dd/yyyy').format(timestamp);
      // final formattedTime = DateFormat('hh:mm a').format(timestamp);
      // final formattedDateTime = '$formattedDate at $formattedTime';

      return DataRow(
        cells: [
          DataCell(Text(docID)),
          DataCell(Text(userNumber)),
          DataCell(Text(name)),
          DataCell(Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.35),
            child: Text(
              mobileNo,
              style: const TextStyle(overflow: TextOverflow.fade),
            ),
          )),
          DataCell(Text(userType)),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: status == 'verified'
                    ? parkingGreenColor.withOpacity(0.08)
                    : status == 'non-verified'
                        ? parkingOrangeColor.withOpacity(0.07)
                        : blackColor,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: status == 'verified'
                      ? const Color.fromARGB(255, 17, 194, 1)
                      : status == 'non-verified'
                          ? parkingOrangeColor
                          : blackColor,
                ),
              ),
            ),
          ),
          // DataCell(Text(formattedDateTime)),
        ],
        onSelectChanged: (selected) {
          if (selected ?? false) {
            _modal(
              context,
              docID,
              userNumber,
              name,
              mobileNo,
              userType,
              plateNo,
              stickerNo,
              email,
              status,
              imageUrl1,
            );
          }
        },
        color: WidgetStateProperty.resolveWith(
          (states) {
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

void _modal(
  BuildContext context,
  String docID,
  String userNumber,
  String name,
  String mobileNo,
  String userType,
  List<dynamic> plateNo,
  List<dynamic> stickerNo,
  String email,
  String status,
  String attachmentUrl1,
) async {
  // query userNumber and mobileNo based on plateNo from Firestore
  // FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // String userNumber = 'Not available';
  // String mobileNo = 'Not available';

  try {
    // QuerySnapshot userSnapshot = await _firestore
    //     .collection('User')
    //     .where('plateNo', arrayContains: plateNo)
    //     .get();

    // if (userSnapshot.docs.isNotEmpty) {
    //   var userData = userSnapshot.docs.first.data() as Map<String, dynamic>;
    //   userNumber = userData['userNumber'] ?? 'Not available';
    //   mobileNo = userData['mobileNo'] ?? 'Not available';
    // }
  } catch (e) {
    print('Error fetching user details: $e');
  }

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
            "User Information",
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
                        'User Number: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      // Text(
                      //   plateNo,
                      //   style: const TextStyle(
                      //     fontWeight: FontWeight.normal,
                      //     color: blackColor,
                      //   ),
                      // ),
                      Text(
                        userNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          color: blackColor,
                        ),
                      ),
                    ],
                  ),
                  // Text(
                  //   timestamp,
                  //   style: TextStyle(
                  //     fontWeight: FontWeight.normal,
                  //     color: blackColor.withOpacity(0.5),
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    spacing: 4,
                    children: [
                      const Text(
                        'Phone Number: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        mobileNo,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          color: blackColor,
                        ),
                      ),
                    ],
                  ),
                  // Text(
                  //   userNumber,
                  //   style: TextStyle(
                  //     fontWeight: FontWeight.normal,
                  //     color: blackColor.withOpacity(0.5),
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 4,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                  const Text(
                    'Name: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
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
                    'Email: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    email,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      color: blackColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                children: [
                  const Text(
                    'Status: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: status == 'verified'
                          ? parkingGreenColor.withOpacity(0.08)
                          : status == 'non-verified'
                              ? parkingOrangeColor.withOpacity(0.07)
                              : blackColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: status == 'verified'
                            ? const Color.fromARGB(255, 17, 194, 1)
                            : status == 'non-verified'
                                ? parkingOrangeColor
                                : blackColor,
                      ),
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
              if (attachmentUrl1.isNotEmpty)
                HoverableImage(imageUrl: attachmentUrl1)
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
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: blueColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              if (status == 'verified') {
                _confirmRevertModal(context, docID);
              } else {
                _confirmResolveModal(context, docID);
              }
            },
            child: Text(
              status == 'verified' ? "Revert to Non-Verified?" : "Verify",
              style: const TextStyle(
                color: whiteColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    },
  );
}

void _confirmResolveModal(BuildContext context, String docID) async {
  bool confirmed = false;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: const Text(
          "Confirm Changes",
          style: TextStyle(
            color: blackColor,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: const Text(
          "Are you sure you want to verify this user?",
          style: TextStyle(
            color: blackColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: blueColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: blueColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              confirmed = true;
              Navigator.of(context).pop();
            },
            child: const Text(
              "Confirm",
              style: TextStyle(
                color: whiteColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    },
  );

  if (confirmed) {
    await _firestore.collection('User').doc(docID).update(
      {
        'status': 'verified',
      },
    );
    Navigator.of(context).pop();
    successSnackbar(
        context, "Verified!", MediaQuery.of(context).size.width * 0.3);
  }
}

void _confirmRevertModal(BuildContext context, String docID) async {
  bool confirmed = false;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: const Text(
          "Confirm Changes",
          style: TextStyle(
            color: blackColor,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: const Text(
          "Are you sure you want to revert this user to non-verified?",
          style: TextStyle(
            color: blackColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: blueColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: blueColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              confirmed = true;
              Navigator.of(context).pop();
            },
            child: const Text(
              "Confirm",
              style: TextStyle(
                color: whiteColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    },
  );

  if (confirmed) {
    await _firestore.collection('User').doc(docID).update(
      {
        'status': 'non-verified',
      },
    );
    Navigator.of(context).pop();
    successSnackbar(context, "User Reverted to Non-Verified!",
        MediaQuery.of(context).size.width * 0.3);
  }
}

class HoverableImage extends StatefulWidget {
  final String imageUrl;

  const HoverableImage({
    Key? key,
    required this.imageUrl,
  }) : super(key: key);

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
