import 'package:boilerplate/models/recomendation/recomendation_list.dart';
import 'package:boilerplate/routes.dart';
import 'package:boilerplate/stores/language/language_store.dart';
import 'package:boilerplate/stores/anime/anime_store.dart';
import 'package:boilerplate/stores/theme/theme_store.dart';
import 'package:boilerplate/stores/user/user_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/widgets/anime_grid_tile.dart';
import 'package:boilerplate/widgets/anime_list_tile.dart';
import 'package:boilerplate/widgets/progress_indicator_widget.dart';
import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_dialog/material_dialog.dart';
import 'package:provider/provider.dart';
import 'package:boilerplate/models/anime/anime.dart';

class SimilarAnimes extends StatefulWidget {
  @override
  _SimilarAnimesState createState() => _SimilarAnimesState();
}

class _SimilarAnimesState extends State<SimilarAnimes> {
  //stores:---------------------------------------------------------------------
  AnimeStore _animeStore;
  ThemeStore _themeStore;
  LanguageStore _languageStore;
  UserStore _userStore;
  Anime _anime;

  RecomendationList _recomendationsList;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_animeStore == null &&
        _themeStore == null &&
        _languageStore == null &&
        _userStore == null) {
      // initializing stores
      _languageStore = Provider.of<LanguageStore>(context);
      _themeStore = Provider.of<ThemeStore>(context);
      _userStore = Provider.of<UserStore>(context);
      _animeStore = Provider.of<AnimeStore>(context);

      _anime = ModalRoute.of(context).settings.arguments;

      _animeStore
          .querrySImilarItems(_anime.dataId.toString())
          .then((value) => setState(() => _recomendationsList = value));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Similar"),
        ),
        body: _buildMainContent());
  }

  Widget _buildMainContent() {
    return Observer(
      builder: (context) {
        return _animeStore.isLoading
            ? CustomProgressIndicatorWidget()
            : Material(child: _buildGridView());
      },
    );
  }

  Widget _buildGridView() {
    return _recomendationsList != null
        ? GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.5,
            ),
            itemCount: _recomendationsList.recomendations.length,
            itemBuilder: (context, index) {
              return _buildGridItem(index);
            },
          )
        : Center(
            child: Text(
              AppLocalizations.of(context).translate('home_tv_no_post_found'),
            ),
          );
  }

  Widget _buildGridItem(int position) {
    Anime animeItem = _animeStore.animeList.animes.firstWhere(
        (anime) =>
            anime.dataId.toString() ==
            _recomendationsList.recomendations[position].item.toString(),
        orElse: () => null);

    if (animeItem == null)
      animeItem = Anime(id: "0", dataId: 0, name: "noname", imgUrl: "");
    final isLiked = _userStore.isLikedAnime(animeItem.dataId);
    final isLater = _userStore.isLaterAnime(animeItem.dataId);
    final isBlack = _userStore.isBlackListedAnime(animeItem.dataId);

    return AnimeGridTile(
        anime: animeItem, isLiked: isLiked, isLater: isLater, isBlack: isBlack);
  }
}