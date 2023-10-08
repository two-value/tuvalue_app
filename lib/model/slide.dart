import 'package:flutter/material.dart';

class Slide {
  final String imageUrl;
  final String title;
  final String description;

  Slide({
    @required this.imageUrl,
    @required this.title,
    @required this.description,
  });
}

final slideList = [
  Slide(
    imageUrl: 'assets/images/slider1.png',
    title: 'Simple',
    description:
        'Together we transform communication globally. Make your own valuable media and share stories to the world.',
  ),
  Slide(
    imageUrl: 'assets/images/slider2.png',
    title: 'Powerful',
    description:
        'Imagine having a platform that can speak out loud for your business. '
        'What you can do with it the limit is your imagination.',
  ),
  Slide(
    imageUrl: 'assets/images/slider3.png',
    title: 'Friendly',
    description:
        '2value is meant to be the means of communication between companies and journalists. '
        'Being boring is never an option.',
  ),
];
