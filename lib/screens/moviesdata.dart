import 'package:firebase_auth/firebase_auth.dart';
import 'package:graburticket/model/constants.dart';
import 'package:graburticket/components/moviesdata/castDetails.dart';
import 'package:graburticket/components/moviesdata/movieSummary.dart';
import 'package:graburticket/components/moviesdata/ratingbar.dart';
import 'package:graburticket/components/moviesdata/topbannersection.dart';
import 'package:flutter/material.dart';
import 'package:graburticket/screens/login_page.dart';
import 'package:graburticket/screens/ticketbookingscreen.dart';

// ✅ MOVIES TAB PAGE (for bottom navigation)
class MoviesPage extends StatelessWidget {
  const MoviesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // All movies from your constants.dart
    final allMovies = movieData;

    // Try to detect "new" movies using a flag `isNew` in movieData (optional)
    final newMovies = allMovies
        .where((m) => (m as Map<String, dynamic>)['isNew'] == true)
        .toList();

    // Popular movies – by rating >= 4.5 or flag `isPopular`
    final popularMovies = allMovies.where((m) {
      final map = m as Map<String, dynamic>;
      final rating = (map['rating'] ?? map['rate'] ?? 0);
      final isPopular = map['isPopular'] == true;
      return isPopular || (rating is num && rating >= 4.5);
    }).toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Movies',
            style: TextStyle(
              color: darkColor,
              fontSize: textContent,
              fontFamily: primaryFont,
            ),
          ),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: false,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.red,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'New'),
              Tab(text: 'Popular'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _MoviesGrid(movies: allMovies),
            _MoviesGrid(movies: newMovies),
            _MoviesGrid(movies: popularMovies),
          ],
        ),
      ),
    );
  }
}

// ✅ Common grid widget for all / new / popular
class _MoviesGrid extends StatelessWidget {
  final List movies;

  const _MoviesGrid({super.key, required this.movies});

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const Center(
        child: Text('No movies found'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        // a bit taller cards to avoid overflow
        childAspectRatio: 0.55, // width / height
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final map = movies[index] as Map<String, dynamic>;

        // Poster path (asset or url)
        final String imagePath =
        (map['imageUrl'] ??
            map['image'] ??
            map['poster'] ??
            map['posterUrl'] ??
            '') as String;

        final String title = (map['title'] ?? 'Untitled') as String;

        final ratingValue = map['rating'] ?? map['rate'] ?? 0;
        final numRating =
        ratingValue is num ? ratingValue : num.tryParse('$ratingValue') ?? 0;

        // index in original movieData (for MovieDetails)
        final int originalIndex = movieData.indexOf(map);

        // choose correct image widget
        Widget posterWidget;
        if (imagePath.isEmpty) {
          posterWidget = Container(
            color: Colors.grey.shade300,
            alignment: Alignment.center,
            child: const Icon(Icons.movie, size: 40),
          );
        } else if (imagePath.startsWith('http')) {
          // network image
          posterWidget = Image.network(
            imagePath,
            fit: BoxFit.cover,
          );
        } else {
          // asset image
          posterWidget = Image.asset(
            imagePath,
            fit: BoxFit.cover,
          );
        }

        return GestureDetector(
          onTap: () {
            if (originalIndex != -1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MovieDetails(movieIndex: originalIndex),
                ),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 poster takes remaining height safely
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: posterWidget,
                  ),
                ),

                const SizedBox(height: 6),

                // title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: primaryFont,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // rating
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        numRating.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // book button
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                      ),
                      onPressed: () {
                        if (originalIndex != -1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  MovieDetails(movieIndex: originalIndex),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Book Now',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


class MovieDetails extends StatefulWidget {
  const MovieDetails({super.key, required this.movieIndex});
  final int movieIndex;

  @override
  State<MovieDetails> createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails> {
  @override
  Widget build(BuildContext context) {
    final movidetails = movieData[widget.movieIndex];

    // 🔹 read cast & crew from this movie if available, else fall back to global lists
    final List<Map<String, dynamic>> movieCast =
        (movidetails['cast'] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
            [];

    final List<Map<String, dynamic>> movieCrew =
        (movidetails['crew'] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
            [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(
              movidetails['title'],
              style: TextStyle(
                color: darkColor,
                fontSize: textContent,
                fontFamily: primaryFont,
              ),
            ),
            const Spacer(),
            const Icon(Icons.share),
          ],
        ),
      ),
      backgroundColor: Colors.white,

      // ✅ Book Tickets button logic
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GestureDetector(
          onTap: () async {
            final user = FirebaseAuth.instance.currentUser;

            if (user == null) {
              // not logged in → redirect to login and wait for result
              final loggedIn = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                    builder: (_) => const LoginPage()),
              );

              if (loggedIn == true && mounted) {
                // after successful login → go to booking
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Ticketbookingscreen(
                      movieIndex: widget.movieIndex,
                    ),
                  ),
                );
              }
            } else {
              // logged in → allow booking
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Ticketbookingscreen(
                    movieIndex: widget.movieIndex,
                  ),
                ),
              );
            }
          },
          child: Container(
            height: 48,
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width - 60,
            decoration: BoxDecoration(
              color: kPrimary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Book Tickets',
              style: TextStyle(
                color: Colors.white,
                fontSize: textContent,
                fontFamily: primaryFont,
              ),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TopBannerSection(
              movieIndex1: widget.movieIndex,
            ),
            const SizedBox(height: 15),
            RatingBarDetails(
              ratingIndex: widget.movieIndex,
            ),
            const SizedBox(height: 15),
            MovieSummary(
              summaryIndex: widget.movieIndex,
            ),
            CastDetails(
              peopleDetails: movieCast,
              title: 'Cast',
            ),
            const Divider(),
            CastDetails(
              peopleDetails: movieCrew,
              title: 'Crew',
            ),
          ],
        ),
      ),
    );
  }
}
