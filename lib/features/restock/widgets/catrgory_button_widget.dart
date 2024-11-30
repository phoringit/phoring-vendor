import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/restock/controllers/restock_controller.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class CategoryButtonWidget extends StatelessWidget {
  final String? text;
  final int index;
  final int? categoryId;
  const CategoryButtonWidget({Key? key, required this.text, required this.index, this.categoryId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (){
         Provider.of<RestockController>(context, listen: false).setIndex(index, categoryId);
         Provider.of<RestockController>(context, listen: false).getRestockProductList(1);
        },
        child: Consumer<RestockController>(builder: (context, order, child) {
          return Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: order.categoryIndex == index ? Theme.of(context).primaryColor : ColorResources.getButtonHintColor(context),
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeLarge),
            ),
            child: Text(text!, style: order.categoryIndex == index ? titilliumBold.copyWith(color: order.categoryIndex == index
                ? ColorResources.getWhite(context) : ColorResources.getTextColor(context)):
            robotoRegular.copyWith(color: order.categoryIndex == index
                ? ColorResources.getWhite(context) : ColorResources.getTextColor(context))),
          );
        },
        ),
      ),
    );
  }
}