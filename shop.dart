import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:upointshop/scanqr.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(

    ShopManagePageStateless());
class ShopManagePageStateless extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
        home:ShopManagePage(shopid:"1111111",shopname:'Gigi sri',
            smobile: '0818897915',businesspic:'https://www.upoint.app/shopu/pic/1111111.png',location:'Bangkok')
    );
  }

}

class ShopManagePage extends StatefulWidget {
  final String shopid;
  final String shopname;
  final String smobile;
  final String businesspic;
  final String location;
  const ShopManagePage({ Key key, this.shopid,this.shopname,
    this.smobile,this.businesspic,this.location }) : super(key: key);
  @override
  ShopManage createState()=> ShopManage();

}

class ShopManage extends State<ShopManagePage> {

  int point=0;
  int _selectedItem = 0, customerscore=0;
  String customer ="",search="", history="";
  PageController _pageview = new PageController();
  Record recordSave ;
  int savescore=0, usescore=0;
  TextEditingController scoremore = TextEditingController();
  TextEditingController _customercontroller = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  int incscore=0,decscore=0,savecustscore=0,usecustscore=0;
  String newuserkey="";
  @override
  void initState() {
    super.initState();
    _pageview = PageController();
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
    return MaterialApp(home:Scaffold(
      backgroundColor: Colors.white,

      appBar: PreferredSize(
          preferredSize: Size.fromHeight(200.0), // here the desired height
          child: Column( children:[
            //  Container(height:800,child:Text("U-Point",style: TextStyle(fontSize: 40),)),
            AppBar(elevation: 10,
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
                    child: Text('Shop Member - Upoint', style: TextStyle(fontSize:25,color: Colors.blue),)),backgroundColor: Colors.white,
                flexibleSpace:
                Column(children: [Padding(padding: EdgeInsets.all(25)),Container(height:150, child:
                Image.asset("images/tea.png",width:MediaQuery.of(context).size.width,height:50))
                ],) ),]
          )),
      body: // _buildBody(context),
      PageView(  scrollDirection: Axis.horizontal,
          controller: _pageview,
          children:[
            _homepage(context),
            _searchPoint(context),
            _statPointDay(context),
         //   _RegisterMember(context),

            //   _usePoint(context), list customer point

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
                icon: Icon(Icons.search,color: Colors.white),
                label: 'Search',

              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart,color: Colors.white),
                label: 'Stat',

              ),
    /*          BottomNavigationBarItem(
                icon: Icon(Icons.person, color: Colors.white),
                label: 'Register',
              ),*/
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



    ) );
  }
  movePage(int page){
    _pageview.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
  _statPointDay(BuildContext context) {
    getPoint();

    return Center(child: Column(children: [
      Text("สมาชิกสะสมแต้มวันนี้", style: TextStyle(fontSize: 20),),
      Text(savescore.toString(),style: TextStyle(fontSize: 85,color:Colors.blueAccent),),
      Text("สมาชิกแลกแต้มวันนี้", style: TextStyle(fontSize: 20)),
      Text(usescore.toString(),style: TextStyle(fontSize: 85,color:Colors.red),),

    ],),);



  }

  checkDigit(num){
    if (num.length <2){
      return "0"+num;
    }else
      return num;
  }
  Future getPoint() async {
    var today = checkDigit(DateTime.now().day.toString())+"-"+
        checkDigit(DateTime.now().month.toString())+"-"+
        checkDigit(DateTime.now().year.toString());
    print("shop "+widget.shopid);
    Firestore.instance
        .collection("counterpoint")
        .where('shopid', isEqualTo: widget.shopid)
        .where('dpoint', isEqualTo: today)

        .getDocuments().then(
            (snapshot) {
          for (DocumentSnapshot ds in snapshot.documents) {
            setState(() {
              savescore= ds.data['point'];
              usescore =ds.data['exchange'];
              return;
            });
          };

        })
        .catchError((error) => print("Can't find the business: $error"));

  }

  _RegisterMember(BuildContext context){

    return SingleChildScrollView(
        child: Column(

          children: <Widget>[
            Text('ขั้นตอนในการลงทะเบียน', style: TextStyle(fontSize: 20,color:Colors.blueAccent),),
            Padding(padding: EdgeInsets.only(top:10)) ,
            Container(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: phoneController,
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

            Text("ดูนโยบายและเงื่อนไขการให้บริการ"),
            IconButton(icon:Icon(Icons.receipt),
              onPressed: (){_showPolicy(context);},
            ),
            Padding(padding:EdgeInsets.only(bottom:10)),
            Container(
                width:MediaQuery.of(context).size.width/2,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green,
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child:
                FlatButton(
              onPressed: (){
      if (phoneController.value.text.toString()!="" &&
          emailController.value.text.toString()!="" &&
          nameController.value.text.toString()!="") {
        AddCustomer(phoneController.value.text.toString(),
            nameController.value.text.toString(),
            emailController.value.text.toString(),
            widget.shopid);
        _showAlert(context,
            "ลงทะเบียนสำเร็จแล้ว กรุณาแจ้งกุญแจการใช้บริการกับลูกค้า \n หมายเลขกุญแจคือ " +
                newuserkey);
      }else
        _showAlert(context,'ลงทะเบียนไม่สำเร็จ จะต้องกรอกข้อมูลให้ครบถ้วน!!');

    } ,
    child:Column(children:[
            Text("ลงทะเบียน",style: TextStyle(color:Colors.white),),
            IconButton(icon: Icon(Icons.app_registration,color:Colors.white),
                onPressed: null)

                ]),

        ))
          ]));
  }
  AddCustomer(phone,name,email,shop) {

    CollectionReference custinfo = Firestore.instance.collection(
        'customer');
    String apply =  checkDigit(DateTime.now().day.toString())+"-"+
        checkDigit(DateTime.now().month.toString())+"-"+
        checkDigit(DateTime.now().year.toString());
    String usekey = phone+checkDigit(DateTime.now().day.toString())+
        checkDigit(DateTime.now().month.toString())+
        checkDigit(DateTime.now().year.toString())+
        checkDigit(DateTime.now().hour.toString())+
        checkDigit(DateTime.now().minute.toString());
    setState(() {
      newuserkey = usekey;
    });
    return custinfo
        .add({
      'name': name,
      'phone': phone,
      'email': email,
      'apply':apply,
      'userkey': usekey,
      'shop':shop

    })
        .then((value) => print("Add customer  info Added"))
        .catchError((error) => print("Failed to add info: $error"));
  }

  _showAlert(context,msg) {
    return showDialog(
        context: context,
        builder: (BuildContext context)
        {
          return AlertDialog(
              title: new Text('ผลการลงทะเบียนสมาชิก'),
              content: Text(msg),
              actions: <Widget>[
                IconButton(
                  icon:Icon(Icons.close),
                  onPressed: (){
                    Navigator.pop(context);
                    phoneController.text="";
                    emailController.text="";
                    nameController.text="";
                   // movePage(0);
                  },
                )]);});

  }
  _showPolicy(context){
    TextEditingController policyController = new TextEditingController(text:
    'นโยบายการคุ้มครองข้อมูลส่วนบุคคล (Privacy & Policy)\n'+
        'บริษัท อินเทลลิคซ์ซอฟต์ จำกัด (ซึ่งต่อไปนี้จะเรียกว่า "บริษัทฯ") ผู้พัฒนาแอพพลิคชัน Upoint (ซึ่งต่อไปนี้จะเรียกว่า "บริการ")\n'+
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
        'บริษัทฯ อาจมีการเก็บข้อมูลการใช้บริการ เช่น การสะสมคะแนน การใช้คูปองส่วนลด การจัดส่งสินค้า เพื่อสิทธิประโยชน์ของลูกค้า'+
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

        '4. การแจ้งข่าวสาร/การแจ้งเตือน\n'+
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

    return showDialog(
        context: context,
        builder: (BuildContext context)
        {
          return AlertDialog(
              title: new Text("นโยบายและเงื่อนไขการให้บริการ",style: TextStyle(color:Colors.blue),),
              content: new SingleChildScrollView(
              scrollDirection: Axis.vertical,

        //reverse: true,

        // here's the actual text box
        // here's the actual text box
        child:  TextField(
                minLines: null,
                showCursor: true,
                readOnly: true,
                //scrollPadding: EdgeInsets.only(right:0.0),
                controller:policyController,
                maxLines: null,)),
              actions: <Widget>[
               Container(width:MediaQuery.of(context).size.width,child: IconButton(
                  icon:Icon(Icons.close),
                  onPressed: (){
                    Navigator.pop(context);
                  },
               ))]);});
  }


  _searchPoint(BuildContext context){

    return Container (child:SingleChildScrollView(child:

    Container(
        child:Column(children: [
          Text('ค้นหาคะแนนสะสมสมาชิก'),
          Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(

                borderRadius: BorderRadius.circular(15),
                border: Border.all(color:Colors.blue)
            ),
            child: TextField(
              controller: _customercontroller,
              decoration: InputDecoration(
                //     border: OutlineInputBorder(),
                labelText: 'หมายเลขโทรศัพท์สมาชิก',
              ),
            ),),
          Column(children:[
            Container(
              width:MediaQuery.of(context).size.width/2,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue,
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child:

              FlatButton(onPressed: (){
                checkScoreMember(_customercontroller.value.text.toString(), widget.shopid,
                    false);
                checkScoreMember(_customercontroller.value.text.toString(), widget.shopid,
                    true);
              },
                  child: Column(children:[
                    Text('ค้น', style:TextStyle(color:Colors.white, fontWeight:FontWeight.bold ))
                    ,
                    IconButton(icon: Icon(Icons.search,color: Colors.white,),
                        onPressed: (){
                          checkScoreMember(_customercontroller.value.text.toString(), widget.shopid,
                              false);
                          checkScoreMember(_customercontroller.value.text.toString(), widget.shopid,
                              true);

                        }

                    )
                  ])
              )),

          ]),
          Text("แต้มสะสมของสมาชิก "+_customercontroller.value.text.toString()),
          Text(savecustscore.toString(), style: TextStyle(fontSize: 85,color:Colors.blue),),
          Text("ใช้ไปแล้ว"),
          Text(usecustscore.toString(), style: TextStyle(fontSize: 85,color:Colors.red),),

        ],))));
  }
  Future checkScoreMember(customer,shopid,flag) async{
    var respectsQuery = Firestore.instance
        .collection(customer+"_point")
        .where('phone', isEqualTo: customer)
        .where('shopid', isEqualTo: shopid);

    var querySnapshot = await respectsQuery.getDocuments();

    for (DocumentSnapshot ds in querySnapshot.documents){
      setState(() {
        savecustscore = ds.data['point'];
        usecustscore = ds.data['exchange'];
      });
    }

    if (flag==false)
      return savecustscore;
    else
      return  usecustscore;

  }




  _homepage(BuildContext context){
    return //Column(children:[
      // Text("Upoint แพ็กเกจ EasyPoint\n ยินดีต้อยรับเข้าสู่ระบบจัดการคะแนนสำหรับร้ายค้า \n มีปัญหาในการใช้บริการติดต่อที่ upoint@kidlovescode.com\n"),
      _buildShopInfo();

    //]);
  }

  Widget _buildShopInfo() {

    return SingleChildScrollView(

      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(

          child: Container(
              child:Column(children: [
                Padding(padding: EdgeInsets.only(top:8),child:  Text("ชื่อธุรกิจ:"+widget.shopname),),
                Padding(padding: EdgeInsets.only(top:8),child:  Text("ที่ตั้ง:"+widget.location),),
                //  Padding(padding: EdgeInsets.only(top:8),child:  Text("สมาชิกเลขที่:"+record.shopid),),

                Padding(padding: EdgeInsets.only(top:8),child:  Image.network(widget.businesspic,width:200,height:200),),
                Text('ไประบบ Upoint service'),
                IconButton(icon:Icon(Icons.web),
                  onPressed: (){
                    launch("https://www.upoint.app/home/") ;
                  },
                ),
                Padding(padding: EdgeInsets.only(bottom:20)),
                Column(children:[   Container(
                    width:MediaQuery.of(context).size.width/2,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber[700],
                      border: Border.all(color: Colors.amber),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child:

                    FlatButton(onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => QRViewExample(store:widget.shopid,location:widget.location,shopname:widget.shopname,businesspic:widget.businesspic)),
                      );

                    },
                        child: Column(children:[
                          Text('อ่าน QR code', style:TextStyle(color:Colors.white, fontWeight:FontWeight.bold ))
                          ,
                          IconButton(icon: Icon(Icons.qr_code,color: Colors.white,),
                              onPressed: null)
                      ])
                    )),

                ])
              ],)
          )
      ),
    );
  }

  //Widget _
  // buildBody(BuildContext context) {
  Widget _buildBody(String search) {

    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection(search).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return  _buildList(context, snapshot.data.documents);
      },
    );
  }


  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return
      ListView(
        padding: const EdgeInsets.only(top: 20.0),
        children: snapshot.map((data) => _buildListItem(context, data)).toList(),
      );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);
    recordSave = record;
    customerscore++;
    return Padding(
      key: ValueKey(record.umobile),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
              child:Column(children: [
                //    Padding(padding: EdgeInsets.only(top:8),child:  Text("CID:"+record.umobile+": แต้มที่ "+customerscore.toString()),),
                Container(child:Row(children: [
                  Expanded(child:Container(padding:EdgeInsets.only(left:10),child:Text(record.buydate+":"+record.location))),
                  FlatButton(child: Image.asset('images/upointscore.jpeg' ,width:70),
                    onPressed: (){
                      //Alert to confirm delete
                      record.reference.updateData({'delete': true}); },)
                ],))


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
class RecordShopInfo {
  final String smobile, shopname,shopid,location,businesspic;
  final DocumentReference reference;

  RecordShopInfo.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['smobile'] != null),
        assert(map['shopname'] != null),
        assert(map['shopid'] != null),
        assert(map['location'] != null),
        assert(map['businesspic'] != null),


        smobile = map['smobile'],
        shopname = map['shopname'],
        shopid = map['shopid'],
        location = map['location'],
        businesspic= map['businesspic'];



  RecordShopInfo.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$smobile:$shopname:$shopid:$location:$businesspic>";
}