import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../model/CityModel.dart';
import '../model/ProFileModel.dart';
import '../model/SearchFoodMeal.dart';
import '../model/StateModel.dart';
import '../model/WeightModel.dart';
import '../utils/BasalDeliveryNotifier.dart';
import '../utils/BolusDeliveryNotifier.dart';
import '../utils/GlucoseNotifier.dart';
import '../utils/NutritionNotifier.dart';
import '../utils/WeightNotifier.dart';
import '../utils/config.dart';
import 'SharedPrefsHelper.dart';

Future<void> addMeal(FoodItem foodItem, String text, double newCarbs,
    double carbs, BuildContext context) async {
  final dio = Dio();
  final _sharedPreference = SharedPrefsHelper();
  final String? userId = await _sharedPreference.getString('userId');
  try {
    final response = await dio.post(
      postMealData,
      data: {
        'userId': userId,
        'brandName': foodItem.brandName,
        'foodDescription': foodItem.foodDescription,
        'foodName': foodItem.foodName,
        'calories': foodItem.calories,
        'fat': foodItem.fat,
        'carbs': newCarbs.toString(),
        'protein': foodItem.protein,
        'quantity': text,
      },
    );

    if (response.statusCode == 200) {
      bool nutritionFound = true;
      Provider.of<NutritionChartNotifier>(context, listen: false)
          .nutritionUpdate(nutritionFound);
      print('Added successfully');
      print(' ${response}');
    } else {
      print('Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Error sending request: $e');
  }
}

Future<List<FoodItem>> getMeal() async {
  final _sharedPreference = SharedPrefsHelper();
  final dio = Dio();

  final String? userId = await _sharedPreference.getString('userId');
  if (userId == null) {
    throw Exception('User ID not found in shared preferences');
  }

  final String url = '$getMealData/$userId';

  try {
    final response = await dio.get(url);

    if (response.statusCode == 200) {
      var data = response.data['data'];
      return (data as List).map((item) => FoodItem.fromJson(item)).toList();
    } else {
      print('Error: ${response.statusCode} ${response.statusMessage}');
      throw Exception('Failed to load meal data');
    }
  } catch (e) {
    print('Exception: $e');
    throw Exception('Failed to load meal data');
  }
}

Future<void> deleteMeal(String id) async {
  final dio = Dio();

  final response = await dio.delete(
    '$deleteMealData/$id',
  );

  if (response.statusCode == 200) {
    print('Deleted successfully');
  } else {
    print('Error: ${response.statusCode} ${response.statusMessage}');
  }
}

Future<void> deleteWeight(String id) async {
  final dio = Dio();

  final response = await dio.delete(
    '$deleteWeightData/$id',
  );

  if (response.statusCode == 200) {
    print('Deleted successfully');
  } else {
    print('Error: ${response.statusCode} ${response.statusMessage}');
  }
}

Future<void> updateQuantity(
    String? id, double enteredQuantity, double newCarbs) async {
  final dio = Dio();

  try {
    final response = await dio.put(
      '$updateMealQuantity/$id',
      data: {
        'carbs': newCarbs.toString(),
        'quantity': enteredQuantity.toString(),
      },
    );

    if (response.statusCode == 200) {
      print('Added successfully');
    } else {
      print('Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Error sending request: $e');
  }
}

Future<void> addWeight(String tempWeight, BuildContext context) async {
  final _sharedPreference = SharedPrefsHelper();
  final dio = Dio();
  final String? userId = await _sharedPreference.getString('userId');
  try {
    final response = await dio.post(postWeightData, data: {
      'userId': userId,
      'weight': tempWeight,
    });
    if (response.statusCode == 200) {
      print('API HIT weight ADDED');
      bool weightFound = true;
      Provider.of<WeightSetup>(context, listen: false)
          .weightUpdate(weightFound);
      print(response);
    } else {
      print('error');
    }
  } catch (e) {
    print(e);
  }
}

Future<List<WeightPostData>> fetchWeightHistory() async {
  final _sharedPreference = SharedPrefsHelper();
  final dio = Dio();

  final String? userId = await _sharedPreference.getString('userId');
  if (userId == null) {
    throw Exception('User ID not found in shared preferences');
  }

  try {
    final response = await dio.get('$getWeightHistory/$userId');
    if (response.statusCode == 200) {
      var data = response.data['data'];
      // print(data);
      return (data as List)
          .map((item) => WeightPostData.fromJson(item))
          .toList();
    } else {
      // print(response);
      throw Exception('Failed to load food items');
    }
  } catch (e) {
    print(e);
    throw Exception('Failed to load food items');
  }
}

Future<void> setUpProfileApi(
  String? firstnameController,
  String? lastnameController,
  String? dobController,
  String? ageController,
  String? cityController,
  String? stateController,
  String? selectedGender,
  String? heightController,
  String? weightController,
  bool? diabetes,
  bool? hypertension,
  bool? isProfileCompleted,
) async {
  final _sharedPreference = SharedPrefsHelper();
  final dio = Dio();

  final String? userId = await _sharedPreference.getString('userId');

  print(userId);
  try {
    final response = await dio.post('$postSetUpProfile/$userId', data: {
      "firstName": firstnameController,
      "lastName": lastnameController,
      "dob": dobController,
      "age": ageController,
      "city": cityController,
      "state": stateController,
      "gender": selectedGender,
      "height": heightController,
      "weight": weightController,
      "diabetes": diabetes,
      "hypertension": hypertension,
      "isProfileCompleted": isProfileCompleted
    });
    print(response);
    print('api  hit');
    _sharedPreference.putBool('DeviceSetup', false);
    if (response.statusCode == 200) {
      _sharedPreference.putString(
        'firstName',
        firstnameController!,
      );
      _sharedPreference.putString('lastName', lastnameController!);

      _sharedPreference.putBool('ProfileUpdated', true);
      _sharedPreference.putBool('isProfileCompleted', isProfileCompleted!);
      _sharedPreference.putString('weight', weightController!);

      print(response);
    } else if (response.statusCode == 400) {
      print('api not hit');
      _sharedPreference.putBool('DeviceSetup', false);
      print(response);
    }
  } catch (e) {
    print('this throw error $e');
  }
}

Future<ProfileModel> getProfileData() async {
  print('API HIT');
  final _sharedPreference = SharedPrefsHelper();
  final dio = Dio();

  final String? userId = await _sharedPreference.getString('userId');
  print('$getprofile/$userId');

  final response = await dio.get('$getprofile/$userId');

  if (response.statusCode == 200) {
    var data = response.data['data'];
    print('respose $data');
    if (data != null) {
      return ProfileModel.fromJson(data);
    } else {
      throw Exception('Data is null');
    }
  } else {
    throw Exception('Failed to load profile data: ${response.statusCode}');
  }
}

Future<void> addBolusUnit(String unit, BuildContext context) async {
  final _sharedPreference = SharedPrefsHelper();
  final dio = Dio();

  final String? userId = await _sharedPreference.getString('userId');
  try {
    final response = await dio.post('$postBolusUnit/$userId', data: {
      'unit': unit,
    });
    if (response.statusCode == 200) {
      bool deliveryStatus = true;
      Provider.of<Bolusdelivery>(context, listen: false)
          .updateStatus(deliveryStatus);

      print(response);
    } else {
      print('error');
    }
  } catch (e) {
    print(e);
  }
}

Future<void> deviceSetup(bool status, BuildContext context) async {
  final _sharedPreference = SharedPrefsHelper();
  final dio = Dio();

  final String? userId = await _sharedPreference.getString('userId');
  try {
    final response = await dio.post('$postSetupDevice/$userId', data: {
      'isDeviceSetup': status,
    });
    if (response.statusCode == 200) {
      print(response);
    } else {
      print('error');
    }
  } catch (e) {
    print(e);
  }
}

Future<void> addGlucoseUnit(String unit, BuildContext context) async {
  final _sharedPreference = SharedPrefsHelper();
  final dio = Dio();

  final String? userId = await _sharedPreference.getString('userId');
  try {
    final response = await dio.post('$postGlucoseUnit/$userId', data: {
      'unit': unit,
    });
    if (response.statusCode == 200) {
      print('API HIT GLUCOSE ADDED');
      bool glucoseStatus = true;
      Provider.of<GlucoseDelivery>(context, listen: false)
          .glucoseUpdate(glucoseStatus);
      print('this is glucose $response');
    } else {
      print('error');
    }
  } catch (e) {
    print(e);
  }
}

Future<List<Statemodel>> getStateList() async {
  final dio = Dio();

  final response = await dio.get('$getStateDataList/India');

  if (response.statusCode == 200) {
    List data = response.data['data'];
    print('response of state list api $data');

    return data.map((state) => Statemodel.fromJson(state)).toList();
  } else {
    throw Exception('Failed to load state data: ${response.statusCode}');
  }
}

Future<List<Citymodel>> getCityList(state) async {
  final dio = Dio();

  final response = await dio.get(
    '$getCityDataList',
    queryParameters: {'stateName': state},
  );

  if (response.statusCode == 200) {
    List data = response.data['data'];
    print('response of state list api $data');

    return data.map((state) => Citymodel.fromJson(state)).toList();
  } else {
    throw Exception('Failed to load state data: ${response.statusCode}');
  }
}

Future<void> addBasal(
    String endTimeController, String dosage, BuildContext context) async {
  final _sharedPreference = SharedPrefsHelper();
  final dio = Dio();
  final String? userId = await _sharedPreference.getString('userId');
  try {
    final response = await dio.post('$postBasalData/$userId', data: {
      'time': endTimeController,
      'unit': dosage,
    });
    if (response.statusCode == 200) {
      bool basalStatus = true;
      Provider.of<BasalDelivery>(context, listen: false)
          .updateBasalGraph(basalStatus);
      print(response);
    } else {
      print('error');
    }
  } catch (e) {
    print(e);
  }
}

void getLastWeight() async {
  print('API HIT');
  final _sharedPreference = SharedPrefsHelper();
  final dio = Dio();

  final String? userId = await _sharedPreference.getString('userId');

  final response = await dio.get('$lastWeight/$userId');

  if (response.statusCode == 200) {
    var data = response.data['data'][0]['weight'];
    print('weight list ${data}');
    _sharedPreference.putString('weight', data.toString());
  } else {
    throw Exception('Failed to load profile data: ${response.statusCode}');
  }
}
