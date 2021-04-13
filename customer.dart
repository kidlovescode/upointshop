import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'EncryptQrCode.dart';
import 'register.dart';
//import 'package:encrypt/encrypt.dart';
void main() => runApp(UpointCustomer());
class UpointCustomer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'U-Point',
      home: Customer(),


    );
  }
}
class Customer extends StatefulWidget {

  @override
  CusSignInPage createState() =>  CusSignInPage();

}

class CusSignInPage extends State<Customer> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool FoundCus = false;
  String userkey="";
  String customer="";
  int totalEquals = 99;//search customer
  String customername="";
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> readUserKey() async {
    //check case just register
    final SharedPreferences prefs = await _prefs;
    setState(() {
      userkey = prefs.getString("userkey").toString();
      customer = prefs.getString("customer").toString();
      var register = prefs.getString("register").toString();
      if (register=="waitconfirm" && userkey!=""&&customer!=""){
          prefs.setString("register", "confirm");
      }
      if (register=="confirm" && userkey!=""&&customer!=""){
        phoneController.text = customer;
      }
    });
    print("userkey "+userkey+" "+customer);

  }

  @override
  void initState(){
  //  writeUserKey();
    readUserKey();

  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(

          preferredSize: Size.fromHeight(170.0), // here the desired height
          child: Column( children:[
            //  Container(height:800,child:Text("U-Point",style: TextStyle(fontSize: 40),)),
            AppBar(
                elevation: 10,
                flexibleSpace:
                Column(children: [
                  Padding(padding: EdgeInsets.all(8), child:Text("Shop Member - Point for you", style: TextStyle(fontSize: 16, color:Colors.white),)),
                  Container(color:Colors.white,height:130, child: Image.asset("images/upoint.png",width:MediaQuery.of(context).size.width))
                ],) ,


            ),]
          )),
      body:
      SingleChildScrollView(
          child: Column(

            children: <Widget>[


              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(

                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color:Colors.blue)
                ),
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(
                    //  border: OutlineInputBorder(),
                    labelText: 'หมายเลขโทรศัพท์',
                  ),
                ),
              ),

              Padding(padding: EdgeInsets.only(bottom:20),),
              Container(

                  height: 85, width: 260,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child:  Container(
                      height:85,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: Colors.blue,

                      ),
                      child:FlatButton(
                          textColor: Colors.black,
                          child: Text('สมาชิกเข้าสู่ระบบ',style: TextStyle(fontSize: 20, color:Colors.white)),
                          onPressed: (){
                            if (phoneController.value.text.toString()=="" )
                            {

                              checkEmpty( context,"");

                            }
                            else

                            {   //check mach user or not
                              //  searchCustomer(phoneController.value.text.toString());
                              searchCustomer(phoneController.value.text.toString());
                              if (totalEquals ==10) //found
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => CustomerManagePage(customer: customer,customername:customername,
                                        userkey: userkey))) ;
                              else if (totalEquals ==0)
                                cannotLogin(context);



                            }
                          }

                      )
                  )),
              Padding(padding:EdgeInsets.only(bottom:25)),
              Text('ลงทะเบียนสมาชิก'),
              IconButton(icon:Icon(Icons.app_registration),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => SignInPage()
                  )) ;


                },)

            ],
          )),

    )

    ;
  }
  _showManageUserkey(context) {
    TextEditingController keyController= TextEditingController();

        return showDialog(
            context: context,
            builder: (BuildContext context) {
              return SimpleDialog(
                  children: [
              Container(padding: EdgeInsets.all(10),
              child: Text("บันทึกกุญแจ",
              style: TextStyle(fontSize: 20, color: Colors.red),)),
                 TextField(controller:keyController),
                    Container(
                        width:MediaQuery.of(context).size.width/2,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child:

                        FlatButton(onPressed: (){
                        },
                            child: Column(children:[
                              Text('บันทึก', style:TextStyle(color:Colors.white, fontWeight:FontWeight.bold ))
                              ,
                              IconButton(icon: Icon(Icons.lock,color: Colors.white,),
                                  onPressed: (){
                                    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
                                    final SharedPreferences prefs =  _prefs as SharedPreferences;
                                    prefs.setString("userkey",
                                        keyController.value.text.toString());

                                  }

                              )
                            ])
                        )),


              ]);});
  }
  Future<void> searchCustomer(String phone) async {
    Firestore.instance.collection(phone+"_memberof")
        .where('userkey',isEqualTo: userkey)
        .getDocuments().then(
            (snapshot) {
          for (DocumentSnapshot ds in snapshot.documents){
            Firestore.instance.collection("customer")
                .where('userkey',isEqualTo: userkey).getDocuments()
                .then((value) {
              for (DocumentSnapshot dn in value.documents){
                   setState(() {
                     if (dn.data['name']!=null && dn.data['name']!="")
                     customername = dn.data['name'];
                     else
                       customername = "ไม่ทราบชื่อ";

                   });
              }

            }
            ).catchError((error) =>
                setState(() {
                  customername = "ไม่ทราบชื่อ";
                })

            );

            setState(() {

              totalEquals = 10;  //found info
            });

          };
        })

        .catchError((error) => print("Failed to add info: $error"));


  }


  checkEmpty(BuildContext context, String input){
    if (input == ""){
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
                children: [
                  Container(padding: EdgeInsets.all(10),
                      child: Text("มีข้อผิดพลาด",
                        style: TextStyle(fontSize: 20, color: Colors.red),)),
                  Container(padding: EdgeInsets.all(10),
                      child: Text(
                          "โปรดกรอกข้อมูลให้ครบถ้วน ไม่สามารถเว้นว่างได้ ")),
                  Container(padding: EdgeInsets.all(10),
                      child: FlatButton(color: Colors.blueAccent,
                          padding: EdgeInsets.all(25),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(" ปิด ")))

                ]
            );
          }); }
  }

  Widget cannotLogin(BuildContext context){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              children: [
                Container(padding: EdgeInsets.all(10),
                    child: Text("มีข้อผิดพลาด",
                      style: TextStyle(fontSize: 20, color: Colors.red,fontWeight: FontWeight.bold),)),
                Container(padding: EdgeInsets.all(10),
                    child: Text(
                        "ชื่อหรือรหัสผ่านไม่ถูกต้อง โปรดติดต่อ admin@upoint.app")),
                Container(padding: EdgeInsets.all(10),
                    child: FlatButton(color: Colors.blueAccent,
                        padding: EdgeInsets.all(25),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(" ปิด ")))

              ]
          );
        });
  }


}
class CustomerManagePage extends StatefulWidget {
  final  String customer ;
  final String userkey;
  final String customername;
  const CustomerManagePage({ Key key, this.customer,this.customername,this.userkey }) : super(key: key);
  @override
  _CustomerManagePageState createState() {
    return _CustomerManagePageState();
  }
}

