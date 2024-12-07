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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                selectedCategory = categoryList[index];
                _fetchNewsData(); 
              });
            },
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.bold),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,
            indicator: ShapeDecoration(
              color: Colors.deepPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            isScrollable: true,
            tabs: categoryList
                .map((category) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Tab(text: category),
                    ))
                .toList(),
          ),
        ),
        body: FutureBuilder(
          future: _newsData,
          builder: (context, AsyncSnapshot<CategoriesModel> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: SpinKitSpinningLines(color: Colors.blue));
            } else if (snapshot.hasError) {
              return Center(child: Text('Error fetching news'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.articles!.length,
                itemBuilder: (context, index) {
                  DateTime datetime = DateTime.parse(snapshot.data!.articles![index].publishedAt.toString());
                  return InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder:(context) => CategpryDetail(
                        author: snapshot.data!.articles![index].author.toString(),
                         date: format.format(datetime),
                          image: snapshot.data!.articles![index].urlToImage.toString(),
                           source: snapshot.data!.articles![index].source!.name.toString(),
                           title: snapshot.data!.articles![index].title.toString(),
                           description: snapshot.data!.articles![index].description.toString(),
                           ),));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 180.h,
                          width: 160.w,
                          child: Padding(
                            padding: EdgeInsets.all(11.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15.r),
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: snapshot.data!.articles![index].urlToImage.toString(),
                                placeholder: (context, url) => Center(child: SpinKitSpinningLines(color: Colors.blue)),
                                errorWidget: (context, url, error) => Center(child: Image.asset("images/replace.png")),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Padding(
                            padding:  EdgeInsets.only(top:10.h,right:5.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data!.articles![index].title.toString(),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 15.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        snapshot.data!.articles![index].source!.name.toString(),
                                        style: TextStyle(fontSize: 14.sp, color: Colors.blue),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    SizedBox(width: 5.w),
                                    Text(
                                      format.format(datetime),
                                      style: TextStyle(fontSize: 14.sp, color: Colors.blue),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
