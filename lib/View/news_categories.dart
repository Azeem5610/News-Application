import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:news_application/Modals/categories_model.dart';
import 'package:http/http.dart' as http;
import 'package:news_application/View/home_screen.dart';
import 'package:news_application/View/news_category_detail_scree.dart';

class NewsCategories extends StatefulWidget {
  NewsCategories({super.key});

  @override
  State<NewsCategories> createState() => _NewsCategoriesState();
}

class _NewsCategoriesState extends State<NewsCategories> {
  final format = DateFormat("MMMM dd");
  List<String> categoryList = [
    "General",
    "Business",
    "Entertainment",
    "Health",
    "Science",
    "Sports",
    "Technology"
  ];
  
  // Category icons mapping
  Map<String, IconData> categoryIcons = {
    "General": Icons.public,
    "Business": Icons.business,
    "Entertainment": Icons.movie,
    "Health": Icons.health_and_safety,
    "Science": Icons.science,
    "Sports": Icons.sports_soccer,
    "Technology": Icons.computer
  };
  
  Future<CategoriesModel> fetchCategories(String category) async {
    final String url =
        'https://newsapi.org/v2/everything?q=$category&apiKey=d6de33fe3fed40b59c8ba2e87a3b2407';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return CategoriesModel.fromJson(body);
    } else {
      throw Exception('Error fetching $category news');
    }
  }
  
  String selectedCategory = "General"; 
  Future<CategoriesModel>? _newsData;

  @override
  void initState() {
    super.initState();
    _fetchNewsData(); 
  }

  void _fetchNewsData() {
    setState(() {
      _newsData = fetchCategories(selectedCategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categoryList.length,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "NEWS ",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                TextSpan(
                  text: "CATEGORIES",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700],
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
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back, size: 22.sp, color: Colors.black87),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60.h),
            child: Container(
              height: 60.h,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TabBar(
                onTap: (index) {
                  setState(() {
                    selectedCategory = categoryList[index];
                    _fetchNewsData(); 
                  });
                },
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: TextStyle(
                  fontSize: 14.sp, 
                  fontWeight: FontWeight.bold,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black87,
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[700]!, Colors.purple[700]!],
                  ),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                isScrollable: true,
                tabs: categoryList.map((category) => 
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                    child: Row(
                      children: [
                        Icon(categoryIcons[category] ?? Icons.article, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(category),
                      ],
                    ),
                  ),
                ).toList(),
              ),
            ),
          ),
        ),
        body: FutureBuilder(
          future: _newsData,
          builder: (context, AsyncSnapshot<CategoriesModel> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SpinKitFadingCircle(
                  color: Colors.purple[700],
                  size: 50.sp,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 50.sp, color: Colors.red[400]),
                    SizedBox(height: 16.h),
                    Text(
                      'Failed to load ${selectedCategory.toLowerCase()} news',
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 8.h),
                    ElevatedButton(
                      onPressed: _fetchNewsData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (snapshot.data!.articles!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off_rounded, size: 50.sp, color: Colors.grey[500]),
                    SizedBox(height: 16.h),
                    Text(
                      'No ${selectedCategory.toLowerCase()} news found',
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
                    ),
                  ],
                ),
              );
            } else {
              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                itemCount: snapshot.data!.articles!.length,
                itemBuilder: (context, index) {
                  DateTime datetime = DateTime.parse(snapshot.data!.articles![index].publishedAt.toString());
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => CategoryDetail(
                            author: snapshot.data!.articles![index].author.toString(),
                            date: format.format(datetime),
                            image: snapshot.data!.articles![index].urlToImage.toString(),
                            source: snapshot.data!.articles![index].source!.name.toString(),
                            title: snapshot.data!.articles![index].title.toString(),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 120.w,
                            height: 120.h,
                            margin: EdgeInsets.all(12.r),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: snapshot.data!.articles![index].urlToImage.toString(),
                                placeholder: (context, url) => Center(
                                  child: SpinKitPulse(
                                    color: Colors.purple[700],
                                    size: 30.sp,
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[300],
                                  child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      selectedCategory,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.purple[700],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    snapshot.data!.articles![index].title.toString(),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14.sp, 
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.source_outlined, 
                                              size: 14.sp,
                                              color: Colors.blue[700],
                                            ),
                                            SizedBox(width: 4.w),
                                            Expanded(
                                              child: Text(
                                                snapshot.data!.articles![index].source!.name.toString(),
                                                style: TextStyle(
                                                  fontSize: 12.sp, 
                                                  color: Colors.blue[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today, 
                                            size: 14.sp,
                                            color: Colors.grey[600],
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            format.format(datetime),
                                            style: TextStyle(
                                              fontSize: 12.sp, 
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}