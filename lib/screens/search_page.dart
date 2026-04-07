import 'package:flutter/material.dart';
import 'package:graburticket/components/ticketbooking/cinemalisting.dart';
import 'package:graburticket/screens/seatselections.dart';
import 'package:iconsax/iconsax.dart';
import '../model/constants.dart'; // contains movieData

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = "";

  late List<Map<String, dynamic>> allMovies;
  List<Map<String, dynamic>> results = [];

  @override
  void initState() {
    super.initState();
    allMovies = List<Map<String, dynamic>>.from(movieData);
  }

  void searchMovies(String value) {
    setState(() {
      query = value;

      if (value.isEmpty) {
        results = [];
      } else {
        results = allMovies.where((movie) {
          return movie['title']
              .toString()
              .toLowerCase()
              .contains(value.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Search movies...",
            border: InputBorder.none,
          ),
          onChanged: searchMovies,
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.close_circle),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),

      body: query.isEmpty
          ? const Center(
        child: Text(
          "Start typing to search...",
          style: TextStyle(fontSize: 18),
        ),
      )
          : results.isEmpty
          ? Center(
        child: Text(
          "No results for \"$query\"",
          style: const TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final movie = results[index];

          return Card(
            child: ListTile(
              leading: Image.network(
                movie['imageUrl'],
                width: 50,
                fit: BoxFit.cover,
              ),
              title: Text(movie['title']),
              subtitle: Text(movie['metadata']),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CinemaTimings(movie: movie),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
