import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:sixvalley_vendor_app/features/pos/domain/models/place_order_body.dart';
import 'package:sixvalley_vendor_app/features/pos/domain/models/cart_model.dart';
import 'package:sixvalley_vendor_app/features/pos/domain/models/temporary_cart_for_customer_model.dart' as customer;
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/pos/controllers/cart_controller.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_dialog_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_divider_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_header_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/pos/screens/add_new_customer_screen.dart';
import 'package:sixvalley_vendor_app/features/pos/screens/customer_search_screen.dart';
import 'package:sixvalley_vendor_app/features/pos/widgets/cart_pricing_widget.dart';
import 'package:sixvalley_vendor_app/features/pos/widgets/confirm_purchase_dialog_widget.dart';
import 'package:sixvalley_vendor_app/features/pos/widgets/coupon_apply_widget.dart';
import 'package:sixvalley_vendor_app/features/pos/widgets/extra_discount_and_coupon_dialog_widget.dart';
import 'package:sixvalley_vendor_app/features/pos/widgets/item_card_widget.dart';
import 'package:sixvalley_vendor_app/features/pos/widgets/pos_no_product_widget.dart';


class PosScreen extends StatefulWidget {
  final bool fromMenu;
  const PosScreen({Key? key, this.fromMenu = false}) : super(key: key);

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final ScrollController _scrollController = ScrollController();
  double subTotal = 0, productDiscount = 0, total = 0, payable = 0, couponAmount = 0, extraDiscount = 0, productTax = 0, xxDiscount = 0, payableWithoutExDiscount = 0;


  int userId = 0;
  String customerName = '';
  final List<String> _paymentVia = ["cash", "card", "wallet"];

  final TextEditingController _paidAmountController = TextEditingController();
  final FocusNode _paidAmountNode = FocusNode();
  bool isNotSet = true;


  @override
  void initState() {
    super.initState();
    Provider.of<CartController>(context, listen: false).getCustomerList('all');
    Provider.of<CartController>(context, listen: false).clearCardForCancel();
    Provider.of<CartController>(context, listen: false).extraDiscountController.text = '0';
    Provider.of<CartController>(context, listen: false).setPaidAmountles(true, isUpdate: false);
    Provider.of<CartController>(context, listen: false).setUpdatePaidAmount(true, isUpdate: false);
    if(Provider.of<CartController>(context, listen: false).customerSelectedName == ''){
      Provider.of<CartController>(context, listen: false).searchCustomerController.text = 'walking customer';
      Provider.of<CartController>(context, listen: false).setCustomerInfo( 0,  'walking customer', 'NULL', false, fromInit: true);
    }
  }

