import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:cfdata/pages/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cfdata/constants.dart';

class RatingScreen extends StatefulWidget {
  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final TextEditingController _handleController = TextEditingController();
  List<UserRating> _savedRatings = [];
  List<Rating> ratings = [];
  bool _showSaveButton = false;
  
  Future<void> fetchData() async {
    try {
      http.Response response = await http.get(Uri.parse('$api/ratinglist/'));
      print("fetchdata");
      print(response.statusCode);
      if (response.statusCode == 200) {
        print("inif");
        List<dynamic> data = jsonDecode(response.body);
        print(response.body);
        setState(() {
          ratings = data
              .map((item) => Rating(
                    id: item['id'],
                    // print(item['id'])printitem['handle'] item['rating']),
                    handle: item['username'],
                    rating: item['rating'],
                  ))
              .toList();
        print(ratings);
        });
      } else {
        print('Failed to fetch data. Error code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error hello occurred while fetching data: $e');
    }
  }

  void _addrating(String username, int rating) async {
      // final dumrating = rating as String;
    try {
      http.Response response = await http.post(Uri.parse('$api/ratinglist/'), 
      body: {
        'username': username,
        'rating': rating.toString(),
      },
      );
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 201) {
        setState(() {
          ratings.add(Rating(
            id: jsonDecode(response.body)['id'],
            handle: username,
            rating: rating,
          ));
          print(ratings);
        });
      } else {
        print('Failed to add item. Error code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while adding item: $e');
    }
  }

 
  Future<void> _fetchRating() async {
    final String handle = _handleController.text.trim();
    final String apiUrl = 'https://codeforces.com/api/user.rating?handle=$handle';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      final responseData = jsonDecode(response.body);

      if (responseData['status'] == 'OK') {
        final ratingChanges = responseData['result'];
        if (ratingChanges != null && ratingChanges is List && ratingChanges.isNotEmpty) {
          final latestRating = ratingChanges.last['newRating'] as int;
          final userRating = UserRating(handle: handle, rating: latestRating);
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('user_handle', handle);
          prefs.setInt('user_rating', latestRating);

          Provider.of<UserRatingProvider>(context, listen: false).addUserRating(userRating);
          _showSuccessDialog(handle, latestRating);
          setState(() {
            _showSaveButton = true;
          });
        } else {
          _showErrorDialog("No rating information found for the handle.");
        }
      } else {
        _showErrorDialog(responseData['comment'] ?? "Unknown error");
      }
    } catch (e) {
      _showErrorDialog("Error making API request: $e");
    }
  }
 
 Future<String> getAuthToken() async {
  // Obtain the authentication token from SharedPreferences
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? authToken = prefs.getString('auth_token');
  print(authToken);

  // Return the token, or an empty string if not found
  return authToken ?? '';
}
 