class _CustomerManagePageState extends State<CustomerManagePage> {
  int point=0;
  int _selectedItem = 0,customerscore=0;
  String customer,search="";
  PageController _pageview = new PageController();
  Record recordSave;
  RecordShop recordShop ;
  String shop = "";
  String shopname ="";
  String coupon="";
  String picrule="",scoretype="";
  String userkey="";
  int savescore=0,usescore=0;

  @override
  void initState() {
    customer = widget.customer;
    super.initState();
    _pageview = PageController();
    userkey = widget.userkey;
  }

  @override
  void dispose() {
    _pageview.dispose();
    super.dispose();
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedItem = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(200.0), // here the desired height
          child: Column( children:[
            //  Container(height:800,child:Text("U-Point",style: TextStyle(fontSize: 40),)),
            AppBar(
              // bottom: Icon(Icons.local_drink),
          actions: [
        ClipOval(
            child: Container(width:50,color:Colors.amberAccent,
                child: IconButton(icon: Icon(Icons.logout, color:Colors.blue),
                    onPressed: (){
                   SystemNavigator.pop();
        // _showManageUserkey(context);

      })))
        ],
                title: Center(
                    child: Text('', style: TextStyle(fontSize:25,color: Colors.blue),)),backgroundColor: Colors.white,
                flexibleSpace:
                Column(children: [Padding(padding: EdgeInsets.all(25)),Container(height:150, child: Image.asset("images/upoint.png",width:MediaQuery.of(context).size.width-100,height:50))
                ],) ),]
          )),
      body: // _buildBody(context),
      PageView(  scrollDirection: Axis.horizontal,
          controller: _pageview,
          children:[
            _homepage(context),  //list shop of member
            _usePoint(context),
            _genQr(context,"savepoint"),
            _genQrShop(context,'addshop')

          ]),


      bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.blue,
            primaryColor: Colors.white,
            textTheme: Theme.of(context)
                .textTheme
                .copyWith(caption: TextStyle(color: Colors.white)),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.lightBlue,

            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home, color: Colors.white,),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.star, color: Colors.white),
                label: 'Your point',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.qr_code,color: Colors.white),
                label: 'QR Point',

              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.store, color: Colors.white),
                label: 'Add shop',
              ),
            ],
            currentIndex: _selectedItem,
            selectedItemColor: Colors.white,
            selectedLabelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),

            onTap:(_selectedItem){
              _onItemTapped(_selectedItem);
              if (_selectedItem==0){
                _pageview.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              }else  if (_selectedItem==1){
                _pageview.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              }else  if (_selectedItem==2){
                _pageview.animateToPage(
                  2,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                ); }else  if (_selectedItem==3){
                _pageview.animateToPage(
                  3,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                ); }
            },
          )),
    );
  }



  _usePoint(BuildContext context){
    if (customer!="" && shop!="") {
      print(customer + "_" + shop);
      return _buildBookScore(customer + "_" + shop);
    }else
      return Container (height: 100, child:Card (child:Text("ต้องเลือกร้านค้าที่ท่านเป็นสมาชิกก่อน ")));
  }
  _homepage(BuildContext context){
    return  _buildMember(context);
  }

  _genQr(BuildContext context,what){
    EncryptQrCode eq = new EncryptQrCode(customer:
    customer,userkey:userkey,shop:shop,what:what);
    final encryptcode =  eq.showData();
    return Container (child:Column(
        children:[
          // Text(encryptcode, style: TextStyle(fontSize: 18),),
          QrImage(
            //data: customer+":"+shop,
            data:encryptcode,
            version: QrVersions.auto,
            size: 300,
            padding:EdgeInsets.all(50),
          ),
          Text("สแกนสะสมแต้มกับ "+shopname, style: TextStyle(fontSize: 20),),

        ]));
  }
  _genQrShop(BuildContext context,what){
    EncryptQrCode eq = new EncryptQrCode(customer:
    customer,userkey:userkey,shop:'N/A',what:what);
    final encryptcode =  eq.showData();
    return Container (child:Column(
        children:[
          // Text(encryptcode, style: TextStyle(fontSize: 18),),
          QrImage(
            //data: customer+":"+shop,
            data:encryptcode,
            version: QrVersions.auto,
            size: 300,
            padding:EdgeInsets.all(50),
          ),
          Text("สแกนเพิ่มร้านค้าสะสมแต้ม ", style: TextStyle(fontSize: 20),),
          IconButton(icon: Icon(Icons.store,color:Colors.blue), onPressed: null),

        ]));
  }

  Widget _buildBookScore(String search) {

    return SingleChildScrollView(child:Center(child: Column(children: [
      Text(shopname, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
      Padding(padding:EdgeInsets.only(bottom:10)),
      Text("แต้มสะสม", style: TextStyle(fontSize: 20),),
      FutureBuilder(
          future: totalPoint(customer,userkey,shop,false),
          builder: (context, countsave) {

            return (countsave.hasData)? Text(countsave.data.toString(),style: TextStyle(fontSize: 85,color:Colors.blueAccent),):Text("");
          }),
      Text("แต้มใช้แล้ว", style: TextStyle(fontSize: 20)),
      FutureBuilder(
          future: totalPoint(customer,userkey,shop,true),
          builder: (context, countuse) {
            return (countuse.hasData)?Text(countuse.data.toString(),style: TextStyle(fontSize: 85,color:Colors.redAccent),):Text("");
          }),
      Padding(padding: EdgeInsets.only(bottom:30),),
     Container(
         width:MediaQuery.of(context).size.width,
         child:Column(children:[
         Column(children: [
           Text("ดูเงื่อนไข", style: TextStyle(fontSize: 20, color:Colors.blue,
               fontWeight: FontWeight.bold)),

           Container(
               decoration: BoxDecoration(
                 borderRadius: BorderRadius.circular(20),

               ),
               child:IconButton(
                   icon: Icon(Icons.receipt),
                   onPressed:(){
                     showPointRule(context);
                   })),
         ],) ,
       Padding(padding:EdgeInsets.only(right:30)),
      Column(children: [
         Text("แลกแต้ม", style: TextStyle(fontSize: 20, color:Colors.blue,
             fontWeight: FontWeight.bold)),
         savescore>0?
         Container(
             decoration: BoxDecoration(
               borderRadius: BorderRadius.circular(20),

             ),
             child:IconButton(
               icon: Icon(Icons.local_drink),
               onPressed:(){
                 Navigator.push(context, MaterialPageRoute(
                     builder: (context) => UseScore(customer:customer,
                         userkey:userkey,shop:shop,what:"usepoint"))) ;

                 //UsePoint(context);
               },

             )):Text('คะแนนของคุณยังไม่สามารถแลกแต้มได้')
       ],)
      ])),



    ],),));
  }

  Widget showPointRule(BuildContext context){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              children: [
                Container(padding: EdgeInsets.all(10),
                    child: Text("เงื่อนไขการใช้แต้มสะสม",
                      style: TextStyle(fontSize: 20, color: Colors.red,fontWeight: FontWeight.bold),)),
                FutureBuilder(
                    future: readPointRule("pointrule",shop),
                    builder: (context, rule) {
                      return Image.network(picrule);
                    }),
                Container(padding: EdgeInsets.all(10),
                    child: IconButton(
                      icon:Icon(Icons.close),
                      color: Colors.blueAccent,
                      padding: EdgeInsets.all(25),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ))

              ]
          );
        });



  }




  Future readPointRule(collectionname,docname) async {
    //  print(collectionname+" "+docname);

    final firestoreInstance = Firestore.instance;
    firestoreInstance.collection(collectionname)
        .document(docname)
        .get()
        .
    then((querySnapshot) {
      if (querySnapshot.exists)
        querySnapshot.data.forEach((key, value) {
          print(key+" "+value.toString());
          if (key=="adrule"){
            setState(() {
              picrule = value;
            });
          }
          if (key=="scoretype"){
            setState(() {
              scoretype = value;
            });
            //return querySnapshot;
          }

        });
      else
        print("No info");

    });

  }

  Future totalPoint(customer,userkey,shop, flag) async {
     print ("shop point"+shop);
    var respectsQuery = Firestore.instance
        .collection(customer+"_point")
        .where('phone', isEqualTo: customer)
        .where('userkey', isEqualTo: userkey)
        .where('shopid', isEqualTo: shop);

    var querySnapshot = await respectsQuery.getDocuments();

    for (DocumentSnapshot ds in querySnapshot.documents){
        setState(() {
          savescore = ds.data['point'];
          usescore = ds.data['exchange'];
        });
    }

    if (flag==false)
      return savescore;
    else
      return usescore;

  }


  Widget  _buildMember(BuildContext  context) {

    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection(customer+'_memberof').snapshots(),
      builder: (context, snapshot) {
        //  print(snapshot.data);
        if (!snapshot.hasData) return LinearProgressIndicator();

        return   Column(children:[
                Text(' สวัสดี '+widget.customername),
         Expanded(child: Container(width:MediaQuery.of(context).size.width,
                child:Scrollbar(child:
          _buildListMemberInfo(context, snapshot.data.documents))))])
            ;
      },
    );
  }
