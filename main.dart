import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:upointshop/shop.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop Sign In',

      home: SignInPage(),
    );
  }
}

class SignInPage extends StatefulWidget {
  @override
  SignState createState() => SignState();
}
class SignState extends State<SignInPage>{

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController shopController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String shopphone="";
  String shopuserkey = "";
  bool registerconfirm = false;
  String expiredate="";
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    readUserKey();
  }


  CheckDigit(String numberd){
    if(numberd.length==1){
      return "0"+numberd;

    }else
      return numberd;
  }
  Future<void> readUserKey() async {
    //check case just register
    final SharedPreferences prefs = await _prefs;
    var today = CheckDigit(DateTime.now().day.toString())+"-"+
        CheckDigit(DateTime.now().month.toString())+"-"+
        CheckDigit(DateTime.now().year.toString());
    setState(() {
      shopuserkey = prefs.getString("shopuserkey").toString();
      shopphone = prefs.getString("shopcustomer").toString();
      expiredate = prefs.getString("expiredate").toString();
      var register = prefs.getString("register").toString();
      if (today <= expiredate ){
        phoneController.text = shopphone;
      }

    });
    print("shopuserkey "+shopuserkey+" "+shopphone+" "+expiredate);

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
                ],) ),]
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
               //     border: OutlineInputBorder(),
                    labelText: 'หมายเลขโทรศัพท์',
                  ),
                ),
              ),

              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(

                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color:Colors.blue)
                ),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,

                  decoration: InputDecoration(

                  //  border: OutlineInputBorder(),
                    labelText: 'รหัสผ่าน',
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
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blue,

                      ),
                      child:FlatButton(
                        textColor: Colors.black,
                        child: Text('ร้านค้าเข้าสู่ระบบ',style: TextStyle(fontSize: 20, color:Colors.white)),
                        onPressed: () {
                          if (phoneController.value.text.toString()=="" ||
                             passwordController.value.text.toString()== "")
                          {

                               checkEmpty( context,"");

                          }
                           else

                             {   //check mach user or not

                          final firestoreInstance = Firestore.instance;
                          var result = firestoreInstance.collection("RegisteredBusiness")
                             .document(shopuserkey)
                               .get()
                               .then ((data) {
                             if (!data.exists)
                                cannotLogin(context);
                             else
    if (
    data.data['smobile'] ==
    phoneController.value.text.toString() &&
    data.data['password'] ==
    passwordController.value.text.toString()){
    Navigator.push(context,
    MaterialPageRoute(builder: (context) =>
    ShopManagePage(
    shopid: data.data['shopid'],shopname:data.data['shopname'],
        smobile: data.data['smobile'],
        businesspic:data.data['businesspic'],
        location:data.data['location'])));
    }else
      cannotLogin(context);

          });
    }
    }//onpressed
     )
                      )),
              Padding(padding: EdgeInsets.only(bottom:25)),
              Text('ลงทะเบียนร้านค้าสมาชิกใหม่'),
              IconButton(icon:Icon(Icons.app_registration),
                onPressed: (){
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Shopregister()));


                },),


            ],
          )),

    )

    ;
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
                        "หมายเลขโทรศัพท์หรือรหัสผ่านอาจไม่ถูกต้อง "
                            "โปรดติดต่อ admin@upoint.app")),
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


