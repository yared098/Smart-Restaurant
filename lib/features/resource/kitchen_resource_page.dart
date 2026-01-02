// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:smart_restaurant/core/providers/resource_provider.dart';


// class KitchenResourcePage extends StatefulWidget {
//   @override
//   _KitchenResourcePageState createState() => _KitchenResourcePageState();
// }

// class _KitchenResourcePageState extends State<KitchenResourcePage> {
//   Map<String, int> selectedItems = {}; // resourceId -> quantity

//   @override
//   void initState() {
//     super.initState();
//     final provider = Provider.of<ResourceProvider>(context, listen: false);
//     provider.fetchResources();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Kitchen Resources")),
//       body: Consumer<ResourceProvider>(
//         builder: (context, provider, _) {
//           if (provider.loading) return Center(child: CircularProgressIndicator());

//           if (provider.resources.isEmpty) return Center(child: Text("No resources available"));

//           return ListView(
//             children: provider.resources.map((res) {
//               selectedItems.putIfAbsent(res['id'], () => 0);

//               return Card(
//                 margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//                 child: ListTile(
//                   title: Text(res['name']),
//                   subtitle: Text("Available: ${res['quantity']} ${res['unit']}"),
//                   trailing: SizedBox(
//                     width: 100,
//                     child: TextField(
//                       keyboardType: TextInputType.number,
//                       decoration: InputDecoration(
//                         hintText: "0",
//                         border: OutlineInputBorder(),
//                         contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       ),
//                       onChanged: (val) {
//                         setState(() {
//                           selectedItems[res['id']] = int.tryParse(val) ?? 0;
//                         });
//                       },
//                     ),
//                   ),
//                 ),
//               );
//             }).toList(),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         label: Text("Send Request"),
//         icon: Icon(Icons.send),
//         onPressed: () async {
//           final provider = Provider.of<ResourceProvider>(context, listen: false);

//           // Build list of items with quantity > 0
//           final itemsToSend = selectedItems.entries
//               .where((e) => e.value > 0)
//               .map((e) => {"resourceId": e.key, "quantity": e.value})
//               .toList();

//           if (itemsToSend.isEmpty) {
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Select at least 1 resource")));
//             return;
//           }

//           try {
//             await provider.createRequest(itemsToSend, note: "Kitchen request");
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Request sent")));
            
//             // Reset selected quantities
//             setState(() {
//               selectedItems = {};
//             });
//           } catch (e) {
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to send request")));
//           }
//         },
//       ),
//     );
//   }
// }