  Future<void> _fetchAndSaveRating() async {
  final String handle = _handleController.text.trim();
  final String apiUrl = 'https://codeforces.com/api/user.rating?handle=$handle';
  final String token = await getAuthToken();
  print(apiUrl);
  try {
    final response = await http.get(Uri.parse(apiUrl),
    // headers: {
    //     'Authorization': 'Bearer $token',
    //   },
    );
    
    final responseData = jsonDecode(response.body);
    print(responseData);
    print(responseData['status']);

    if (responseData['status'] == 'OK') {
      final ratingChanges = responseData['result'];
      final contestId = responseData['result'][0]['contestId'];
       if (ratingChanges != null && ratingChanges is List && ratingChanges.isNotEmpty) {
        final latestRating = ratingChanges.last['newRating'] as int;
        print(latestRating);
        // Fetch the last contest date
        final lastContestDate = await _fetchLastContestDate(handle);

        final prefs = await SharedPreferences.getInstance();
        final savedHandle = prefs.getString('user_handle');

        final isUserSaved = _savedRatings.any((rating) => rating.handle == handle);
        print(savedHandle);
        if (isUserSaved) {
          _showErrorDialog("The user $handle is already saved.");
        } else {
          print("inelse");
          final userRating = UserRating(
            handle: handle,
            rating: latestRating,
            lastContestDate: lastContestDate,
          );
          // print(response.body);
          print("down");
          print(contestId);
          print(latestRating);
          final userrating = Rating(
            id:contestId,
            handle: handle,
            rating: latestRating,
          );
          print(userRating);
          print(userrating);
          prefs.setString('user_handle', handle);
          prefs.setInt('user_rating', latestRating);

          setState(() {
            _savedRatings.add(userRating);
            ratings.add(userrating);
          });

          Provider.of<UserRatingProvider>(context, listen: false).addUserRating(userRating);
          _showSuccessDialog(handle, latestRating);
          setState(() {
            _showSaveButton = true;
          });
        }
        print("Saved Ratings");
        print(_savedRatings);
        print("Ratings:");
        for(int i=0;i<ratings.length;i++){
          print(ratings[i]);
        }
        _addrating(handle, latestRating);
        print("added rating");
      } else {
        _showErrorDialog("No rating information found for the handle.");
      }
    } else {
      _showErrorDialog(responseData['comment'] ?? "Unknown error");
    }
  } catch (e) {
    _showErrorDialog("Error making API request: $e");
  }
}


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String handle, int rating) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rating Fetched'),
          content: Text('$handle\'s current rating is: $rating'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

void _saveRating() async {
  final String handle = _handleController.text.trim();
  final prefs = Provider.of<UserRatingProvider>(context, listen: false);
  final latestRating = prefs.userRatings.last.rating;
  final userRating = UserRating(handle: handle, rating: latestRating);

  try {
    final http.Response response = await http.get(Uri.parse('$api/ratinglist/'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<UserRating> fetchedRatings = data.map((item) => UserRating(
        handle: item['username'],
        rating: item['rating'],
      )).toList();

      if (fetchedRatings.any((rating) => rating.handle == handle)) {
        _showErrorDialog("The user $handle is already saved.");
      } else {
        // Save the user to the backend
        final http.Response postResponse = await http.post(Uri.parse('$api/ratinglist/'),
          body: {
            'username': handle,
            'rating': latestRating.toString(),
          },
        );

        if (postResponse.statusCode == 201) {
          // If the user was successfully saved in the backend, update the local list
          setState(() {
            _savedRatings.add(userRating);
          });

          // Save the updated list to local storage
          final encodedRatings = _savedRatings.map((rating) => jsonEncode(rating.toJson())).toList();
          final prefsInstance = await SharedPreferences.getInstance();
          prefsInstance.setStringList('saved_ratings', encodedRatings);
          _showSuccessDialog(handle, latestRating);
        } else {
          print('Failed to add item. Error code: ${postResponse.statusCode}');
        }
      }
    } else {
      print('Failed to fetch data. Error code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error occurred while fetching data: $e');
  }
}

  

  Future<void> _loadSavedRatings() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedRatings = prefs.getStringList('saved_ratings');
    if (encodedRatings != null) {
      setState(() {
        _savedRatings = encodedRatings.map((encodedRating) => UserRating.fromJson(jsonDecode(encodedRating))).toList();
      });
    }
  }
Future<DateTime?> _fetchLastContestDate(String handle) async {
    final String apiUrl = 'https://codeforces.com/api/user.status?handle=$handle';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      final responseData = jsonDecode(response.body);

      if (responseData['status'] == 'OK') {
        final submissions = responseData['result'];
        if (submissions != null && submissions is List && submissions.isNotEmpty) {
          final latestSubmission = submissions.last['creationTimeSeconds'] as int;
          return DateTime.fromMillisecondsSinceEpoch(latestSubmission * 1000);
        }
      }
    } catch (e) {
      print("Error fetching last contest date: $e");
    }
    return null;
  }
  Future<void> _checkSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedHandle = prefs.getString('user_handle');
    if (savedHandle != null && savedHandle.isNotEmpty) {
      _handleController.text = savedHandle;
    }
    final isUserSaved = _savedRatings.any((rating) => rating.handle == savedHandle);

    if (isUserSaved) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('User Already Saved'),
            content: Text('The user $savedHandle is already saved.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        _showSaveButton = true;
      });
    }
  }
  Future<void> _fetchSavedRatingsFromBackend() async {
  try {
    http.Response response = await http.get(Uri.parse('$api/ratinglist/'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<UserRating> fetchedRatings = data.map((item) => UserRating(
        handle: item['username'],
        rating: item['rating'],
      )).toList();

      setState(() {
        _savedRatings = fetchedRatings;
      });
    } else {
      print('Failed to fetch data. Error code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error occurred while fetching data: $e');
  }
}


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _loadSavedRatings();
      _checkSavedUser();
      _fetchSavedRatingsFromBackend();
    });
  }
// ...

void _deleterating(String name) async {
  final prefs = await SharedPreferences.getInstance();

  try {
    final deleteResponse = await http.delete(Uri.parse('$api/ratingdelete/$name/'));

    if (deleteResponse.statusCode == 204) {
      setState(() {
        _savedRatings.removeWhere((rating) => rating.handle == name);
      });
    } else {
      print('Failed to delete item. Error code: ${deleteResponse.statusCode}');
    }
  } catch (e) {
    print('Error occurred while deleting item: $e');
  }

  _checkSavedUser();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fetch Rating'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _handleController,
              decoration: InputDecoration(
                labelText: 'Enter Codeforces Handle',
              ),
            ),
             SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _fetchRating, // Use the new method here
              child: Text('Fetch Rating'), // Change button text
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveRating, // Use the new method here
              child: Text('Save Rating'), // Change button text
            ),
            SizedBox(height: 16.0),
            if (_savedRatings.isNotEmpty)
              Text(
                'Saved Ratings:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (_savedRatings.isEmpty)
            Text(
              'No current saved ratings.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _savedRatings.length,
                itemBuilder: (context, index) {
                  final rating = _savedRatings[index];
                  return ListTile(
                    title: Text(rating.handle),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rating: ${rating.rating}'),
                        // if (rating.lastContestDate != null)
                          // Text('Last Contest Date: ${rating.lastContestDate!.toLocal()}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleterating(rating.handle),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
