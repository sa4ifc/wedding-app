import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedding/main.dart';
import 'package:wedding/pages/home_section.dart';

class login_section extends StatefulWidget {
  const login_section({required this.indexSearch});
final String indexSearch;
  @override
  State<login_section> createState() => _login_sectionState();
}

class _login_sectionState extends State<login_section> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _email, _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 200,
              ),
              Row(
                children: [
                  Text(
                    "Admin Only",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Padding(padding: EdgeInsets.only(left: 10)),
                 
                ],
              ),
              Row(
                children: [
                  Text(
                    "Log In",
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى إدخال البريد الإلكتروني';
                          }
                          if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                            return 'يرجى إدخال بريد إلكتروني صالح';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _email = value!.trim();
                        },
                        decoration: InputDecoration(
                          hintText: "Enter your mail",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'please enter your password';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _password = value!.trim();
                        },
                        decoration: InputDecoration(
                          hintText: "Enter your password",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  )),
              SizedBox(
                height: 30,
              ),
              SizedBox(
                width: double.infinity,
                child: customButton(
                  text: "Log in",
                  onPressed: _submit,
                ),
              ),
              ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: _email!,
                 password: _password!
                 );
        User? user = FirebaseAuth.instance.currentUser;
        String uid = user!.uid;
        SharedPreferences prefs = await SharedPreferences.getInstance();
prefs.setBool('isUserLoggedIn', true);
prefs.setString("uid", uid);
Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => home_section(indexSearch: widget.indexSearch,)));
        
        } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('لا يوجد مستخدم بهذا البريد الإلكتروني.');
        } else if (e.code == 'wrong-password') {
          print('كلمة المرور غير صحيحة.');
        }
      }
    }
  }
}
