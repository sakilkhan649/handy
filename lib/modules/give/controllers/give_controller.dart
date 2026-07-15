import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy/core/services/api_client.dart';
import 'package:handy/config/constants/api_constants.dart';
import 'package:handy/core/utils/helpers.dart';
import '../../../data/models/give_model.dart';

class GiveController extends GetxController {
  final ApiClient apiClient = Get.find<ApiClient>();

  final showHistory = false.obs;
  final isLoading = true.obs;

  final totalThisYear = 0.0.obs;

  final selectedFundId = ''.obs;
  final selectedAmount = 0.obs;

  final amountController = TextEditingController();

  final selectedFrequency = 'One-time'.obs;
  final selectedPaymentMethod = 'Card (Stripe)'.obs;

  final funds = <GiveFundModel>[].obs;

  final List<int> presetAmounts = [10, 20, 50, 100, 250, 500];

  final historyData = <GiveHistoryModel>[].obs;
  final isHistoryLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFunds();
    amountController.addListener(() {
      if (amountController.text.isNotEmpty) {
        final val = int.tryParse(amountController.text) ?? 0;
        selectedAmount.value = val;
      } else {
        selectedAmount.value = 0;
      }
    });
  }

  Future<void> fetchFunds() async {
    if (funds.isEmpty) isLoading.value = true;
    try {
      try {
        final fundsResponse = await apiClient.getData(
          ApiConstants.givingFunds,
          query: {'t': DateTime.now().millisecondsSinceEpoch},
        );
        if (fundsResponse.statusCode == 200 ||
            fundsResponse.statusCode == 201) {
          if (fundsResponse.data['data'] != null &&
              fundsResponse.data['data'] is List) {
            final fundsList = (fundsResponse.data['data'] as List)
                .map((x) => GiveFundModel.fromJson(x as Map<String, dynamic>))
                .toList();
            funds.assignAll(fundsList);

            if (fundsList.isNotEmpty) {
              final exists = fundsList.any((f) => f.id == selectedFundId.value);
              if (!exists) {
                selectedFundId.value = fundsList.first.id;
              }
            }
          }
        }
      } catch (e) {
        Helpers.showDebugLog('Failed to parse funds: $e');
      }

      try {
        final totalResponse = await apiClient.getData(
          ApiConstants.givingTotalThisYear,
          query: {'t': DateTime.now().millisecondsSinceEpoch},
        );
        if (totalResponse.statusCode == 200 ||
            totalResponse.statusCode == 201) {
          var dataObj = totalResponse.data['data'];
          if (dataObj != null) {
            if (dataObj is Map && dataObj['totalThisYear'] != null) {
              final rawValue = dataObj['totalThisYear'];
              if (rawValue is num) {
                totalThisYear.value = rawValue.toDouble();
              } else if (rawValue is String) {
                totalThisYear.value = double.tryParse(rawValue) ?? 0.0;
              }
            } else if (dataObj is num) {
              totalThisYear.value = dataObj.toDouble();
            } else if (dataObj is String) {
              totalThisYear.value = double.tryParse(dataObj) ?? 0.0;
            }
          }
        } else {
          Helpers.showDebugLog('Total API Error: ${totalResponse.statusCode}');
        }
      } catch (e) {
        Helpers.showDebugLog('Failed to parse totalThisYear: $e');
      }
    } catch (e) {
      Helpers.showDebugLog('Failed to fetch data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }

  void selectAmount(int amount) {
    selectedAmount.value = amount;
    amountController.value = TextEditingValue(
      text: amount.toString(),
      selection: TextSelection.collapsed(offset: amount.toString().length),
    );
  }

  Future<void> fetchHistory() async {
    isHistoryLoading.value = true;
    try {
      final response = await apiClient.getData(
        ApiConstants.givingHistory,
        query: {'t': DateTime.now().millisecondsSinceEpoch},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['data'] != null &&
            response.data['data']['transactions'] != null) {
          final list = (response.data['data']['transactions'] as List)
              .map((x) => GiveHistoryModel.fromJson(x))
              .toList();
          historyData.assignAll(list);
        }
      }
    } catch (e) {
      Helpers.showDebugLog('Failed to fetch history: $e');
    } finally {
      isHistoryLoading.value = false;
    }
  }

  void toggleHistory() {
    showHistory.value = !showHistory.value;
    if (showHistory.value && historyData.isEmpty) {
      fetchHistory();
    }
  }
}
