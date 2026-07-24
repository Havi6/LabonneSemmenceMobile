import 'package:flutter/material.dart';
import 'package:la_bonne_semence_mobile/theme/app_colors.dart';
import 'package:la_bonne_semence_mobile/services/responsive_utils.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("À propos de nous")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.pageHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              "Héritage et Intégration",
              const Text("Une église, Un seul corps : le Christ."),
            ),
            _buildSection(
              context,
              "INTRODUCTION",
              const Text(
                "La bonne semence est cette église qui a vu le jour en 1992 avec son grand visionnaire, le patriarche Jean Médard Kalonda Bin Baruani. La bonne semence croit et enseigne que Jesus-christ est le seul Sauveur et Seigneur du monde. Jean 3 : 16 « Car Dieu a tant aimé le monde qu'il a donné son fils unique afin que quiconque croit en lui ne périsse point mais qu'il ait la vie éternelle. » Le salut des âmes est le premier objectif que poursuit la bonne semence. Matthieu 28 : 19 « Allez, faites de toutes les nations des disciples les baptisants au nom du Père, du Fils et du Saint-Esprit. » Nous croyons en un seul et unique vrai Dieu qui s'est révélé sous trois dimensions.",
                textAlign: TextAlign.justify,
              ),
            ),
            _buildSection(
              context,
              "LE PATRIARCHE JEAN MEDARD",
              const Text(
                "Le patriarche Jean Médard Bin Baruani est un ancien musulman. Après avoir renoncé à l'islam en 1980, il crut à l'évangile du pasteur Jean Momu. Sous la conduite de ce dernier, le patriarche devient un grand sauveur d'âmes ainsi que le président du département de l'évangelisation à l'église viens et vois. En 1992, il reçut la vision de bâtir trois édifices pour le seigneur, d'où la naissance de l'église la Bonne Semence. En 2015 débuta la grande vision de la naissance de la communauté des assemblées Bonne Semence, CABCS.",
                textAlign: TextAlign.justify,
              ),
            ),
            _buildSection(
              context,
              "QUI CONDUIT ET DIRIGE LA BONNE SEMENCE ?",
              const Text(
                "Depuis la mort de son Bishop en Septembre 2020, la Bonne Semence est dirigée par le Pasteur Djoe Baruani, fils biologique du Pasteur Jean Médard. Après avoir vécu plus de vingt ans en Europe, le Pasteur Djoe Baruani a accepté l'appel de Dieu d'une manière inconditionnelle étant l'ami du Saint-Esprit. Le pasteur Djoe voit dans son ministère l'accomplissement des promesses bibliques écrites dans Marc 16 : 17 - 18",
                textAlign: TextAlign.justify,
              ),
            ),
            _buildSection(
              context,
              "Notre église",
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("La bonne semence s'ancre sur quatre bases :"),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SizedBox(
                        width: context.screenWidth < 500
                            ? double.infinity
                            : (context.screenWidth -
                                      (context.pageHorizontalPadding * 2) -
                                      8) /
                                  2,
                        child: _buildInfoCard(
                          "Le mystère de l'église",
                          "Aimer Dieu ainsi que son prochain est la source et le sommet de toute la vie chrétienne",
                        ),
                      ),
                      SizedBox(
                        width: context.screenWidth < 500
                            ? double.infinity
                            : (context.screenWidth -
                                      (context.pageHorizontalPadding * 2) -
                                      8) /
                                  2,
                        child: _buildInfoCard(
                          "La consolation et la compassion",
                          "Soutenir mutuellement les familles dans l’affliction, la solitude ou la détresse financière",
                        ),
                      ),
                      SizedBox(
                        width: context.screenWidth < 500
                            ? double.infinity
                            : (context.screenWidth -
                                      (context.pageHorizontalPadding * 2) -
                                      8) /
                                  2,
                        child: _buildInfoCard(
                          "L'accompagnement des enfants",
                          "Être là et accompagner tous les enfants dans leur marche sur le chemin de la foi.",
                        ),
                      ),
                      SizedBox(
                        width: context.screenWidth < 500
                            ? double.infinity
                            : (context.screenWidth -
                                      (context.pageHorizontalPadding * 2) -
                                      8) /
                                  2,
                        child: _buildInfoCard(
                          "L’Engagement",
                          "La foi s’exprime concrètement par les œuvres d’amour fraternel.",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, Widget content) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Container(height: 2, width: 40, color: AppColors.primary),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String description) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.all(4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
