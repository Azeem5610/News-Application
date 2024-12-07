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
enum FilterList {AlJazeeraNews,bbcNews,espnNews,cnnNews}
class _HomeScreenState extends State<HomeScreen> {
  FilterList? selectedMenu;
  
  final format=DateFormat("MMMM dd, yyyy");
  Future<FetchHeadlines>fetchHeadlinesApi()async{
    String URL='https://newsapi.org/v2/top-headlines?sources=$name&apiKey=d6de33fe3fed40b59c8ba2e87a3b2407';
  final response=await http.get(Uri.parse(URL));
  if(kDebugMode){
      print(response.body);
    }
  if(response.statusCode==200){
    final body=jsonDecode(response.body);
    return FetchHeadlines.fromJson(body);
  }else{
    throw Exception('Error');
  }

  }
  String name='al-jazeera-english';
  @override
  Widget build(BuildContext context) {
    
    double width=MediaQuery.of(context).size.width;
    double height=MediaQuery.of(context).size.height;
    return Scaffold( 
      appBar: AppBar( 
        title: Text("NEWS",style: TextStyle(fontSize: 21.sp,fontWeight: FontWeight.bold),),
        centerTitle: true,
        leading: IconButton(onPressed:() {
          Navigator.push(context, MaterialPageRoute(builder:(context) => NewsCategories(),));
        }, icon: Icon(Icons.grid_view_outlined,size:26.sp,)),
        actions: [ 
          PopupMenuButton(
            
            // initialValue: FilterList.AlJazeeraNews,
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
  }
  
  );
},
            itemBuilder:(context) =><PopupMenuEntry<FilterList>> [
            
            const PopupMenuItem(
              value: FilterList.AlJazeeraNews,
              child: Text("Al-Jazeera NEWS")
            ),
            const PopupMenuItem(
              value: FilterList.bbcNews,
              child: Text("BBC NEWS")
            ),
            const PopupMenuItem(
              value: FilterList.cnnNews,
              child: Text("CNN NEWS")
            ),
            const PopupMenuItem(
              value: FilterList.espnNews,
              child: Text("ESPN NEWS")
            ),
        ])
        ],
      ),
      body: ListView(
        
        children: [
          SizedBox(
            height: height*.55,
          child: FutureBuilder(future: fetchHeadlinesApi(), builder:(context,AsyncSnapshot<FetchHeadlines>snapshot) {
            
            if (snapshot.connectionState==ConnectionState.waiting){
              return  const SpinKitSpinningLines(color: Colors.blue);
            }else if(snapshot.hasError){
              throw Exception('Error');
            }
            return ListView.builder(
              
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.articles!.length,
              itemBuilder:(context, index) {
               DateTime dateTime=DateTime.parse(snapshot.data!.articles![index].publishedAt.toString());
                return InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => NewsDetailScreen(
                      author: snapshot.data!.articles![index].author.toString(),
                      date: format.format(dateTime),
                      title: snapshot.data!.articles![index].title.toString(),
                      image: snapshot.data!.articles![index].urlToImage.toString(),
                      source: snapshot.data!.articles![index].source!.name.toString(),
                      description: snapshot.data!.articles![index].description.toString(),
                      
                      )));
                  },
                  child: SizedBox( 
                    child: 
                      Stack(
                                               
                        alignment: Alignment.center,
                        children:[ 
                          Container(
                            height: height*0.6,
                            width: width*0.9,
                          child: Padding(
                            padding:  EdgeInsets.symmetric(
                              horizontal: width*0.04
                              ),
                            child: ClipRRect(
                              
                              borderRadius: BorderRadius.circular(15),
                              child: CachedNetworkImage(
                                
                                fit: BoxFit.fill,
                                imageUrl:snapshot.data!.articles![index].urlToImage.toString(),
                                placeholder: (context, url) => Center(child:SpinKitSpinningLines(color: Colors.blue,)),
                                errorWidget: (context, url, error) => Center(child: Icon(Icons.error,color: Colors.red,)),
                              ),
                            ),
                          ),
                        ),
                         Positioned(
                          bottom: 20.h,
                         child: SizedBox(
                          width: width*0.8,
                           child: Card(
                           elevation: 5,
                           shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(13).r,
                           ),
                          child: Padding(
                          padding: EdgeInsets.all(12).r,  
                          child: Container(
                          width: width * 0.8,  
                          child: Column(
                            mainAxisSize: MainAxisSize.min,  
                           crossAxisAlignment: CrossAxisAlignment.start,  
                              children: [
                                Text(
                               snapshot.data!.articles![index].title.toString(),                         
                                 maxLines: 3,
                             overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                              fontSize: 17.sp,
                             fontWeight: FontWeight.bold,
                              ),
                           ),
                                                SizedBox(height: 10),  // Add space between title and source row
                                                 Row(
                                                children: [
                                                 Text(
                                              snapshot.data!.articles![index].source!.name.toString(),
                                             style: TextStyle(fontSize: 14.sp, color: Colors.blue),
                                             ),
                                           Spacer(),
                                           Text(
                                             format.format(dateTime),
                                             style: TextStyle(fontSize: 14.sp, color: Colors.blue),
                                           ),
                                         ],
                                       ),
                                     ],
                                   ),
                                 ),
                               ),
                             ),
                         ),
                  )
                  
                   ]
                      )
                    
                   ),
                );
   },);
    },),
        ),
        SizedBox(height:20.h),
        Center(
          child: Container(
  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
  margin: EdgeInsets.symmetric(vertical: 10),
  decoration: BoxDecoration(
    color: Colors.red.shade50, 
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.red.withOpacity(0.2),
        spreadRadius: 2.r,
        blurRadius: 5.r,
        offset: Offset(0, 3), 
      ),
    ],
    border: Border.all(
      color: Colors.red.shade200,
      width: 1.w,
    ),
  ),
  child: Center(
    child: Text(
      "TOP HEADLINES",
      style: TextStyle(
        fontSize: 20.sp, 
        fontWeight: FontWeight.bold,
        color: Colors.red.shade800, // Darker red for text
      ),
    ),
  ),
),

        )
     ] ),
    );
  }
}