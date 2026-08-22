import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/home_repo.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeStates> {
  final HomeRepo homeRepo;

  HomeCubit(this.homeRepo) : super(HomeInitialState());

  static HomeCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> getHome({bool refresh = false}) async {
    if (!refresh) {
      emit(HomeLoadingState());
    }

    try {
      final home = await homeRepo.getHome();
      emit(HomeSuccessState(home));
    } on HomeRequestException catch (e) {
      emit(
        HomeErrorState(
          e.message,
          statusCode: e.statusCode,
          errorCode: e.errorCode,
        ),
      );
    } catch (e) {
      emit(HomeErrorState(e.toString()));
    }
  }
}
