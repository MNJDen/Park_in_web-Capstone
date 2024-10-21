import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:park_in_web/components/fields/search_field.dart';
import 'package:park_in_web/components/navbar/navbar_desktop.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class TicketsDesktopScreen extends StatefulWidget {
  const TicketsDesktopScreen({super.key});

  @override
  State<TicketsDesktopScreen> createState() => _TicketsDesktopScreenState();
}

class _TicketsDesktopScreenState extends State<TicketsDesktopScreen> {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchCtrl = TextEditingController();

  // List to hold fetched tickets
  List<Map<String, dynamic>> tickets = [];
  List<Map<String, dynamic>> filteredTickets = [];
  bool _isLoading = true;

  // Tracking sorted column and sort order (ascending/descending)
  int _sortColumnIndex = 0;
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _listenForTicketUpdates(); // Fetch data when the screen is initialized
    _searchCtrl.addListener(_applySearchFilter);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_applySearchFilter);
    _searchCtrl.dispose();
    super.dispose();
  }

  // Fetch reports from Firestore
  void _listenForTicketUpdates() {
    _firestore.collection('Violation Ticket').snapshots().listen((snapshot) {
      setState(() {
        tickets = snapshot.docs.map((doc) {
          Map<String, dynamic> ticketData = doc.data();
          ticketData['docID'] = doc.id;
          return ticketData;
        }).toList();

        // Sorting tickets by timestamp
        tickets.sort((a, b) {
          DateTime dateA = (a['timestamp'] as Timestamp).toDate();
          DateTime dateB = (b['timestamp'] as Timestamp).toDate();
          return dateA.compareTo(dateB); // Sort in ascending order
        });

        // Initialize filteredTickets to display all tickets initially
        filteredTickets = List.from(tickets);

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
        filteredTickets = List.from(tickets);
      } else {
        // Filter tickets based on the search term
        filteredTickets = tickets.where((ticket) {
          final ticketedTo =
              ticket['plate_number']?.toString().toLowerCase() ?? '';
          final vehicleType =
              ticket['vehicle_type']?.toString().toLowerCase() ?? '';
          final violation = ticket['violation']?.toString().toLowerCase() ?? '';
          final status =
              ticket['status']?.toString().toLowerCase() ?? 'pending';
          final timestamp = ticket['timestamp'] as Timestamp?;
          String ticketDate = '';
          if (timestamp != null) {
            ticketDate = dateFormatter.format(timestamp.toDate()).toLowerCase();
          }

          return ticketedTo.contains(query) ||
              vehicleType.contains(query) ||
              violation.contains(query) ||
              status.contains(query) ||
              ticketDate.contains(query);
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

      filteredTickets.sort((a, b) {
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
          const SizedBox(
            height: 28,
          ),
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
                  dataTextStyle: const TextStyle(color: blackColor),
                ),
              ),
              child: PaginatedDataTable(
                header: const Text(
                  "Tickets Issued",
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
                    label: const Text("Ticket ID"),
                    onSort: (columnIndex, ascending) => _sort<String>(
                        (report) => report['docID'] ?? 0,
                        columnIndex,
                        ascending),
                  ),
                  DataColumn(
                    label: const Text("Ticketed To"),
                    onSort: (columnIndex, ascending) => _sort<String>(
                        (report) => report['plate_number'] ?? 0,
                        columnIndex,
                        ascending),
                  ),
                  DataColumn(
                    label: const Text("Vehicle Type"),
                    onSort: (columnIndex, ascending) => _sort<String>(
                        (report) => report['vehicle_type'] ?? 0,
                        columnIndex,
                        ascending),
                  ),
                  DataColumn(
                    label: const Text("Violation"),
                    onSort: (columnIndex, ascending) => _sort<String>(
                        (report) => report['violation'] ?? 0,
                        columnIndex,
                        ascending),
                  ),
                  DataColumn(
                    label: const Text("Status"),
                    onSort: (columnIndex, ascending) => _sort<String>(
                        (report) => report['status'] ?? 0,
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
                source: ReportDataSource(filteredTickets, context),
                rowsPerPage: 10,
                showCheckboxColumn: false,
                arrowHeadColor: blueColor,
                showEmptyRows: true,
                showFirstLastButtons: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReportDataSource extends DataTableSource {
  final List<Map<String, dynamic>> tickets;
  final BuildContext context;

  ReportDataSource(this.tickets, this.context);

  @override
  DataRow getRow(int index) {
    final ticket = tickets[index];
    final docID = ticket['docID'] ?? '';
    final ticketedTo = ticket['plate_number'] ?? '';
    final vehicleType = ticket['vehicle_type'] ?? '';
    final violation = ticket['violation'] ?? '';
    final description = ticket['description'] ?? '';
    final status = ticket['status'] ?? 'Pending';
    final timestamp =
        (ticket['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    final imageUrl1 = ticket['close_up_image_url'] ?? '';
    final imageUrl2 = ticket['mid_shot_image_url'] ?? '';
    final imageUrl3 = ticket['wide_shot_image_url'] ?? '';

    final formattedDate = DateFormat('MM/dd/yyyy').format(timestamp);
    final formattedTime =
        DateFormat('hh:mm a').format(timestamp); // 12-hour format
    final formattedDateTime = '$formattedDate at $formattedTime';

    return DataRow(
      cells: [
        // DataCell(Text('${index + 1}')),
        DataCell(Text(docID)),
        DataCell(Text(ticketedTo)),
        DataCell(Text(vehicleType)),
        DataCell(Text(violation)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: status == 'Resolved'
                  ? parkingGreenColor.withOpacity(0.08)
                  : status == 'Pending'
                      ? parkingOrangeColor.withOpacity(0.07)
                      : blackColor,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: status == 'Resolved'
                    ? parkingGreenColor
                    : status == 'Pending'
                        ? parkingOrangeColor
                        : blackColor,
              ),
            ),
          ),
        ),
        DataCell(Text(formattedDateTime)),
      ],
      onSelectChanged: (selected) {
        if (selected ?? false) {
          _modal(
            context,
            docID,
            ticketedTo,
            vehicleType,
            violation,
            description,
            status,
            formattedDateTime,
            imageUrl1,
            imageUrl2,
            imageUrl3,
          );
        }
      },
      color: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.hovered)) {
            return blackColor.withOpacity(0.05);
          }
          return index.isEven ? blueColor.withOpacity(0.05) : whiteColor;
        },
      ),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => tickets.length;

  @override
  int get selectedRowCount => 0;
}

void _modal(
  BuildContext context,
  String docID,
  String plateNo,
  String vehicleType,
  String violation,
  String description,
  String status,
  String timestamp,
  String attachmentUrl1,
  String attachmentUrl2,
  String attachmentUrl3,
) async {
  // query userNumber and mobileNo based on plateNo from Firestore
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userNumber = 'Not available';
  String mobileNo = 'Not available';

  try {
    QuerySnapshot userSnapshot = await _firestore
        .collection('User')
        .where('plateNo', arrayContains: plateNo)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      var userData = userSnapshot.docs.first.data() as Map<String, dynamic>;
      userNumber = userData['userNumber'] ?? 'Not available';
      mobileNo = userData['mobileNo'] ?? 'Not available';
    }
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
            "Ticket Information",
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
                        'Ticketed To: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        plateNo,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          color: blackColor,
                        ),
                      ),
                      Text(
                        '($userNumber)',
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
                  Text(
                    vehicleType,
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
                    'Violation: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    violation,
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
                    'Description: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    description,
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
                      color: status == 'Resolved'
                          ? parkingGreenColor.withOpacity(0.08)
                          : status == 'Pending'
                              ? parkingOrangeColor.withOpacity(0.07)
                              : blackColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: status == 'Resolved'
                            ? parkingGreenColor
                            : status == 'Pending'
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (int i = 0;
                      i <
                          [attachmentUrl1, attachmentUrl2, attachmentUrl3]
                              .length;
                      i++)
                    if ([attachmentUrl1, attachmentUrl2, attachmentUrl3][i]
                        .isNotEmpty)
                      HoverableImage(
                        imageUrl: [
                          attachmentUrl1,
                          attachmentUrl2,
                          attachmentUrl3
                        ][i],
                        imageUrls: [
                          attachmentUrl1,
                          attachmentUrl2,
                          attachmentUrl3
                        ],
                        index: i,
                        onTap: (index) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageViewer(
                                imageUrls: [
                                  attachmentUrl1,
                                  attachmentUrl2,
                                  attachmentUrl3
                                ],
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                      ),
                ],
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
              if (status == 'Resolved') {
                _confirmRevertModal(context, docID);
              } else {
                _confirmResolveModal(context, docID);
              }
            },
            child: Text(
              status == 'Resolved' ? "Revert to Pending?" : "Resolve",
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
          "Are you sure you want to resolve this ticket?",
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
    await _firestore.collection('Violation Ticket').doc(docID).update(
      {
        'status': 'Resolved',
      },
    );
    Navigator.of(context).pop();
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
          "Are you sure you want to revert this ticket to pending?",
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
    await _firestore.collection('Violation Ticket').doc(docID).update(
      {
        'status': 'Pending',
      },
    );
    Navigator.of(context).pop();
  }
}

class HoverableImage extends StatefulWidget {
  final String imageUrl;
  final List<String> imageUrls;
  final int index;
  final void Function(int) onTap;

  const HoverableImage({
    Key? key,
    required this.imageUrl,
    required this.imageUrls,
    required this.index,
    required this.onTap,
  }) : super(key: key);

  @override
  _HoverableImageState createState() => _HoverableImageState();
}

class _HoverableImageState extends State<HoverableImage> {
  bool _isHovered = false;
  bool _isLoading = true; // Add a loading state
  double _opacity = 0.0; // For the fade-in effect

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onTap(widget.index),
        child: AnimatedScale(
          scale: _isHovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width * 0.095,
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
                        height: MediaQuery.of(context).size.height * 0.2,
                        width: MediaQuery.of(context).size.width * 0.095,
                      ),
                    ),
                  AnimatedOpacity(
                    opacity: _opacity,
                    duration: const Duration(milliseconds: 500),
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      height: MediaQuery.of(context).size.height * 0.2,
                      width: MediaQuery.of(context).size.width * 0.095,
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
  final List<String> imageUrls;
  final int initialIndex;

  const ImageViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

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
              child: Image.network(
                widget.imageUrls[_currentIndex],
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding:
                EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                hoverColor: whiteColor.withOpacity(0.2),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: whiteColor,
                ),
                onPressed: _currentIndex > 0
                    ? () {
                        setState(() {
                          _currentIndex--;
                        });
                      }
                    : null,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.03),
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                hoverColor: whiteColor.withOpacity(0.2),
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: whiteColor,
                ),
                onPressed: _currentIndex < widget.imageUrls.length - 1
                    ? () {
                        setState(() {
                          _currentIndex++;
                        });
                      }
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
