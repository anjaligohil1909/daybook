import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:daybook/Services/entryService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daybook/Pages/EnlargedImage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
// import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:daybook/Pages/pdf_preview.dart';
import 'package:open_file/open_file.dart';

class DisplayEntryScreen extends StatefulWidget {
  @override
  _DisplayEntryScreenState createState() => _DisplayEntryScreenState();
}

class _DisplayEntryScreenState extends State<DisplayEntryScreen> {
  Future<File> generatePDF(DocumentSnapshot doc) async {
    final pdf = pw.Document();
    final fontData = await rootBundle.load('assets/fonts/OpenSans-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    // final imagePaths = doc['imageURLs']
    // final image = pw.MemoryImage(
    //   File(imagePath).readAsBytesSync(),
    // );
    //

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Center(
              child: pw.Column(children: [
            pw.Text(doc['title'].toString(),
                style: pw.TextStyle(fontSize: 50, font: ttf)),
            pw.Text(doc['content'].toString(),
                style: pw.TextStyle(fontSize: 30, font: ttf)),
            // Image.file(File(imagePath))
            // pw.Image(image)
          ]))
        ],
      ),
    );

    final output2 = (await getExternalStorageDirectory()).path;
    String pdfName = doc['title'] + "_" + doc['dateCreated'].toString();
    File file = File('$output2/$pdfName.pdf');
    final doesExist = await file.exists();

    if (!doesExist) {
      file = await file.create();
    } else {
      pdfName = doc['title'] + "_" + DateTime.now().toString();
    }
    print("PdfName = $pdfName");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  final Map<String, Color> colorMoodMap = {
    "Terrible": Color(0xffa3a8b8), //darkgrey
    "Bad": Color(0xffcbcbcb), //grey
    "Neutral": Color(0xfffdefcc), //yellow
    "Good": Color(0xffffa194), //red
    "Wonderful": Color(0xffadd2ff) //blue
  };

  final Map<String, String> moodText = {
    "Terrible": "Terrible 😭",
    "Bad": "Bad 😥",
    "Neutral": "Neutral 🙂",
    "Good": "Good 😃",
    "Wonderful": "Wonderful 😁"
  };

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;
    // var padding = MediaQuery.of(context).padding;
    var appbarHeight = AppBar().preferredSize.height;
    // double newheight = height - padding.top - padding.bottom - appbarHeight;

    final arguments =
        ModalRoute.of(context).settings.arguments as List<dynamic>;
    DocumentSnapshot documentSnapshot = arguments[0];
    List<dynamic> imageUrls = documentSnapshot["images"];
    print("checking :" + documentSnapshot['title']);
    print("checking :" + documentSnapshot.toString());

    Widget _imagesGrid() {
      return Container(
        height: 140,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.count(
            scrollDirection: Axis.horizontal,
            crossAxisSpacing: 2,
            mainAxisSpacing: 4,
            crossAxisCount: 1,
            children: List.generate(imageUrls.length, (index) {
              return Column(
                children: <Widget>[
                  GestureDetector(
                    onLongPress: () {
                      print("Long Press Registered !!!");
                      setState(() {
                        imageUrls.removeAt(index);
                      });
                    },
                    onTap: () {
                      print("Tap registered !!");
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return EnlargedImage(imageUrls[index], true);
                      }));
                    },
                    child: Container(
                        height: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          child: CachedNetworkImage(
                            imageUrl: imageUrls[index] == ""
                                ? 'https://picsum.photos/250?image=9'
                                : imageUrls[index],
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) => Container(
                              child: Center(
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    value: downloadProgress.progress,
                                    strokeWidth: 2.0,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        )),
                  ),
                ],
              );
            }),
          ),
        ),
      );
    }

    return SafeArea(
        child: Scaffold(
            // resizeToAvoidBottomPadding: false,
            body: Container(
      height: double.infinity,
      width: double.infinity,
      child: Stack(children: [
        SingleChildScrollView(
            child: Stack(children: [
          Column(
            children: [
              Container(
                  width: width,
                  decoration: new BoxDecoration(
                    color: colorMoodMap[documentSnapshot['mood']],
                    // boxShadow: [new BoxShadow(blurRadius: 10.0)],
                    borderRadius: new BorderRadius.vertical(
                        bottom: new Radius.elliptical(width, 40.0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(Icons.arrow_back),
                            ),
                          ),
                          Container(
                            height: appbarHeight,
                            child: Row(children: [
                              GestureDetector(
                                onTap: () async {
                                  await HapticFeedback.vibrate();
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => AlertDialog(
                                      title: Text("Detele Entry ?"),
                                      content: Text(
                                        "This will delete the Entry permanently.",
                                      ),
                                      actions: <Widget>[
                                        Row(
                                          children: [
                                            FlatButton(
                                              onPressed: () {
                                                deleteEntry(documentSnapshot);
                                                Navigator.of(context).pop();
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("Delete"),
                                            ),
                                            FlatButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("Cancel"),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 25),
                              Builder(builder: (BuildContext context) {
                                return GestureDetector(
                                    child: Icon(
                                      Icons.download_outlined,
                                      size: 20,
                                    ),
                                    onTap: () async {
                                      File newfile =
                                          await generatePDF(documentSnapshot);
                                      bool val = await newfile.exists();
                                      print(val);
                                      if (val == true) {
                                        final snackBar = SnackBar(
                                          content: Text('Entry Downloaded !'),
                                          action: SnackBarAction(
                                            label: 'Open PDF',
                                            onPressed: () async {
                                              // Navigator.push(
                                              //     context,
                                              //     MaterialPageRoute(
                                              //         builder: (BuildContext
                                              //                 context) =>
                                              //             PdfPreviewScreen(
                                              //                 path: newfile
                                              //                     .path)));
                                              // var sharePdf =
                                              //     await newfile.readAsBytes();
                                              // await Share.shareFiles(
                                              //     ["${newfile.path}"]);
                                              final result =
                                                  await OpenFile.open(
                                                      newfile.path);
                                            },
                                          ),
                                        );
                                        Scaffold.of(context)
                                            .showSnackBar(snackBar);
                                      }
                                    });
                              }),
                              //   },
                              // ),
                              SizedBox(
                                width: 25,
                              ),
                              GestureDetector(
                                child: Icon(
                                  Icons.share_outlined,
                                  size: 20,
                                ),
                                onTap: () {
                                  String subject =
                                      documentSnapshot['title'].toString();
                                  String text = '*' +
                                      subject +
                                      '*' +
                                      "\n\nFeeling " +
                                      documentSnapshot['mood'].toString() +
                                      "\n\n" +
                                      documentSnapshot['content'].toString();
                                  Share.share(text);
                                },
                              ),
                              SizedBox(
                                width: 15,
                              ),
                            ]),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              documentSnapshot['title'],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.getFont(
                                'Merriweather',
                                color: Colors.grey[900],
                                fontSize: 25,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Feeling " + moodText[documentSnapshot['mood']],
                            style: GoogleFonts.getFont(
                              'Lora',
                              color: Colors.grey[700],
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Chip(
                            label: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                "${DateFormat.yMMMMd().format(DateTime.parse(documentSnapshot['dateCreated']))}  ${DateFormat.jm().format(DateTime.parse(documentSnapshot['dateCreated']))}",
                                style: GoogleFonts.getFont(
                                  'Oxygen',
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            // avatar: Icon(Icons.alarm),
                            backgroundColor: Color(0xffffe9b3),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      )
                    ],
                  )),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22.0),
                child: Text(
                  documentSnapshot['content'],
                  softWrap: true,
                  style: GoogleFonts.getFont(
                    'Nunito',
                    color: Colors.black87,
                    fontSize: 17,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              SizedBox(
                height: 25.0,
              ),
              imageUrls.length != 0
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: _imagesGrid(),
                    )
                  : SizedBox(
                      height: 1,
                    ),
            ],
          ),
        ])),
        Positioned(
          bottom: 15,
          right: 15,
          child: FloatingActionButton(
            backgroundColor: Color(0xffd68598),
            child: Icon(
              Icons.edit_outlined,
            ),
            onPressed: () => {
              Navigator.popAndPushNamed(context, '/createEntry',
                  arguments: [documentSnapshot])
            },
          ),
        ),
      ]),
    )));
  }
}