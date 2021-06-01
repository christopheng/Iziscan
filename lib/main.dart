  import 'dart:convert';
  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:fluttertoast/fluttertoast.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:http/http.dart' as http;
  import 'package:flutter/cupertino.dart';
  import 'package:barcode_widget/barcode_widget.dart';
  void main(){
    runApp(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: Text('Iziscan'),),
            body: SafeArea(
              child: MyApp(),
            ),
          ),
        )
    );
  }

  class MyApp extends StatefulWidget {
    @override
    _MyAppState createState() => _MyAppState();
  }

  class _MyAppState extends State<MyApp> {

    bool signin = true;

    late TextEditingController prenomctrl,nomctrl,emailctrl,passctrl;

    bool processing = false;

    @override
    void initState() {
      // TODO: implement initState
      super.initState();
      prenomctrl=new TextEditingController();
      nomctrl = new TextEditingController();
      emailctrl = new TextEditingController();
      passctrl = new TextEditingController();
    }
    @override
    Widget build(BuildContext context) {
      return Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Icon(Icons.account_circle,size: 200,color: Colors.blue),

              boxUi(),
            ],
          )
      );
    }

    void changeState(){
      if(signin){
        setState(() {
          signin = false;
        });
      }else
        setState(() {
          signin = true;
        });
    }

    void userSignIn() async{
      setState(() {
        processing = true;
      });
      var url = "http://localhost/Iziscan/signIn.php";
      var data = {
        "login":emailctrl.text,
        "pass":passctrl.text,
      };
      var res = await http.post(Uri.parse(url),body:data);
      var test=res.body.trim().substring(1,res.body.length-2).split(',');
      var valeurs=[];
      for (var i=0;i<test.length;i++){
        var temp=test[i].split(":");
        var pros=temp[1].trim().substring(1,temp[1].length-2);
        valeurs.add(pros);
      }

      if(res.body.isNotEmpty) {
        if (jsonDecode(res.body) == "dont have an account") {
          Fluttertoast.showToast(msg: "dont have an account,Create an account",
              toastLength: Toast.LENGTH_SHORT);
        }
        else {
          if (jsonDecode(res.body) == "false") {
            Fluttertoast.showToast(
                msg: "incorrect password", toastLength: Toast.LENGTH_SHORT);
          }
          else {
            //print(jsonDecode(res.body));

            Fluttertoast.showToast(
                msg: "Successfully logged in", toastLength: Toast.LENGTH_SHORT);
            //Navigator.push(context,MaterialPageRoute(builder: (context)=> SecondRoute(valeurs[0])));
            //Navigator.push(context,MaterialPageRoute(builder: (context)=>MyStatefulWidget(valeurs[0])));
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyStatefulWidget(id: valeurs[0],)));
          }
        }
      }else{
        Fluttertoast.showToast(
            msg: "Marche pas", toastLength: Toast.LENGTH_SHORT);
      }

      setState(() {
        processing = false;
      });
    }
    void registerUser() async{

      setState(() {
        processing = true;
      });
      var url="http://localhost/Iziscan/signUp.php";
      var data={
        "prenom":prenomctrl.text,
        "nom":nomctrl.text,
        "login":emailctrl.text,
        "pass":passctrl.text,
      };

      var res = await http.post(Uri.parse(url),body:data);
      if(res.body.isNotEmpty) {
        Fluttertoast.showToast(msg: jsonDecode(res.body));
        if (jsonDecode(res.body) == "account already exists") {
          Fluttertoast.showToast(msg: "account exists, Please login",
              toastLength: Toast.LENGTH_SHORT);
        } else {
          if (jsonDecode(res.body) == "true") {
            Fluttertoast.showToast(
                msg: "account created", toastLength: Toast.LENGTH_SHORT);
          } else {
            Fluttertoast.showToast(msg: "error", toastLength: Toast.LENGTH_SHORT);
          }
        }
      }else Fluttertoast.showToast(msg: "blanc");
      setState(() {
        processing = false;
      });
    }

    Widget boxUi(){
      return Card(
        elevation: 10.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[

                  MaterialButton(
                    onPressed:() => changeState(),
                    child: Text('SIGN IN',
                      style: GoogleFonts.varelaRound(
                        color: signin == true ? Colors.blue : Colors.grey,
                        fontSize: 25.0,fontWeight: FontWeight.bold,
                      ),),
                  ),

                  MaterialButton(
                    onPressed:() => changeState(),
                    child: Text('SIGN UP',
                      style: GoogleFonts.varelaRound(
                        color: signin != true ? Colors.blue : Colors.grey,
                        fontSize: 25.0,fontWeight: FontWeight.bold,
                      ),),
                  ),
                ],
              ),
              signin == true ? signInUi() : signUpUi(),


            ],
          ),
        ),
      );
    }

    Widget signInUi(){
      return Column(
        children: <Widget>[

          TextField(
            controller: emailctrl,
            decoration: InputDecoration(prefixIcon: Icon(Icons.account_box,),
                hintText: 'email'),
          ),


          TextField(
            controller: passctrl,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(prefixIcon: Icon(Icons.lock,),
                hintText: 'password'),
          ),

          SizedBox(height: 10.0,),

          MaterialButton(
              onPressed:()=>userSignIn(),
              child: processing == false ? Text('Sign In',
                style: GoogleFonts.varelaRound(fontSize: 18.0,
                    color: Colors.blue),) : CircularProgressIndicator(backgroundColor: Colors.red,)
          ),

        ],
      );
    }

    Widget signUpUi(){
      return Column(
        children: <Widget>[
          TextField(
            controller: prenomctrl,
            decoration: InputDecoration(prefixIcon: Icon(Icons.account_box,),
                hintText: 'Prénom'),
          ),

          TextField(
            controller: nomctrl,
            decoration: InputDecoration(prefixIcon: Icon(Icons.account_box,),
                hintText: 'Nom'),
          ),

          TextField(
            controller: emailctrl,
            decoration: InputDecoration(prefixIcon: Icon(Icons.account_box,),
                hintText: 'email'),
          ),

          TextField(
            controller: passctrl,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(prefixIcon: Icon(Icons.lock,),
                hintText: 'password'),
          ),

          SizedBox(height: 10.0,),

          MaterialButton(
              onPressed:() => registerUser(),
              child: processing == false ? Text('Sign Up',
                style: GoogleFonts.varelaRound(fontSize: 18.0,
                    color: Colors.blue),) : CircularProgressIndicator(backgroundColor: Colors.red)
          ),

        ],
      );
    }

  }



  class MyStatefulWidget extends StatefulWidget {
    final String id;
    MyStatefulWidget({Key? key, required this.id}) : super(key: key);
    @override
    _MyStatefulWidgetState createState() => _MyStatefulWidgetState(id);

  }

  class _MyStatefulWidgetState extends State<MyStatefulWidget> {
      int _selectedIndex = 0;
      String id="";
      var valeurs=[];
      List<Widget> _widgetOptions=<Widget>[SizedBox(height: 10.0,)];

      _MyStatefulWidgetState(this.id){
        id=this.id;
      }


      Future<void> getTicket() async{
        var url = "http://localhost/Iziscan/getTicket.php";
        var data = {
          "id":this.id,
        };
        var res = await http.post(Uri.parse(url),body:data);
        var test=res.body.trim().substring(1,res.body.length-2).split(',');
        var j=1;
        var tempa='';
        for (var i=0;i<test.length;i++){
          var temp=test[i].split(":");
          var pros=temp[1].trim().substring(1,temp[1].length-2);
          tempa+=" | "+pros;
          if(j==3){
            valeurs.add(tempa);
            j=1;
            tempa="";
          }
          j++;
        }
        print(valeurs);
      }

      @override
      void initState(){
        super.initState();
        getTicket().whenComplete(() {
          // ignore: unnecessary_statements
          _widgetOptions.clear;
          _widgetOptions = <Widget>[
            BarcodeWidget(
              barcode: Barcode.code128(), // Barcode type and settings
              data:id, // Content
              width: 200,
              height: 200,
            ),
            ListView.builder(
                itemCount:valeurs.length,
                itemBuilder: (BuildContext context,int index){
                  return Container(
                    height:50,
                    color:Colors.amber,
                    child:Center(child:Text(valeurs[index])),

                  );
                }
            ),
          ];
        });
      }

      static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

      void _onItemTapped(int index) {
        setState(() {
          _selectedIndex = index;
        });
      }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Iziscan'),
        ),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code),
              label: 'Code barre',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt),
              label: 'Tickets',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
      );
    }
  }