//Must chnage listview to card

  Widget _buildListMemberInfo(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListMemberItemInfo(context, data)).toList(),
    );
  }

  Widget _buildListMemberItemInfo(BuildContext context, DocumentSnapshot data) {
    final record = RecordShopOfCustomer.fromSnapshot(data);

    return Padding(

        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Container(
              child:FlatButton(

                  onPressed: (){
                    setState(() {
                      shop = record.shopid;
                      savescore=0;
                      usescore=0;
                      shopname = record.shopname;
                    });
                    _pageview.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  },
                  child:Row(children:[

                    Padding(padding: EdgeInsets.only(left:5,top:5,bottom:5),
                        child:
                    Image.network(record.businesspic,width:100,height:100),),
                    Column(children: [
                      Padding(padding: EdgeInsets.only(left:10),child:  Text("ชื่อธุรกิจ:"+record.shopname),),
                      Padding(padding: EdgeInsets.only(left:10),child:  Text("สาขา:"+record.location),),


                    ]),


                  ]))

              ,)
        ));
  }


  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);
    recordSave = record;
    customerscore++;
    return  Container(child:ClipOval(
      child: Material(
        color: Colors.redAccent, // button color
        child: InkWell(
          splashColor: Colors.red, // inkwell color
          child: SizedBox(width: 45, height: 45, child: Icon(Icons.star_border,color: Colors.white, )),
          onTap: () {},
        ),
      ),
    ),
      padding: EdgeInsets.all(5),
    );

  }
  Widget _buildListItemMember(BuildContext context, DocumentSnapshot data) {
    final rShop = RecordShop.fromSnapshot(data);
    recordShop = rShop;
    customerscore++;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
          decoration: BoxDecoration(
            // color: Colors.amberAccent,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: FlatButton(
              padding: EdgeInsets.all(15),
              onPressed: (){
                setState(() {
                  shop = recordShop.shopid;

                });
                _pageview.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
              child:Row(children: [

                Image.network("http://www.kidlovescode.com/upoint/shop/"+recordShop.shopid+".png", width:100),
                Padding(padding: EdgeInsets.only(right:10)),
                Column(children: [
                  Text(recordShop.shopid+":"+recordShop.shopname),
                  Container(child:  Text("สมัครกับสาขา:"+recordShop.location, textAlign: TextAlign.left)),
                ],

                )
              ],)
          )
      ),
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> documents) {

    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection(customer+'_memberof').snapshots(),
      builder: (context, snapshot) {
        print(snapshot.data);
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildListInfo(context, snapshot.data.documents);
      },
    );

  }
  Widget _buildListInfo(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItemInfo(context, data)).toList(),
    );
  }
  Widget _buildListItemInfo(BuildContext context, DocumentSnapshot data) {
    final rShop = RecordShop.fromSnapshot(data);
    recordShop = rShop;
    customerscore++;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
          decoration: BoxDecoration(
            // color: Colors.amberAccent,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: FlatButton(

              padding: EdgeInsets.all(15),
              onPressed: (){
                setState(() {
                  shop = recordShop.shopid;
                  print("state "+shop);

                });
                _pageview.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
              child:Row(children: [

                Image.network("http://www.kidlovescode.com/upoint/shop/"+recordShop.shopid+".png", width:100),
                Padding(padding: EdgeInsets.only(right:10)),
                Column(children: [
                  Text(recordShop.shopid+":"+recordShop.shopname),
                  Container(child:  Text("สมัครกับสาขา:"+recordShop.location, textAlign: TextAlign.left)),
                ],

                )
              ],)
          )
      ),
    );
  }

}

