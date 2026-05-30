import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/folder_repository.dart';
import '../../../utils/helpers/color_helper.dart';
import '../../note/models/category_model.dart';
import 'folder_model.dart';

class FolderViewModel extends GetxController {
  final FolderRepository folderRepository;
  final CategoryRepository categoryRepository;

  FolderViewModel(this.folderRepository, this.categoryRepository);

  final box = GetStorage();
  final RxMap<int?, bool> expandedFolders = <int?, bool>{}.obs;

  var folders = <FolderModel>[].obs;
  var categories = <CategoryModel>[].obs;
  var grouped = <int?, List<CategoryModel>>{}.obs;

  bool isExpanded(int? id) => expandedFolders[id] ?? false;

  @override
  void onInit() {
    super.onInit();
    _loadExpandedState();
  }

  void _loadExpandedState() {
    final data = box.read<Map>('expandedFolders') ?? {};
    expandedFolders.value = Map<int?, bool>.from(data);
  }

  void toggleFolder(int? id) {
    final current = expandedFolders[id] ?? false;
    expandedFolders[id] = !current;

    box.write('expandedFolders', expandedFolders);
  }

  Future<void> createFolder(FolderModel newFolder) async {
    final folder = FolderModel(title: newFolder.title, icon: newFolder.icon, position: folders.length, createdAt: DateTime.now(), updatedAt: DateTime.now());
    final insertedId = await folderRepository.insertFolder(folder);
    final savedFolder = folder.copyWith(id: insertedId);
    final randomColor = generateRandomColor();
    final defaultCategory = CategoryModel(id: DateTime.now().millisecondsSinceEpoch, folderId: insertedId, title: 'Блокнот по умолчанию', color: randomColor, stripeColor: randomColor);

    await categoryRepository.insertCategory(defaultCategory);

    folders.add(savedFolder);
    grouped[insertedId] = [defaultCategory];
  }

  Future<void> deleteFolder(int folderId) async {
    await categoryRepository.deleteCategoriesByFolderId(folderId);
    await folderRepository.deleteFolder(folderId);

    folders.removeWhere((f) => f.id == folderId);
  }

  Future<void> loadData() async {
    final loadedFolders = await folderRepository.getFolders();
    final loadedCategories = await categoryRepository.getCategories();

    final Map<int?, List<CategoryModel>> temp = {};

    for (final c in loadedCategories) {
      temp.putIfAbsent(c.folderId, () => []);
      temp[c.folderId]!.add(c);
    }

    folders.value = loadedFolders;
    grouped.value = temp;
  }
}
