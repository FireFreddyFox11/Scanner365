//ignore: file_names
import 'package:flutter/material.dart';
import 'package:touch365_scanner/pages/commonServices/LoginPage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<StatefulWidget> createState() => _SignUpPage();
}

class _SignUpPage extends State<SignUpPage> {
  final TextEditingController _name = TextEditingController(),
      _surname = TextEditingController(),
      _email = TextEditingController(),
      _job = TextEditingController(),
      _company = TextEditingController(),
      _password = TextEditingController(),
      _cPassword = TextEditingController();

  bool _isVisible = true;
  bool _cIsVisible = true;

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _surnameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _jobFocus = FocusNode();
  final FocusNode _companyFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _cPasswordFocus = FocusNode();

  final _formKey = GlobalKey<FormState>();

  bool validateInformation() {
    String name = _name.text,
        surname = _surname.text,
        email = _email.text,
        job = _job.text,
        company = _company.text,
        password = _password.text,
        cPassword = _cPassword.text;

    if (name.isEmpty ||
        surname.isEmpty ||
        email.isEmpty ||
        job.isEmpty ||
        company.isEmpty ||
        password.isEmpty ||
        cPassword.isEmpty) {
      return false;
    }
    if (!email.contains('@')) {
      return false;
    }
    if (password.compareTo(cPassword) != 0) {
      return false;
    }
    if (!password.contains(RegExp(r'!@#$%^&*()')) ||
        !password.contains(RegExp(r'(\d)')) ||
        !password.contains(RegExp(r'([A-Z])'))) {
      return false;
    }
    return true;
  }

  Widget createSet(
    String data,
    TextEditingController controller,
    FocusNode focusNode, {
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(blurRadius: 5)],
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _fieldFocusChange(focusNode),
            decoration: InputDecoration(
              hintText: 'Enter your $data',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }

  void _fieldFocusChange(FocusNode currentFocus) {
    if (currentFocus == _nameFocus) {
      FocusScope.of(context).requestFocus(_surnameFocus);
    } else if (currentFocus == _surnameFocus) {
      FocusScope.of(context).requestFocus(_emailFocus);
    } else if (currentFocus == _emailFocus) {
      FocusScope.of(context).requestFocus(_jobFocus);
    } else if (currentFocus == _jobFocus) {
      FocusScope.of(context).requestFocus(_companyFocus);
    } else if (currentFocus == _companyFocus) {
      FocusScope.of(context).requestFocus(_passwordFocus);
    } else if (currentFocus == _passwordFocus) {
      FocusScope.of(context).requestFocus(_cPasswordFocus);
    } else {
      currentFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              margin: const EdgeInsets.all(20),
              child: Card(
                elevation: 20,
                shadowColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                color: Colors.green.shade600,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              SizedBox(height: 12),
                              Text(
                                "Create Account",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Sign up to get started",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: createSet("Name", _name, _nameFocus),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: createSet(
                                "Surname",
                                _surname,
                                _surnameFocus,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        createSet(
                          "Email",
                          _email,
                          _emailFocus,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 16),

                        createSet("Job Title", _job, _jobFocus),
                        SizedBox(height: 16),

                        createSet("Company", _company, _companyFocus),
                        SizedBox(height: 16),
                        Text(
                          "Password",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(blurRadius: 5)],
                          ),
                          child: TextFormField(
                            obscureText: _isVisible,
                            controller: _password,
                            focusNode: _passwordFocus,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) =>
                                _fieldFocusChange(_passwordFocus),
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isVisible = !_isVisible;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Confirm Password",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(blurRadius: 5)],
                          ),
                          child: TextFormField(
                            obscureText: _cIsVisible,
                            controller: _cPassword,
                            focusNode: _cPasswordFocus,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _cPasswordFocus.unfocus(),
                            decoration: InputDecoration(
                              hintText: 'Confirm your password',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _cIsVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _cIsVisible = !_cIsVisible;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            style: TextStyle(fontSize: 15),
                          ),
                        ),

                        SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () async {
                              print("BUTTON CLICKED");
                              if (_formKey.currentState!.validate()) {                              
                                print("COMPLETE");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.green.shade700,
                              elevation: 10,
                              shadowColor: Colors.green.shade800,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'SIGN UP',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 16),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginPage(),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _surname.dispose();
    _email.dispose();
    _job.dispose();
    _company.dispose();
    _password.dispose();
    _cPassword.dispose();

    _nameFocus.dispose();
    _surnameFocus.dispose();
    _emailFocus.dispose();
    _jobFocus.dispose();
    _companyFocus.dispose();
    _passwordFocus.dispose();
    _cPasswordFocus.dispose();
    super.dispose();
  }
}