class Shopregister extends StatefulWidget {
  @override
  ShopRegisterState createState() =>ShopRegisterState();

}
class ShopRegisterState extends State<Shopregister>{
  String rule;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController ownerController = TextEditingController();
  TextEditingController ruleController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  String shopuserkey="";
  String shopphone="";
  String shopregister="";
  String logocompany="";
  List<String> information=[];
  List<String> informationrule=[];
  @override
  initState(){
    readPointRule("Upointrule","help");
    readPointRule("Upointrule","rule");

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

        appBar: PreferredSize(

          preferredSize: Size.fromHeight(170.0), // here the desired height
          child: Column( children:[
            //  Container(height:800,child:Text("U-Point",style: TextStyle(fontSize: 40),)),
            AppBar(elevation: 10,
                flexibleSpace:
                Column(children: [
                  Row(children: [
                Expanded(child:Padding(padding: EdgeInsets.all(8), child:Text("ลงทะเบียนร้านค้ากับ Upoint", style: TextStyle(fontSize: 20, color:Colors.white, fontWeight: FontWeight.bold),))),
                    Text("สอบถาม", style: TextStyle(fontSize: 18, color: Colors.white),),
                    IconButton(icon:Icon(Icons.call, color:Colors.white),
                      onPressed: (){
                        launch("tel:0612586626");
                      },),
                  ],),
                  Container(color:Colors.white,height:130, child: Image.asset("images/upoint.png",width:MediaQuery.of(context).size.width))
                ],) ),])),

      body:  SingleChildScrollView(child: Column(children: [

        Column(children: [
          Text("คำแนะนำในการกรอกและตัวอย่าง", style: TextStyle(fontSize: 20, color:Colors.blue,
              fontWeight: FontWeight.bold)),

          Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),

              ),
              child:IconButton(
                  icon: Icon(Icons.help),
                  onPressed:(){
                    showPointRule(context,"help");
                  })),
        ],) ,

        Container(
          padding: EdgeInsets.all(10),
          child: TextField(
            controller: ownerController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'ชื่อเจ้าของกิจการ(ใช้ออกใบเสร็จ)',
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(10),
          child: TextField(
            controller: phoneController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],

            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'โทรศัพท์สำหรับติดต่อ/ล็อกอิน',
            ),
          ),
        ),

        Container(
          padding: EdgeInsets.all(10),
          child: TextField(
            controller: nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'ชื่อร้านค้า(ใช้สำหรับสะสมแต้ม)',
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(10),
          child: TextField(
            controller: locationController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'ชื่อสาขา/ที่ตั้ง(ย่อ)',
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(10),
          child: TextField(
            controller: emailController,
            //    onChanged:  checkEmpty(context, emailController.value.text.toString()),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'อีเมล์สำหรับติดต่อ',
            ),
          ),
        ),

        Container(
          padding: EdgeInsets.all(10),
          child: TextField(
            controller: addressController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'ที่อยู่ระบุโดยละเอียดเพื่อออกใบเสร็จ',
            ),
          ),
        ),


