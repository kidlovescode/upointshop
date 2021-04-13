import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upointshop/EncryptQrCode.dart';


//void main() => runApp(Register());
void main()=> runApp(QrPage(
phone: "1111111",userkey:"324324324532432",apply:'09-04-2021'));
class Register extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        //  primarySwatch: Colors.indigo,
      ),
      home: SignInPage(),
    );
  }
}


class SignInPage extends StatefulWidget {
  SignInPageState createState()=> SignInPageState();
}
class SignInPageState extends State<SignInPage>{
  List<String> information=[];
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController ruleController = TextEditingController();

  Future<void> _signInAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }
  @override
  initState(){
    readApply("Upointrule","registercustomer");

  }
  Future readApply(collectionname,what) async {


    final firestoreInstance = Firestore.instance;
    firestoreInstance.collection(collectionname)
        .document(what)
        .get()
        .
    then((querySnapshot) {
      if (querySnapshot.exists)
        querySnapshot.data.forEach((key, value) {
          if (key=='custregister' ) {
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: PreferredSize(

          preferredSize: Size.fromHeight(200.0), // here the desired height
          child: Column( children:[
            //  Container(height:800,child:Text("U-Point",style: TextStyle(fontSize: 40),)),
            AppBar(
              backgroundColor: Colors.white,
                flexibleSpace:
                Column(children: [Padding(padding: EdgeInsets.all(25)),
                  Container(height:150, child: Image.asset("images/upoint.png",width:MediaQuery.of(context).size.width,height:50))
                ],) ),]
          )),
      body:
      SingleChildScrollView(
          child: Container(height:2000,width:400,child:Column(

            children: <Widget>[
              Column(children: [
                Text("คำแนะนำในการลงทะเบียน", style: TextStyle(fontSize: 20, color:Colors.blue,
                    fontWeight: FontWeight.bold)),

                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),

                    ),
                    child:IconButton(
                        icon: Icon(Icons.help),
                        onPressed:(){
                          showPointRule(context,"registercustomer");
                        })),
              ],) ,

              Padding(padding: EdgeInsets.only(top:15)) ,
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
                    labelText: 'หมายเลขโทรศัพท์สำหรับสะสมแต้ม',
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'ชื่อ-สกุล/ชื่อเล่น',
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'email สำหรับการส่งเสริมการขาย',
                  ),
                ),
              ),

              Padding(padding:EdgeInsets.only(bottom:15)),
              Container(
                  height: 85, width: 360,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child:  Container(
                      height:85,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: Colors.blue,

                      ),

                      child:FlatButton(
                        textColor: Colors.white,
                        color: Colors.blue,
                        child: Text('หน้าถัดไป', style: TextStyle(fontSize: 20),),
                        onPressed: () {
                          if (phoneController.value.text.toString()!=""&&
                              nameController.value.text.toString()!=""&&
                              emailController.value.text.toString()!="")
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => PolicyPage(
                                  phone: phoneController.value.text.toString(),
                                  name: nameController.value.text.toString(),
                                  email: emailController.value.text.toString()))) ;
                        else{
                            _showAlert(context, "จะต้องกรอกข้อมูลให้ครบถ้วน !!!");

                          }
                        },
                      ))),
              IconButton(icon: Icon(Icons.home), onPressed: (){
                 Navigator.pop(context);
              })

            ],
          )),
      )
    )

    ;
  }

  _showAlert(context,msg) {
    return showDialog(
        context: context,
        builder: (BuildContext context)
        {
          return AlertDialog(
              title: new Text('แจ้งเตือน'),
              content: Text(msg),
              actions: <Widget>[
                IconButton(
                  icon:Icon(Icons.close),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                )]);});

  }
  Widget showPointRule(BuildContext context,what){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(

              content:   SingleChildScrollView(
              scrollDirection: Axis.vertical,
             child:
              Container(
                  width:450,height:1700,
                  child:Column(children:[

                Container(padding: EdgeInsets.all(10),
                    child: Text("ข้อมูล/เงื่อนไขการบริการ",
                      style: TextStyle(fontSize: 20, color: Colors.red,fontWeight: FontWeight.bold),)),
                FutureBuilder(
                    future: readPointRule("Upointrule",what),
                    builder: (context, rule) {
                      return Text(ruleController.value.text.toString());
                    }),

              Container(width:450,height:460,child:

                    information.length>1?writeRuleInfo(context):Padding(padding:EdgeInsets.only(left:2),child:Text('โหลดข้อมูล...ลองเปิดใหม่อีกครั้ง'))),
                    Container(padding: EdgeInsets.all(10),
                        child: IconButton(
                          icon:Icon(Icons.close),
                          color: Colors.blueAccent,
                          padding: EdgeInsets.all(25),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )),
             //   what=="registercustomer"&&information.length>1?
             //   Image.network(information[information.length-1]):Padding(padding:EdgeInsets.only(left:2)),



              ]
              ) )));
        });



  }
  writeRuleInfo(context){
    return Scrollbar(

        child:ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: information.length,
        itemBuilder: (BuildContext context, int index) {
        //  print(information[index]);
          if (index == information.length - 1)
            return Container(
              // height: 100, width:450,
              child: Center(child: Image.network(information[index], height:370)),
            );
          else
          return Container(
           // height: 100, width:450,
            child: Center(child: Text(information[index].toString())),
          );
        }
    ) );
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

          if (key=='custregister' ) {
            var info = value.split("#");
            setState(() {
              information = info;

              ruleController.text = "บริการ Upoint แอพพลิเคชัน";
            });
            return true;
          }



        });

    });

  }
}


