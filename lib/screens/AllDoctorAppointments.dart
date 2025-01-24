import 'package:alz/models/usermodel.dart';
import 'package:alz/providers/UserProvider.dart';
import 'package:alz/screens/DoctorVisit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DoctorVisitDetailsPage extends StatefulWidget {


  const DoctorVisitDetailsPage({super.key});

  @override
  State<DoctorVisitDetailsPage> createState() => _DoctorVisitDetailsPageState();
}

class _DoctorVisitDetailsPageState extends State<DoctorVisitDetailsPage> {
  Future<List<Map<String, dynamic>>> _fetchDoctorVisits(String userId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('docvisits')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    UserModel user=Provider.of<UserProvider>(context).userModel!;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DoctorVisitPage()),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchDoctorVisits(user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No doctor visits found.'));
          }

          final visits = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: visits.length,
            itemBuilder: (context, index) {
              final visit = visits[index];
              final visitDateTime = DateTime.parse(visit['visitDateTime']);
              final formattedDate = DateFormat('dd MMMM yyyy').format(visitDateTime);
              final formattedTime = DateFormat('hh:mm a').format(visitDateTime);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visit['doctorName'] ?? 'Unknown Doctor',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          const Icon(Icons.medical_services, color: Colors.purple),
                          const SizedBox(width: 8.0),
                          Text(
                            visit['doctorSpeciality'] ?? 'Speciality not specified',
                            style: const TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.blue),
                          const SizedBox(width: 8.0),
                          Text(
                            formattedDate,
                            style: const TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.green),
                          const SizedBox(width: 8.0),
                          Text(
                            formattedTime,
                            style: const TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.red),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              visit['doctorAddress'] ?? 'Address not provided',
                              style: const TextStyle(fontSize: 16, color: Colors.black54),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Logged on ${DateFormat('dd MMM yyyy, hh:mm a').format((visit['timestamp'] as Timestamp).toDate())}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
