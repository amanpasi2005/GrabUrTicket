import 'package:flutter/material.dart';


//Colors

Color kPrimary= Color(0xFFE7384D);
Color grey= Color(0xFF2C2B2B);
Color darkColor= Color(0xFF040404);
Color lightColor= Color(0xFFFFFFFF);

//Fonts

String primaryFont='Poppins';
String secondaryFonts='Proxima';
String subtitleFonts='Roboto';

//Fontsize

double boldTitle= 20;
double semiboldTitle= 18;
double textContent= 16;
double textSubTitle= 14;

//MoviesData List
//Movie 1
List<Map<String, dynamic>> movieData = [
{
"title": "Bhool Bhulaiyaa 3",
"imageUrl": "https://assets-in.bmscdn.com/iedb/movies/images/mobile/thumbnail/xlarge/bhool-bhulaiyaa-3-et00353996-1728474428.jpg",
"bigPicture":"https://assets-in.bmscdn.com/iedb/movies/images/mobile/listing/xxlarge/bhool-bhulaiyaa-3-et00353996-1728474428.jpg",
"rating": 4.0,
"ratingCount": "92k",
"metadata":"2h 38m • Comedy, Horror • UA • 1 Nov, 2024",
"screenType":"2D",
"language":"Hindi",
"about":"Gear up to tickle your funny bones with some thrill. The gates of `haveli` will now open again for Bhool Bhulaiyaa 3!",

"cast": [
{
"name": "Vidya Balan",
"imageUrl": "https://assets-in.bmscdn.com/iedb/artist/images/website/poster/large/vidya-balan-2457-14-09-2017-12-33-54.jpg",
"role":"Mallika",
},
{
"name": "Kartik Aaryan",
"imageUrl": "https://in.bmscdn.com/iedb/artist/images/website/poster/large/kartik-aaryan-1045198-1685968467.jpg",
"role":"Rooh Baba",
},
{
"name": "Tripti Dimri",
"imageUrl": "https://assets-in.bmscdn.com/iedb/artist/images/website/poster/large/tripti-dimri-1093177-01-06-2018-03-16-40.jpg",
"role":"Kriti Singh",
},
{
"name": "Madhuri Dixit",
"imageUrl": "https://assets-in.bmscdn.com/iedb/artist/images/website/poster/large/madhuri-dixit-1318-29-09-2016-01-48-46.jpg",
"role":"Mandira",
},
{
"name": "Vijay Raaz",
"imageUrl": "https://m.media-amazon.com/images/M/MV5BNGQ5NjhmMjEtYTUzOC00ODZlLTg1MDMtYzhjZWFmYWU4YzMzXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg",
"role":"Raja Saab",
},
],
"crew": [
{
"name": "Anees Bazmee",
"imageUrl": "https://assets-in.bmscdn.com/iedb/artist/images/website/poster/large/anees-bazmee-2651-19-09-2017-02-07-46.jpg",
"role":"Director",
},
{
"name": "Bhushan Kumar",
"imageUrl": "https://assets-in.bmscdn.com/iedb/artist/images/website/poster/large/bhushan-kumar-1075903-11-11-2016-05-08-19.jpg",
"role":"Producer",
},
{
"name": "Krishan Kumar",
"imageUrl": "https://assets-in.bmscdn.com/iedb/artist/images/website/poster/large/krishan-kumar-iein019780-24-03-2017-17-35-37.jpg",
"role":"Producer",
},
{
"name": "Tanishk Bagchi",
"imageUrl": "https://assets-in.bmscdn.com/iedb/artist/images/website/poster/large/tanishk-bagchi-1067219-24-03-2017-16-26-34.jpg",
"role":"Musician",
},
{
"name": "Sanjay Sankla",
"imageUrl": "https://assets-in.bmscdn.com/iedb/artist/images/website/poster/large/sanjay-sankla-iein010869-24-03-2017-15-03-41.jpg",
"role":"Editor",
},
],
},

//Movie 2
  {
    "title": "Kanguva",
    "imageUrl":
    "https://assets-in.bmscdn.com/iedb/movies/images/mobile/thumbnail/xlarge/kanguva-et00357490-1711005979.jpg",
    "bigPicture":
    "https://assets-in.bmscdn.com/iedb/movies/images/mobile/listing/xxlarge/kanguva-et00357490-1711005979.jpg",
    "rating": 4.2,
    "ratingCount": "34k",
    "metadata":
    "2h 34m • Action, Adventure, Fantasy, Period • UA • 14 Nov, 2024",
    "screenType": "2D, ICE, ICE 3D, 3D, IMAX 2D, IMAX 3D",
    "language": "Tamil, Hindi, +3",
    "about":
    "Prepare to witness epic emotions, raw rage, primal courage, ruthless revenge in its purest form.",

    "cast": [
      {
        "name": "Suriya",
        "imageUrl":
        "https://images.filmibeat.com/webp/173x230/img/popcorn/profile_photos/suriya-sivakumar-20190423095612-2747.jpg",
        "role": "Kanguva",
      },
      {
        "name": "Bobby Deol",
        "imageUrl":
        "https://images.filmibeat.com/webp/173x230/img/popcorn/profile_photos/bobby-deol-4.jpg",
        "role": "Antagonist",
      },
      {
        "name": "Disha Patani",
        "imageUrl":
        "https://images.filmibeat.com/webp/173x230/img/popcorn/profile_photos/disha-patani-20241118153929-35289.jpg",
        "role": "Female Lead",
      },
      {
        "name": "Jagapathi Babu",
        "imageUrl":
        "https://images.filmibeat.com/webp/173x230/img/popcorn/profile_photos/jagapati-babu-20191213150001-4069.jpg",
        "role": "Supporting Role",
      },
      {
        "name": "Yogi Babu",
        "imageUrl":
        "https://images.filmibeat.com/webp/173x230/img/popcorn/profile_photos/yogi-babu-20191205130221-35602.jpg",
        "role": "Comic Relief",
      },
    ],

    "crew": [
      {
        "name": "Siva",
        "imageUrl":
        "https://upload.wikimedia.org/wikipedia/commons/9/99/Siva_at_Maniyar_Kudumbam_Audio_Launch.jpg",
        "role": "Director",
      },
      {
        "name": "K. E. Gnanavel Raja",
        "imageUrl":
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT7L9IN5Ik1Anjr500h2zFkolye0Zh52tevNg&s",
        "role": "Producer",
      },
      {
        "name": "Devi Sri Prasad",
        "imageUrl":
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRoQJJ4aYW4DIImr3g_tGaZL_jc2osdzR5AzA&s",
        "role": "Music Director",
      },
      {
        "name": "Vettri",
        "imageUrl":
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSWGVioYf1Unsf4KxZAJL5yIkTc-1Ba3MY4Wg&s",
        "role": "Cinematographer",
      },
    ],
  },

//Movie 3
  {
    "title": "Amaran",
    "imageUrl": "https://assets-in.bmscdn.com/iedb/movies/images/mobile/thumbnail/xlarge/amaran-et00388085-1728627184.jpg",
    "bigPicture": "https://assets-in.bmscdn.com/iedb/movies/images/mobile/listing/xxlarge/amaran-et00388085-1728627184.jpg",
    "rating": 4.5,
    "ratingCount": "45k",
    "metadata": "2h 49m • Action, Drama, Thriller • UA • 31 Oct, 2024",
    "screenType": "2D",
    "language": "Tamil, Telugu",
    "about": "True story of Major Mukund Varadarajan, an Indian Army officer awarded the Ashok Chakra.",
    "cast": [
      {
        "name": "Sivakarthikeyan",
        "imageUrl": "https://images.filmibeat.com/webp/173x230/img/popcorn/profile_photos/sivakarthikeyan-20251201100037-27062.jpg",
        "role": "Major Mukund Varadarajan"
      },
      {
        "name": "Sai Pallavi",
        "imageUrl": "https://images.filmibeat.com/webp/173x230/img/popcorn/profile_photos/sai-pallavi-20220716143605-35130.jpg",
        "role": "Female Lead"
      },
      {
        "name": "Rahul Bose",
        "imageUrl": "https://images.filmibeat.com/webp/173x230/img/popcorn/profile_photos/rahul-bose-20180622162739-519.jpg",
        "role": "Army Officer"
      },
      {
        "name": "Bhuvan Arora",
        "imageUrl": "https://images.filmibeat.com/webp/173x230/img/popcorn/profile_photos/bhuvan-arora-20230210153208-56165.jpg",
        "role": "Supporting Role"
      }
    ],
    "crew": [
      {
        "name": "Rajkumar Periasamy",
        "imageUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRjNE0iDOW3bE8LQlkAmyk-WXwdUWmL3KXv-g&s",
        "role": "Director"
      },
      {
        "name": "G. V. Prakash Kumar",
        "imageUrl": "https://m.media-amazon.com/images/M/MV5BM2E0YmU5OGItMTBkZS00NjI5LWFkNGMtZmU3ZmUxYzQwY2IyXkEyXkFqcGc@._V1_.jpg",
        "role": "Music Director"
      },
    ]
  },


//Movie 4
  {
    "title": "Venom: The Last Dance",
    "imageUrl": "https://m.media-amazon.com/images/M/MV5BZDMyYWU4NzItZDY0MC00ODE2LTkyYTMtMzNkNDdmYmFhZDg0XkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg",
    "bigPicture": "https://m.media-amazon.com/images/M/MV5BZDMyYWU4NzItZDY0MC00ODE2LTkyYTMtMzNkNDdmYmFhZDg0XkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg",
    "rating": 4.8,
    "ratingCount": "120k",
    "metadata": "2h 10m • Action, Sci-Fi • UA • 2025",
    "screenType": "IMAX 2D",
    "language": "English",
    "about": "Eddie Brock and Venom face their final and most dangerous challenge yet.",
    "cast": [
      {
        "name": "Tom Hardy",
        "imageUrl": "https://images.filmibeat.com/webp/173x230/img/popcorn/profile_photos/tom-hardy-20712.jpg",
        "role": "Eddie Brock / Venom"
      },
      {
        "name": "Juno Temple",
        "imageUrl": "https://images.filmibeat.com/webp/173x230/img/popcorn/profile_photos/juno-temple-20190514145636-21719.jpg",
        "role": "Scientist"
      },
      {
        "name": "Chiwetel Ejiofor",
        "imageUrl": "https://images.filmibeat.com/webp/173x230/img/popcorn/profile_photos/chiwetel-ejiofor-20190514151059-9382.jpg",
        "role": "Antagonist"
      },
      {
        "name": "Stephen Graham",
        "imageUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRBQR1X-5GOJaz2D_oCJWqqDLatKH3PbrqMrA&s",
        "role": "Supporting Role"
      }
    ],
    "crew": [
      {
        "name": "Kelly Marcel",
        "imageUrl": "https://media.themoviedb.org/t/p/w500/thpdVW7O1975GcA3eNs1H8UIlmd.jpg",
        "role": "Director"
      },
      {
        "name": "Avi Arad",
        "imageUrl": "https://m.media-amazon.com/images/M/MV5BMTg5OTQzNDY2Nl5BMl5BanBnXkFtZTYwMzg3NzY3._V1_.jpg",
        "role": "Producer"
      },
      {
        "name": "Matt Tolmach",
        "imageUrl": "https://resizing.flixster.com/wVSBP4hzq0HM53ONvqFNvcfzXKs=/fit-in/705x460/v2/https://resizing.flixster.com/-XZAfHZM39UwaGJIFWKAE8fS0ak=/v3/t/assets/432171_v9_ba.jpg",
        "role": "Producer"
      },
      {
        "name": "Dan Deacon",
        "imageUrl": "https://m.media-amazon.com/images/M/MV5BODA4NTM3MTMtZjU2Zi00ODRmLWJmNzctYzMyNjkxZTE3ODQ3XkEyXkFqcGc@._V1_.jpg",
        "role": "Music"
      }
    ]
  },

//Movie 5
  {
    "title": "The Wild Robot",
    "imageUrl": "https://upload.wikimedia.org/wikipedia/en/7/70/The_Wild_Robot_poster.jpg",
    "bigPicture": "https://upload.wikimedia.org/wikipedia/en/7/70/The_Wild_Robot_poster.jpg",
    "rating": 4.6,
    "ratingCount": "98k",
    "metadata": "1h 42m • Animation, Adventure • U • 2024",
    "screenType": "2D, 3D",
    "language": "English",
    "about": "A robot stranded on an uninhabited island learns to survive and connect with animals.",
    "cast": [
      {
        "name": "Lupita Nyong'o",
        "imageUrl": "https://m.media-amazon.com/images/M/MV5BMTY0NTQ4MDY2Nl5BMl5BanBnXkFtZTgwNDk1MTEyMDE@._V1_FMjpg_UX1000_.jpg",
        "role": "Roz (Voice)"
      },
      {
        "name": "Pedro Pascal",
        "imageUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRLXBL0nEh608FbPyidFHLa1iiFplgkRsndEg&s",
        "role": "Fink (Voice)"
      },
      {
        "name": "Catherine O'Hara",
        "imageUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS9VQ13pP7-iTPjrI6ixGjUUYpAQBRQ5-LRfg&s",
        "role": "Pinktail (Voice)"
      }
    ],
    "crew": [
      {
        "name": "Chris Sanders",
        "imageUrl": "https://m.media-amazon.com/images/M/MV5BMTg4MDI2NTY0OV5BMl5BanBnXkFtZTgwMTM5ODYxMTE@._V1_FMjpg_UX1000_.jpg",
        "role": "Director"
      },
      {
        "name": "Peter Brown",
        "imageUrl": "https://d28hgpri8am2if.cloudfront.net/author_images/10504/peter-brown-45981127.jpg",
        "role": "Story"
      },
      {
        "name": "Kris Bowers",
        "imageUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ7vjLXxw4TtZsJcZMrAS0LuvCLcJTL_cnmMA&s",
        "role": "Music"
      }
    ]
  },


//Movie 6
  {
    "title": "Tere Ishq Mein",
    "imageUrl": "https://m.media-amazon.com/images/M/MV5BOGRjMzM1ZmUtMjk0Yi00NzA0LTk3ZWYtZWM3MWY3M2EwMjBhXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg",
    "bigPicture": "https://m.media-amazon.com/images/M/MV5BOGRjMzM1ZmUtMjk0Yi00NzA0LTk3ZWYtZWM3MWY3M2EwMjBhXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg",
    "rating": 4.8,
    "ratingCount": "110k",
    "metadata": "2h 18m • Romance, Drama • UA • 28 Nov, 2025",
    "screenType": "2D",
    "language": "Hindi",
    "about": "An intense romantic drama about love, longing, and emotional sacrifice.",
    "isNew": true,
    "cast": [
      {
        "name": "Dhanush",
        "imageUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTwTvoyFnWqMrJGBvBVsphjhoq3v-RYhMeW_A&s",
        "role": "Male Lead"
      },
      {
        "name": "Kriti Sanon",
        "imageUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRqpt5KxMkYZWEDou8pVhhFoUKW-Fee7Po9ew&s",
        "role": "Female Lead"
      },
      {
        "name": "Jimmy Shergill",
        "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/thumb/5/54/Jimmy_Shergill.jpg/250px-Jimmy_Shergill.jpg",
        "role": "Supporting Role"
      }
    ],
    "crew": [
      {
        "name": "Aanand L Rai",
        "imageUrl": "https://m.media-amazon.com/images/M/MV5BOTc5MDkzZDctNmI2MS00ODcwLTlhNjMtNmI1MTE2MWVhNmI2XkEyXkFqcGc@._V1_.jpg",
        "role": "Director"
      },
      {
        "name": "A. R. Rahman",
        "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/3/3b/AR_Rahman_At_The_%E2%80%98Marvel_Anthem%E2%80%99_Launch_%283x4_cropped%29.jpg",
        "role": "Music Director"
      },
      {
        "name": "Colour Yellow Productions",
        "imageUrl": "https://assets-in.bmscdn.com/iedb/artist/images/website/poster/large/colour-yellow-productions-2032571-1659441178.jpg",
        "role": "Producer"
      }
    ]
  },

//Movie 7
  {
    "title": "Dude",
    "imageUrl":
    "https://m.media-amazon.com/images/M/MV5BZWFiMzEzZTQtZjFiZC00YjhjLTk3Y2QtYzA2MjE4MmRiNzdmXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg",
    "bigPicture":
    "https://m.media-amazon.com/images/M/MV5BZWFiMzEzZTQtZjFiZC00YjhjLTk3Y2QtYzA2MjE4MmRiNzdmXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg",
    "rating": 4.1,
    "ratingCount": "27k",
    "metadata": "2h 15m • Comedy, Drama • UA • 2025",
    "screenType": "2D",
    "language": "Tamil",
    "about":
    "A fun-filled coming-of-age story about friendship, dreams, and unexpected twists.",
    "isNew": true,

    "cast": [
      {
        "name": "Pradeep Ranganathan",
        "imageUrl": "https://m.media-amazon.com/images/M/MV5BNzA1NTFlMjgtM2Q5Ni00MmFmLWFhMDktOTgwNzFhZDMyY2I1XkEyXkFqcGc@._V1_.jpg",
        "role": "Male Lead"
      },
      {
        "name": "Mamitha Baiju",
        "imageUrl": "https://img.studioflicks.com/wp-content/uploads/2024/03/11201402/Mamitha-Baiju.jpg",
        "role": "Female Lead"
      },
      {
        "name": "Radhika Sarathkumar",
        "imageUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTpakneAVU06yArpVZhiAXUkbCvAKoTcqgEdg&s",
        "role": "Supporting Role"
      }
    ],
    "crew": [
      {
        "name": "Keerthiswaran",
        "imageUrl": "https://www.thenewsmedium.com/wp-content/uploads/2025/05/Director-Keerthiswaran-Age.webp",
        "role": "Director"
      },
      {
        "name": "Ilaiyaraaja",
        "imageUrl": "https://media.assettype.com/tnm%2Fimport%2Fsites%2Fdefault%2Ffiles%2FIlaiyaraaja_1200.jpg?w=480&auto=format%2Ccompress&fit=max",
        "role": "Music Director"
      },
      {
        "name": "Mythri Movie Makers",
        "imageUrl": "https://yt3.googleusercontent.com/ytc/AIdro_nK15CgfpX4wxGnfNxbDMu-8s7coE5LQr2JYy3OI05cmTY=s900-c-k-c0x00ffffff-no-rj",
        "role": "Producer"
      }
    ]
  },

//Movie 8
  {
    "title": "Final Destination: Bloodlines",
    "imageUrl": "https://m.media-amazon.com/images/M/MV5BMzc3OWFhZWItMTE2Yy00N2NmLTg1YTktNGVlNDY0ODQ5YjNlXkEyXkFqcGc@._V1_.jpg",
    "bigPicture": "https://m.media-amazon.com/images/M/MV5BMzc3OWFhZWItMTE2Yy00N2NmLTg1YTktNGVlNDY0ODQ5YjNlXkEyXkFqcGc@._V1_.jpg",
    "rating": 4.1,
    "ratingCount": "76k",
    "metadata": "1h 55m • Horror, Thriller • A • 2025",
    "screenType": "2D",
    "language": "English",
    "about": "Death returns with a terrifying new design that traces the origins of the curse.",
    "cast": [
      {
        "name": "Brec Bassinger",
        "imageUrl": "https://m.media-amazon.com/images/M/MV5BYzNlYWZiZGMtM2JkMC00NjVlLWJhMGUtMTQ4ZWUwMmJmZmVkXkEyXkFqcGc@._V1_CR374,23,1509,2264_FMjpg_UX1000_.jpg",
        "role": "Lead Role"
      },
      {
        "name": "Teo Briones",
        "imageUrl": "https://m.media-amazon.com/images/M/MV5BNWI0NTk3NGYtMzhmMi00NzcwLTkyZmQtYjc4MWI4YmJjNzk0XkEyXkFqcGc@._V1_.jpg",
        "role": "Supporting Role"
      },
      {
        "name": "Richard Harmon",
        "imageUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTW38YxY_wmhT3gqZwevWT1NoLZcQ8TWzZpXw&s",
        "role": "Key Character"
      },
      {
        "name": "Tony Todd",
        "imageUrl": "https://m.media-amazon.com/images/M/MV5BMTUzNTI1Njc4NV5BMl5BanBnXkFtZTcwMDg4NzcyNg@@._V1_FMjpg_UX1000_.jpg",
        "role": "William Bludworth"
      }
    ],
    "crew": [
      {
        "name": "Zach Lipovsky",
        "imageUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSN1vFkgvwhAu2gbpSuwdo3-Kqf-hvOkZ5glw&s",
        "role": "Director"
      },
      {
        "name": "Adam Stein",
        "imageUrl": "https://api.screendollars.com/wp-content/uploads/2021/11/0-ADAM-B-STEIN-PROFILE-02.jpg",
        "role": "Director"
      },
      {
        "name": "Craig Perry",
        "imageUrl": "https://m.media-amazon.com/images/M/MV5BNTNjZTZhNjctZWJlOS00NWUwLWE3YzUtYTVmOGY5NTljOTUyXkEyXkFqcGc@._V1_.jpg",
        "role": "Producer"
      }
    ]
  },


//Movie 9
  {
    "title": "Kantara: A Legend – Chapter 1",
    "imageUrl": "https://m.media-amazon.com/images/M/MV5BNDU2ZTYxYTMtMjhlZC00ZjEwLThhNDUtMzdlNWM4ZDcyYTM1XkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg",
    "bigPicture": "https://m.media-amazon.com/images/M/MV5BNDU2ZTYxYTMtMjhlZC00ZjEwLThhNDUtMzdlNWM4ZDcyYTM1XkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg",
    "rating": 4.7,
    "ratingCount": "150k",
    "metadata": "2h 35m • Action, Drama • UA • 2025",
    "screenType": "2D",
    "language": "Kannada, Hindi",
    "about": "A divine legend rooted in folklore unfolds as destiny and tradition collide.",
    "isNew": true,
    "cast": [
      {
        "name": "Rishab Shetty",
        "imageUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQlJsqIODrxh7e-wM8d-zJmtPbLTCP0mICd6g&s",
        "role": "Lead Role"
      },
      {
        "name": "Sapthami Gowda",
        "imageUrl": "https://m.media-amazon.com/images/M/MV5BM2NlZmIyYzktMmU1NS00MWJhLTlkMzUtMjA3MWNhZGU0OTRjXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg",
        "role": "Female Lead"
      },
      {
        "name": "Kishore",
        "imageUrl": "https://images.hindustantimes.com/img/2023/01/03/1600x900/Kishore_Kumar_G_1672733045905_1672733059551_1672733059551.jpg",
        "role": "Supporting Role"
      }
    ],
    "crew": [
      {
        "name": "Rishab Shetty",
        "imageUrl": "https://m.media-amazon.com/images/M/MV5BODc2ZGU1MGEtNDhkMS00NjBlLTg1MWItYWJlZmYzZjdmMjFjXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg",
        "role": "Director"
      },
      {
        "name": "Ajaneesh Loknath",
        "imageUrl": "https://images.filmibeat.com/img/popcorn/profile_photos/b-ajaneesh-loknath-20250701154752-31573.jpg",
        "role": "Music Director"
      },
      {
        "name": "Hombale Films",
        "imageUrl": "https://media.licdn.com/dms/image/v2/C560BAQGCmvmV9vr0vw/company-logo_200_200/company-logo_200_200/0/1630669417644/hombale_films_logo?e=2147483647&v=beta&t=mpzxSR5ChqHGPBKJwXWh52-9bwCEuGHi-5EBozXMsDY",
        "role": "Producer"
      }
    ]
  },

//Movie 10
  {
    "title": "Jurassic World: Rebirth",
    "imageUrl": "https://s3.amazonaws.com/nightjarprod/content/uploads/sites/130/2025/06/13172640/q0fGCmjLu42MPlSO9OYWpI5w86I-683x1024.jpg",
    "bigPicture": "https://s3.amazonaws.com/nightjarprod/content/uploads/sites/130/2025/06/13172640/q0fGCmjLu42MPlSO9OYWpI5w86I-683x1024.jpg",
    "rating": 4.4,
    "ratingCount": "135k",
    "metadata": "2h 25m • Action, Sci-Fi • UA • 2025",
    "screenType": "IMAX 2D",
    "language": "English",
    "about": "A new era begins as humanity faces the return of genetically enhanced dinosaurs.",
    "cast": [
      {
        "name": "Scarlett Johansson",
        "imageUrl": "https://www.thehawk.in/_next/image?url=https%3A%2F%2Fd2py10ayqu2jji.cloudfront.net%2F0d85eeb0-40e3-4d73-a3d8-665cf872427e%2F202505303416196-81e37090-66e0-40d2-86ea-a6f8c494e130.jpg&w=3840&q=75",
        "role": "Lead Scientist"
      },
      {
        "name": "Jonathan Bailey",
        "imageUrl": "https://m.media-amazon.com/images/M/MV5BNDhhZjdlZjctZjQ0OS00ODIwLWFmMTItNmQ0MzJiYTQ0MjFmXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg",
        "role": "Field Expert"
      },
      {
        "name": "Mahershala Ali",
        "imageUrl": "https://m.media-amazon.com/images/M/MV5BMzBhZTM4ZTMtYzYwMi00ZGQwLTljNDEtZTVlNjYwYTZiODEzXkEyXkFqcGc@._V1_.jpg",
        "role": "Supporting Role"
      }
    ],
    "crew": [
      {
        "name": "Gareth Edwards",
        "imageUrl": "https://m.media-amazon.com/images/M/MV5BMjAyMjU1MjIzOF5BMl5BanBnXkFtZTcwNDY5ODYxNA@@._V1_FMjpg_UX1000_.jpg",
        "role": "Director"
      },
      {
        "name": "Frank Marshall",
        "imageUrl": "https://m.media-amazon.com/images/M/MV5BOTk2OTA3ZjItNGQzOC00ZmUxLTg2YjgtNzg1ZmZlNGU1ZDAwXkEyXkFqcGc@._V1_.jpg",
        "role": "Producer"
      },
      {
        "name": "John Williams",
        "imageUrl": "https://m.media-amazon.com/images/M/MV5BMjY5MTgzMTQ1NF5BMl5BanBnXkFtZTYwNDg3OTcz._V1_FMjpg_UX1000_.jpg",
        "role": "Music"
      }
    ]
  },

//Movie 11
  {
    "title": "Mission: Impossible – Final Reckoning",
    "imageUrl": "https://m.media-amazon.com/images/M/MV5BZGQ5NGEyYTItMjNiMi00Y2EwLTkzOWItMjc5YjJiMjMyNTI0XkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg",
    "bigPicture": "https://m.media-amazon.com/images/M/MV5BZGQ5NGEyYTItMjNiMi00Y2EwLTkzOWItMjc5YjJiMjMyNTI0XkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg",
    "rating": 4.6,
    "ratingCount": "200k",
    "metadata": "2h 40m • Action, Thriller • UA • 2025",
    "screenType": "IMAX 2D",
    "language": "English",
    "about": "Ethan Hunt faces his final mission where every choice has consequences.",
    "cast": [
      {
        "name": "Tom Cruise",
        "imageUrl": "https://m.media-amazon.com/images/M/MV5BMmU1YWU1NmMtMjAyMi00MjFiLWFmZmUtOTc1ZjI5ODkxYmQyXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg",
        "role": "Ethan Hunt"
      },
      {
        "name": "Hayley Atwell",
        "imageUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSThEQpQiujH8qqpByjZUhtNDwKlkWTAUiyGQ&s",
        "role": "Grace"
      },
      {
        "name": "Ving Rhames",
        "imageUrl": "https://m.media-amazon.com/images/M/MV5BMTMwMTgyMzc4MV5BMl5BanBnXkFtZTYwNjE5Mjk1._V1_QL75_UX140_CR0,2,140,207_.jpg",
        "role": "Luther Stickell"
      },
      {
        "name": "Simon Pegg",
        "imageUrl": "https://m.media-amazon.com/images/M/MV5BNzMwODE1NjA3OV5BMl5BanBnXkFtZTgwNTY5MzM2OTE@._V1_FMjpg_UX1000_.jpg",
        "role": "Benji Dunn"
      }
    ],
    "crew": [
      {
        "name": "Christopher McQuarrie",
        "imageUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRLIxDpkSMXVIrCEc9hmavJBTntYNwXDEkybQ&s",
        "role": "Director"
      },
      {
        "name": "Tom Cruise",
        "imageUrl": "https://m.media-amazon.com/images/M/MV5BMmU1YWU1NmMtMjAyMi00MjFiLWFmZmUtOTc1ZjI5ODkxYmQyXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg",
        "role": "Producer"
      },
      {
        "name": "Lorne Balfe",
        "imageUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQncsPcamx9NaTY-rqAuzSX_-pLD_IzY_rANw&s",
        "role": "Music"
      }
    ]
  },

//Movie 12
  {
    "title": "How to Train Your Dragon",
    "imageUrl": "https://lh3.googleusercontent.com/proxy/csh3plklkMjrbf4qfWCP8E8TJLaC9E8IznR18LgHcQgfLTpayXMHdzD_kqyOaNR4dPC27UygdJBkON6yzXvFxdi1f1v7rGxQym0S7c1K0rYas2SBHA",
    "bigPicture": "https://lh3.googleusercontent.com/proxy/csh3plklkMjrbf4qfWCP8E8TJLaC9E8IznR18LgHcQgfLTpayXMHdzD_kqyOaNR4dPC27UygdJBkON6yzXvFxdi1f1v7rGxQym0S7c1K0rYas2SBHA",
    "rating": 4.8,
    "ratingCount": "500k",
    "metadata": "1h 38m • Animation, Fantasy • U • 2010",
    "screenType": "2D, 3D",
    "language": "English",
    "about": "A young Viking befriends a dragon and changes his village forever.",
    "isNew": true,
    "cast": [
      {
        "name": "Jay Baruchel",
        "imageUrl": "https://m.media-amazon.com/images/M/MV5BMTM5MjY0MzU0OV5BMl5BanBnXkFtZTcwOTE0NDA2NA@@._V1_FMjpg_UX1000_.jpg",
        "role": "Hiccup (Voice)"
      },
      {
        "name": "Gerard Butler",
        "imageUrl": "https://m.media-amazon.com/images/M/MV5BMjE4NDMwMzc4Ml5BMl5BanBnXkFtZTcwMDg4Nzg4Mg@@._V1_FMjpg_UX1000_.jpg",
        "role": "Stoick (Voice)"
      },
      {
        "name": "America Ferrera",
        "imageUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQOAcikHRYzhhi45qgkoR-y-ojNzhVUhiT00A&s",
        "role": "Astrid (Voice)"
      }
    ],
    "crew": [
      {
        "name": "Dean DeBlois",
        "imageUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR95tGM490FrzZaQDO0051FMsdCmum8RpWGGA&s",
        "role": "Director"
      },
      {
        "name": "Chris Sanders",
        "imageUrl": "https://m.media-amazon.com/images/M/MV5BMTg4MDI2NTY0OV5BMl5BanBnXkFtZTgwMTM5ODYxMTE@._V1_FMjpg_UX1000_.jpg",
        "role": "Director"
      },
      {
        "name": "John Powell",
        "imageUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQsVZ_KSP7HiosX1ASK6x2gGmbK-THpIZubDw&s",
        "role": "Music"
      }
    ]
  },

];

