import 'package:frontend/services/calculator_tab_service.dart';

class CalculatorTabViewmodel {
  final CalculatorTabService _tabService;

  CalculatorTabViewmodel(this._tabService);

  List<String> getTabs() {
    return _tabService.getTabs();
  }
}
