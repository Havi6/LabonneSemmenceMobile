import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:la_bonne_semence_mobile/services/apiService/api_client.dart';
import 'package:la_bonne_semence_mobile/services/app_data.dart';
import 'package:la_bonne_semence_mobile/services/responsive_utils.dart';
import 'package:la_bonne_semence_mobile/theme/app_colors.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _EditorResult {
  const _EditorResult(this.values, this.files);

  final Map<String, String> values;
  final Map<String, PlatformFile> files;
}

enum _FileInput { image, audio }

class _AdminPageState extends State<AdminPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _isActionInProgress = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool refresh = false}) async {
    setState(() {
      _isLoading = true;
    });

    final tasks = <Future<void>>[
      _safeFetch(() => AppData.fetchSermons(forceRefresh: refresh, authenticated: true), 'Sermons'),
      _safeFetch(() => AppData.fetchEvents(forceRefresh: refresh, authenticated: true), 'Événements'),
      _safeFetch(() => AppData.fetchGallery(forceRefresh: refresh, authenticated: true), 'Galerie'),
      _safeFetch(() => AppData.fetchContacts(forceRefresh: refresh), 'Contacts'),
      _safeFetch(() => AppData.fetchUsers(forceRefresh: refresh), 'Membres'),
      _safeFetch(() => AppData.fetchMotDuPasteur(forceRefresh: refresh, authenticated: true), 'Mots du Pasteur'),
    ];

    await Future.wait(tasks);

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _safeFetch(Future<dynamic> Function() fetch, String label) async {
    try {
      await fetch();
    } catch (error) {
      debugPrint('Error fetching $label: $error');
      if (mounted) {
        _showMessage('Erreur lors du chargement de ($label): ${_message(error)}', error: true);
      }
    }
  }

  Future<void> _deleteSermon(Sermon sermon) async {
    if (sermon.id == null || !await _confirm('Supprimer ce sermon ?')) return;
    await _runAction(() async {
      await AppData.deleteSermon(sermon.id!);
    }, 'Sermon supprimé.');
  }

  Future<void> _deleteEvent(Event event) async {
    if (event.id == null || !await _confirm('Supprimer cet événement ?')) {
      return;
    }
    await _runAction(() async {
      await AppData.deleteEvent(event.id!);
    }, 'Événement supprimé.');
  }

  Future<void> _deletePhoto(GalleryItem photo) async {
    if (photo.id == null || !await _confirm('Supprimer cette photo ?')) return;
    await _runAction(() async {
      await AppData.deleteGalleryItem(photo.id!);
    }, 'Photo supprimée.');
  }

  Future<void> _deleteContact(ContactMessage contact) async {
    if (!await _confirm('Supprimer ce message de contact ?')) return;
    await _runAction(() async {
      await AppData.deleteContact(contact.id);
    }, 'Message supprimé.');
  }

  Future<void> _deleteUser(AppUser user) async {
    if (user.id == null || !await _confirm('Supprimer cet utilisateur ?')) {
      return;
    }
    await _runAction(() async {
      await AppData.deleteUser(user.id!);
    }, 'Utilisateur supprimé.');
  }

  Future<void> _deleteMotDuPasteur(MotDuPasteur mot) async {
    if (mot.id == null || !await _confirm('Supprimer ce message ?')) return;
    await _runAction(() async {
      await AppData.deleteMotDuPasteur(mot.id!);
    }, 'Message supprimé.');
  }

