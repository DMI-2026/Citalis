import '../../../data/repositories/my_business/my_business_repository.dart';
import '../../../domain/models/my_business.dart';
import '../../../utils/result.dart';
import '../../core/view_model.dart';

class BusinessHomeViewModel extends ViewModel {
  BusinessHomeViewModel({required this._myBusinessRepository}) {
    _myBusinessRepository.addListener(load);
  }

  final MyBusinessRepository _myBusinessRepository;

  bool _isLoading = false;
  String? _errorMessage;
  MyBusiness? _business;
  int _tab = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MyBusiness? get business => _business;
  int get tab => _tab;

  void selectTab(int i) {
    _tab = i;
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    switch (await _myBusinessRepository.getMyBusiness()) {
      case Ok(:final value):
        _business = value;
        _errorMessage = null;
      case Failure(:final error):
        _errorMessage = error.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _myBusinessRepository.removeListener(load);
    super.dispose();
  }
}