            Container(
                width:300,
                height:85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.blue,

                ),
                child:
                FlatButton(
                  textColor: Colors.white,
                  // color: Colors.blue,
                  child: Text('หน้าถัดไป',style: TextStyle(fontSize: 20),),
                  onPressed: () {
                    if (emailController.value.text.toString()!=""&&
                        phoneController.value.text.toString()!=""&&
                        ownerController.value.text.toString()!=""&&
                        addressController.value.text.toString()!="") {
                      //check if exists
                      generateUserKey();
                      writeUserKey(shopphone, shopuserkey);
                      final firestoreInstance = Firestore.instance;
                      firestoreInstance.collection("RegisteredBusiness")
                          .document(shopuserkey)
                          .get()
                          .
                      then((querySnapshot) {
                        if (!querySnapshot.exists) {
                          //ลงทะเบียนข้อมูลใหม่

                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => PolicyPage(
                                name: nameController.value.text.toString(),
                                email: emailController.value.text.toString(),
                                phone: phoneController.value.text.toString(),
                                address: addressController.value.text.toString(),
                                owner: ownerController.value.text.toString(),
                                location:locationController.value.text.toString(),
                                businesspic: "https://www.upoin.app/shopu/pic/upointshop.png",
                                userkey: shopuserkey,



                              ))) ;
                                  RegisFirebase(name: nameController.value.text
                                      .toString(),
                                      phone: phoneController.value.text
                                          .toString(),
                                      email: emailController.value.text
                                          .toString(),
                                      address: addressController.value.text
                                          .toString(),
                                      owner: ownerController.value.text
                                          .toString(),
                                      location: locationController.value.text.toString(),
                                      businesspic:'',
                                      userkey:shopuserkey);


                        } else {
                          warnOldEmailRegister(context);
                        }
                      });
                    }else{
                      checkEmpty(context, "");
                    }

                  },
                )),

      ],)
      ));

  }
  Widget showPointRule(BuildContext context,what){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(

              children: [
                SingleChildScrollView(child: Column(children: [
                Container(padding: EdgeInsets.all(10),
                    child: Text("ข้อมูล/เงื่อนไขการบริการ",
                      style: TextStyle(fontSize: 20, color: Colors.red,fontWeight: FontWeight.bold),)),
         //shoe logo
               ((what=="rule")&& information.length>1)?Image.network(information[information.length-1],width:200,height:150):Padding(padding:EdgeInsets.only(left:2)),
                /*  FutureBuilder(
                      future: readPointRule("Upointrule",what),
                      builder: (context, rule) {
                        return Text(ruleController.value.text.toString());
                      }),*/
                (what=='help')? Container(height:500,width:400,
                    child:
                    ( information.length>1)?writeRuleInfo(context,information):Padding(padding:EdgeInsets.only(left:2)))
                :Padding(padding:EdgeInsets.only(left:2)),

                Container(padding: EdgeInsets.all(10),
                    child: IconButton(
                      icon:Icon(Icons.close),
                      color: Colors.blueAccent,
                      padding: EdgeInsets.all(25),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ))

                ]))]
          );
        });



  }
  writeRuleInfo(context,data){
    print(data.length);
    return
        Container(height:2000,width:400,child:
       ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: data.length,
        itemBuilder: (BuildContext context, int index) {

          if (index!= (data.length-1))
           return Container( width:400,
           // height:200,
            child: Center(child: Text(data[index].toString())),
          );
          else
            return Container(
              width:400,
              child: Center(child: Text('www.intellixsoft.com')),
            );
        }
    ) );
  }
  checkDigit(String numberd){
    if(numberd.length==1){
      return "0"+numberd;

    }else
      return numberd;
  }
 generateUserKey(){
   String userkey = phoneController.value.text.toString()+
       checkDigit(DateTime.now().day.toString())+
       checkDigit(DateTime.now().month.toString())+
       checkDigit(DateTime.now().year.toString())+
       checkDigit(DateTime.now().hour.toString())+
       checkDigit(DateTime.now().minute.toString());
   setState(() {
     shopuserkey = userkey;
   });
 }
  Future readPointRule(collectionname,what) async {


    final firestoreInstance = Firestore.instance;
    firestoreInstance.collection(collectionname)
        .document(what)
        .get()
        .
    then((querySnapshot) {
      if (querySnapshot.exists)
        querySnapshot.data.forEach((key, value) {
            if (key=='shoprule' ) {
              var info = value.split("#");
                 setState(() {
                   informationrule = info;

                ruleController.text = "";
              });
                return true;
              }
            if (key=='forminfo' || key=='help' ) {
              var info = value.split("#");
              setState(() {
                information = info;

                ruleController.text = "";
              });
              return true;
            }



        });

    });

  }
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> writeUserKey(shopphone,shopuserkey) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString("shopuserkey",shopuserkey);
    prefs.setString("shopphone",shopphone);

  }


  Widget warnOldEmailRegister(BuildContext context){
  showDialog(
      context: context,
      builder: (BuildContext context){
        return SimpleDialog(
            children: [
              Container(padding:EdgeInsets.all(10),child: Text("มีข้อผิดพลาด", style: TextStyle(fontSize:20, color:Colors.red ),)),
              Container(padding:EdgeInsets.all(10),child:Text("อีเมล์นี้ได้ใช้ในการลงทะเบียนแล้ว กรุณาติดต่อ admin@upoint.app หรือเลือกใช้อีเมล์อื่น ")),
              Container(padding:EdgeInsets.all(10),child:FlatButton(color:Colors.blueAccent, padding:EdgeInsets.all(25), onPressed:(){Navigator.pop(context);},child:Text(" ปิด ")))

            ]
        );
      }
  );
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



}



class PolicyPage extends StatefulWidget {
  final String name;
  final String  phone;
  final String email;
  final String address;
  final String owner;
  final String location;
  final String businesspic;
  final String userkey;

  PolicyPage({Key key, this.name,this.phone,this.email, this.address,
    this.owner, this.location,this.businesspic,this.userkey}) : super(key: key);


  @override
  PolicyPageState createState()=> PolicyPageState();

}

