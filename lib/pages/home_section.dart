import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedding/main.dart';
import 'package:wedding/pages/login_screen.dart';
import 'package:wedding/pages/payment_screen.dart';
import 'package:wedding/pages/schedule_section.dart';
import 'package:wedding/pages/upload_section.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class home_section extends StatefulWidget {
  home_section({required this.indexSearch});
  final String indexSearch;
  @override
  State<home_section> createState() => _home_sectionState();
}

class _home_sectionState extends State<home_section> {
  bool isUserLoggedIn = false;
  String uid = "";
  Future getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user_uid = prefs.getString('uid') ?? '';
    final bool _isUserLoggedIn = prefs.getBool('isUserLoggedIn') ?? false;
    setState(() {
      uid = user_uid;
      isUserLoggedIn = _isUserLoggedIn;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  int number = 1;
// String word = numberToWord[number];

  bool _isHidden = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: pinkColor,
          elevation: 0.1,
          title: const Text("الصفحة الرئيسية"),
          leading: IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const schedule_section()));
              },
              icon: const Icon(Icons.schedule)),
          actions: [
            Row(children: [
              isUserLoggedIn == true
                  ? Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const upload_section()));
                            },
                            icon: const Icon(Icons.upload)),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                isUserLoggedIn = false;
                              });
                            },
                            icon: Icon(Icons.person_off))
                      ],
                    )
                  : IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => login_section(
                                  indexSearch: widget.indexSearch
                                )));
                      },
                      icon: Icon(Icons.person))
            ]),
            IconButton(
                onPressed: () {
                  setState(() {
                    _isHidden = !_isHidden;
                  });
                },
                icon: const Icon(Icons.search)),
          ]),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isHidden)
              Directionality(
                textDirection: TextDirection.rtl,
                child: TextFormField(
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                      labelText: "البحث",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20))),
                ),
              ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("indexcollection")
                    .where('type', isEqualTo: widget.indexSearch)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Text('Loading...');
                  }
                  final products = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final List<dynamic> imageUrls = product['image_url'];
                      final imageUrl = imageUrls.first;

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) =>
                                      payment_screen(productname: product))));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.only(bottom: 5),
                          padding: const EdgeInsets.only(
                            top: 5,
                            bottom: 2,
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Image.network(imageUrl)),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                               Expanded(child: Container()),
                                 Text(
                                      product["name"],
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  Expanded(child: Container()),
                                  
                        isUserLoggedIn == true
                         ? IconButton(
                                       onPressed: () async {
                                                    await FirebaseFirestore.instance
                                                        .collection('indexcollection')
                                                        .doc(product.id)
                                                        .delete();
                                                  },
                                      icon: Icon(Icons.delete))
                                      : Container()
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Divider(color: Colors.black, height: 2),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
