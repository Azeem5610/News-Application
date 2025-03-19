import 'dart:convert';
import 'dart:core';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:news_application/Modals/headlines_model.dart';
import 'package:news_application/View/news_categories.dart';
import 'package:news_application/View/news_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum FilterList {AlJazeeraNews, bbcNews, espnNews, cnnNews}

class _HomeScreenState extends State<HomeScreen> {
  FilterList? selectedMenu;

  final format = DateFormat("MMMM dd, yyyy");
  
  Future<FetchHeadlines> fetchHeadlinesApi() async {
    String URL = 'https://newsapi.org/v2/top-headlines?sources=$name&apiKey=d6de33fe3fed40b59c8ba2e87a3b2407';
    final response = await http.get(Uri.parse(URL));
    if (kDebugMode) {
      print(response.body);
    }
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return FetchHeadlines.fromJson(body);
    } else {
      throw Exception('Error');
    }
  }
  
  String name = 'al-jazeera-english';
  
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "GLOBAL ",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              TextSpan(
                text: "NEWS",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        leading: Container(
          margin: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => NewsCategories()));
            },
            icon: Icon(Icons.grid_view_outlined, size: 22.sp, color: Colors.black87),
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: PopupMenuButton(
              icon: Icon(Icons.filter_list, color: Colors.black87, size: 22.sp),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              onSelected: (FilterList items) {
                setState(() {
                  if (FilterList.AlJazeeraNews.name == items.name) {
                    name = 'al-jazeera-english';
                  } else if (FilterList.bbcNews.name == items.name) {
                    name = 'bbc-news';
                  } else if (FilterList.cnnNews.name == items.name) {
                    name = 'cnn';
                  } else if (FilterList.espnNews.name == items.name) {
                    name = 'espn';
                  }
                });
              },
              itemBuilder: (context) => <PopupMenuEntry<FilterList>>[
                PopupMenuItem(
                  value: FilterList.AlJazeeraNews,
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 10.sp, color: Colors.blue),
                      SizedBox(width: 10.w),
                      Text("Al-Jazeera NEWS"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: FilterList.bbcNews,
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 10.sp, color: Colors.red),
                      SizedBox(width: 10.w),
                      Text("BBC NEWS"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: FilterList.cnnNews,
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 10.sp, color: Colors.orange),
                      SizedBox(width: 10.w),
                      Text("CNN NEWS"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: FilterList.espnNews,
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 10.sp, color: Colors.green),
                      SizedBox(width: 10.w),
                      Text("ESPN NEWS"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              "Breaking News",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 8.h),

          SizedBox(
            height: height * 0.5,
            child: FutureBuilder(
              future: fetchHeadlinesApi(),
              builder: (context, AsyncSnapshot<FetchHeadlines> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: SpinKitFadingCircle(
                      color: Colors.blue[700],
                      size: 50.sp,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 50.sp, color: Colors.red),
                        SizedBox(height: 10.h),
                        Text(
                          "Failed to load news",
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.articles!.length,
                  itemBuilder: (context, index) {
                    DateTime dateTime = DateTime.parse(snapshot.data!.articles![index].publishedAt.toString());
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewsDetailScreen(
                              author: snapshot.data!.articles![index].author.toString(),
                              date: format.format(dateTime),
                              title: snapshot.data!.articles![index].title.toString(),
                              image: snapshot.data!.articles![index].urlToImage.toString(),
                              source: snapshot.data!.articles![index].source!.name.toString(),
                              description: snapshot.data!.articles![index].description.toString(),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: width * 0.8,
                        margin: EdgeInsets.symmetric(horizontal: 8.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20.r),
                              child: CachedNetworkImage(
                                height: height * 0.5,
                                width: width * 0.8,
                                fit: BoxFit.cover,
                                imageUrl: snapshot.data!.articles![index].urlToImage.toString(),
                                placeholder: (context, url) => Center(
                                  child: SpinKitPulse(
                                    color: Colors.blue[700],
                                    size: 30.sp,
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[300],
                                  child: Icon(Icons.error, color: Colors.red),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.r),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.3),
                                      Colors.black.withOpacity(0.8),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 16.h,
                              left: 16.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  snapshot.data!.articles![index].source!.name.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(16.r),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      snapshot.data!.articles![index].title.toString(),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 14.sp, color: Colors.white70),
                                        SizedBox(width: 4.w),
                                        Text(
                                          format.format(dateTime),
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: 24.h),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[900]!],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(15.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  "TOP HEADLINES",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          FutureBuilder(
            future: fetchHeadlinesApi(),
            builder: (context, AsyncSnapshot<FetchHeadlines> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: SpinKitThreeBounce(
                    color: Colors.blue[700],
                    size: 30.sp,
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text("Error loading headlines"),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.articles!.length,
                itemBuilder: (context, index) {
                  DateTime dateTime = DateTime.parse(snapshot.data!.articles![index].publishedAt.toString());
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewsDetailScreen(
                            author: snapshot.data!.articles![index].author.toString(),
                            date: format.format(dateTime),
                            title: snapshot.data!.articles![index].title.toString(),
                            image: snapshot.data!.articles![index].urlToImage.toString(),
                            source: snapshot.data!.articles![index].source!.name.toString(),
                            description: snapshot.data!.articles![index].description.toString(),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15.r),
                              bottomLeft: Radius.circular(15.r),
                            ),
                            child: CachedNetworkImage(
                              height: 100.h,
                              width: 100.w,
                              fit: BoxFit.cover,
                              imageUrl: snapshot.data!.articles![index].urlToImage.toString(),
                              placeholder: (context, url) => Center(
                                child: SpinKitFadingCube(
                                  color: Colors.blue[700],
                                  size: 20.sp,
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: Icon(Icons.error, color: Colors.red),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(12.r),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    snapshot.data!.articles![index].title.toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[100],
                                          borderRadius: BorderRadius.circular(4.r),
                                        ),
                                        child: Text(
                                          snapshot.data!.articles![index].source!.name.toString(),
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.blue[700],
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      Icon(
                                        Icons.access_time,
                                        size: 12.sp,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        format.format(dateTime),
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}