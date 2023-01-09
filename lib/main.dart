// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BreadCrumbProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: const MyHomePage(),
        routes: {
          '/new': (context) => const NewBreadCrumbWidget(),
        },
      ),
    );
  }
}

//? BreadCrumb App

class BreadCrumb {
  bool isActive;
  final String name;
  final String uuid;

  BreadCrumb({
    required this.isActive,
    required this.name,
  }) : uuid = const Uuid().v4();

  void activate() {
    isActive = true;
  }

  // bool operator == and hashCode
  //? check for equal equal
  // @override
  // bool operator ==(covariant BreadCrumb other) =>
  //  isActive == other.isActive && name == other.name;
  @override
  bool operator ==(covariant BreadCrumb other) => uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;
  // calculating the title
  String get title => name + (isActive ? ' >' : '');
}

// changenotifier that manages our breadcrumb
class BreadCrumbProvider extends ChangeNotifier {
  final List<BreadCrumb> _items = [];
  UnmodifiableListView<BreadCrumb> get items => UnmodifiableListView(_items);

  void add(BreadCrumb breadCrumb) {
    for (final item in _items) {
      item.activate();
    }
    _items.add(breadCrumb);
    notifyListeners();
  }

  void reset() {
    _items.clear();
    notifyListeners();
  }
}

// create an instance of our Breadcrumbprovider
// we'll use  ChangeNotifierProvider

typedef OnBreadCrumbTapped = void Function(BreadCrumb);

class BreadCrumbsWidget extends StatelessWidget {
  final OnBreadCrumbTapped onTapped;
  final UnmodifiableListView<BreadCrumb> breadCrumbs;
  const BreadCrumbsWidget({
    Key? key,
    required this.breadCrumbs,
    required this.onTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      //? not an arrow function??
      children: breadCrumbs.map((breadCrumb) {
        return GestureDetector(
          onTap: () {
            onTapped(breadCrumb);
          },
          child: Text(
            breadCrumb.title,
            style: TextStyle(
              color: breadCrumb.isActive ? Colors.blue : Colors.black,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Consumer<BreadCrumbProvider>(
            builder: (context, value, child) {
              return BreadCrumbsWidget(
                breadCrumbs: value.items, onTapped: (BreadCrumb ) {  },
              );
            },
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                '/new',
              );
            },
            child: const Text('Add new bread crumb'),
          ),
          TextButton(
            onPressed: () {
              context.read<BreadCrumbProvider>().reset();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class NewBreadCrumbWidget extends StatefulWidget {
  const NewBreadCrumbWidget({super.key});

  @override
  State<NewBreadCrumbWidget> createState() => _NewBreadCrumbWidgetState();
}

class _NewBreadCrumbWidgetState extends State<NewBreadCrumbWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add new bread crumb',
        ),
      ),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Enter a new bread crumb here...',
            ),
          ),
          TextButton(
            onPressed: () {
              final text = _controller.text;
              if (text.isNotEmpty) {
                final breadCrumb = BreadCrumb(isActive: false, name: text);
                context.read<BreadCrumbProvider>().add(breadCrumb);
                Navigator.of(context).pop();
              }
            },
            child: const Text(
              "Add",
            ),
          ),
        ],
      ),
    );
  }
}




 // NOTES ABOUT PROVIDER

            //? various ways of communicating with provider
            //?1 Read  -  used inside callbacks in a textbutton "contect.read()"
            // don't use it if you expecting a mutable value to change ui
            // us it for oneway 
            //?2 Select - "context.select()" 
            //similar to inherited model
            //used when you want to watch a specific aspect of a provider
            // only useful inside build() functions
            // changes to the selceted value will mark the widget as needing to be rebuilt
            // reubuilds your widget only if the given aspect of your provider changes (useful if large provider has many moving parts)
            // when provider emits an update, all selectors will be called
            
            //? 3 "context.watch()"
            // for watching changes to a provider
            // default value of listening is true
            // allows you to depend on an optional provider
            // is the same as Provider.of<T>(context) coz listen is true
            // should only be used inside build functions of stless widgets and build() functions of state
            //Outside build function? use provider.of<T> instead

            //? Consumer
            //consumes a provider and has a builder
            // creates a new widget and calls the builder with its own buildcontext
            // has a child widget that doesn't get rebuild when the provider changes
            // this chold gets passed to the builder of the consumer
            // and can be reused regardless of changes to the provider