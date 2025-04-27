import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/zakat_providers.dart';
import '../../../utils/constant/validation_utils.dart';
import '../../../utils/widgets/custom/custom_field.dart';

List<Widget> buildFields(
  WidgetRef ref,
  Map<StateProvider<String>, TextEditingController> controllers,
) {
  final fields = [
    {'label': 'Miisaanka dahabka (gram)', 'provider': goldValueProvider},
    {
      'label': 'Miisaanka lacagta dayaxa (gram)',
      'provider': silverValueProvider,
    },
    {'label': 'Lacagta (gacanta iyo bangiga)', 'provider': cashValueProvider},
    {
      'label': 'Lacagta lagu deponay mustaqbalka',
      'provider': depositedProvider,
    },
    {'label': 'Deyn bixinta', 'provider': loansProvider},
    {
      'label': 'Maalgashiga ganacsiga, saamiyada, mushaharka hawlgabka',
      'provider': investmentsProvider,
    },
    {'label': 'Qiimaha saamiyada', 'provider': stockProvider},
    {'label': 'Lacag ama alaab lagu amaahdo', 'provider': borrowedProvider},
    {'label': 'Mushaarka loo leeyahay shaqaalaha', 'provider': wagesProvider},
    {
      'label': 'Xoolo degdeg ah (cashuuraha, kirada, adeegyada)',
      'provider': taxesProvider,
    },
  ];

  return fields.map((field) {
    final label = field['label'] as String;
    final provider = field['provider'] as StateProvider<String>;
    final controller = controllers[provider]!;

    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: CustomField(
        labelText: label,
        controller: controller,
        keyboardType: TextInputType.number,
        validator: ValidationUtils.validateNumberField,
      ),
    );
  }).toList();
}
