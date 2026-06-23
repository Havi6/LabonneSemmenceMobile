import 'package:flutter/material.dart';
import 'package:la_bonne_semence_mobile/theme/app_colors.dart';
import 'package:la_bonne_semence_mobile/widget/reveal_item.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Administration", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.dashboard_outlined), text: "Dashboard"),
              Tab(icon: Icon(Icons.people_outline), text: "Membres"),
              Tab(icon: Icon(Icons.event_note_outlined), text: "Évènements"),
              Tab(icon: Icon(Icons.mic_none_outlined), text: "Sermons"),
              Tab(icon: Icon(Icons.photo_library_outlined), text: "Galerie"),
              Tab(icon: Icon(Icons.volunteer_activism_outlined), text: "Dons"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDashboardTab(isDark),
            _buildMembersTab(isDark),
            _buildEventsTab(isDark),
            _buildSermonsTab(isDark),
            _buildGalleryTab(isDark),
            _buildDonationsTab(isDark),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: DASHBOARD ---
  Widget _buildDashboardTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RevealItem(child: Text("Statistiques Globales", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.2, // Ajusté pour plus de hauteur par rapport à 1.5
            children: [
              _buildStatCard("Membres", "1,240", Icons.people, Colors.blue),
              _buildStatCard("Sermons", "85", Icons.mic, Colors.orange),
              _buildStatCard("Évènements", "12", Icons.event, Colors.green),
              _buildStatCard("Dons (Mois)", "4.5M", Icons.payments, Colors.purple),
            ],
          ),
          const SizedBox(height: 30),
          const RevealItem(delay: Duration(milliseconds: 200), child: Text("Activités Récentes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 15),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: AppColors.primary, child: Icon(Icons.notifications_none, color: Colors.white)),
                title: Text("Nouvel inscrit : Membre #${index + 100}"),
                subtitle: const Text("Il y a 2 heures"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: MEMBRES ---
  Widget _buildMembersTab(bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Rechercher un membre...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) => ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text("Jean Philippe #${index + 1}"),
              subtitle: Text("membre$index@email.com"),
              trailing: IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
            ),
          ),
        ),
      ],
    );
  }

  // --- TAB 3: ÉVÈNEMENTS ---
  Widget _buildEventsTab(bool isDark) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.only(bottom: 15),
          child: Column(
            children: [
              ListTile(
                title: Text("Culte de louange #${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Date: 12/12/2023 - Lieu: Temple"),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(child: Text("Modifier")),
                    const PopupMenuItem(child: Text("Supprimer", style: TextStyle(color: Colors.red))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB 4: SERMONS ---
  Widget _buildSermonsTab(bool isDark) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.upload_file, color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (context, index) => ListTile(
          leading: const Icon(Icons.audio_file_outlined, color: AppColors.primary),
          title: Text("Sermon sur la grâce part ${index + 1}"),
          subtitle: const Text("Pasteur Jean Dupont - 45:00"),
          trailing: const Icon(Icons.more_vert),
        ),
      ),
    );
  }

  // --- TAB 5: GALERIE ---
  Widget _buildGalleryTab(bool isDark) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_a_photo, color: Colors.white),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 12,
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
            image: const DecorationImage(
              image: NetworkImage("https://picsum.photos/200"),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 0,
                child: IconButton(icon: const Icon(Icons.delete, color: Colors.white, size: 20), onPressed: () {}),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB 6: DONS ---
  Widget _buildDonationsTab(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          color: AppColors.primary.withOpacity(0.1),
          child: Column(
            children: [
              const Text("Total des dons ce mois"),
              const SizedBox(height: 10),
              Text("4,520,000 FCFA", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 15,
            itemBuilder: (context, index) => ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.arrow_downward, color: Colors.white, size: 16)),
              title: Text("Don de Membre #${index + 1}"),
              subtitle: const Text("Dîme - 14 Oct. 2023"),
              trailing: const Text("50,000 F", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