class PolicyPageState extends State<PolicyPage>{
  TextEditingController policyController = new TextEditingController(text:
  'นโยบายการคุ้มครองข้อมูลส่วนบุคคล (Privacy & Policy)\n'+
      'บริษัท อินเทลลิคซ์ซอฟต์ จำกัด (ซึ่งต่อไปนี้จะเรียกว่า "บริษัทฯ") ผู้พัฒนาแอพพลิคชั่น Upoint (ซึ่งต่อไปนี้จะเรียกรวมว่า "บริการฯ")\n'+
      'ร้านค้า (คือผู้ใช้บริการ Upoint) และลูกค้า  (คือลูกค้าที่ใช้บริการ Upoint เพื่อดำเนินการซื้อของกับร้านค้า)\n'+
      'บริษัทฯ ให้ความสำคัญกับข้อมูลส่วนบุคคลบริษัทฯ จึงประกาศนโยบายเกี่ยวกับข้อมูลส่วนบุคคลของคุณภายใต้ข้อกำหนดและเงื่อนไข ดังต่อไปนี้\n'+
      '1. การเก็บข้อมูล วัตถุประสงค์การเก็บรวบรวม ใช้ หรือเปิดเผยข้อมูลส่วนบุคคล \n'+
      ' ข้อมูลส่วนบุคคลทั่วไป\n'+
      ' บริษัทฯ มีการเก็บข้อมูล ชื่อ นามสกุล เบอร์โทรศัพท์ อีเมล หรือตามที่แต่ละร้านค้าที่เป็นคู่ค้ากับบริษัทฯ ร้องขอ เช่น'+
      'เลขบัตรประจำตัวประชาชน วันเกิด อายุ เพศ ที่อยู่ ฯลฯ (ซึ่งผู้ใช้งานสามารถเลือกจะให้ข้อมูลหรือไม่ก็ได้)\n'+
      'ข้อมูลทางด้านเทคนิค\n'+
      'บริษัทฯ อาจมีการเก็บข้อมูลส่วนบุคคลทางด้านเทคนิคเพื่อตรวจสอบปัญหาและพัฒนาปรับปรุงระบบให้ดียิ่งขึ้น เช่น IP Address, พิกัด, เวลาเข้าใช้งาน,'+
      'ชนิดของอุปกรณ์, OS Version, Device Version, APP Version\n'+
      'ข้อมูลการใช้บริการ\n'+
      ' บริษัทฯ อาจมีการเก็บข้อมูลการใช้บริการ เช่น การสะสมคะแนน การใช้คูปองส่วนลด การจัดส่งสินค้า เพื่อสิทธิประโยชน์ของลูกค้า'+
      'นอกจากนี้ข้อมูลอาจถูกนำไปจัดทำฐานข้อมูล วิเคราะห์ ให้กับร้านค้าที่สมัครใช้บริการกับบริษัท เพื่อให้ร้านค้าและบรัษัทฯ'+
      'นำเสนอบริการในแอพพลิเคชั่นที่เป็นประโยชน์กับลูกค้าต่อไป\n\n'+
      ' 2. ระยะเวลาในการเก็บรวบรวมข้อมูลส่วนบุคคล\n'+
      'บริษัทฯ จะจัดเก็บข้อมูลส่วนบุคคลของคุณตลอดระยะเวลาที่ลูกค้าใช้บริการฯ เว้นแต่จะมีการเปลี่ยนแปลงข้อมูลหรือเพิกถอนจากร้านค้า'+
      ' กรณีที่ลูกค้าไม่ใช้บริการฯ เป็นระยะเวลานาน บริษัทอาจลบข้อมูลของลูกค้า และการกลับมาขอใช้บริการอาจจะต้องทำการสมัครใหม่กับทางร้านค้าอีกครั้ง ในกรณีที่ร้านค้ากำหนดระยะเวลาในการสิ้นสุดการใช้บริการของลูกค้าบริษัทสามารถดำเนินการลบข้อมูลได้ทันที'+
      'กรณีที่ร้านค้ายุติการใช้บริการกับบริษัทฯ ข้อมูลของลูกค้าในการใช้บริการกับร้านค้านั้นอาจถูกลบออกจากระบบ\n\n'+

      '3. การเปิดเผยข้อมูลส่วนบุคคล\n'+
      ' ข้อมูลส่วนบุคคลของคุณจะถูกเก็บเป็นความลับ การเปิดเผยข้อมูลจะอนุญาตให้เข้าถึงได้เฉพาะทีมพัฒนาระบบของบริษัทฯ'+
      'และอาจนำข้อมูลไปใช้กับบริการอื่นๆกับร้านค้าพันธมิตรหรือคู่ค้ากับบริษัทฯ เฉพาะร้านค้าที่ลูกค้าสมัครเข้าร่วมเท่านั้น'+
      'โดยข้อมูลของลูกค้าจะแสดงบนแอพพลิเคชั่น Upoint สำหรับผู้ใช้งาน และแสดงบนแอพพลิเคชั่น Upoint Shop  สำหรับร้านค้า และพนักงานร้านค้า\n\n'+

      ' 4. การแจ้งข่าวสาร/การแจ้งเตือน\n'+
      'บริษัทฯ หรือร้านค้าพันธมิตรหรือคู่ค้ากับบริษัทฯ อาจจะมีการส่งข่าวสารประชาสัมพันธ์ โปรโมชั่น สิทธิประโยชน์ แจ้งเตือนไปยังอุปกรณ์ของลูกค้า'+
      'ซึ่งคุณสามารถตั้งค่าเปิด/ปิด การแจ้งเตือนได้ด้วยตัวเองผ่านแอพพลิเคชั่น Upoint\n\n'+

      '5. สิทธิของเจ้าของข้อมูล\n'+
      'เจ้าของข้อมูลมีสิทธิดังต่อไปนี้\n'+
      '5.1 มีสิทธิเลือกที่จะให้ข้อมูลส่วนบุคคลใดๆที่บริษัทฯ ร้องขอ และยินยอมให้บริษัทฯ จัดเก็บ ใช้ และเปิดเผย ข้อมูลส่วนบุคคลดังกล่าวหรือไม่ก็ได้\n'+
      '5.2 มีสิทธิเพิกถอนความยินยอมในการเก็บ รวบรวม ใช้ เปิดเผย ซึ่งข้อมูลส่วนบุคคลของตนได้\n'+
      '5.3 มีสิทธิเข้าดูข้อมูลส่วนบุคคล และขอให้บริษัทฯ ทำสำเนาข้อมูลจากการใช้บริการ\n'+
      '5.4 มีสิทธิแก้ไขข้อมูลส่วนบุคคลของตนเอง\n'+
      '5.5 มีสิทธิในการขอให้บริษัทฯ ทำการลบ หรือทำลายข้อมูลส่วนบุคคลของตนด้วยเหตุบางประการได้\n'+
      '5.6 มีสิทธิขอให้บริษัทฯ ทำการระงับการใช้ข้อมูลส่วนบุคคลของตนด้วยเหตุบางประการได้\n'+
      '5.7 มีสิทธิร้องขอข้อมูลของตนเอง หรือให้บริษัทฯ ส่งต่อข้อมูลต่อไปยังหน่วยงานอื่นด้วยเหตุบางประการได้\n'+
      '5.8 มีสิทธิคัดค้านหรือยับยั้งไม่ให้บริษัทฯ เก็บรวบรวม ใช้ หรือเปิดเผยข้อมูลส่วนบุคคลด้วยเหตุบางประการได้\n'+
      'การใช้สิทธิข้างต้น อาจจะต้องได้รับการยินยอมจากร้านค้าในบางกรณี ตามเงื่อนไขของร้านค้า\n\n'+

      ' 6. มาตรการและวิธีการรักษาความปลอดภัยของข้อมูลส่วนบุคคล\n'+
      ' บริษัทฯ จัดให้มีมาตรการในการรักษาความมั่นคงปลอดภัยข้อมูลส่วนบุคคลอย่างเหมาะสม ข้อมูลส่วนบุคคลของคุณจะถูกเก็บรักษาไว้เป็นความลับ'+

      ' การเปิดเผยข้อมูลจะกระทำเฉพาะร้านค้าที่ลูกค้าอนุญาติเท่านั้น\n\n'+

      '7. นโยบายคุกกี้\n'+
      'หากมีการใช้คุกกี้ในบริการที่เกี่ยวข้อง บริษัทฯ จะจัดให้มีนโยบายคุกกี้ให้มีมาตรฐานการรักษาความมั่นคงปลอดภัยของข้อมูลที่เป็นมาตรฐานสากล\n\n'+

      '8. การแก้ไขเปลี่ยนแปลงและการเปิดเผยนโยบายการคุ้มครองข้อมูลส่วนบุคคล\n'+
      'บริษัทฯ จะพิจารณาทบทวนปรับปรุงนโยบายการคุ้มครองข้อมูลส่วนบุคคลเพื่อให้สอดคล้องกับการเปลี่ยนแปลงของการให้บริการ การดำเนินงานภายใต้วัตถุประสงค์ของบริษัทฯ และให้มีความทันสมัยและเป็นมาตรฐานที่ยอมรับได้อย่างสม่ำเสมอ โดยบริษัทฯ จะเปิดเผยนโยบายการคุ้มครองข้อมูลส่วนบุคคลให้แก่ท่านทราบผ่านแอพพลิเคช่น หรือช่องทางอื่นๆ ตามความเหมาะสม'+
      ' หากท่านมีข้อสงสัยเพิ่มเติมเกี่ยวกับนโยบายการคุ้มครองข้อมูลส่วนบุคคล สามารถติดต่อเจ้าหน้าที่คุ้มครองข้อมูลส่วนบุคคลที่บริษัท อินเทลลิคซ์ซอฟต์ จำกัด  อีเมล intellixsoftco@gmail.com\n\n'+

      ' ข้อกำหนดและเงื่อนไขการให้บริการ (Terms & Condition)\n'+
      ' ●  การสมัครสมาชิกเพื่อใช้บริการแอพ Upoint จะถือว่าคุณยอมรับข้อกำหนดและเงื่อนไขแล้ว\n'+
      ' ●	สมาชิกตกลงและยินยอมให้แอพ Upoint เก็บข้อมูลส่วนตัว เพื่อใช้กับระบบในเครือที่เกี่ยวข้องกับแอพ Upoint\n'+
      ' ●	ข้อมูลส่วนตัวของสมาชิกจะถูกเก็บเป็นความลับ ระบบจะแสดงข้อมูลของคุณเฉพาะที่จำเป็น ให้กับร้านค้าที่คุณอนุญาติเท่านั้น\n'+
      ' ●	เงื่อนไขการสะสมคะแนน และการแลกรับของรางวัล เป็นไปตามที่แต่ละร้านกำหนด\n'+
      ' ●	สมาชิกยอมรับว่า สมาชิกแต่ละรายอาจได้รับสิทธิประโยชน์แตกต่างกัน ขึ้นอยู่กับเงื่อนไขที่แต่ละร้านกำหนด เช่น ประวัติการเป็นสมาชิก ประวัติการซื้อสินค้า รายการโปรโมชั่นในช่วงเวลา หรือสถานที่ต่างๆ เป็นต้น\n'+
      ' ●	Upoint เป็นเพียงผู้ให้บริการระบบส่งเสริมการขายทางการตลาดเท่านั้น ความรับผิดชอบต่างๆ ไม่รวมถึงสินค้าและโปรโมชั่นของทางร้านค้า\n'+
      ' ●	สมาชิกยินยอมให้มีการแจ้งเตือนข่าวสารใหม่ๆ และโปรโมชั่นจากแอพ Upoint และร้านค้าผ่านทางช่องทางต่างๆ (สมาชิกขอยกเลิกการรับข่าวสารได้ผ่านทางช่องทางที่กำหนด)\n'+
      ' ●	ระบบอาจจะมีการขอยืนยันตัวตนด้วยวิธีการ OTP ผ่านทางโทรศัพท์มือถือ (SMS)\n'+
      ' ●	การสมัครสมาชิกของแอพ Upoint จะใช้วิธีการลงทะเบียนกับระบบ Upoint หรือ Login ด้วยระบบ Google Login, Facebook Login, หรือ Apple Login เมื่อ Login ด้วยระบบใดระบบหนึ่งแล้ว จะไม่สามารถ โอน ย้าย ข้อมูลทุกชนิด รวมถึงคะแนนและสิทธิประโยชน์ต่างๆ ไปยังบัญชี Login อื่นได้\n'+
      ' ●	ระบบอาจจะมีการขออนุญาติ ให้สมาชิกเปิด GPS เพื่อยืนยันพิกัดว่าสมาชิกใช้สิทธิ์ที่ร้านนั้นจริง\n'+
      ' ●	ลูกค้าสามารถขอยกเลิกการใช้บริการแอพ Upoint ได้ทุกเมื่อ แต่แอพ Upoint จะไม่สามารถคืนหรือโอนแต้มที่ค้างอยู่ในระบบกลับคืนไปให้ในรูปแบบอื่นหรือแอพอื่นได้\n'+
      ' ●	กรณีที่พบว่ามีการทุจริต แอพ Upoint มีสิทธิ์ยกเลิกการเป็นสมาชิกได้ทันที โดยไม่จำเป็นต้องแจ้งให้ทราบล่วงหน้า และไม่มีนโยบายการคืนแต้มที่ค้างอยู่ในระบบในทุกกรณี\n'+

      'กรุณาอ่านและทำความเข้าใจ นโยบายการคุ้มครองข้อมูลส่วนบุคคล (Privacy & Policy) และ ข้อกำหนดและเงื่อนไขการให้บริการ (Terms & Condition) ซึ่งระบุไว้ด้านบนนี้อย่างละเอียด การสมัครสมาชิกเพื่อใช้บริการของแอพพลิเคชั่น Upoint จะถือว่าคุณยินยอมรับเงื่อนไขแล้ว\n');
  String apply="";
  @override
  Widget build(BuildContext context) {
    return MaterialApp
      (home: Scaffold(
      appBar: AppBar(
        title: Text('นโยบายการคุ้มครองข้อมูลและเงื่อนไขการใช้บริการ'),

      ),
      body: SingleChildScrollView(

          child:TextField(
            controller: policyController,
            readOnly: true,
            showCursor: true,
            maxLines: null ,
            decoration: InputDecoration(
              border: OutlineInputBorder(),

            ),
          )
      )
      ,floatingActionButton: FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => RegisFirebase(name: widget.name,
                phone:widget.phone,email:widget.email,address:widget.address,
               owner: widget.owner,location:widget.location,
              businesspic:widget.businesspic,userkey:widget.userkey
            ))) ;


      },
      label: const Text('ยอมรับเงื่อนไขทุกประการ'),
      icon: const Icon(Icons.thumb_up),
      backgroundColor: Colors.blue,
    ),
    ));
  }
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  //This is just for testing, normally if the customer login it will use their keys
  Future<void> writeUserKey(phone,userkey) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString("userkey",userkey);
    prefs.setString("customer",phone);
    prefs.setString("register","waitconfirm");

  }
  checkDigit(String numberd){
    if(numberd.length==1){
      return "0"+numberd;

    }else
      return numberd;
  }



}