class Record {
  final String buydate,location,umobile,shopid;
  final bool usepoint,delete;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['buydate'] != null),
        assert(map['location'] != null),
        assert(map['umobile'] != null),
        assert(map['usepoint'] != true),
        assert(map['shopid'] != null),
        assert(map['delete'] != true),

        buydate = map['buydate'],
        location = map['location'],
        umobile = map['umobile'],
        usepoint = map['usepoint'],
        shopid = map['shopid'],
        delete = map['delete']



  ;

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$buydate:$location:$umobile:$usepoint>";
}
//Record Shop That the customer is member

class RecordShop {
  final String shopid, shopname,location;
  final DocumentReference reference;

  RecordShop.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['location'] != null),
        assert(map['shopid'] != null),
        assert(map['shopname'] != null),

        location = map['location'],
        shopid = map['shopid'],
        shopname = map['shopname']

  ;

  RecordShop.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$location:$shopid:$shopname>";
}

class RecordShopOfCustomer {
  final String shopid, shopname,location,businesspic;
  final DocumentReference reference;

  RecordShopOfCustomer.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['location'] != null),
        assert(map['shopid'] != null),
        assert(map['shopname'] != null),
        assert(map['businesspic'] != null),
        location = map['location'],
        shopid = map['shopid'],
        shopname = map['shopname'],
        businesspic = map['businesspic']

  ;

  RecordShopOfCustomer.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$location:$shopid:$shopname>";
}

class UseScore extends StatefulWidget {
  final  String customer ;
  final String userkey;
  final String shop;
  final String what;
  const UseScore({ Key key, this.customer,this.userkey,this.shop, this.what }) : super(key: key);
  @override
  _UseScoreState createState() {
    return _UseScoreState();
  }
}

class _UseScoreState extends State<UseScore> {
  @override
  Widget build(BuildContext context) {

    EncryptQrCode eq = new EncryptQrCode(customer:
    widget.customer,userkey:widget.userkey,shop:widget.shop,what:widget.what);
    final encryptcode =  eq.showData();
    return  MaterialApp(

        home:Scaffold(
            appBar:AppBar(
                title: Text("สแกน QR แลกรับสินค้า")
            ),
            body:
            Container (
                width:MediaQuery.of(context).size.width,
                child:Column(
                    children:[
                      // Text(encryptcode, style: TextStyle(fontSize: 18),),
                      QrImage(
                        //data: customer+":"+shop,
                        data:encryptcode,
                        version: QrVersions.auto,
                        size: 300,
                        padding:EdgeInsets.all(50),
                      ),
                      Text("โปรดส่ง QrCode ให้พนักงานสแกนใช้แต้ม ", style: TextStyle(fontSize: 20),),
                      IconButton(
                        icon:Icon(Icons.home),
                        onPressed: (){
                          Navigator.pop(context);

                        },
                      )
                    ]))));
  }

}
