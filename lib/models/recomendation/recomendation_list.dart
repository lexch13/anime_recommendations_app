import 'package:boilerplate/models/recomendation/recomendation.dart';

class RecomendationList {
  final List<Recomendation> recomendations;
  List<Recomendation> cachedRecomendations;

  RecomendationList({
    this.recomendations,
  });

  factory RecomendationList.fromJson(List<dynamic> json) {
    List<Recomendation> recs = List<Recomendation>();
    recs = json.map((anime) => Recomendation.fromMap(anime)).toList();

    return RecomendationList(
      recomendations: recs,
    );
  }
}