class PolicyPage extends StatefulWidget {
  final String name;
  final String  phone;
  final String email;

  PolicyPage({Key key, this.phone, this.name, this.email}) : super(key: key);


  @override
  PolicyPageState createState()=> PolicyPageState();

}

class PolicyPageState extends State<PolicyPage>{
  String usergeneratedkey="";
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
            showCursor: true,
            readOnly: true,
            maxLines: null ,
            decoration: InputDecoration(
              border: OutlineInputBorder(),

            ),
          )
      )
      ,floatingActionButton: FloatingActionButton.extended(
      onPressed: () {

        AddCustomer(widget.phone, widget.name, widget.email);
        writeUserKey(widget.phone,usergeneratedkey);

        Navigator.push(context, MaterialPageRoute(
            builder: (context) =>QrPage(
                phone: widget.phone,userkey:usergeneratedkey,apply:apply) ));

        // Add your onPressed code here!
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

  }
  checkDigit(String numberd){
    if(numberd.length==1){
      return "0"+numberd;

    }else
      return numberd;
  }

  AddCustomer(phone,name,email) {

    CollectionReference custinfo = Firestore.instance.collection(
        'customer');
    String apply =  checkDigit(DateTime.now().day.toString())+"-"+
        checkDigit(DateTime.now().month.toString())+"-"+
        checkDigit(DateTime.now().year.toString());
    setState(() {
      this.apply = apply;
    });
    String usekey = phone+checkDigit(DateTime.now().day.toString())+
        checkDigit(DateTime.now().month.toString())+
        checkDigit(DateTime.now().year.toString())+
        checkDigit(DateTime.now().hour.toString())+
        checkDigit(DateTime.now().minute.toString());
     setState(() {
       usergeneratedkey = usekey;
     });
    return custinfo
        .add({
      'name': name,
      'phone': phone,
      'email': email,
      'apply':apply,
      'userkey': usekey,
      'shop':"N/A"

    })
        .then((value) => print("Add customer  info Added"))
        .catchError((error) => print("Failed to add info: $error"));
  }

}

class QrPage extends StatefulWidget {
  bool registered = false;
  final String phone;
  final String userkey;
  final String apply;

  QrPage({Key key, this.phone, this.userkey, this.apply}) : super(key: key);

  //check ถ้าร้านค้ารับลงทะเบียนแล้ว shopid ใน firebase จะไม่ใช่ N/a
  @override
  QRpageState createState() => QRpageState();
}
class QRpageState  extends State<QrPage>{
  bool registerstate = false;
  _genQr(BuildContext context){
    EncryptQrCode eq = new EncryptQrCode(customer:
    widget.phone,userkey:widget.userkey,shop:"N/A",what:"register");
    final encryptcode =  eq.showData();
    //created   share prefere ,set unenable to register
    return MaterialApp(
        home:Scaffold(
            body:
      Container (
         width:MediaQuery.of(context).size.width,
          child:Column(
              children:[
                //  Text(customer+":"+shop, style: TextStyle(fontSize: 20),),
                QrImage(
                  data: encryptcode,
                  version: QrVersions.auto,
                  size: 300,
                  padding:EdgeInsets.all(50),
                ),
                Text("ให้ร้านค้าสแกน แล้วเข้าสู่ระบบใหม่", style: TextStyle(fontSize: 20),),
                Container(
                    width: 250,
                    child: IconButton(icon: Icon(Icons.home), onPressed: (){
                     // Navigator.pop(context);
                      var count = 0;
                      Navigator.popUntil(context, (route) {
                        return count++ == 3;
                      });

                    }))
                //checkRegister(context),
               // registerstate==false?Text("รอผลการลงทะเบียน"):Text(""),
                 ]))));
  }
    checkRegister(context) async{

    Firestore.instance
         .collection("customer")
         .where('phone', isEqualTo: widget.phone)
         .where('userkey', isEqualTo: widget.userkey)
         .where('dpoint', isEqualTo: widget.apply)
         .getDocuments().then(
             (snapshot) {
           for (DocumentSnapshot ds in snapshot.documents){
             if (ds.data['shop']!="N/A"){
               setState(() {
                 registerstate= true;
                 //write sharepreference
               });
               return;
             }

           };
         })

         .catchError((error) => print("Failed to find registered info point: $error"));
    if (registerstate ==false){
       return Text("รอสักครู่...");

    }else{
      return FlatButton(
          onPressed: (){
            Navigator.pop(context);
          },
          child:Text("การลงทะเบียนสำเร็จแล้วกรุณาเข้าสู่ระบบใหม่"));

    }

   }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home:Scaffold(
        appBar: AppBar(
          title: Text('ลงทะเบียนกับร้านค้า'),

        ),
        body:_genQr(context)
    ));
  }
}
