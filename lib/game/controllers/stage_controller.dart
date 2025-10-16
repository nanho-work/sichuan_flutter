import 'package:flutter/foundation.dart';
import '../data/stage_repository.dart';

class StageController extends ChangeNotifier {
  final StageRepository repo;
  StageController({required this.repo});

  bool _loading = false;
  String? _error;
  List<StageMeta> _stages = [];
  int _page = 0;

  bool get loading => _loading;
  String? get error => _error;
  List<StageMeta> get stages => _stages;
  int get page => _page;
  StageMeta? get current => (_stages.isEmpty) ? null : _stages[_page];

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _stages = await repo.fetchIndex();
      if (_page >= _stages.length) _page = 0;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setPage(int value) {
    if (value < 0 || value >= _stages.length) return;
    _page = value;
    notifyListeners();
  }
}