
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'EncryptQrCode.dart';
import 'shop.dart';
void main() => runApp(MaterialApp(home: QRViewLess(shop:'1111111')));

const flashOn = 'เปิดแฟรช';
const flashOff = 'ปิดแฟรช';
const frontCamera = 'กล้องหน้า';
const backCamera = 'กล้องหลัง';
class QRViewLess extends StatelessWidget {
  final String shop;
  const QRViewLess({ key,this.shop
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home:QRViewExample(store:this.shop)
    );
  }

}

class QRViewExample extends StatefulWidget {
  final String store;
  final String location;
  final String shopname;
  final String businesspic;
  const QRViewExample({ key,this.store,this.location, this.shopname,this.businesspic
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  var qrText = '';
  var flashState = flashOn;
  var cameraState = frontCamera;
  QRViewController controller ;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
   String plaintext="";
   int _selectedItem= 0;
   String rcustomerid="",ruserkey="",rshopid="",rwhat="";
   bool successadd =false, successaddcount=false,successusecount=false,
       successuse = false,successregister=false;
   bool pushornot=false;
  _onItemTapped(_selectedItem){

  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

        home:Scaffold(


          bottomNavigationBar: Theme(
              data: Theme.of(context).copyWith(
                canvasColor: Colors.amber,
                primaryColor: Colors.white,
                textTheme: Theme.of(context)
                    .textTheme
                    .copyWith(caption: TextStyle(color: Colors.white)),
              ),
              child: BottomNavigationBar(
                backgroundColor: Colors.amber[700],

                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home, color: Colors.white,),
                    label: 'Home',
                  ),

                  BottomNavigationBarItem(
                    icon: Icon(Icons.flash_on,color: Colors.white),
                    label: 'Flash on/off',

                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.camera_front,color: Colors.white),
                    label: 'Front/back ',

                  ),

                ],
                currentIndex: _selectedItem,
                selectedItemColor: Colors.white,
                selectedLabelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),

                onTap:(_selectedItem){
                //  _onItemTapped(_selectedItem);
                  if (_selectedItem==0){
                     Navigator.pop(context);
                  }else  if (_selectedItem==1){
                      if (controller != null) {
                        controller.toggleFlash();
                        if (_isFlashOn(flashState)) {
                          setState(() {
                            flashState = flashOff;
                          });
                        } else {
                          setState(() {
                            flashState = flashOn;
                          });
                        }
                      }

                  }else  if (_selectedItem==2){
                    if (controller != null) {
                      controller.flipCamera();
                      if (_isBackCamera(cameraState)) {
                        setState(() {
                          cameraState = frontCamera;
                        });
                      } else {
                        setState(() {
                          cameraState = backCamera;
                        });
                      }
                    }
                     }
                },
              )),

          body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                 checkQR(context),
                Text(qrText),

                ],
              ),
            ),
          )
        ],
      ),
    ));
  }

  bool _isFlashOn(String current) {
    return flashOn == current;
  }

  bool _isBackCamera(String current) {
    return backCamera == current;
  }

  checkQR(context){
    if (qrText!= null && qrText!="") {
      DecryptQrCode dd = DecryptQrCode(ecdata: qrText.toString());
      setState(() {
        plaintext = dd.showData();
        var info = plaintext.split(":");
         rcustomerid = info[1];
         ruserkey = info[2];
         rshopid = info[3];
         rwhat = info[4];
      });

    }
      return (qrText!= null && qrText!=""?
      Container(
          margin: EdgeInsets.all(8),
          width:270,
          child:RaisedButton(
              padding:EdgeInsets.all(20),
        color: Colors.green,

          onPressed: (){


          },
          child:Text('อ่านสำเร็จ',

        style: TextStyle(color:Colors.white, fontSize: 20),
      ))):
     Text('ยังอ่านไม่ได้',style: TextStyle(color:Colors.red),));

  }

  checkDigit(num){
    if (num.length<2)
      return '0'+num;
    else
      return num;

  }

  Future<void> saveScore(customer, userkey,shop) async{
    //if new record
    String apply =  checkDigit(DateTime.now().day.toString())+"-"+
        checkDigit(DateTime.now().month.toString())+"-"+
        checkDigit(DateTime.now().year.toString());

    var respectsQuery = Firestore.instance
        .collection(customer+"_point")
        .where('shopid',isEqualTo: shop)
        .where ('userkey',isEqualTo: userkey);

    var querySnapshot = await respectsQuery.getDocuments();
    var record = querySnapshot.documents.length;
    if (record==0){
      return Firestore.instance
          .collection(customer+"_point")
          .add({
        'pdate': apply,
        'phone':customer,
        'shopid':shop,
        'exchange':0,
        'point':1,
        'userkey':userkey
      })
          .then((value) => print('add info to counterpoint success')
      )
          .catchError((error) => print("Failed to add info: $error"));
    }
    //Update
    Firestore.instance.collection(
        customer+"_point")
        .where('shopid',isEqualTo: shop)
        .where ('userkey',isEqualTo: userkey)
        .getDocuments().then(
            (snapshot) {
          for (DocumentSnapshot ds in snapshot.documents){
            var pn =ds.data['point']+1;
            Firestore.instance.collection(
                customer+"_point")
                .document(ds.documentID)
                .updateData({'point':pn});

          };
        })

        .catchError((error) => print("Failed to update counter point save point: $error"));


  }
  //https://www.upoint.app/shopu/pic/0001_rule.png

    Future<void> saveScoreCount(customer, userkey,shop) async{
    //add to counterpoint too
    //check ว่ามีรายการของวันนี้หรือยัง ถ้าไม่มีก็เพิ่มรายการ
    String apply =  checkDigit(DateTime.now().day.toString())+"-"+
        checkDigit(DateTime.now().month.toString())+"-"+
        checkDigit(DateTime.now().year.toString());

    var respectsQuery = Firestore.instance
        .collection("counterpoint")
        .where('shopid',isEqualTo: shop)
        .where ('dpoint',isEqualTo: apply);

    var querySnapshot = await respectsQuery.getDocuments();
    var record = querySnapshot.documents.length;
    if (record==0){
     return Firestore.instance
          .collection("counterpoint")
          .add({
        'dpoint': apply,
        'exchange': 0,
        'point': 1,
        'shopid':shop

      })
          .then((value) => print('add info to counterpoint success')
         )
          .catchError((error) => print("Failed to add info: $error"));
    }

/*
 CollectionReference users = Firestore.instance.collection(
        'CheckRoomStatus');
    var updateuser = users
        .document('roomstatus' + room)
        .updateData({
      'status': 'ไม่ว่าง',
 */
    Firestore.instance.collection(
        "counterpoint")
    .where('shopid',isEqualTo: shop)
    .where ('dpoint',isEqualTo: apply)
    .getDocuments().then(
             (snapshot) {
           for (DocumentSnapshot ds in snapshot.documents){
               var pn =ds.data['point']+1;
               Firestore.instance.collection(
                   "counterpoint")
                   .document(ds.documentID)
                   .updateData({'point':pn});

           };
         })

         .catchError((error) => print("Failed to update counter point save point: $error"));

  }
  Future<void> saveUseScore(customer, userkey,shop) async{
    String apply =  checkDigit(DateTime.now().day.toString())+"-"+
        checkDigit(DateTime.now().month.toString())+"-"+
        checkDigit(DateTime.now().year.toString());

    var respectsQuery = Firestore.instance
        .collection(customer+"_point")
        .where('shopid',isEqualTo: shop)
        .where ('userkey',isEqualTo: userkey);

    var querySnapshot = await respectsQuery.getDocuments();
    var record = querySnapshot.documents.length;
    if (record==0){
      return Firestore.instance
          .collection(customer+"_point")
          .add({
        'pdate': apply,
        'phone':customer,
        'shopid':shop,
        'exchange':1,
        'point':0,
        'userkey':userkey
      })
          .then((value) => print('add info to counterpoint success')
      )
          .catchError((error) => print("Failed to add info: $error"));
    }
    //add to counterpoint too

    //update
    Firestore.instance.collection(
        customer+"_point")
        .where('userkey',isEqualTo: userkey)
        .where ('shopid',isEqualTo: shop)
        .getDocuments().then(
            (snapshot) {
          for (DocumentSnapshot ds in snapshot.documents){
            var ex = ds.data['exchange']+10;
            var po = ds.data['point']-10;
              Firestore.instance.collection(
                  customer+"_point")
                  .document(ds.documentID)
                  .updateData({'exchange':ex,'point':po });
            }
          }
        )
        .catchError((error) => print("Failed to update exchage point yser: $error"));

  }
  Future<void> saveUseScoreCount(customer, userkey,shop) async{
    //add to counterpoint too
    String apply =  checkDigit(DateTime.now().day.toString())+"-"+
        checkDigit(DateTime.now().month.toString())+"-"+
        checkDigit(DateTime.now().year.toString());
   // info to counterpoint if no record for today
    var respectsQuery = Firestore.instance
        .collection("counterpoint")
        .where('shopid',isEqualTo: shop)
        .where ('dpoint',isEqualTo: apply);

    var querySnapshot = await respectsQuery.getDocuments();
    var record = querySnapshot.documents.length;
    if (record==0){
      return Firestore.instance
          .collection("counterpoint")
          .add({
        'dpoint': apply,
        'exchange': 10,
        'point': 0,
        'shopid':shop

      })
          .then((value) => print('add info to counterpoint success')
      )
          .catchError((error) => print("Failed to add info: $error"));
    }


    //Update use point score
    Firestore.instance.collection(
        "counterpoint")
        .where('shopid',isEqualTo: shop)
        .where ('dpoint',isEqualTo: apply)
        .getDocuments().then(
            (snapshot) {
          for (DocumentSnapshot ds in snapshot.documents){
            var ex =ds.data['exchange']+10;
            Firestore.instance.collection(
                "counterpoint")
                .document(ds.documentID)
                .updateData({'exchange':ex});
             return;

          };
        })

        .catchError((error) => print("Failed to update counter point save point: $error"));

  }
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData;
        if (qrText!=null && qrText!="") {

          if (rcustomerid!=""&&rshopid!=""&&rwhat!=""&&pushornot==false) {
            this.controller.pauseCamera();
            pushornot=true;
            if (rwhat == "savepoint" && rshopid == widget.store){
              saveScore(rcustomerid,ruserkey,rshopid);
              saveScoreCount(rcustomerid,ruserkey,rshopid);

          }else if (rwhat=="usepoint" && rshopid == widget.store){
            saveUseScore(rcustomerid,ruserkey,rshopid);
            saveUseScoreCount(rcustomerid,ruserkey,rshopid);

          }else if (rwhat=="register" ) {
           updateShop(rcustomerid,ruserkey,widget.store,widget.businesspic);

          }else if (rwhat=="addshop" ) {
             // print('customer $rcustomerid $ruserkey shop '+widget.store);
             addShop(rcustomerid,ruserkey,widget.store);

            }
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(
                builder: (context) =>
                    ReportQrScan(customer: rcustomerid,
                        shop: rshopid, what: rwhat, applyshop: widget.store)));
          }
        }
      });
    });
  }
  Future<void> addShop(customer,userkey,shop) async {
    //shop is register shop
    Firestore.instance
        .collection(customer+"_memberof")
        .add({
      'businesspic': widget.businesspic,
      'location': widget.location,
      'shopid': shop,
      'shopname':widget.shopname,
      'userkey':userkey

    })
        .then((value) => print('add info to _memberof')
    )
        .catchError((error) => print("Failed to add info: $error"));

  }
  Future<void> updateShop(customer,userkey,shop,businesspic) async{
    //shop is register shop
    Firestore.instance.collection(
        "customer")
        .where('shop',isEqualTo: "N/A")
        .where('userkey',isEqualTo: userkey)
        .where ('phone',isEqualTo: customer)
        .getDocuments().then(
            (snapshot) {
          for (DocumentSnapshot ds in snapshot.documents){

            Firestore.instance.collection(
                "customer")
                .document(ds.documentID)
                .updateData({'shop':shop,'businesspic':businesspic});
            return;

          };
        })

        .catchError((error) => print("Failed to update customer info: $error"));
    //add into customer_memberof
    Firestore.instance
        .collection(customer+"_memberof")
        .add({
      'businesspic': widget.businesspic,
      'location': widget.location,
      'shopid': shop,
      'shopname':widget.shopname,
      'userkey':userkey

    })
        .then((value) => print('add info to memberof')
    )
        .catchError((error) => print("Failed to add info: $error"));

    }

  _doAlert(context,msg){
    return  showDialog(
        context: context,
        builder: (_) => new AlertDialog(
          title: new Text("แจ้งผลการสแกน "),
          content: new Text(msg + plaintext),
          actions: <Widget>[
            IconButton(

              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ));
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class ReportQrScan extends StatelessWidget{
  final String customer;
  final String shop;
  final String what;
  final String applyshop;
  const ReportQrScan({ key,this.customer,this.shop,this.what,this.applyshop}) : super(key: key);
  @override
  Widget build(BuildContext context) {
     return MaterialApp(
       home:Scaffold(
         appBar: AppBar(
           title:Text("ผลการอ่านบาร์โค้ด")
         ),
        body:SingleChildScrollView(
          child:Container(
              width: MediaQuery.of(context).size.width,
              child:Column(children: [
            Container(padding:EdgeInsets.all(10),child:Text("ผลการอ่าน QR code ")),
            what=='savepoint'?  Container(padding:EdgeInsets.all(10),child:Text("สะสมแต้ม")):Padding(padding: EdgeInsets.only(left:1)),
            what=='usepoint'?  Container(padding:EdgeInsets.all(10),child:Text("แลกแต้ม")):Padding(padding:  EdgeInsets.only(left:1)),
            what=='register'?  Container(padding:EdgeInsets.all(10),child:Text("ลงทะเบียน")):Padding(padding:  EdgeInsets.only(left:1)),
            what=='addshop'?  Container(padding:EdgeInsets.all(10),child:Text("เพิ่มร้านค้า")):Padding(padding:  EdgeInsets.only(left:1)),

                Container(padding:EdgeInsets.all(10),child: Text("สมาชิกหมายเลข "+this.customer)),
       //    Container(padding:EdgeInsets.all(10),child:Text("กับร้านค้า "+this.applyshop)),
            this.shop==this.applyshop&&(what=="savepoint"||what=="usepoint")? Container(padding:EdgeInsets.all(10),child:Text('ดำเนินการสำเร็จ')):
                Padding(padding:EdgeInsets.only(left:3)),
                this.shop!=this.applyshop&&(what=="savepoint"||what=="usepoint")?
                Container(padding:EdgeInsets.all(10),child:Text('ไม่สามารถดำเนินการได้ \nเพราะรหัสร้านค้าไม่ตรงกับ QR Code')):

                what=="register"? Container(padding:EdgeInsets.all(10),child:Text('ดำเนินการสำเร็จ กรุณาแจ้งเตือนลูกค้าให้เข้าสู่ระบบใหม่')):
                Container(padding:EdgeInsets.all(10)),

                this.shop==this.applyshop&&(what!="register")?IconButton(icon: Icon(Icons.thumb_up, color:Colors.green),
                    onPressed: null):Padding(padding:EdgeInsets.only(left:5)),
                this.shop!=this.applyshop&&(what!="register"&&what!="addshop")?IconButton(icon: Icon(Icons.thumb_down, color:Colors.red),
                    onPressed: null):Padding(padding:EdgeInsets.only(left:5)),
                what=="register"? IconButton(icon: Icon(Icons.thumb_up, color:Colors.green),
                    onPressed: null):Padding(padding:EdgeInsets.only(left:5)),
                what=="addshop"? IconButton(icon: Icon(Icons.thumb_up, color:Colors.blue),
                    onPressed: null):Padding(padding:EdgeInsets.only(left:5)),

                Padding(padding: EdgeInsets.only(bottom:20)),
               Container(
                   width: 250,
                   child: IconButton(icon: Icon(Icons.home), onPressed: (){
               Navigator.pop(context);

            }))
          ],))

        )
       )

     );
  }

}
