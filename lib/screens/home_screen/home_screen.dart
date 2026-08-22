import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_key/logic/home_cubit/home_cubit.dart';
import 'package:work_key/logic/home_cubit/home_state.dart';
import 'package:work_key/screens/auth/login/login_screen.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';
import 'package:work_key/utils/shared%20preferences.dart';

import 'widgets/home_content.dart';
import 'widgets/home_states.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class GuestHomePage extends StatelessWidget {
  const GuestHomePage({super.key});

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: SafeArea(child: HomeScreen()));
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    HomeCubit.get(context).getHome();
  }

  Future<void> _refresh() => HomeCubit.get(context).getHome(refresh: true);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: BlocConsumer<HomeCubit, HomeStates>(
        listener: (context, state) async {
          if (state is HomeErrorState && state.isUnauthorized) {
            await CacheHelper.removeData(key: 'token');
            if (context.mounted)
              navigateAndFinish(context, const LoginScreen());
          }
        },
        builder: (context, state) {
          if (state is HomeInitialState || state is HomeLoadingState) {
            return const HomeLoadingView();
          }
          if (state is HomeErrorState) {
            if (state.isSuspended) return const HomeAccessView.suspended();
            if (state.isForbiddenRole) return const HomeAccessView.wrongRole();
            if (state.isUnauthorized) return const SizedBox.shrink();
            return HomeErrorView(onRetry: _refresh);
          }

          final home = (state as HomeSuccessState).homeResponse;
          return RefreshIndicator(
            color: HomeColors.brand,
            onRefresh: _refresh,
            child: LayoutBuilder(
              builder: (context, constraints) => CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: ResponsiveContent(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: constraints.maxWidth < 600 ? 16 : 28,
                          bottom: 120,
                        ),
                        child: home.isGuest
                            ? GuestHomeContent(home: home)
                            : MemberHomeContent(home: home),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
