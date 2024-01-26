import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:team_tracking/ui/cubits/homepage_cubit.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

  @override
  void initState() {
    context.read<HomepageCubit>().runUpdateMyLocation();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomepageCubit,void>(
      builder: (BuildContext context, void state) {
        return Scaffold(
          body: Center(
            child: Column(

            ),
          ),
        );
      },
    );
  }
}
