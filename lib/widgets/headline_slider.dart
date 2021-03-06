import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:justnews/bloc/get_top_headlines_bloc.dart';
import 'package:justnews/bloc/get_top_ngheadlines_bloc.dart';
import 'package:justnews/elements/error_element.dart';
import 'package:justnews/elements/loader_element.dart';
import 'package:justnews/model/article.dart';
import 'package:justnews/model/article_response.dart';
import 'package:justnews/screens/tabs/news_details.dart';
import 'package:timeago/timeago.dart' as timeago;

class HeadlineSliderWidget extends StatefulWidget {
  @override
  _HeadlineSliderWidgetState createState() => _HeadlineSliderWidgetState();
}

class _HeadlineSliderWidgetState extends State<HeadlineSliderWidget> {
  @override
  void initState() {
    super.initState();
    getTopHeadlinesBloc.getHeadlines();
    getTopNgHeadlinesBloc.getNgHeadlines();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ArticleResponse>(
      stream: getTopNgHeadlinesBloc.subject.stream,
      builder: (context, AsyncSnapshot<ArticleResponse> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.error != null && snapshot.data.error.length < 0) {
            return buildErrorWidget(snapshot.error);
          }
          return _buildHeadlineSlider(snapshot.data);
        } else if (snapshot.hasError) {
          return buildErrorWidget(snapshot.error);
        } else {
          return buildLoadingWidget();
        }
      },
    );
  }

  Widget _buildHeadlineSlider(ArticleResponse data) {
    List<ArticleModel> articles = data.articles;
    return Container(
      child: CarouselSlider(
        options: CarouselOptions(
            enlargeCenterPage: false, height: 200, viewportFraction: 0.9),
        items: getExpenseSliders(articles),
      ),
    );
  }

  getExpenseSliders(List<ArticleModel> articles) {
    return articles
        .map((article) => GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NewsDetails(article: article)));
              },
              child: Container(
                padding:
                    EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          shape: BoxShape.rectangle,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: article.img == null
                                  ? AssetImage("assets/images/placeholder.jpg")
                                  : NetworkImage(article.img))),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              stops: [
                                0.1,
                                0.9
                              ],
                              colors: [
                                Colors.black.withOpacity(0.9),
                                Colors.white.withOpacity(0)
                              ])),
                    ),
                    Positioned(
                      bottom: 30,
                      child: Container(
                        //  color: Colors.black.withOpacity(0.5),
                        padding: EdgeInsets.only(left: 10, right: 10),
                        width: 250,
                        child: Column(
                          children: [
                            Text(
                              article.title,
                              style: TextStyle(
                                  height: 1.5,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            )
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Text(
                        article.source.name,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 9,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Text(
                        timeAgo(DateTime.parse(article.date)),
                        style: TextStyle(color: Colors.white54, fontSize: 9),
                      ),
                    ),
                  ],
                ),
              ),
            ))
        .toList();
  }

  String timeAgo(DateTime date) {
    return timeago.format(date, allowFromNow: true, locale: 'en');
  }
}
