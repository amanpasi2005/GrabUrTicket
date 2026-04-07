import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

class TopCarousel extends StatefulWidget {
  const TopCarousel({super.key});

  @override
  State<TopCarousel> createState() => _TopCarouselState();
}

class _TopCarouselState extends State<TopCarousel> {

  @override
  Widget build(BuildContext context) {
    List<Widget> carouselItem=[
    Padding(
      padding: const EdgeInsets.all(6.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          'https://cdn.cgmagonline.com/wp-content/uploads/2020/04/avengers-endgame-and-infinity-war-directors-want-their-hits-to-return-to-theaters-2.jpg',
          fit: BoxFit.cover,
          height: 150,
          width: MediaQuery.of(context).size.width-40,
        ),
      ),
    ),
      Padding(
        padding: const EdgeInsets.all(6.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            'https://i0.wp.com/staticmultimedia.com/wp-content/uploads/2023/10/christopher-nolans-oppenheimer-c.jpg?fit=1280%2C720&ssl=1',
            fit: BoxFit.cover,
            height: 150,
            width: MediaQuery.of(context).size.width-40,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(6.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            'https://fulminofan.com/wp-content/uploads/2022/03/Indian-Movies-in-IMAX.jpg',
            fit: BoxFit.cover,
            height: 150,
            width: MediaQuery.of(context).size.width-40,
          ),
        ),
      ),
    ];
    // ignore: avoid_unnecessary_containers
    return Container(
      child: FlutterCarousel(
        items: carouselItem,
        options: FlutterCarouselOptions(
          height: 200,
          enableInfiniteScroll: true,
          viewportFraction: 0.8,
          autoPlay: true,
          showIndicator: false,
        ),
      ),
    );
  }
}