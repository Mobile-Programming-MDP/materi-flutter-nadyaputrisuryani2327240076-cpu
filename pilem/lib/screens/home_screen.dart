import 'package:flutter/material.dart';
import 'package:pilem/models/movie.dart';
import 'package:pilem/services/api_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiServices = ApiService();

  List<Movie> allMovies = [];
  List<Movie> trendingMovie = [];
  List<Movie> popularMovie = [];
  List<Movie> _popularMovies = [];

  Future<void> _loadMovies() async {
  final List<Map<String, dynamic>> allMoviesData =
      await apiServices.getAllMovies();

  final List<Map<String, dynamic>> trendingMoviesData =
      await apiServices.getTrendingMovies();

  final List<Map<String, dynamic>> popularMoviesData =
      await apiServices.getPopularMovies();

  setState(() {
      allMovies = allMoviesData.map((e) => Movie.fromJson(e)).toList();
     trendingMovie =
        trendingMoviesData.map((e) => Movie.fromJson(e)).toList();
    _popularMovies =
        popularMoviesData.map((e) => Movie.fromJson(e)).toList();
  });
}
  @override
  void initState() {
    
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pilem"),
      ),
      body : SingleChildScrollView (child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           
        ],
      ))
    
    );
  }
}