  @override
  Widget build(BuildContext context) {


    var rng = Random();
    for (var i = 0; i < 10; i++) {
      if (kDebugMode) {
        print(rng.nextInt(10000));
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar:  CustomAppBarWidget(title: getTranslated('pos', context), isBackButtonExist: true),
      body: RefreshIndicator(
        color: Theme.of(context).cardColor,
        backgroundColor: Theme.of(context).primaryColor,
        onRefresh: () async {
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(child: Consumer<CartController>(
                builder: (context,cartController, _) {
                  productDiscount = 0;
                  total = 0;
                  productTax = 0;
                  subTotal = 0;
                  if(cartController.customerCartList.isNotEmpty){
                    subTotal = cartController.amount;

                    for(int i=0; i< cartController.customerCartList[cartController.customerIndex].cart!.length; i++) {
                      print("=====Tax==>>${cartController.customerCartList[cartController.customerIndex].cart![i].product!.taxModel}");
                      double? digitalVPrice = cartController.customerCartList[cartController.customerIndex].cart![i].digitalVariationPrice;
                      Variation? variation = cartController.customerCartList[cartController.customerIndex].cart![i].variation;

                      if (kDebugMode) {
                        print('dis==> ${cartController.customerCartList[cartController.customerIndex].cart![i].product!.discountType}');
                      }

                      productDiscount  = cartController.customerCartList[cartController.customerIndex].cart![i].product!.discountType == 'flat'?
                      productDiscount + cartController.customerCartList[cartController.customerIndex].cart![i].product!.discount! * cartController.customerCartList[cartController.customerIndex].cart![i].quantity! :
                      productDiscount + ((cartController.customerCartList[cartController.customerIndex].cart![i].product!.discount!/100)*
                        (variation != null ? variation.price! : digitalVPrice ?? cartController.customerCartList[cartController.customerIndex].cart![i].product!.unitPrice!) * cartController.customerCartList[cartController.customerIndex].cart![i].quantity!);

                      if(cartController.customerCartList[cartController.customerIndex].cart![i].product!.taxModel == "exclude"){
                        productTax = productTax + (cartController.customerCartList[cartController.customerIndex].cart![i].product!.tax!/100)*
                            (variation != null ? variation.price! :  digitalVPrice ?? cartController.customerCartList[cartController.customerIndex].cart![i].product!.unitPrice!) * cartController.customerCartList[cartController.customerIndex].cart![i].quantity!;
                      } else if (cartController.customerCartList[cartController.customerIndex].cart![i].product!.taxModel == "include") {
                         productTax =   cartController.calculateIncludedTax(((variation != null ? variation.price! : digitalVPrice ?? cartController.customerCartList[cartController.customerIndex].cart![i].product!.unitPrice!) * cartController.customerCartList[cartController.customerIndex].cart![i].quantity!), cartController.customerCartList[cartController.customerIndex].cart![i].product!.tax!);
                           // productTax +((variation != null ? variation.price! : digitalVPrice ?? cartController.customerCartList[cartController.customerIndex].cart![i].product!.unitPrice!) * cartController.customerCartList[cartController.customerIndex].cart![i].quantity!) * (cartController.customerCartList[cartController.customerIndex].cart![i].product!.tax!/100) / (1 + (cartController.customerCartList[cartController.customerIndex].cart![i].product!.tax!/100)).round();
                      }
                    }
                  }


                  if( cartController.customerCartList.isNotEmpty){
                    couponAmount = cartController.customerCartList[cartController.customerIndex].couponAmount?? 0;
                    xxDiscount = cartController.customerCartList[cartController.customerIndex].extraDiscount?? 0;
                  }

                  extraDiscount = double.parse(PriceConverter.discountCalculationWithOutSymbol(context, subTotal, xxDiscount, cartController.selectedDiscountType));

                  print("====ExtraDisAmount====>>${extraDiscount}");
                  print("====Subtotal====>>${subTotal}");
                  print("====ExtraDisAmount==2==>>${double.tryParse(PriceConverter.reverseConvertPriceWithoutSymbol(context, extraDiscount))}");

                  total = subTotal - productDiscount - couponAmount - double.tryParse(PriceConverter.reverseConvertPriceWithoutSymbol(context, extraDiscount))! + productTax;

                  print("====Total====>>${total}");
                  print("====Total====>>${cartController.extraDiscountAmount}");

                  payable = total;

                  payableWithoutExDiscount = subTotal - productDiscount - couponAmount + productTax;

                  if(isNotSet || cartController.updatePaidAmount) {
                    _paidAmountController.text = payable.toString();
                    cartController.setPaidAmountles(false, isUpdate: false);
                    if(cartController.updatePaidAmount) {
                      cartController.setUpdatePaidAmount(false, isUpdate: false);
                    }
                    isNotSet = false;
                  }

                  return SingleChildScrollView(
                    child: Column(children: [
                      CustomHeaderWidget(title: getTranslated('billing_section', context), headerImage: Images.billingSection),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                    
                    
                      Consumer<CartController>(
                          builder: (context,customerController,_) {
                    
                            return Container(padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 0, Dimensions.paddingSizeDefault, 0),
                              child: Row(crossAxisAlignment: CrossAxisAlignment.start,children: [
                                Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                    
                    
                                    GestureDetector(
                                      onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> const CustomerSearchScreen())),
                                        child: Container(width: MediaQuery.of(context).size.width/2,
                                          decoration: BoxDecoration(
                                          border: Border.all(width: .25, color: Theme.of(context).primaryColor.withOpacity(.75)),
                                            color: Theme.of(context).cardColor,
                                            boxShadow: ThemeShadow.getShadow(context),
                                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)
                                        ),
                                            child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSize),
                                              child: Text(customerController.searchCustomerController.text)))),
                    
                    
                                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    
                                    CustomButtonWidget(btnTxt: getTranslated('add_customer', context),
                                      backgroundColor: Theme.of(context).primaryColor,
                                      onTap: (){
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AddNewCustomerScreen()));
                                      },
                                    ),
                                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    
                                    // CustomButtonWidget(btnTxt: getTranslated('new_order', context),
                                    //   onTap: (){
                                    //     String customerId = '${customerController.customerId}';
                                    //     customer.TemporaryCartListModel customerCart = customer.TemporaryCartListModel(
                                    //       cart: [],
                                    //       userIndex: customerId != '0' ?  int.parse(customerId) : rng.nextInt(10000),
                                    //       userId: customerId != '0' ?  int.parse(customerId) : int.parse(customerId),
                                    //       customerName: customerId == '0'? 'wc-${rng.nextInt(10000)}':'${customerController.customerSelectedName} ${customerController.customerSelectedMobile}',
                                    //       customerBalance: customerController.customerBalance,
                                    //       isUser: customerId == '0' ? false : true,
                                    //     );
                                    //     // cartController.addToCartListForUser(customerCart, clear: true);
                                    //
                                    //     cartController.setCustomerInfo(customerCart.userId,
                                    //         'walking customer', '', true, formCart: false);
                                    //   }),
                    
                                  ],)),
                                const SizedBox(width: Dimensions.paddingSizeSmall),
                                Expanded(child: Column(children: [
                                  Text('${getTranslated('current_customer_status', context)} :',
                                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),),
                    
                                  SizedBox(height: 50,child: Column(children: [
                    
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                      child: Text(customerController.customerSelectedName ?? '',maxLines: 1,overflow: TextOverflow.ellipsis,
                                        style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.paddingSizeSmall),),
                                    ),
                    
                                    Text(customerController.customerSelectedMobile != 'NULL'? customerController.customerSelectedMobile??'':'',
                                      style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),),
                                  ])),
                    
                    
                                  // const SizedBox(height: Dimensions.paddingSizeCustomerBottom),
                                  // CustomButtonWidget(fontColor: ColorResources.getTextColor(context),
                                  //   btnTxt: getTranslated('clear_all_cart', context),
                                  //   backgroundColor: Theme.of(context).hintColor.withOpacity(.25),
                                  //   onTap: (){
                                  //     cartController.removeAllCartList();
                                  //   }),
                                ],)),
                              ],),);
                          }
                      ),

                     ///Dropdown
                     // const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                      // Consumer<CartController>(
                      //   builder: (context, customerCartController, _) {
                      //     return customerCartController.customerCartList.isNotEmpty ?
                      //     Padding(
                      //       padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault,0,Dimensions.paddingSizeDefault,0),
                      //       child: Container(
                      //         height: 50,
                      //         padding: const EdgeInsets.symmetric(horizontal:Dimensions.paddingSizeSmall),
                      //         decoration: BoxDecoration(color: Theme.of(context).cardColor,
                      //             border: Border.all(width: .5, color: Theme.of(context).hintColor.withOpacity(.7)),
                      //             borderRadius: BorderRadius.circular(Dimensions.paddingSizeMediumBorder)),
                      //         child: DropdownButton<int>(
                      //           value: customerCartController.customerIds[cartController.customerIndex],
                      //           items: customerCartController.customerIds.map((int? value) {
                      //             if (kDebugMode) {
                      //               print('=======>>${customerCartController.customerIds}/$value/${customerCartController.customerIndex}');
                      //             }
                      //             return DropdownMenuItem<int>(
                      //                 value: value,
                      //                 child:  Text(customerCartController.customerCartList[(customerCartController.customerIds.indexOf(value))].customerName??'',
                      //                     style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall))
                      //             );
                      //           }).toList(),
                      //           onChanged: (int? value) async {
                      //             cartController.setPaymentTypeIndex(0, true);
                      //             await customerCartController.setCustomerIndex(cartController.customerIds.indexOf(value), true);
                      //             // print("==CustomerIds==>>${cartController.customerIds}");
                      //             // print("==CustomerIds==>>${cartController.customerCartList}");
                      //             customer.TemporaryCartListModel  tempCustomer = customerCartController.customerCartList[(customerCartController.customerIds.indexOf(value))];
                      //
                      //             // print("===tempCustomer===>>${tempCustomer.toJson()}");
                      //             // print("===tempCustomer===>>${tempCustomer.customerName}");
                      //             // print("===tempCustomer===>>${tempCustomer.userId}");
                      //
                      //             // customerCartController.setCustomerInfo(customerCartController.customerCartList[customerCartController.customerIndex].userId,
                      //             //     customerCartController.customerCartList[(customerCartController.customerIndex)].customerName, '', true);
                      //
                      //             customerCartController.setCustomerInfo(tempCustomer.userId,
                      //               tempCustomer.customerName, '', true, formCart: true);
                      //             customerCartController.getReturnAmount(payable);
                      //           },
                      //           isExpanded: true, underline: const SizedBox(),),),
                      //     ):const SizedBox();
                      //   }
                      // ),
                    
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                    
                    
                      Container(padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 0, Dimensions.paddingSizeDefault, 0),
                        height: 50,
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(.06),),
                        child: Row(children: [
                    
                          Expanded(flex:6, child: Text(getTranslated('item_info', context)!)),
                          Expanded(flex:4, child: Text(getTranslated('qty', context)!)),
                          Expanded(flex:2, child: Text(getTranslated('price', context)!)),
                    
                        ],),
                      ),
                      cartController.customerCartList.isNotEmpty?
                      Consumer<CartController>(builder: (context,custController,_) {
                        return ListView.builder(
                            itemCount: cartController.customerCartList[custController.customerIndex].cart!.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (itemContext, index){
                              return ItemCartWidget(cartModel: cartController.customerCartList[custController.customerIndex].cart![index], index:  index, onChanged: () {
                                isNotSet=true;
                                print("<<===OnChangedCall==>>");
                              },);
                            });
                      }) : const SizedBox(),
                    
                    
                      (cartController.customerCartList.isNotEmpty && cartController.customerCartList[cartController.customerIndex].cart!.isNotEmpty) ?
                      Padding(
                        padding: const EdgeInsets.only(top: Dimensions.paddingSizeMedium),
                        child: Container(
                          decoration: BoxDecoration(
                    
                              color: Theme.of(context).cardColor,
                              boxShadow: [BoxShadow(color: Provider.of<ThemeController>(context, listen: false).darkTheme? Theme.of(context).primaryColor.withOpacity(0):
                              Theme.of(context).primaryColor.withOpacity(.05), blurRadius: 1, spreadRadius: 1, offset: const Offset(0,0))]
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                    
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(Dimensions.fontSizeDefault,  Dimensions.paddingSizeExtraSmall, Dimensions.fontSizeDefault,Dimensions.fontSizeDefault,),
                              child: Row(children: [
                                Expanded(child: Text(getTranslated('bill_summery', context)!,
                                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge))),
                                SizedBox(width: 120,height: 40,child: CustomButtonWidget(btnTxt: getTranslated('edit_discount', context),
                                  onTap: () async {
                                   bool? isNotSetDialog = await showDialog<bool>(
                                      context: context, builder: (ctx) => Stack(
                                        children: [
                                          Positioned(
                                            top: 50, left: 0, right: 0,
                                            child: Material(
                                              type: MaterialType.transparency, // Make sure the dialog has material styling
                                              child: ExtraDiscountAndCouponDialogWidget(
                                                payable: payableWithoutExDiscount,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    );
                                   print("==isNotSetDialog=>>$isNotSetDialog");

                                    // showGeneralDialog(
                                    //   context: context,
                                    //   barrierDismissible: true,
                                    //   barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
                                    //   transitionDuration: const Duration(milliseconds: 200),
                                    //   pageBuilder: (ctx, anim1, anim2) {
                                    //     return Align(
                                    //       alignment: Alignment.topCenter,
                                    //       child: ExtraDiscountAndCouponDialogWidget(
                                    //         onChanged: () {
                                    //           isNotSet=true;
                                    //         }
                                    //       ),
                                    //     );
                                    //   },
                                    //   transitionBuilder: (context, animation, secondaryAnimation, child) {
                                    //     return SlideTransition(
                                    //       position: Tween<Offset>(
                                    //         begin: Offset(0, -1), // Start position (off the screen, top)
                                    //         end: Offset(0, 0),    // End position (top of the screen)
                                    //       ).animate(animation),
                                    //       child: child,
                                    //     );
                                    //   },
                                    // );

                                    // showAnimatedDialogWidget(context,
                                    //     ExtraDiscountAndCouponDialogWidget(
                                    //       onChanged: () {
                                    //         isNotSet=true;
                                    //     }),
                                    //     dismissible: false,
                                    //     isFlip: false);

                                  },)),
                              ],),
                            ),
                            PricingWidget(title: getTranslated('subtotal', context), amount: PriceConverter.convertPrice(context, subTotal)),
                            PricingWidget(title: getTranslated('product_discount', context), amount: PriceConverter.convertPrice(context,productDiscount)),
                            PricingWidget(title: getTranslated('coupon_discount', context), amount: PriceConverter.convertPrice(context,couponAmount),
                              isCoupon: true,onTap: (){
                                showAnimatedDialogWidget(context,
                                    const CouponDialogWidget(),
                                    dismissible: false,
                                    isFlip: false);
                              },),
                            PricingWidget(title: getTranslated('extra_discount', context), amount: PriceConverter.discountCalculation(context,
                                subTotal, extraDiscount, 'amount')),
                            PricingWidget(title: getTranslated('vat', context), amount: PriceConverter.convertPrice(context, productTax)),
                            Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                              child: CustomDividerWidget(height: .4,color: Theme.of(context).hintColor.withOpacity(1),),),
                    
                            PricingWidget(title: getTranslated('total', context), amount: PriceConverter.convertPrice(context, total), isTotal: true),



                            Padding( padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall,
                              Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall),
                              child: Text(getTranslated('paid_by', context)!, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault))
                            ),

                            Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                              child: SizedBox(height: 35, child: ListView.builder(
                                  itemCount:
                                  cartController.customerId != 0 ? _paymentVia.length : 2,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index){
                                    return Padding(
                                      padding:  const EdgeInsets.only(left : Dimensions.paddingSizeSmall),
                                      child: GestureDetector(
                                        onTap: (){
                                          cartController.setPaymentTypeIndex(index, true);
                                          _paidAmountController.text = payable.toString();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                          decoration: BoxDecoration(
                                              color: cartController.paymentTypeIndex == index? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                                              borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                                              border: Border.all(width: .5, color: Theme.of(context).hintColor)
                                          ),
                                          child: Center(child: Text(getTranslated(_paymentVia[index], context)!,
                                            style: robotoRegular.copyWith(color: cartController.paymentTypeIndex == index?
                                            Colors.white :  null, fontSize: cartController.paymentTypeIndex == index? Dimensions.fontSizeLarge : Dimensions.fontSizeDefault),)),
                                        ),
                                      ),
                                    );
                                  })),
                            ),

                            const SizedBox(height: Dimensions.paddingSizeDefault),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                              child: Container (
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSeven, vertical: Dimensions.paddingSize),
                                decoration: BoxDecoration (
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  color: Theme.of(context).hintColor.withOpacity(0.10),
                                  border: Border.all(color: Theme.of(context).hintColor.withOpacity(0.30))
                                ),
                                child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    (cartController.paymentTypeIndex ==2 && !cartController.checkWalletAmount(
                                        cartController.customerId, payable)) ?
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                          child: Container(
                                            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                            decoration: BoxDecoration (
                                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                              color: Theme.of(context).colorScheme.error.withOpacity(0.30),
                                            ),
                                            child: Text(
                                              getTranslated('insufficient_balance', context)!,
                                              style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error),
                                            ),
                                          ),
                                        ),
                                      ) : const SizedBox(),

                                    (cartController.paymentTypeIndex ==2 && !cartController.checkWalletAmount(cartController.customerId, payable)) ?
                                       const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),


                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [

                                          Text('${getTranslated('paid_amount', context)!} :', style: robotoRegular.copyWith()),
                    
                                          SizedBox(
                                            height: 45, width: 150,
                                            child: CustomTextFieldWidget(
                                              idDate: cartController.paymentTypeIndex != 0,
                                              border: true,
                                              hintText: getTranslated('amount', context),
                                              controller: _paidAmountController,
                                              focusNode: _paidAmountNode,
                                              textInputAction: TextInputAction.next,
                                              textInputType: TextInputType.number,
                                              borderColor: cartController.paidAmountless ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
                                              //showBorder: true,
                                              isAmount: true,
                                              focusBorder: true,
                                              onChanged: (value) {
                                                double? amount = double.tryParse(value);
                                                if(amount != null && (amount >= total)) {
                                                  cartController.setPaidAmountles(false);
                                                } else if (amount != null && (amount < total) && !cartController.paidAmountless) {
                                                  cartController.setPaidAmountles(true);
                                                }

                                                if (_paidAmountNode.hasFocus && MediaQuery.of(context).viewInsets.bottom > 0) {
                                                  // _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                                                  // FocusScope.of(context).unfocus();
                                                }

                                              },
                                              // isAmount: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    
                                    // (cartController.paymentTypeIndex == 0  && !cartController.paidAmountless) ?
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('${getTranslated('change_amount', context)!} :', style: robotoRegular.copyWith()),

                                          Text(PriceConverter.convertPrice(context, (double.tryParse(PriceConverter.reverseConvertPriceWithoutSymbol(context, double.tryParse(_paidAmountController.text)))! - total)), style: robotoRegular.copyWith()),
                                        ],
                                      ),
                                    ) ,

                                        //: const SizedBox(),
                    
                                     const SizedBox(height: Dimensions.paddingSizeDefault),
                                  ],
                                ),
                              ),
                            ),
                    
                            SizedBox(height:  MediaQuery.of(context).viewInsets.bottom > 0 ? 100 : Dimensions.paddingSizeDefault),
                    
                    
                    
                    
                            Container(padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 0,
                                  Dimensions.paddingSizeDefault, Dimensions.paddingSizeExtraSmall),
                              height: 50,child: Row(children: [
                              Expanded(child: CustomButtonWidget(
                                fontColor: ColorResources.getTextColor(context),
                                btnTxt: getTranslated('cancel', context),
                                backgroundColor: Theme.of(context).hintColor.withOpacity(.25),
                                onTap: (){
                                  subTotal = 0; productDiscount = 0; total = 0; payable = 0; couponAmount = 0; extraDiscount = 0; productTax = 0;
                                  cartController.customerCartList[cartController.customerIndex].cart!.clear();
                                  cartController.removeAllCart();
                                },)),
                              const SizedBox(width: Dimensions.paddingSizeSmall,),
                    
                              Expanded(child: CustomButtonWidget(btnTxt: getTranslated('place_order', context),
                                  onTap: () {
                                    if((cartController.paymentTypeIndex == 0 && cartController.paidAmountless)) {
                                      showCustomSnackBarWidget(getTranslated('paid_amount_cannot_less_then_order_amount', context), context, sanckBarType: SnackBarType.warning);
                                    } else if(double.tryParse(_paidAmountController.text) ==0){
                                      showCustomSnackBarWidget(getTranslated('paid_amount_cannot_zero', context), context, sanckBarType: SnackBarType.warning);
                                    } else if (cartController.paymentTypeIndex ==2 && !cartController.checkWalletAmount(cartController.customerId, payable)) {
                                      showCustomSnackBarWidget(getTranslated('your_wallet_balance_is_less_then_order_amount', context), context, sanckBarType: SnackBarType.warning);
                                    } else if(cartController.customerCartList[cartController.customerIndex].cart!.isEmpty) {
                                      showCustomSnackBarWidget(getTranslated('please_select_at_least_one_product', context), context);
                                    }
                                    else{
                                      showAnimatedDialogWidget(context,
                                        ConfirmPurchaseDialogWidget(
                                            onYesPressed: cartController.isLoading ? null : () {
                                              List<Cart> carts = [];
                                              productDiscount = 0;
                                              for (int index = 0; index < cartController.customerCartList[cartController.customerIndex].cart!.length; index++) {
                                                CartModel cart = cartController.customerCartList[cartController.customerIndex].cart![index];
                                                double? digitalVPrice = cart.digitalVariationPrice;
                                                carts.add(Cart(
                                                  cart.product!.id.toString(),
                                                  cart.price.toString(),
                                                  cart.product!.discountType == 'flat'?
                                                  productDiscount + cart.product!.discount! : productDiscount + ((cart.product!.discount!/100)* (digitalVPrice ?? cart.product!.unitPrice!)),
                                                  cart.quantity,
                                                  cart.variant,
                                                  cart.varientKey,
                                                  cart.digitalVariationPrice,
                                                  cart.variation!=null?
                                                  [cart.variation]:[],
                                                ));
                                              }

                                              print("==1234==>>${double.tryParse(PriceConverter.convertPriceWithoutSymbol(context, cartController.amount))}");

                                              print("====paidAmountPlaceOrder==>>${_paidAmountController.text}");

                                              PlaceOrderBody placeOrderBody = PlaceOrderBody(
                                                cart: carts,
                                                couponDiscountAmount: cartController.couponCodeAmount,
                                                couponCode: cartController.customerCartList[cartController.customerIndex].couponCode,
                                                couponAmount: cartController.customerCartList[cartController.customerIndex].couponAmount,
                                                orderAmount: double.tryParse(PriceConverter.convertPriceWithoutSymbol(context, cartController.amount)),
                                                userId: cartController.customerId,
                                                extraDiscountType: cartController.selectedDiscountType,
                                                paymentMethod: cartController.paymentTypeIndex == 0 ? 'cash' : cartController.paymentTypeIndex == 1 ? 'card' : 'wallet' ,
                                                extraDiscount: cartController.extraDiscountController.text.trim().isEmpty? 0.0 :
                                                cartController.selectedDiscountType == 'percent' ? cartController.customerCartList[cartController.customerIndex].extraDiscount :
                                                double.parse(PriceConverter.discountCalculationWithOutSymbol(context, subTotal, double.tryParse(PriceConverter.reverseConvertPriceWithoutSymbol(context, extraDiscount))!, cartController.selectedDiscountType)),
                                                paidAmount: double.tryParse(_paidAmountController.text)
                                              );

                                              print("===PlaceOrderBody====>>${placeOrderBody.toJson()}");
                                              cartController.placeOrder(context,placeOrderBody).then((value) {
                                                if(value.response!.statusCode == 200) {
                                                  couponAmount = 0;
                                                  extraDiscount = 0;
                                                }
                                              });

                                            }
                                        ),
                                        dismissible: false, isFlip: false);
                                    }
                                  })),
                            ],),),
                    
                    
                            const SizedBox(height: Dimensions.paddingSizeRevenueBottom,),
                          ],),),
                      ):const PosNoProductWidget(),
                    ],),
                  );
                }
            ) )
          ],
        ),
      ),
    );
  }
}


