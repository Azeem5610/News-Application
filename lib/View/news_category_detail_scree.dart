import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategpryDetail extends StatefulWidget {
  String source,image,title,description,date,author;
   CategpryDetail({
    super.key,
    required this.author,
    required this.date,
    required this.image,
    required this.source,
    required this.title,
    required this.description,
   });

  @override
  State<CategpryDetail> createState() => _CategpryDetailState();
}

class _CategpryDetailState extends State<CategpryDetail> {
  @override
  Widget build(BuildContext context) {
       double width=MediaQuery.of(context).size.width;
    double height=MediaQuery.of(context).size.height;
    return Scaffold( 
      appBar: AppBar(),
       body: Column( 
        children: [ 
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ClipRRect(
             borderRadius: BorderRadius.circular(15.r),
              child: SizedBox(
                height: height*0.42,
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: widget.image
                  ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card( 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
             color: Colors.white,
             child: Padding(
               padding: const EdgeInsets.all(8.0),
               child: Column(  
                 children: [ 
                   Text(
                      maxLines: 3,
                      
                      overflow: TextOverflow.ellipsis,
                     widget.title,
                     style: TextStyle(fontSize: 18.sp,fontWeight: FontWeight.bold),
                   ),
                   SizedBox(height: 3.h,),
                   Text( 
                widget.description,
                     style: TextStyle(fontSize: 15.sp),
                   ),
                   SizedBox(height: 7.h,),
                   Row( 
                    children: [ 
                      Text(widget.source,style: TextStyle(color: Colors.blue),),
                      Spacer(),
                      Text(widget.date,style: TextStyle(color: Colors.blue),)
                    ],
                   )
                             
                 ],
               ),
             ),
            ),
          )
        ],
      )
    );
  }
}
    