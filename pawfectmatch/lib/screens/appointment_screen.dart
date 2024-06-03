import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pawfectmatch/models/appointment_model.dart';
import 'package:pawfectmatch/screens/appointmentdetails_screen.dart';
import 'package:pawfectmatch/screens/newappointment_screen.dart';
import '/repositories/database_repository.dart'; 

class AppointmentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Appointments'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _AppointmentList(status: 'pending', appointments: [],),
            _AppointmentList(status: 'upcoming', appointments: [],),
            _AppointmentList(status: 'completed', appointments: [],),
            _AppointmentList(status: 'cancelled', appointments: [],),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewAppointmentScreen(),
              ),
            );
            if (result != null && result){
              DefaultTabController.of(context).animateTo(0);// Switch to the 'Pending' tab
            }
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  final String status;
  final List<Appointment> appointments; // Pass the list of Appointment objects
  final VoidCallback? onAppointmentCreated; // Callback function

  _AppointmentList({required this.status, required this.appointments, this.onAppointmentCreated});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Appointment>>(
      // Update the generic type of FutureBuilder
      future: _getAppointments(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No $status appointments available.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              // Use a GestureDetector to make the ListTile tappable
              return GestureDetector(
                onTap: () {
                  // Navigate to AppointmentDetailsScreen when tapped
                  _navigateToAppointmentDetails(context, snapshot.data![index]);
                },
                child: ListTile(
                  title: Text(snapshot.data![index].dog),
                  subtitle: Text('Date and Time: ${_formatDateTime(snapshot.data![index].date)}'),
                ),
              );
            },
          );
        }
      },
    );
  }

  String _formatDateTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('EEE, MMM d, y h:mm a').format(dateTime);
  }

  void _navigateToAppointmentDetails(BuildContext context, Appointment appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentDetailsScreen(appointment: appointment),
      ),
    );
  }

  Future<List<Appointment>> _getAppointments(String status) async {
    try {
      List<Appointment> appointments = await DatabaseRepository().getAppointmentsByStatus(status);
      return appointments;
    } catch (error) {
      print('Error fetching appointments: $error');
      return [];
    }
  }
}
