import 'package:flutter/material.dart';

class ChipDemo extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _ChipDemoState();
}

class _ChipDemoState extends State<ChipDemo> {


  late GlobalKey<ScaffoldState> _key;
  late bool _isSelected;
  late List<CompanyWidget> _companies;
  late List<String> _filters;
  late List<String> _choices;
  late int _choiceIndex;
  String bioState = "";
  String mathState = "";
  String historyState = "";
  String artState = "";
  String humanGeoState = "";
  String civicsState = "";
  String physicsState = "";
  String elaState = "";
  String languageState = "";

  @override
  void initState() {
    super.initState();
    _key = GlobalKey<ScaffoldState>();
    _isSelected = false;
    _choiceIndex = 0;
    _filters = <String>[];
    _companies = <CompanyWidget>[
      CompanyWidget('Biology'),
      CompanyWidget('Math'),
      CompanyWidget('History'),
      CompanyWidget('Arts'),
      CompanyWidget('Human Geography'),
      CompanyWidget('Civics'),
      CompanyWidget('Chemistry'),
      CompanyWidget('Physics'),
      CompanyWidget('ELA'),
      CompanyWidget('Language Arts'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text("Chip Widget In Flutter"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Wrap(
              children: companyPosition.toList(),
            ),
          ],
        ),
      ),
    );
  }


  Iterable<Widget> get companyPosition sync* {
    for (CompanyWidget company in _companies) {
      yield Padding(
        padding: const EdgeInsets.all(2.0),
        child: FilterChip(
          backgroundColor: Colors.orangeAccent,
          avatar: CircleAvatar(
            backgroundColor: Colors.orange,
            child: Text(company.name[0].toUpperCase(),style: TextStyle(color: Colors.white),),
          ),
          label: Text(company.name,),
          selected: _filters.contains(company.name),selectedColor: Colors.redAccent,
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                if (company.name == "Biology") {
                  bioState = "yes";
                  print(bioState);
                  print(mathState);
                  print("state");
                }
                _filters.add(company.name);
              } else {
                bioState = "no";
                print(bioState);
                print(mathState);
                print("state2");
                _filters.removeWhere((String name) {
                  return name == company.name;
                });
              }
            });
          },
        ),
      );
    }
  }

}

class CompanyWidget {
  const CompanyWidget(this.name);
  final String name;
}