import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pawfectmatch/models/appointment_model.dart';
import 'package:pawfectmatch/repositories/database_repository.dart';
import 'package:pawfectmatch/screens/appointment_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final Appointment appointment;

  AppointmentDetailsScreen({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appointment Details:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildDetailRow('Dog:', appointment.dog),
            _buildDetailRow('Status:', appointment.status),
            _buildDetailRow('Date and Time:', _formatDateTime(appointment.date)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (appointment.status == 'pending')
                  ElevatedButton(
                    onPressed: () {
                      _confirmAppointment(context);
                    },
                    child: Text('Confirm Appointment'),
                  ),
                ElevatedButton(
                  onPressed: () {
                    _cancelAppointment(context);
                  },
                  child: Text('Cancel Appointment'),
                ),
                if (appointment.status == 'upcoming')
                  ElevatedButton(
                    onPressed: () {
                      _paidAppointment(context);
                      _proceedToPayment(context);
                    },
                    child: Text('Proceed to Payment'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  String _formatDateTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('EEE, MMM d, y h:mm a').format(dateTime);
  }

  void _cancelAppointment(BuildContext context) async {
    try {
      await DatabaseRepository().CancelAppointment(
        appointment.id,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AppointmentScreen()),
      );
    } catch (error) {
      // Handle the error (e.g., show an error message)
      print('Error cancelling appointment: $error');
    }
  }
  void _paidAppointment(BuildContext context) async {
    try {
      await DatabaseRepository().PaidAppointment(
        appointment.id,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AppointmentScreen()),
      );
    } catch (error) {
      // Handle the error (e.g., show an error message)
      print('Error cancelling appointment: $error');
    }
  }
  void _confirmAppointment(BuildContext context) async {
    try {
      // Add logic to update the appointment status to 'upcoming' in the database
      // You may need to call a function to update the status based on your data model
      await DatabaseRepository().confirmAppointment(appointment.id);

      // Reload the screen or update the UI as needed
      // For simplicity, just printing a message here
      print('Appointment confirmed successfully!');

      // Optionally, show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Appointment confirmed successfully!'),
      ));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AppointmentScreen()),
      );
    } catch (error) {
      // Handle the error (e.g., show an error message)
      print('Error confirming appointment: $error');
    }
  }

  void _proceedToPayment(BuildContext context) {
    try {
      _launchURL(
          "https://pm.link/org-CE8qjbKiDcVRAQjPkYns4jk8/test/DTtRuBj", context);
      // Additional logic after launching the URL if needed
    } catch (e) {
      print('Error in _proceedToPayment: $e');
    }
    //Navigator.pop(context);
  }

  void _launchURL(String url, BuildContext context) async {
    try {
      await launch(url);
      //await launch(url, forceWebView: true, enableJavaScript: true);
    } catch (e) {
      // If an error occurs, try opening in the external browser without WebView
      try {
        await launch(url, forceWebView: true, enableJavaScript: true);
        //await launch(url);
      } catch (e) {
        print('Error launching URL: $e');
      }
    }
  }
}
