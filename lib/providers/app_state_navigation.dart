part of 'app_state.dart';

mixin _NavigationState on ChangeNotifier {
  AppState get _state => this as AppState;

  void selectDate(DateTime date) {
    _state._selectedDate = date;
    _state.loadSelectedDateMeals();
  }

  void nextDay() {
    _state._selectedDate = _state._selectedDate.add(const Duration(days: 1));
    _state.loadSelectedDateMeals();
  }

  void previousDay() {
    _state._selectedDate = _state._selectedDate.subtract(
      const Duration(days: 1),
    );
    _state.loadSelectedDateMeals();
  }

  void selectTab(int index) {
    _state._selectedTabIndex = index;
    notifyListeners();
  }

  void setTemplateMeal(Meal? meal) {
    _state._templateMeal = meal;
    if (meal != null) {
      _state._selectedTabIndex = 1;
    }
    notifyListeners();
  }

  void clearTemplateMeal() {
    _state._templateMeal = null;
    notifyListeners();
  }
}
