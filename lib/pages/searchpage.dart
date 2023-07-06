// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:provider/provider.dart';
// import 'package:cfdata/pages/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SearchScreen extends StatefulWidget {
//   @override
//   _SearchScreenState createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   final TextEditingController _handleController = TextEditingController();
//   List<UserRating> _savedRatings = [];
//   List<UserRating> _searchResults = [];

//   Future<void> _fetchRating(String handle) async {
//     final String apiUrl = 'https://codeforces.com/api/user.rating?handle=$handle';

//     try {
//       final response = await http.get(Uri.parse(apiUrl));
//       final responseData = jsonDecode(response.body);

//       if (responseData['status'] == 'OK') {
//         final ratingChanges = responseData['result'];
//         if (ratingChanges != null && ratingChanges is List && ratingChanges.isNotEmpty) {
//           final latestRating = ratingChanges.last['newRating'] as int;
//           final userRating = UserRating(handle: handle, rating: latestRating);

//           // Save the user handle and rating to local storage
//           final prefs = await SharedPreferences.getInstance();
//           prefs.setString('user_handle', handle);
//           prefs.setInt('user_rating', latestRating);

//           Provider.of<UserRatingProvider>(context, listen: false).addUserRating(userRating);
//           setState(() {
//             _savedRatings.add(userRating);
//           });
//         } else {
//           setState(() {
//             _searchResults = [];
//           });
//         }
//       } else {
//         setState(() {
//           _searchResults = [];
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _searchResults = [];
//       });
//     }
//   }

//   void _saveRating(String handle, int rating) async {
//     final userRating = UserRating(handle: handle, rating: rating);
//     // Save the user handle and rating to local storage
//     final prefs = await SharedPreferences.getInstance();
//     prefs.setString('user_handle', handle);
//     prefs.setInt('user_rating', rating);

//     setState(() {
//       _savedRatings.add(userRating);
//       _searchResults = [];
//     });

//     Provider.of<UserRatingProvider>(context, listen: false).addUserRating(userRating);
//   }

//   Future<void> _searchUsers(String query) async {
//     if (query.isNotEmpty) {
//       final String apiUrl = 'https://codeforces.com/api/user.ratedList?handle=$query';

//       try {
//         final response = await http.get(Uri.parse(apiUrl));
//         final responseData = jsonDecode(response.body);

//         if (responseData['status'] == 'OK') {
//           final users = responseData['result'];
//           if (users != null && users is List && users.isNotEmpty) {
//             setState(() {
//               _searchResults = users
//                   .map((user) => UserRating(
//                         handle: user['handle'],
//                         rating: user['rating'],
//                       ))
//                   .toList();
//             });
//           } else {
//             setState(() {
//               _searchResults = [];
//             });
//           }
//         } else {
//           setState(() {
//             _searchResults = [];
//           });
//         }
//       } catch (e) {
//         setState(() {
//           _searchResults = [];
//         });
//       }
//     } else {
//       setState(() {
//         _searchResults = [];
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _loadSavedRating();
//   }

//   Future<void> _loadSavedRating() async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedHandle = prefs.getString('user_handle');
//     final savedRating = prefs.getInt('user_rating');

//     if (savedHandle != null && savedRating != null) {
//       final userRating = UserRating(handle: savedHandle, rating: savedRating);

//       Provider.of<UserRatingProvider>(context, listen: false).addUserRating(userRating);
//       setState(() {
//         _savedRatings.add(userRating);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Search Users'),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _handleController,
//               onChanged: (query) {
//                 _searchUsers(query);
//               },
//               decoration: InputDecoration(
//                 labelText: 'Search user by handle',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ),
//           SizedBox(
//             height: 300,
//             child: ListView.separated(
//               itemCount: _searchResults.length,
//               separatorBuilder: (context, index) => Divider(),
//               itemBuilder: (context, index) {
//                 final rating = _searchResults[index];
//                 return ListTile(
//                   title: Text(rating.handle),
//                   subtitle: Text('Rating: ${rating.rating}'),
//                   trailing: IconButton(
//                     icon: Icon(Icons.save),
//                     onPressed: () {
//                       _saveRating(rating.handle, rating.rating); // Save the selected rating
//                     },
//                   ),
//                 );
//               },
//             ),
//           ),
//           Divider(),
//           Expanded(
//             child: ListView.separated(
//               itemCount: _savedRatings.length,
//               separatorBuilder: (context, index) => Divider(),
//               itemBuilder: (context, index) {
//                 final rating = _savedRatings[index];
//                 return ListTile(
//                   title: Text(rating.handle),
//                   subtitle: Text('Rating: ${rating.rating}'),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