//Events list

List<String> eventImages=[
  'assets/images/amusement.png',
  'assets/images/r2.jpeg',
  'assets/images/comedy.png',
  'assets/images/games.png',
  'assets/images/kids.png',
  'assets/images/music.png',
];

//Premier moviedata

List<Map<String, dynamic>> premierMovieData = [
  {
    "title": "Glassmates",
    "imageUrl": "https://assets-in.bmscdn.com/iedb/movies/images/extra/vertical_logo/mobile/thumbnail/xxlarge/glassmates-et00372199-1730716676.jpg",
    "rating": 5.0,
    "ratingCount": "2.5k",
  },
  {
    "title": "Natpuna Ennanu Theriyuma",
    "imageUrl": "https://assets-in.bmscdn.com/iedb/movies/images/extra/vertical_logo/mobile/thumbnail/xxlarge/natpuna-ennanu-theriyuma-et00058078-1678779835.jpg",
    "rating": 5.0,
    "ratingCount": "2.4k",
  },
  {
    "title": "Kaaka Muttai",
    "imageUrl": "https://assets-in.bmscdn.com/iedb/movies/images/extra/vertical_logo/mobile/thumbnail/xxlarge/kaaka-muttai-et00025412-1728300154.jpg",
    "rating": 4.5,
    "ratingCount": "2.2k",
  },
  {
    "title": "Hostel",
    "imageUrl": "https://assets-in.bmscdn.com/iedb/movies/images/website/poster/large/hostel-et00327214-25-05-2022-02-16-59.jpg",
    "rating": 4.5,
    "ratingCount": "2.0k",
  },
  {
    "title": "Kaththi",
    "imageUrl": "https://assets-in.bmscdn.com/iedb/movies/images/website/poster/large/kaththi-et00023580-20-02-2021-06-29-11.jpg",
    "rating": 4.8,
    "ratingCount": "2.0k",
  },
  {
    "title": "Mission Chapter-1",
    "imageUrl": "https://assets-in.bmscdn.com/iedb/movies/images/website/poster/large/mission-chapter-1-et00382276-1710326350.jpg",
    "rating": 4.8,
    "ratingCount": "2.0k",
  },
  {
    "title": "Rasavathi",
    "imageUrl": "https://assets-in.bmscdn.com/iedb/movies/images/website/poster/large/rasavathi-et00397142-1718784969.jpg",
    "rating": 4.8,
    "ratingCount": "2.0k",
  },
];

