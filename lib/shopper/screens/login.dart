import 'package:flutter/material.dart';

class ShopLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Login', style: Theme.of(context).textTheme.headline3),
              TextFormField(decoration: InputDecoration(hintText: 'Username')),
              TextFormField(
                decoration: InputDecoration(hintText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/catalog');
                },
                child: Text('Login'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