class RegisFirebase extends StatelessWidget{
  final String name;
  final String email;
  final String phone;
  final String address;
  final String owner;
  final String location;
  final String businesspic;
  final String userkey;
  String dapplyexpire="";
   RegisFirebase({ Key key, this.name,this.phone,this.email,this.address,
    this.owner ,this.location,this.businesspic,this.userkey}) : super(key: key);
  int countwrite=0;
  @override
  Widget build(BuildContext context) {
    if (countwrite==0) {
      _writeShop(context);

      _addRule(context);
      countwrite=1;
    }
    return Scaffold(
        backgroundColor:  Colors.white,
        appBar: PreferredSize(

            preferredSize: Size.fromHeight(170.0), // here the desired height
            child: Column( children:[
              //  Container(height:800,child:Text("U-Point",style: TextStyle(fontSize: 40),)),
              AppBar(elevation: 10,
                  flexibleSpace:
                  Column(children: [
                    Row(children: [
                      Expanded(child:Padding(padding: EdgeInsets.all(8), child:Text("ลงทะเบียนร้านค้ากับ Upoint", style: TextStyle(fontSize: 20, color:Colors.white, fontWeight: FontWeight.bold),))),
                      Text("สอบถาม", style: TextStyle(fontSize: 18, color: Colors.white),),
                      IconButton(icon:Icon(Icons.call, color:Colors.white),
                        onPressed: (){
                          launch("tel:0818897915");
                        },),
                    ],),
                    Container(color:Colors.white,height:130, child: Image.asset("images/upoint.png",width:MediaQuery.of(context).size.width))
                  ],) ),])),

        body:  SingleChildScrollView(

      child:Container (padding: EdgeInsets.all(20),
          decoration: BoxDecoration(

      //  border: Border.all(color: Colors.lightBlue),
         borderRadius: BorderRadius.circular(20)
      )
      ,child: Column(children: [
        Container(padding:EdgeInsets.only(bottom:10), child: Text("ขอบคุณสำหรับข้อมูล  ",style: TextStyle(fontSize: 20,

        ),)),
          Container(padding:EdgeInsets.only(bottom:10), child: Text("ขั้นตอนถัดไปคือ",style: TextStyle(fontSize: 20,))),
              Container(padding:EdgeInsets.only(bottom:10), child: Text("1. ตรวจสอบอีเมล์ของท่าน แล้วทำการชำระเงินค่าใช้บริการตามรายละเอียดในอีเมล์ "+email ,style: TextStyle(fontSize: 20,))),
    Container(padding:EdgeInsets.only(bottom:10), child:   Text("2. ระบบจะส่งรหัสผ่านไปยังอีเมล์ (ของท่าน) "+email+" "
        "เพื่อยินยันการลงทะเบียนที่ชำระเงินแล้ว ",style: TextStyle(fontSize: 20,))),
     Container(padding:EdgeInsets.only(bottom:10), child:   Text("3. ท่านสามารถล็อกอินเข้าใช้งานได้ทันที โดยใช้ ")),
            Container(padding:EdgeInsets.only(bottom:10), child:   Text("username:"+phone,style: TextStyle(fontWeight: FontWeight.bold,color:Colors.red,fontSize: 20),)),
            Container(padding:EdgeInsets.only(bottom:10), child:   Text("password: justdemo",style: TextStyle(fontWeight: FontWeight.bold,color:Colors.red,fontSize: 20))),
            Container(padding:EdgeInsets.only(bottom:10), child:   Text("โดย 7 วันเป็นการทดลองใช้งานซึ่งจะสิ้นสุดในวันที่ "+dapplyexpire+" หากท่านชำระเงินภายใน 7 วัน "
         "จะถือว่าท่านได้สมัครสมาชิกกับ Upoint แล้ว  หากไม่ชำระเงินใน 7 วันที่ทดลองใช้บริการบัญชีของท่านจะถูกยกเลิกอัตโนมัติ"
         ,style: TextStyle(fontSize: 20,))),
            Container(padding:EdgeInsets.only(bottom:10), child:   Text("สอบถามการใช้บริการได้ที่ facebook:intellixsoft, Line: intellixsoft, หรือ "
                "061-2586626 ขอบคุณที่สนใจใช้บริการกับเรา"
                ,style: TextStyle(fontSize: 20,))),

    //        Container(padding:EdgeInsets.only(bottom:10), child: Image.network("https://www.upoint.app/shopu/pic/intellixsoft.png")),
          Container(padding:EdgeInsets.all(25),
              child:   FlatButton(
                   onPressed: (){
          SystemNavigator.pop();
        //  Navigator.of(context).popUntil((route) => route.isFirst);
        }, child:  Container(
              padding: EdgeInsets.all(20),
              height:85, width:400,
              decoration: BoxDecoration(
                border: Border.all(color:Colors.blue),
                borderRadius: BorderRadius.circular(20),
                color: Colors.blue,

              ),
              child:Text("ออกจากแอพพลิเคชัน", style: TextStyle(fontSize: 20, color:Colors.white, shadows: [

                ],),))))
      ],)
    ),));

  }
  Future<void> _addRule(context) async {
    var shop  =this.phone+this.userkey.substring(
        this.userkey.length-5,this.userkey.length);

    return Firestore.instance
        .collection("pointrule")
        .document(shop)
        .setData({
      'adrule': "https://www.upoint.app/shopu/pic/0001_rule.png",
      'scoretype':"every10",

    })
        .then((value) => print('add point rule success')
    )
        .catchError((error) => print("Failed to add info: $error"));
  }
//Registration  need to add _businessinfo
  CheckDigit(dday){
    if (dday.length<2)
      return '0'+dday;
    else
      return dday;
  }
  _writeShop(BuildContext context){

    final firestoreInstance = Firestore.instance;

       String todaydate = DateTime.now().toString();
       var expire = DateTime.now().add(Duration (days:8));
       String expired = CheckDigit(expire.day.toString())+"-"+
           CheckDigit(expire.month.toString())+"-"+
           CheckDigit(expire.year.toString());
        dapplyexpire = expired;
       todaydate = todaydate.substring(0, 16);
       var shopid = phone+userkey.substring(userkey.length-5,userkey.length);

       firestoreInstance.collection("RegisteredBusiness").document(userkey).setData(

    //   firestoreInstance.collection(email).add(
           {
             "smobile": phone,
             "address": address,
             "shopname": name,
             "owner": owner,
             "email": email,
             "userkey": userkey,
             "location": location,
             'businesspic': 'https://www.upoint.app/shopu/pic/upointshop.png',
             "password": "justdemo",
             "regiswhen": todaydate,
             'expiretrial': expired,
             "paid": false,
             "emailconfirm": false,
             "shopid":shopid
           }).then((value) {
         //    print(customer + " Save point");
       });
     }

}
