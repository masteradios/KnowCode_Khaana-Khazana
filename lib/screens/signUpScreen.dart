import 'package:alz/helper/services/auth.dart';
import 'package:alz/providers/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading=false;
  void signin() async {
    if(_nameController.text.isNotEmpty&&_emailController.text.isNotEmpty&&_passwordController.text.isNotEmpty){

      setState(() {
        _isLoading=true;
      });
     await FirebaseServices().signUpUser(name: _nameController.text.trim(),email: _emailController.text.trim(), password: _passwordController.text.trim(),context: context);
      setState(() {
        _isLoading=false;
      });
  }
  else{

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('YaadonKiBaarat',textAlign:TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 38),),
        Padding(
          padding: const EdgeInsets.fromLTRB(12,8,12,8),
          child: TextField(
            keyboardType: TextInputType.name,
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Name',
            ),

          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12,8,12,8),
          child: TextField(
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'Email',
            ),

          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12,8,12,8),
          child: TextField(
            keyboardType: TextInputType.visiblePassword,
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: 'Password',
              ),

              ),
        ),

        (_isLoading)?Container(
          padding: const EdgeInsets.fromLTRB(12,8,12,8),
          color: Colors.deepPurpleAccent,
          child: Center(child : CircularProgressIndicator(color: Colors.white,))
        ):
        Padding(
          padding: const EdgeInsets.fromLTRB(12,8,12,8),

          child: ElevatedButton(
            child: Text('Sign In'),
            onPressed: () {
              signin();
            },
          ),
        )

      ],
    ));
  }
}
