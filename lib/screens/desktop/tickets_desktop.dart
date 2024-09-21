import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:park_in_web/components/navbar/navbar_desktop.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';
import 'package:intl/intl.dart';

class TicketsDesktopScreen extends StatefulWidget {
  const TicketsDesktopScreen({super.key});

  @override
  State<TicketsDesktopScreen> createState() => _TicketsDesktopScreenState();
}

class _TicketsDesktopScreenState extends State<TicketsDesktopScreen> {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List to hold fetched tickets
  List<Map<String, dynamic>> tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReports(); // Fetch data when the screen is initialized
  }

  // Fetch reports from Firestore
  Future<void> _fetchReports() async {
    QuerySnapshot snapshot =
        await _firestore.collection('Violation Ticket').get();
    setState(() {
      tickets = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // Sorting tickets
      tickets.sort((a, b) {
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
          const SizedBox(
            height: 28,
          ),
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
                        "Tickets Issued",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: blackColor,
                        ),
                      ),
                      columns: const [
                        DataColumn(label: Text("Ticket ID")),
                        DataColumn(label: Text("Ticketed To")),
                        DataColumn(label: Text("Vehicle Type")),
                        DataColumn(label: Text("Violation")),
                        DataColumn(label: Text("Status")),
                        DataColumn(label: Text("Date")),
                      ],
                      source: ReportDataSource(tickets, context),
                      rowsPerPage: 6,
                    ),
            ),
          ),
          const SizedBox(
            height: 28,
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
    final ticketedTo = ticket['plate_number'] ?? '';
    final vehicleType = ticket['vehicle_type'] ?? '';
    final violation = ticket['violation'] ?? '';
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

    return DataRow(cells: [
      DataCell(Text('${index + 1}')),
      // DataCell(Text(ticketedTo)),
      DataCell(
        GestureDetector(
          onTap: () {
            _modal(context, ticketedTo, vehicleType, violation, status,
                formattedDateTime, imageUrl1, imageUrl2, imageUrl3);
          },
          child: Container(
            constraints: BoxConstraints(maxWidth: 250),
            child: Text(
              ticketedTo,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
      // DataCell(Text(vehicleType)),
      DataCell(
        GestureDetector(
          onTap: () {
            _modal(context, ticketedTo, vehicleType, violation, status,
                formattedDateTime, imageUrl1, imageUrl2, imageUrl3);
          },
          child: Container(
            constraints: BoxConstraints(maxWidth: 250),
            child: Text(
              vehicleType,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
      // DataCell(Text(violation)),
      DataCell(
        GestureDetector(
          onTap: () {
            _modal(context, ticketedTo, vehicleType, violation, status,
                formattedDateTime, imageUrl1, imageUrl2, imageUrl3);
          },
          child: Container(
            constraints: BoxConstraints(maxWidth: 250),
            child: Text(
              violation,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
      // DataCell(Text(status)),
      DataCell(
        GestureDetector(
          onTap: () {
            _modal(context, ticketedTo, vehicleType, violation, status,
                formattedDateTime, imageUrl1, imageUrl2, imageUrl3);
          },
          child: Container(
            constraints: BoxConstraints(maxWidth: 250),
            child: Text(
              status,
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
            _modal(context, ticketedTo, vehicleType, violation, status,
                formattedDateTime, imageUrl1, imageUrl2, imageUrl3);
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

  void _modal(
      BuildContext context,
      String ticketedTo,
      String vehicleType,
      String violation,
      String status,
      String timestamp,
      String attachmentUrl1,
      String attachmentUrl2,
      String attachmentUrl3) {
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
                      'Ticketed To: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      ticketedTo,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Vehicle Type: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      vehicleType,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Description: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      violation,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Status: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      status,
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
                  violation,
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
                if (attachmentUrl1.isNotEmpty)
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
                        attachmentUrl1,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
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
                      attachmentUrl2,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
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
                      attachmentUrl3,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // else
                //   Text(
                //     'No attachment available.',
                //     style: TextStyle(color: Colors.grey),
                //   ),
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
  int get rowCount => tickets.length;

  @override
  int get selectedRowCount => 0;
}
