import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/product_controller.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_search_field_widget.dart';
import 'package:sixvalley_vendor_app/features/product/widgets/product_widget.dart';

class ProductListMenuScreen extends StatefulWidget {
  final bool fromNotification;
  const ProductListMenuScreen({Key? key,  this.fromNotification = false}) : super(key: key);
  @override
  State<ProductListMenuScreen> createState() => _ProductListMenuScreenState();
}

class _ProductListMenuScreenState extends State<ProductListMenuScreen> {
  TextEditingController searchController = TextEditingController();
  int? userId;
  @override
  void initState() {
    userId = Provider.of<ProfileController>(context, listen: false).userId;
    // if(widget.fromNotification) {
    //   Provider.of<ProductController>(context, listen: false).emptySellerProduct();
    //   Provider.of<ProfileController>(context, listen: false).getSellerInfo().then((responce) {
    //     if(responce.isSuccess) {
    //       userId = Provider.of<ProfileController>(context, listen: false).userId;
    //       Provider.of<ProductController>(context, listen: false).initSellerProductList(userId.toString(), 1, context, 'en', '', reload: true);
    //     } else {
    //       Provider.of<ProductController>(context, listen: false).initSellerProductList(userId.toString(), 1, context, 'en', '', reload: true);
    //     }
    //   });
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (val) async {
        if(widget.fromNotification) {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const DashboardScreen()), (route) => false);
        } else {
          Navigator.of(context).pop();
        }
        return;
      },
      child: Scaffold(
        appBar: CustomAppBarWidget(
          title: getTranslated('product_list', context),
          onBackPressed: () {
            if(widget.fromNotification) {
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const DashboardScreen()), (route) => false);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        body: Column(children: [
            SizedBox(height: 80,
              child: Consumer<ProductController>(
                builder: (context, searchProductController, _) {
                  return Container(
                    color: Theme.of(context).cardColor,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault),
                      child: CustomSearchFieldWidget(
                        controller: searchController,
                        hint: getTranslated('search', context),
                        prefix: Images.iconsSearch,
                        iconPressed: () => (){},
                        onSubmit: (text) => (){},
                        onChanged: (value){
                          if(value.toString().isNotEmpty){
                            searchProductController.initSellerProductList(userId.toString(), 1, context, 'en',value, reload: true);
                          }
                        },
                      ),
                    ),
                  );
                }
              )),
            Expanded(child: ProductViewWidget(sellerId: userId, fromNotification: widget.fromNotification,))
          ],
        ),

      ),
    );
  }
}
