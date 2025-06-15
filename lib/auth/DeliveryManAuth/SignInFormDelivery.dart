import 'package:dastarkhana/services/DeliveryService/signin_service.dart';
import 'package:flutter/material.dart';
import '../../screens/OnBoarding/RoleScreen.dart';
import '../../utils/colors.dart';
import '../../widgets/AuthFormWidget/PasswordFieldWidget.dart';
import '../../widgets/AuthFormWidget/SignInButtonWidget.dart';
import '../../widgets/AuthFormWidget/phoneFieldWidget.dart';

class SignInFormDelivery extends StatefulWidget {
  const SignInFormDelivery({super.key});

  @override
  State<SignInFormDelivery> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInFormDelivery> {
  final _formKey = GlobalKey<FormState>();
  String? phone;
  String? password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: successColor),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => RoleScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(-1.0, 0.0); // Slide from left
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);
                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(height: 10,),
              Center(child: Image.asset("assets/images/3d.png")),

              SizedBox(height: 10),
              Center(child:
              //SizedBox(width: 15),
              ClipRRect(
                child: Image.asset("assets/images/Group.png"),
              ),

              ),

              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      PhoneFieldWidget(onChanged: (value) => phone = value),
                      SizedBox(height: 20),
                      PasswordFieldWidget(onChanged: (value) => password = value),
                      SizedBox(height: 40),
                      SignInButtonWidget(text: 'Кіру',
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await SignInService.login(phone!, password!, context);
                          }
                        },
                      ),
                      SizedBox(height: 30),
                      // TextDividerWidget(text: "Or continue with"),
                      // SizedBox(height: 30),
                      // SocialMediaIconsWidget(),
                      // SizedBox(height: 40),
                      // SignUpOptionWidget(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
