
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

class DateSelecter extends StatefulWidget {
  final String workerId;
  final String workerName;
  final String workerDp;
  final String workerPh;
  final String userId;
  final String userDp;
  final String userName;
  final String userPh;

  DateSelecter({
    required this.workerId,
    required this.workerName,
    required this.workerPh,
    required this.workerDp,
    required this.userId,
    required this.userDp,
    required this.userName,
    required this.userPh,
  });

  @override
  _DateSelecterState createState() => _DateSelecterState();
}

class _DateSelecterState extends State<DateSelecter> {
  late FirebaseFirestore _firestore;
  List<DateTime> selectedDates = [];
  DateTime focusedDate = DateTime.now();
  List<DateTime> unavailableDates = [];

  TextEditingController addressControler = TextEditingController();
  TextEditingController jobDetailsControler = TextEditingController();

  @override
  void initState() {
    super.initState();
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);
    _firestore = FirebaseFirestore.instance;
    _fetchUnavailableDates();
  }

  Future<void> _fetchUnavailableDates() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('unavailable_dates')
          .where('worker_id', isEqualTo: widget.workerId)
          .get();

      setState(() {
        unavailableDates = snapshot.docs
            .map((doc) => DateTime.parse(doc['date'] as String))
            .toList();
      });
    } catch (e) {
      print('Error fetching unavailable dates: $e');
    }
  }

  Future<void> _submitUserRequest() async {
    try {
      for (var date in selectedDates) {
        String formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        String requestId = randomAlphaNumeric(10);
        final requestInfomap = {
          'worker_id': widget.workerId,
          'user_id': widget.userId,
          'worker_name': widget.workerName,
          'worker_ph': widget.workerPh,
          'worker_dp': widget.workerDp,
          'user_name': widget.userName,
          'user_ph': widget.userPh,
          'user_dp': widget.userDp,
          'user_location': addressControler.text.trim(),
          'job_details': jobDetailsControler.text.trim(),
          'date': formattedDate,
          'status': 'pending',
          'requestId': requestId,
        };

        await _firestore.collection('requests').doc(requestId).set(requestInfomap);
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request submitted for selected dates')));
    } catch (e) {
      print('Error submitting user request: $e');
    }
  }


  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      if (selectedDates.contains(selectedDay)) {
        selectedDates.remove(selectedDay);
      } else {
        selectedDates.add(selectedDay);
      }
    });
  }

  bool _isUnavailable(DateTime date) {
    return unavailableDates.any((unavailableDate) =>
    unavailableDate.year == date.year &&
        unavailableDate.month == date.month &&
        unavailableDate.day == date.day);
  }

  bool _isPastDate(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  late Razorpay razorpay;

  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    showAlertDialog(context,
        "Payment Failed",
        "Code: ${response.code}\nDescription: ${response.message}\nMetadata:${response.error.toString()}",
        Icons.cancel, Colors.redAccent);
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) async {
    await _submitUserRequest();
    Navigator.pop(context);
    showAlertDialog(context, "Request Sending Successful", "Payment ID: ${response.paymentId}",
        Icons.check_circle, Colors.green);
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {
    showAlertDialog(context, "External Wallet Selected", "${response.walletName}",
        Icons.wallet, Colors.blue);
  }

  @override
  void dispose() {
    super.dispose();
    razorpay.clear();
  }

  void openCheckout() async {
    var options = {
      'key': 'rzp_test_JsrtWUyyMDQGOB',
      'amount': 5500,
      'name': '${widget.userName}',
      'description': '${widget.workerName}',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': '${widget.userPh}',
        'email': 'test@razorpay.com'
      },
    };
    try {
      razorpay.open(options);
    } catch (e) {
      print('Error:$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select The Requested Dates')),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(10),
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: focusedDate,
                selectedDayPredicate: (day) {
                  return selectedDates.contains(day);
                },
                onDaySelected: _onDaySelected,
                calendarFormat: CalendarFormat.month,
                headerStyle: HeaderStyle(formatButtonVisible: false),
                enabledDayPredicate: (day) => !_isUnavailable(day) && _isPastDate(day),
              ),
              TextField(
                controller: addressControler,
                maxLines: 5,
                minLines: 5,
                decoration: InputDecoration(label: Text('Enter your address')),
              ),
              SizedBox(height: 20),
              TextField(
                controller: jobDetailsControler,
                maxLines: 5,
                minLines: 5,
                decoration: InputDecoration(label: Text('Enter job details')),
              ),
              SizedBox(height: 30),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                        selectedDates.isEmpty||addressControler.text.isEmpty||jobDetailsControler.text.isEmpty ? Colors.grey : Colors.blue.shade200),
                  ),
                  onPressed: selectedDates.isEmpty||addressControler.text.isEmpty||jobDetailsControler.text.isEmpty
                      ? null
                      : () {
                    openCheckout();
                  },
                  child: Text(
                    'Continue',
                    style: TextStyle(
                        color: selectedDates.isEmpty||addressControler.text.isEmpty||jobDetailsControler.text.isEmpty ? Colors.white : Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showAlertDialog(BuildContext context, String title, String message, IconData icon, Color iconClr) {
    Widget continueButton = ElevatedButton(
      child: const Text("Continue"),
      onPressed: () {},
    );
    AlertDialog alert = AlertDialog(
      icon: Icon(icon, color: iconClr),
      title: Text(title),
      content: Text('          $message'),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