//Cast Details



//Crew Details


//Date

List<Map<String, dynamic>> dateDetails = [
  {
    "date": "19",
    "day": "Tue",
    "month":"Nov",
  },
  {
    "date": "20",
    "day": "Wed",
    "month":"Nov",
  },
  {
    "date": "21",
    "day": "Fri",
    "month":"Nov",
  },
  {
    "date": "22",
    "day": "Sat",
    "month":"Nov",
  },
  {
    "date": "23",
    "day": "Sun",
    "month":"Nov",
  },
  {
    "date": "24",
    "day": "Mon",
    "month":"Nov",
  },
  {
    "date": "25",
    "day": "Tue",
    "month":"Nov",
  },

];

//Price Ranges

List<String> priceRange=[
  "0-100",
  "100-200",
  "200-300",
  "300-400",
  "400-500",
  "500-600",
  "600-700",
  "700-800",
  "800-900",
  "900-1000",
];

//Show Timings

List<String> showTimings=[
  "09:00 AM",
  "11:00 AM",
  "03:00 PM",
  "06:00 PM",
  "08:00 PM",
];

//Seat Options

List<Map<String, dynamic>> seatOptions = [
  {
    "number": 1,
    "image": "assets/images/bicycle.png",
  },
  {
    "number": 2,
    "image": "assets/images/bycicle.png",
  },
  {
    "number": 3,
    "image": "assets/images/autorickshaw.png",
  },
  {
    "number": 4,
    "image": "assets/images/car.png",
  },
  {
    "number": 5,
    "image": "assets/images/suv.png",
  },


];