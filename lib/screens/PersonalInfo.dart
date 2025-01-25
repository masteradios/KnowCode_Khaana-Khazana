import 'package:alz/models/usermodel.dart';
import 'package:alz/providers/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Personal_Info extends StatelessWidget {

  const Personal_Info({super.key});

  @override
  Widget build(BuildContext context) {
    UserModel user=Provider.of<UserProvider>(context).userModel!;
    return Flexible(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.deepPurple[400],
            borderRadius: BorderRadius.circular(30)),
        padding: EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: buildUserInfo(user),
            ),
          ],
        ),
      ),
    );
  }

  Padding buildUserInfo(UserModel user) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.name,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Age: 70",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "Address : Ashwa platinum ",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "Phone : 8591870313",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "Emergency Contact: Lintomon 9324309587",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          // Additional medical information can be added here
        ],
      ),
    );
  }
}
