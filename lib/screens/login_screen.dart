import 'package:ceg_ev_driver/screens/home_screen.dart';
import 'package:ceg_ev_driver/screens/navigation_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/widgets.dart';
import 'package:ceg_ev_driver/screens/forgot_pw_page.dart';
import 'package:ceg_ev_driver/ui/splash.dart';
//import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget with NavigationStates {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isVisible = false;
  TextEditingController idController = TextEditingController();
  TextEditingController passController = TextEditingController();
  // form key
  final _formKey = GlobalKey<FormState>();
  late SharedPreferences sharedPreferences;

  // editing controller

  // firebase
  final _auth = FirebaseAuth.instance;
  
  // string for displaying the error Message
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    //phonenumber field
  final emailField = TextFormField(
        autofocus: false,
        controller: idController,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value!.isEmpty) {
            return ("Please Enter EV Number");
          }
          // reg expression for email validation
          if (!RegExp("^[A-Za-z0-9]+(?:[ _-][A-Za-z0-9]+)*")
              .hasMatch(value)) {
            return ("Please Enter a valid EV Number");
          }
          return null;
        },
        onSaved: (value) {
          idController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.mail,color: Color.fromARGB(255, 32, 32, 32)),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "EV Number",
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 32, 32, 32)),
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    //password field
    final passwordField = TextFormField(
        autofocus: false,
        controller: passController,
        obscureText: !_isVisible,
        validator: (value) {
          RegExp regex = new RegExp(r'^.{8,}$');
          if (value!.isEmpty) {
            return ("Password is required for login");
          }
          if (!regex.hasMatch(value)) {
            return ("Enter Valid Password(Min. 8 Character)");
          }
        },
        onSaved: (value) {
          passController.text = value!;
        },
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.vpn_key,color: Color.fromARGB(255, 32, 32, 32),),
          suffixIcon: IconButton(onPressed: () {
            setState(() {
              _isVisible = !_isVisible;
            });
          },
          icon: _isVisible ? Icon(Icons.visibility,color:Color.fromARGB(255, 32, 32, 32)):Icon(Icons.visibility_off,color: Color.fromARGB(255, 32, 32, 32)),
          ),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Password",
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 32, 32, 32)),
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    final loginButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Color.fromARGB(255, 32, 32, 32),
      child: MaterialButton(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            prefs.setBool('isLoggedIn',true);
            signIn(idController.text, passController.text);
          },
          child: Text(
            "Login",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white , fontWeight: FontWeight.bold),
          )),
    );

    return Stack(
      children: [
        BackgroundImage(), 
    Scaffold(
      backgroundColor: Colors.transparent,
      //backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                        height: 150,
                        child: Image.asset(
                          "assets/logo.png",
                          color: Color.fromARGB(255, 32, 32, 32),
                          fit: BoxFit.contain,
                        )),
                    SizedBox(height: 45),
                    emailField,
                    SizedBox(height: 25),
                    passwordField,
                    SizedBox(height: 8),
        /*Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap:() {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) {
                        return ForgotPasswordPage();
                      },
                    ),
                    );
                },
              child: Text(
                'Forgot Password?',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              ),
              ),
            ],
          ),
        ),*/
         SizedBox(height: 25),
                    loginButton,
                    /*SizedBox(height: 15),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Don't have an account? " ,style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold
                                  ),
                                  ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          HomeScreen()));
                            },
                            child: Text(
                              "SignUp",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          )
                        ])*/
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
      ],
    );
  }

  // login function
  void signIn(String id, String password) async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
                    String id = idController.text.trim();
                    String password = passController.text.trim();

                    if(id.isEmpty) {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("EV Number is still empty!"),
                      ));
                    } else if(password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Password is still empty!"),
                      ));
                    } else {
                      QuerySnapshot snap = await FirebaseFirestore.instance
                          .collection("EV_Number").where('id', isEqualTo: id).get();

      try {
        if(password == snap.docs[0]['password']) {
                          sharedPreferences = await SharedPreferences.getInstance();

                          sharedPreferences.setString('id', id).then((_) {
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) => Splash())
                            );
                             });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("Password is not correct!"),
                          ));
                        }
                      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "wrong-password":
            errorMessage = "Your password is wrong.";
            break;
          case "user-not-found":
            errorMessage = "User with this EV Number doesn't exist.";
            break;
          case "user-disabled":
            errorMessage = "User with this EV Number has been disabled.";
            break;
          case "too-many-requests":
            errorMessage = "Too many requests";
            break;
          case "operation-not-allowed":
            errorMessage = "Signing in with Email and Password is not enabled.";
            break;
          default:
            errorMessage = "An undefined Error happened.";
        }
        Fluttertoast.showToast(msg: errorMessage!);
        print(error.code);
        final prefs = await SharedPreferences.getInstance();
        final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      }
}
    }
  }
}