  Future<bool> _confirm(String message) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmation'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Supprimer'),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _runAction(
    Future<void> Function() action,
    String success,
  ) async {
    if (_isActionInProgress) return;
    setState(() => _isActionInProgress = true);
    try {
      await action();
      final serverMsg = AppData.consumeLastServerMessage();
      if (mounted) _showMessage(serverMsg ?? success);
    } catch (error) {
      debugPrint('Admin action error: $error');
      if (mounted) _showMessage(_message(error), error: true);
    } finally {
      if (mounted) setState(() => _isActionInProgress = false);
    }
  }

  String _message(Object error) {
    if (error is ApiException) return error.message;
    final text = error.toString();
    if (text.contains('Connection refused') || text.contains('Network is unreachable')) {
      return 'Impossible de contacter le serveur. Vérifiez votre connexion.';
    }
    if (text.contains('NoSuchMethodError')) {
      return 'Erreur de traitement des données serveur.';
    }
    return 'Une erreur est survenue. Veuillez réessayer.';
  }

  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    final sermons = appData.cachedSermons;
    final events = appData.cachedEvents;
    final gallery = appData.cachedGallery;
    final contacts = appData.cachedContacts;
    final users = appData.cachedUsers;
    final motDuPasteur = appData.cachedMotDuPasteur;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Administration',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: () => _loadData(refresh: true),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined), text: 'Dashboard'),
            Tab(icon: Icon(Icons.people_outline), text: 'Membres'),
            Tab(icon: Icon(Icons.event_note_outlined), text: 'Événements'),
            Tab(icon: Icon(Icons.mic_none_outlined), text: 'Sermons'),
            Tab(icon: Icon(Icons.comment_outlined), text: 'Mots du Pasteur'),
            Tab(icon: Icon(Icons.photo_library_outlined), text: 'Galerie'),
            Tab(icon: Icon(Icons.contact_mail_outlined), text: 'Contacts'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_isActionInProgress)
            const LinearProgressIndicator(
              color: AppColors.primary,
              backgroundColor: Colors.transparent,
              minHeight: 2,
            ),
          Expanded(
            child: (_isLoading && sermons.isEmpty && events.isEmpty && users.isEmpty)
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDashboard(
                        sermons.length,
                        events.length,
                        gallery.length,
                        contacts.length,
                        users.length,
                        motDuPasteur.length,
                      ),
                      _buildMembers(users),
                      _buildEvents(events),
                      _buildSermons(sermons),
                      _buildMotDuPasteur(motDuPasteur),
                      _buildGallery(gallery),
                      _buildContacts(contacts),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(
    int sermonsCount,
    int eventsCount,
    int galleryCount,
    int contactsCount,
    int usersCount,
    int motDuPasteurCount,
  ) => SingleChildScrollView(
    padding: EdgeInsets.all(context.pageHorizontalPadding),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistiques du serveur',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: context.responsiveValue(
            mobile: context.screenWidth < 360 ? 1 : 2,
            tablet: 3,
            desktop: 4,
          ),
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: context.responsiveValue(
            mobile: context.screenWidth < 360 ? 2.1 : 1.1,
            tablet: 1.25,
            desktop: 1.4,
          ),
          children: [
            _buildStatCard(
              'Sermons',
              sermonsCount,
              Icons.mic,
              Colors.orange,
            ),
            _buildStatCard(
              'Événements',
              eventsCount,
              Icons.event,
              Colors.green,
            ),
            _buildStatCard(
              'Mot du Pasteur',
              motDuPasteurCount,
              Icons.comment,
              Colors.blueGrey,
            ),
            _buildStatCard(
              'Photos',
              galleryCount,
              Icons.photo_library,
              Colors.purple,
            ),
            _buildStatCard(
              'Membres',
              usersCount,
              Icons.people,
              Colors.teal,
            ),
            _buildStatCard(
              'Contacts',
              contactsCount,
              Icons.contact_mail,
              Colors.blue,
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildEvents(List<Event> events) => _resourceLayout(
    label: 'Ajouter un événement',
    icon: Icons.add,
    onAdd: () => _showEventEditor(),
    isEmpty: events.isEmpty,
    empty: 'Aucun événement disponible.',
    content: ListView.separated(
      padding: EdgeInsets.all(context.pageHorizontalPadding),
      itemCount: events.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final event = events[index];
        return Card(
          child: ListTile(
            title: Text(event.title),
            subtitle: Text(
              [
                event.date,
                event.location,
              ].where((value) => value.isNotEmpty).join(' • '),
            ),
            trailing: _editDeleteMenu(
              onEdit: () => _showEventEditor(event),
              onDelete: () => _deleteEvent(event),
            ),
          ),
        );
      },
    ),
  );

  Widget _buildSermons(List<Sermon> sermons) => _resourceLayout(
    label: 'Ajouter un sermon',
    icon: Icons.add,
    onAdd: () => _showSermonEditor(),
    isEmpty: sermons.isEmpty,
    empty: 'Aucun sermon disponible.',
    content: ListView.separated(
      padding: EdgeInsets.all(context.pageHorizontalPadding),
      itemCount: sermons.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final sermon = sermons[index];
        return Card(
          child: ListTile(
            leading: const Icon(
              Icons.audio_file_outlined,
              color: AppColors.primary,
            ),
            title: Text(sermon.title),
            subtitle: Text(sermon.author),
            trailing: _editDeleteMenu(
              onEdit: () => _showSermonEditor(sermon),
              onDelete: () => _deleteSermon(sermon),
            ),
          ),
        );
      },
    ),
  );

  Widget _buildMotDuPasteur(List<MotDuPasteur> list) => _resourceLayout(
        label: 'Ajouter un message',
        icon: Icons.add,
        onAdd: () => _showMotDuPasteurEditor(),
        isEmpty: list.isEmpty,
        empty: 'Aucun message du pasteur disponible.',
        content: ListView.separated(
          padding: EdgeInsets.all(context.pageHorizontalPadding),
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, index) {
            final item = list[index];
            return Card(
              child: ListTile(
                leading: const Icon(
                  Icons.comment_outlined,
                  color: AppColors.primary,
                ),
                title: Text(item.title),
                subtitle: Text(item.author),
                trailing: _editDeleteMenu(
                  onEdit: () => _showMotDuPasteurEditor(item),
                  onDelete: () => _deleteMotDuPasteur(item),
                ),
              ),
            );
          },
        ),
      );

  Widget _buildGallery(List<GalleryItem> gallery) => _resourceLayout(
    label: 'Téléverser une photo',
    icon: Icons.upload_outlined,
    onAdd: _uploadPhoto,
    isEmpty: gallery.isEmpty,
    empty: 'Aucune photo disponible.',
    content: GridView.builder(
      padding: EdgeInsets.all(context.pageHorizontalPadding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.responsiveValue(
          mobile: 2,
          tablet: 3,
          desktop: 4,
        ),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: gallery.length,
      itemBuilder: (_, index) {
        final photo = gallery[index];
        return InkWell(
          onTap: () => _showPhotoActions(photo),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  photo.url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const ColoredBox(
                    color: Colors.black12,
                    child: Center(child: Icon(Icons.broken_image_outlined)),
                  ),
                ),
                const Positioned(
                  right: 4,
                  top: 4,
                  child: CircleAvatar(
                    radius: 14,
                    child: Icon(Icons.more_horiz, size: 18),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  Widget _buildMembers(List<AppUser> users) => _resourceLayout(
    label: 'Ajouter un membre',
    icon: Icons.person_add_outlined,
    onAdd: () => _showUserEditor(),
    isEmpty: users.isEmpty,
    empty: 'Aucun membre enregistré.',
    content: ListView.separated(
      padding: EdgeInsets.all(context.pageHorizontalPadding),
      itemCount: users.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final user = users[index];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(user.name),
            subtitle: Text('${user.email} • ${user.role ?? 'user'}'),
            trailing: _editDeleteMenu(
              onEdit: () => _showUserEditor(user),
              onDelete: () => _deleteUser(user),
            ),
          ),
        );
      },
    ),
  );

  Widget _buildContacts(List<ContactMessage> contacts) => isEmpty(contacts)
      ? _buildUnavailable('Aucun message de contact.')
      : ListView.separated(
          padding: EdgeInsets.all(context.pageHorizontalPadding),
          itemCount: contacts.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, index) {
            final contact = contacts[index];
            return Card(
              child: ExpansionTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(contact.nom),
                subtitle: Text(contact.email),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deleteContact(contact),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sujet: ${contact.sujet}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(contact.contenu),
                        if (contact.createdAt != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Reçu le: ${contact.createdAt!.day}/${contact.createdAt!.month}/${contact.createdAt!.year}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );

  bool isEmpty(List list) => list.isEmpty;

  Widget _resourceLayout({
    required String label,
    required IconData icon,
    required VoidCallback onAdd,
    required bool isEmpty,
    required String empty,
    required Widget content,
  }) => Column(
    children: [
      Padding(
        padding: EdgeInsets.fromLTRB(
          context.pageHorizontalPadding,
          12,
          context.pageHorizontalPadding,
          4,
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: onAdd,
            icon: Icon(icon),
            label: Text(label),
          ),
        ),
      ),
      Expanded(child: isEmpty ? _buildUnavailable(empty) : content),
    ],
  );

  Widget _editDeleteMenu({
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) => PopupMenuButton<String>(
    onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
    itemBuilder: (_) => const [
      PopupMenuItem(value: 'edit', child: Text('Modifier')),
      PopupMenuItem(value: 'delete', child: Text('Supprimer')),
    ],
  );

  Future<void> _showSermonEditor([Sermon? existing]) async {
    final values = <String, String>{
      'title': existing?.title ?? '',
      'description': existing?.description ?? '',
      'author': existing?.author ?? '',
      'date': existing?.date ?? '',
      'verse': existing?.verse ?? '',
      'audioUrl': existing?.audioUrl ?? '',
      'imageUrl': existing?.imageUrl ?? '',
      'autoDelete': existing?.autoDelete.toString() ?? 'false',
      'deleteAfterDays': existing?.deleteAfterDays?.toString() ?? '',
    };
    final result = await _showEditor(
      title: existing == null ? 'Nouveau sermon' : 'Modifier le sermon',
      values: values,
      fields: const [
        ('title', 'Titre', true),
        ('author', 'Auteur / pasteur', true),
        ('description', 'Description', false),
        ('verse', 'Verset', false),
        ('date', 'Date', false),
        ('audioUrl', 'Fichier audio', true),
        ('imageUrl', 'Image de couverture', false),
        ('autoDelete', 'Suppression automatique', false),
        ('deleteAfterDays', 'Délai (jours)', false),
      ],
      fileFields: const {
        'audioUrl': _FileInput.audio,
        'imageUrl': _FileInput.image,
      },
      dateFields: const {'date'},
      switchFields: const {'autoDelete'},
      numericFields: const {'deleteAfterDays'},
      conditionalFields: const {'deleteAfterDays': 'autoDelete'},
    );
    if (result == null) return;
    await _runAction(
      () async {
        final audioUrl = result.files['audioUrl'] == null
            ? result.values['audioUrl']!
            : await AppData.uploadAsset(
                bytes: result.files['audioUrl']!.bytes!,
                filename: result.files['audioUrl']!.name,
                categorie: 'sermon',
                additionalFields: {
                  'titre': result.values['title']!,
                  'auteur': result.values['author']!,
                },
              );

        final imageUrl = result.files['imageUrl'] == null
            ? result.values['imageUrl']!
            : await AppData.uploadAsset(
                bytes: result.files['imageUrl']!.bytes!,
                filename: result.files['imageUrl']!.name,
                categorie: 'sermon',
                additionalFields: {
                  'usage': 'cover',
                },
              );

        final sermon = Sermon(
          id: existing?.id,
          title: result.values['title']!,
          description: result.values['description']!,
          author: result.values['author']!,
          duration: '',
          date: result.values['date']!,
          verse: result.values['verse']!,
          audioUrl: audioUrl,
          imageUrl: imageUrl,
          imageCaption: '',
          autoDelete: result.values['autoDelete'] == 'true',
          deleteAfterDays: int.tryParse(result.values['deleteAfterDays'] ?? ''),
        );
        await (existing == null
            ? AppData.createSermon(sermon)
            : AppData.updateSermon(sermon));
      },
      existing == null ? 'Sermon créé.' : 'Sermon mis à jour.',
    );
  }

  Future<void> _showMotDuPasteurEditor([MotDuPasteur? existing]) async {
    final values = <String, String>{
      'title': existing?.title ?? '',
      'content': existing?.content ?? '',
      'label': existing?.label ?? '',
      'author': existing?.author ?? '',
      'autoDelete': existing?.autoDelete.toString() ?? 'false',
      'deleteAfterDays': existing?.deleteAfterDays?.toString() ?? '',
    };
    final result = await _showEditor(
      title: existing == null ? 'Nouveau message' : 'Modifier le message',
      values: values,
      fields: const [
        ('title', 'Titre', true),
        ('content', 'Contenu', true),
        ('label', 'Libellé', true),
        ('author', 'Auteur', true),
        ('autoDelete', 'Suppression automatique', false),
        ('deleteAfterDays', 'Délai (jours)', false),
      ],
      switchFields: const {'autoDelete'},
      numericFields: const {'deleteAfterDays'},
      conditionalFields: const {'deleteAfterDays': 'autoDelete'},
    );
    if (result == null) return;
    await _runAction(
      () async {
        final mot = MotDuPasteur(
          id: existing?.id,
          title: result.values['title']!,
          content: result.values['content']!,
          label: result.values['label']!,
          author: result.values['author']!,
          autoDelete: result.values['autoDelete'] == 'true',
          deleteAfterDays: int.tryParse(result.values['deleteAfterDays'] ?? ''),
        );
        await (existing == null
            ? AppData.createMotDuPasteur(mot)
            : AppData.updateMotDuPasteur(mot));
      },
      existing == null ? 'Message créé.' : 'Message mis à jour.',
    );
  }

  Future<void> _showEventEditor([Event? existing]) async {
    final values = <String, String>{
      'title': existing?.title ?? '',
      'description': existing?.description ?? '',
      'date': existing?.date ?? '',
      'time': existing?.time ?? '',
      'location': existing?.location ?? '',
      'imageUrl': existing?.imageUrl ?? '',
      'label': existing?.label ?? '',
      'autoDelete': existing?.autoDelete.toString() ?? 'false',
      'deleteAfterDays': existing?.deleteAfterDays?.toString() ?? '',
    };
    final result = await _showEditor(
      title: existing == null ? 'Nouvel événement' : 'Modifier l’événement',
      values: values,
      fields: const [
        ('title', 'Titre', true),
        ('date', 'Date', true),
        ('time', 'Heure', false),
        ('location', 'Lieu', false),
        ('label', 'Catégorie', false),
        ('description', 'Description', false),
        ('imageUrl', 'Image', false),
        ('autoDelete', 'Suppression automatique', false),
        ('deleteAfterDays', 'Délai (jours)', false),
      ],
      fileFields: const {'imageUrl': _FileInput.image},
      dateFields: const {'date'},
      timeFields: const {'time'},
      dropdownFields: const {
        'label': ['Jeunesse', 'Culte', 'Prière', 'Social'],
      },
      switchFields: const {'autoDelete'},
      numericFields: const {'deleteAfterDays'},
      conditionalFields: const {'deleteAfterDays': 'autoDelete'},
    );
    if (result == null) return;
    await _runAction(
      () async {
        final imageUrl = result.files['imageUrl'] == null
            ? result.values['imageUrl']!
            : await AppData.uploadAsset(
                bytes: result.files['imageUrl']!.bytes!,
                filename: result.files['imageUrl']!.name,
                categorie: 'event',
                additionalFields: {
                  'titre': result.values['title']!,
                },
              );
        final event = Event(
          id: existing?.id,
          title: result.values['title']!,
          description: result.values['description']!,
          date: result.values['date']!,
          time: result.values['time']!,
          location: result.values['location']!,
          imageUrl: imageUrl,
          label: result.values['label']!,
          autoDelete: result.values['autoDelete'] == 'true',
          deleteAfterDays: int.tryParse(result.values['deleteAfterDays'] ?? ''),
        );
        await (existing == null
            ? AppData.createEvent(event)
            : AppData.updateEvent(event));
      },
      existing == null ? 'Événement créé.' : 'Événement mis à jour.',
    );
  }

  Future<void> _showUserEditor([AppUser? existing]) async {
    final values = <String, String>{
      'name': existing?.name ?? '',
      'email': existing?.email ?? '',
      'role': existing?.role ?? 'user',
      'password': '',
    };
    final result = await _showEditor(
      title: existing == null ? 'Nouveau membre' : 'Modifier le membre',
      values: values,
      fields: [
        ('name', 'Nom complet', true),
        ('email', 'Adresse e-mail', true),
        ('role', 'Rôle', true),
        if (existing == null) ('password', 'Mot de passe', true),
      ],
      dropdownFields: const {
        'role': ['admin', 'user'],
      },
    );
    if (result == null) return;
    await _runAction(
      () async {
        final user = AppUser(
          id: existing?.id,
          name: result.values['name']!,
          email: result.values['email']!,
          role: result.values['role'],
        );
        if (existing == null) {
          await AppData.createUser(user, result.values['password']!);
        } else {
          await AppData.updateUser(user);
        }
      },
      existing == null ? 'Membre créé.' : 'Membre mis à jour.',
    );
  }

  Future<_EditorResult?> _showEditor({
    required String title,
    required Map<String, String> values,
    required List<(String, String, bool)> fields,
    Map<String, _FileInput> fileFields = const {},
    Set<String> dateFields = const {},
    Set<String> timeFields = const {},
    Map<String, List<String>> dropdownFields = const {},
    Set<String> switchFields = const {},
    Set<String> numericFields = const {},
    Map<String, String> conditionalFields = const {},
  }) async {
    final formKey = GlobalKey<FormState>();
    final controllers = {
      for (final field in fields)
        field.$1: TextEditingController(text: values[field.$1]),
    };
    final selectedFiles = <String, PlatformFile>{};
    final result = await showDialog<_EditorResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(title),
          content: Container(
            width: 420,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final field in fields)
                      if (!conditionalFields.containsKey(field.$1) ||
                          controllers[conditionalFields[field.$1]]!.text == 'true')
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: switchFields.contains(field.$1)
                              ? SwitchListTile(
                                  title: Text(field.$2),
                                  value: controllers[field.$1]!.text == 'true',
                                  activeThumbColor: AppColors.primary,
                                  onChanged: (val) {
                                    setDialogState(() {
                                      controllers[field.$1]!.text = val.toString();
                                    });
                                  },
                                )
                              : dropdownFields.containsKey(field.$1)
                                  ? DropdownButtonFormField<String>(
                                      initialValue: dropdownFields[field.$1]!
                                              .contains(controllers[field.$1]!.text)
                                          ? controllers[field.$1]!.text
                                          : null,
                                      decoration: InputDecoration(
                                        labelText: field.$2,
                                        border: const OutlineInputBorder(),
                                      ),
                                      items: dropdownFields[field.$1]!
                                          .map(
                                            (opt) => DropdownMenuItem(
                                              value: opt,
                                              child: Text(opt),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setDialogState(() {
                                            controllers[field.$1]!.text = val;
                                          });
                                        }
                                      },
                                      validator: field.$3
                                          ? (value) => value == null || value.isEmpty
                                              ? 'Champ obligatoire'
                                              : null
                                          : null,
                                    )
                                  : fileFields.containsKey(field.$1)
                                      ? TextFormField(
                                          controller: controllers[field.$1],
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            labelText: field.$2,
                                            border: const OutlineInputBorder(),
                                            prefixIcon: Icon(
                                              fileFields[field.$1] == _FileInput.image
                                                  ? Icons.image_outlined
                                                  : Icons.audio_file_outlined,
                                            ),
                                            suffixIcon: IconButton(
                                              icon: const Icon(Icons.attach_file),
                                              tooltip: 'Choisir un fichier',
                                              onPressed: () async {
                                                final file = await _pickEditorFile(
                                                  fileFields[field.$1]!,
                                                );
                                                if (file == null) return;
                                                setDialogState(() {
                                                  selectedFiles[field.$1] = file;
                                                  controllers[field.$1]!.text =
                                                      file.name;
                                                });
                                              },
                                            ),
                                          ),
                                          validator: field.$3
                                              ? (value) => (value == null ||
                                                          value.isEmpty) &&
                                                      !selectedFiles.containsKey(
                                                          field.$1)
                                                  ? 'Fichier obligatoire'
                                                  : null
                                              : null,
                                        )
                                      : TextFormField(
                                          controller: controllers[field.$1],
                                          maxLines: field.$1 == 'description' ||
                                                  field.$1 == 'content'
                                              ? 3
                                              : 1,
                                          keyboardType:
                                              numericFields.contains(field.$1)
                                                  ? TextInputType.number
                                                  : TextInputType.text,
                                          readOnly: dateFields.contains(field.$1) ||
                                              timeFields.contains(field.$1),
                                          decoration: InputDecoration(
                                            labelText: field.$2,
                                            border: const OutlineInputBorder(),
                                            suffixIcon: dateFields.contains(field.$1)
                                                ? IconButton(
                                                    icon: const Icon(
                                                      Icons.calendar_today,
                                                    ),
                                                    onPressed: () async {
                                                      final date =
                                                          await showDatePicker(
                                                        context: context,
                                                        initialDate: DateTime.now(),
                                                        firstDate: DateTime(2000),
                                                        lastDate: DateTime(2100),
                                                      );
                                                      if (date != null) {
                                                        controllers[field.$1]!
                                                                .text =
                                                            "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                                                      }
                                                    },
                                                  )
                                                : timeFields.contains(field.$1)
                                                    ? IconButton(
                                                        icon: const Icon(
                                                            Icons.access_time),
                                                        onPressed: () async {
                                                          final time =
                                                              await showTimePicker(
                                                            context: context,
                                                            initialTime:
                                                                TimeOfDay.now(),
                                                          );
                                                          if (time != null) {
                                                            controllers[field.$1]!
                                                                    .text =
                                                                "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
                                                          }
                                                        },
                                                      )
                                                    : null,
                                          ),
                                          validator: field.$3
                                              ? (value) => value == null ||
                                                      value.trim().isEmpty
                                                  ? 'Champ obligatoire'
                                                  : null
                                              : null,
                                          onTap: dateFields.contains(field.$1)
                                              ? () async {
                                                  final date = await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime(2000),
                                                    lastDate: DateTime(2100),
                                                  );
                                                  if (date != null) {
                                                    controllers[field.$1]!.text =
                                                        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                                                  }
                                                }
                                              : timeFields.contains(field.$1)
                                                  ? () async {
                                                      final time =
                                                          await showTimePicker(
                                                        context: context,
                                                        initialTime: TimeOfDay.now(),
                                                      );
                                                      if (time != null) {
                                                        controllers[field.$1]!.text =
                                                            "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
                                                      }
                                                    }
                                                  : null,
                                        ),
                        ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(
                    context,
                    _EditorResult(
                      {
                        for (final entry in controllers.entries)
                          entry.key: entry.value.text.trim(),
                      },
                      selectedFiles,
                    ),
                  );
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
    for (final controller in controllers.values) {
      // Small delay to allow the dialog to finish its closing animation
      // and unmount its widgets before disposing controllers.
      Future.delayed(const Duration(milliseconds: 300), () => controller.dispose());
    }
    return result;
  }

  Future<PlatformFile?> _pickEditorFile(_FileInput type) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: type == _FileInput.image
          ? const ['jpg', 'jpeg', 'png', 'webp', 'gif']
          : const ['mp3', 'wav', 'm4a', 'aac'],
      withData: true,
    );
    final file = result?.files.single;
    return file?.bytes == null ? null : file;
  }

  Future<void> _showPhotoActions(GalleryItem photo) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.visibility_outlined),
              title: const Text('Rendre publique'),
              onTap: () => Navigator.pop(context, 'public'),
            ),
            ListTile(
              leading: const Icon(Icons.visibility_off_outlined),
              title: const Text('Rendre privée'),
              onTap: () => Navigator.pop(context, 'private'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Supprimer'),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    if (action == 'delete') return _deletePhoto(photo);
    if (photo.id == null) {
      return _showMessage('Identifiant de photo manquant.', error: true);
    }
    await _runAction(
      () => AppData.setGalleryVisibility(photo.id!, action == 'public'),
      action == 'public' ? 'Photo rendue publique.' : 'Photo rendue privée.',
    );
  }

  Future<void> _uploadPhoto() async {
    final legendController = TextEditingController();
    final legend = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Légende de la photo'),
        content: TextField(
          controller: legendController,
          decoration: const InputDecoration(
            hintText: 'Entrez une légende (optionnel)',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, legendController.text.trim()),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );

    if (legend == null) {
      legendController.dispose();
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'gif'],
      withData: true,
    );
    final file = result?.files.single;
    final bytes = file?.bytes;

    // Attendre un peu avant de libérer le controller car le dialogue vient de se fermer
    Future.delayed(const Duration(milliseconds: 300), () => legendController.dispose());

    if (file == null || bytes == null) return;
    await _runAction(() async {
      await AppData.uploadGalleryItem(
        bytes: bytes,
        filename: file.name,
        legend: legend,
      );
    }, 'Photo téléversée.');
  }

  Widget _buildUnavailable(String message) => Center(
    child: Padding(
      padding: EdgeInsets.all(context.pageHorizontalPadding),
      child: Text(message, textAlign: TextAlign.center),
    ),
  );

  Widget _buildStatCard(String title, int value, IconData icon, Color color) =>
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}
