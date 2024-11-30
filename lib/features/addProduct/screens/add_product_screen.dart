import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/add_product_model.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/edt_product_model.dart';
import 'package:sixvalley_vendor_app/features/addProduct/widgets/add_product_section_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/widgets/add_product_title_bar.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/add_product_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/screens/add_product_next_screen.dart';
import 'package:sixvalley_vendor_app/features/addProduct/widgets/digital_product_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/widgets/select_category_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/widgets/title_and_description_widget.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;
  final AddProductModel? addProduct;
  final EditProductModel? editProduct;
  final bool fromHome;
  const AddProductScreen({Key? key, this.product,  this.addProduct, this.editProduct,  this.fromHome = false}) : super(key: key);
  @override
  AddProductScreenState createState() => AddProductScreenState();
}

class AddProductScreenState extends State<AddProductScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  int? length;
  late bool _update;
  int cat=0, subCat=0, subSubCat=0, unit=0, brand=0;
  String? unitValue = '';
  List<String> titleList = [];
  List<String> descriptionList = [];
  List<String> authors = [];
  List<String> publishingHouses = [];
  FocusNode _publishingFocus = FocusNode();
  FocusNode _authorFocus = FocusNode();
  ScrollController _scrollController = ScrollController();

  Future<void> _load() async{
    Provider.of<AddProductController>(context, listen: false).resetCategory();
    String languageCode = Provider.of<LocalizationController>(context, listen: false).locale.countryCode == 'US'?
    'en':Provider.of<LocalizationController>(context, listen: false).locale.countryCode!.toLowerCase();
    await Provider.of<SplashController>(Get.context!, listen: false).getColorList();
     await Provider.of<AddProductController>(Get.context!,listen: false).getAttributeList(Get.context!, widget.product, languageCode);
    await Provider.of<AddProductController>(Get.context!,listen: false).getCategoryList(Get.context!,widget.product, languageCode);
    await Provider.of<AddProductController>(Get.context!,listen: false).getBrandList(Get.context!, languageCode);
    if(!_update && widget.product?.brandId == null){
      Provider.of<AddProductController>(Get.context!,listen: false).setBrandIndex(0, false);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: Provider.of<SplashController>(context,listen: false).configModel!.languageList!.length,
        initialIndex: 0,vsync: this);
    _tabController?.addListener((){
    });

    Provider.of<AddProductController>(context,listen: false).setSelectedPageIndex(0, isUpdate: false);
    _load();
    length = Provider.of<SplashController>(context,listen: false).configModel!.languageList!.length;
    _update = widget.product != null;
    Provider.of<AddProductController>(context, listen: false).initColorCode();
    if(widget.product != null){
      unitValue = widget.product!.unit;
      Provider.of<AddProductController>(context,listen: false).productCode.text = widget.product!.code ?? '123456';
      Provider.of<AddProductController>(context,listen: false).getEditProduct(context, widget.product!.id);
      // Provider.of<AddProductController>(context,listen: false).getProductImage(widget.product!.id.toString());
      Provider.of<AddProductController>(context,listen: false).setValueForUnit(widget.product!.unit.toString()) ;
      Provider.of<AddProductController>(context,listen: false).setProductTypeIndex(widget.product!.productType == "physical" ? 0 : 1, false);
      Provider.of<AddProductController>(context,listen: false).setDigitalProductTypeIndex(widget.product!.digitalProductType == "ready_after_sell"? 0 : 1, false);
      if(widget.product!.productType == 'digital') {
        Provider.of<AddProductController>(context,listen: false).setAuthorPublishingData(widget.product!);
      }

    }else{
      Provider.of<AddProductController>(context, listen: false).setCurrentStock('1');
      Provider.of<AddProductController>(context,listen: false).
      getTitleAndDescriptionList(Provider.of<SplashController>(context,listen: false).configModel!.languageList!, null);
      Provider.of<AddProductController>(context,listen: false).emptyDigitalProductData();
    }


    if(Provider.of<AddProductController>(context, listen: false).authorsList!.isNotEmpty) {
      for (var author in Provider.of<AddProductController>(context, listen: false).authorsList!) {
        authors.add(author.name!);
      }
    }

    if(Provider.of<AddProductController>(context, listen: false).publishingHouseList!.isNotEmpty) {
      for (var author in Provider.of<AddProductController>(context, listen: false).publishingHouseList!) {
        publishingHouses.add(author.name!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    late List<int?> brandIds;
     return PopScope(
       canPop: true,
       onPopInvoked: (value){
         Provider.of<AddProductController>(context,listen: false).removeCategory();
       },
       child: Scaffold(
        appBar: CustomAppBarWidget(title: widget.product != null ?
        getTranslated('update_product', context):getTranslated('add_product', context)),

         body: Consumer<AddProductController>(
           builder: (context, resProvider, child){
             brandIds = [];
             brandIds.add(0);
             if(resProvider.brandList != null) {
              for(int index=0; index<resProvider.brandList!.length; index++) {
                brandIds.add(resProvider.brandList![index].id);
              }
              if(_update && widget.product!.brandId != null) {
                if(brand ==0){
                  resProvider.setBrandIndex(brandIds.indexOf(widget.product!.brandId), false);
                  brand++;
                }
              }
            }
            return widget.product !=null && resProvider.editProduct == null?
            const Center(child: CircularProgressIndicator()):
            length != null? Consumer<SplashController>(
              builder: (context, splashController, _) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                      child: AddProductTitleBar()),

                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
                            AddProductSectionWidget(
                              title: getTranslated('product_name', context)!,
                              childrens: [
                                SizedBox(height: 50, width: MediaQuery.of(context).size.width,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                    child: TabBar(
                                      tabAlignment: TabAlignment.start,
                                      isScrollable: true,
                                      dividerColor: Colors.transparent,
                                      controller: _tabController,
                                      indicatorColor: Theme.of(context).primaryColor,
                                      indicatorWeight: 5,
                                      indicator: BoxDecoration(
                                          border: Border(bottom: BorderSide(color: Theme.of(context).primaryColor, width: 2))),
                                      labelColor: Theme.of(context).primaryColor,
                                      unselectedLabelColor: ColorResources.getTextColor(context),
                                      unselectedLabelStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor,
                                          fontSize: Dimensions.fontSizeLarge),
                                      labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge,
                                          color: Theme.of(context).primaryColor),
                                      tabs: _generateTabChildren(),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 240,
                                    child: TabBarView(controller: _tabController, children: _generateTabPage(resProvider))),
                              ],
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),



                            AddProductSectionWidget(
                              title: getTranslated('general_setup', context)!,
                              childrens: [
                                const SizedBox(height: Dimensions.paddingSizeSmall),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                  child: SelectCategoryWidget(product: widget.product),
                                ),

                                Provider.of<SplashController>(context, listen: false).configModel!.brandSetting == "1"  && resProvider.productTypeIndex != 1 ?
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(getTranslated('select_brand', context)! , style: robotoRegular.copyWith(
                                              color: ColorResources.titleColor(context), fontSize: Dimensions.fontSizeDefault)),
                                          Text('*',style: robotoBold.copyWith(color: ColorResources.mainCardFourColor(context),
                                              fontSize: Dimensions.fontSizeDefault),),
                                        ],
                                      ),
                                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                          border: Border.all(width: .5, color: Theme.of(context).primaryColor.withOpacity(.7)),
                                        ),
                                        child: DropdownButton<int>(
                                          value: resProvider.brandIndex,
                                          items: brandIds.map((int? value) {
                                            return DropdownMenuItem<int>(
                                              value: brandIds.indexOf(value),
                                              child: Text(value != 0 ? resProvider.brandList![(brandIds.indexOf(value)-1)].name! : getTranslated('select_brand', context)!),
                                            );
                                          }).toList(),
                                          onChanged: (int? value) {
                                            resProvider.setBrandIndex(value, true);
                                            // resProvider.changeBrandSelectedIndex(value);
                                          },
                                          isExpanded: true,
                                          underline: const SizedBox(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ):const SizedBox(),
                                const SizedBox(height: Dimensions.paddingSizeSmall),


                                resProvider.productTypeIndex == 0?
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        Text(getTranslated('select_unit', context)!, style: robotoRegular.copyWith(
                                          color: ColorResources.titleColor(context), fontSize: Dimensions.fontSizeDefault)),
                                        Text('*',style: robotoBold.copyWith(color: ColorResources.mainCardFourColor(context),
                                          fontSize: Dimensions.fontSizeDefault)),
                                      ]),
                                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                      Container(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                        decoration: BoxDecoration(color: Theme.of(context).cardColor,
                                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                            border: Border.all(width: .5, color: Theme.of(context).primaryColor.withOpacity(.7))
                                        ),
                                        child: DropdownButton<String>(
                                          hint: resProvider.unitValue == null || resProvider.unitValue == 'null'
                                              ? Text(getTranslated('select_unit', context)!, style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodySmall?.color))
                                              : Text(resProvider.unitValue!, style: TextStyle(color: ColorResources.getTextColor(context)),),
                                          items: Provider.of<SplashController>(context,listen: false).configModel!.unit!.map((String value) {
                                            return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value));}).toList(),
                                          onChanged: (val) {
                                            unitValue = val;
                                            setState(() {resProvider.setValueForUnit(val);},);},
                                          isExpanded: true,
                                          underline: const SizedBox(),
                                        ),
                                      ),

                                    ],
                                  ),
                                ):const SizedBox(),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                Provider.of<SplashController>(context, listen: false).configModel!.digitalProductSetting == "1"?
                                DigitalProductWidget(resProvider: resProvider, product: widget.product):const SizedBox(),

                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                Container(padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 0, Dimensions.paddingSizeDefault, 0),
                                  child: Column(children: [
                                    Row(
                                      children: [
                                        // Text(getTranslated('product_code_sku', context)!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
                                        // Text('*',style: robotoBold.copyWith(color: ColorResources.mainCardFourColor(context),
                                        //     fontSize: Dimensions.fontSizeDefault),),
                                        const Spacer(),
                                        InkWell(
                                            splashColor: Colors.transparent,
                                            onTap: (){
                                              String generateSKU() {
                                                const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
                                                final random = Random();
                                                String sku = '';

                                                for (int i = 0; i < 6; i++) {
                                                  sku += chars[random.nextInt(chars.length)];
                                                }
                                                return sku;
                                              }

                                              String code = generateSKU();
                                              resProvider.productCode.text = code.toString();
                                            },
                                            child: Text(getTranslated('generate_code', context)!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: ColorResources.mainCardFourColor(context)))),
                                      ],
                                    ),
                                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                    CustomTextFieldWidget(
                                      formProduct: true,
                                      required: true,
                                      border: true,
                                      controller: resProvider.productCode,
                                      textInputAction: TextInputAction.next,
                                      textInputType: TextInputType.text,
                                      isAmount: false,
                                      hintText: getTranslated('product_code_sku', context)!,
                                    ),
                                  ])),


                                //Author
                                resProvider.productTypeIndex == 1  ?
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                                  child: Autocomplete<String>(
                                    optionsBuilder: (TextEditingValue value) {
                                      if (value.text.isEmpty) {
                                        return const Iterable<String>.empty();
                                      } else {
                                        return authors.where((author) => author.toLowerCase().contains(value.text.toLowerCase()));
                                      }
                                    },
                                    fieldViewBuilder: (context, controller, node, onComplete) {
                                      _authorFocus = node;
                                      if(!node.hasFocus){
                                        _authorFocus.unfocus();
                                      } else{
                                        _authorFocus.requestFocus();
                                      }
                                      return TextField(
                                        keyboardType: TextInputType.text,
                                        controller: controller,
                                        focusNode: node,
                                        onEditingComplete: onComplete,
                                        onSubmitted: (value) {
                                          if(resProvider.selectedAuthors!.isEmpty){
                                            _scrollController.jumpTo(_scrollController.offset + 20);
                                          }
                                          resProvider.addAuthor(value);
                                          // controller.text = '';
                                        },
                                        decoration: InputDecoration(
                                          hintText: '',
                                          label : Text.rich(TextSpan(children: [
                                            TextSpan(text: getTranslated('author_creator_artist', context), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).hintColor.withOpacity(.75))),
                                          ])),
                                          border: InputBorder.none,
                                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(color: Color(0x261455AC), width: .75)),
                                        ),
                                      );
                                    },
                                    displayStringForOption: (value) =>  value,
                                    onSelected: (String value) {
                                     // resProvider.addAuthor(value);
                                    },
                                    optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                                      return Align(
                                        alignment: Alignment.topLeft,
                                        child: Container(
                                          height:  (keyboardHeight ==0 &&  (_authorFocus.hasFocus)) ? 155 : 250,
                                          padding: const EdgeInsets.only(right: 8.0), // Add padding to the right
                                          width: MediaQuery.of(context).size.width * 0.9, // Adjust the width if needed
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                            boxShadow: [BoxShadow(color: Colors.grey[Provider.of<ThemeController>(context).darkTheme ? 800 : 200]!,
                                                spreadRadius: 0.5, blurRadius: 0.3)],
                                          ),
                                          child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            itemCount: options.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              final String option = options.elementAt(index);
                                              return InkWell(
                                                onTap: () {
                                                  onSelected(option);
                                                },
                                                child: Builder(
                                                  builder: (BuildContext context) {
                                                    final bool highlight = AutocompleteHighlightedOption.of(context) == index;
                                                    if (highlight) {
                                                      SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
                                                        Scrollable.ensureVisible(context, alignment: 0.5);
                                                      }, debugLabel: 'AutocompleteOptions.ensureVisible');
                                                    }
                                                    return Container(
                                                      color: highlight ? Theme.of(context).focusColor : null,
                                                      padding: const EdgeInsets.all(16.0),
                                                      child: Text(option),
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ) : const SizedBox(),

                                SizedBox(height: resProvider.productTypeIndex == 1 && resProvider.selectedAuthors!.isNotEmpty ? Dimensions.paddingSizeSmall : 0),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                  child: SizedBox(height: (resProvider.productTypeIndex == 1 && resProvider.selectedAuthors!.isNotEmpty) ? 40 : 0,
                                    child: (resProvider.selectedAuthors!.isNotEmpty) ?

                                    ListView.builder(
                                      itemCount: resProvider.selectedAuthors!.length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.all(Dimensions.paddingSizeVeryTiny),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeMedium),
                                            margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                            decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(.20),
                                              borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                                            ),
                                            child: Row(children: [
                                              Consumer<SplashController>(builder: (ctx, colorP,child){
                                                return Text(resProvider.selectedAuthors![index]!,
                                                  style: robotoRegular.copyWith(color: ColorResources.titleColor(context)),);
                                              }),
                                              const SizedBox(width: Dimensions.paddingSizeSmall),
                                              InkWell(
                                                splashColor: Colors.transparent,
                                                onTap: (){resProvider.removeAuthor(index);},
                                                child: Icon(Icons.close, size: 15, color: ColorResources.titleColor(context)),
                                              ),
                                            ]),
                                          ),
                                        );
                                      },
                                    ):const SizedBox(),
                                  ),
                                ),


                                //Publishing
                                resProvider.productTypeIndex == 1  ?
                                  Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                                  child: Autocomplete<String> (
                                    optionsBuilder: (TextEditingValue value) {
                                      if (value.text.isEmpty) {
                                        return const Iterable<String>.empty();
                                      } else {
                                        return publishingHouses.where((author) => author.toLowerCase().contains(value.text.toLowerCase()));
                                      }
                                    },
                                    fieldViewBuilder: (context, controller, node, onComplete) {
                                      _publishingFocus = node;
                                      if(!node.hasFocus){
                                        _publishingFocus.unfocus();
                                      } else{
                                        _publishingFocus.requestFocus();
                                      }
                                      return TextField(
                                        keyboardType: TextInputType.text,
                                        controller: controller,
                                        focusNode: node,
                                        onEditingComplete: onComplete,
                                        onSubmitted: (value) {
                                          if(resProvider.selectedPublishingHouse!.isEmpty){
                                            _scrollController.jumpTo(_scrollController.offset + 20);
                                          }
                                          resProvider.addPublishingHouse(value);
                                        },
                                        decoration: InputDecoration(
                                          hintText: '',
                                          contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                                          label : Text.rich(TextSpan(children: [
                                            TextSpan(text: getTranslated('publishing_house', context), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).hintColor.withOpacity(.75))),
                                          ])),
                                          border: InputBorder.none,
                                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                                            borderSide: const BorderSide(color: Color(0x261455AC), width: .75)
                                          ),
                                        ),
                                      );
                                    },
                                    displayStringForOption: (value) =>  value,
                                    onSelected: (String value) {
                                      // resProvider.addAuthor(value);
                                    },

                                    optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                                      return Align(
                                        alignment: Alignment.topLeft,
                                        child: Container(
                                          height: (keyboardHeight ==0 &&  (_publishingFocus.hasFocus)) ? 100 : 250,
                                          padding: const EdgeInsets.only(right: 8.0), // Add padding to the right
                                          width: MediaQuery.of(context).size.width * 0.9, //
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                            boxShadow: [BoxShadow(color: Colors.grey[Provider.of<ThemeController>(context).darkTheme ? 800 : 200]!,
                                                spreadRadius: 0.5, blurRadius: 0.3)],
                                          ),

                                          // Adjust the width if needed
                                          child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            itemCount: options.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              final String option = options.elementAt(index);
                                              return InkWell(
                                                onTap: () {
                                                  onSelected(option);
                                                },
                                                child: Builder(
                                                  builder: (BuildContext context) {
                                                    final bool highlight = AutocompleteHighlightedOption.of(context) == index;
                                                    if (highlight) {
                                                      SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
                                                        Scrollable.ensureVisible(context, alignment: 0.5);
                                                      }, debugLabel: 'AutocompleteOptions.ensureVisible');
                                                    }
                                                    return Container(
                                                      color: highlight ? Theme.of(context).focusColor : null,
                                                      padding: const EdgeInsets.all(16.0),
                                                      child: Text(option),
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ) : const SizedBox(),

                                SizedBox(height: resProvider.productTypeIndex == 1 && resProvider.selectedPublishingHouse!.isNotEmpty ? Dimensions.paddingSizeSmall : 0),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault ),
                                  child: SizedBox(height: (resProvider.productTypeIndex == 1 && resProvider.selectedPublishingHouse!.isNotEmpty) ? 40 : 0,
                                    child: (resProvider.selectedPublishingHouse!.isNotEmpty) ?

                                    ListView.builder(
                                      itemCount: resProvider.selectedPublishingHouse!.length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.all(Dimensions.paddingSizeVeryTiny),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeMedium),
                                            margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                            decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(.20),
                                              borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                                            ),
                                            child: Row(children: [
                                              Consumer<SplashController>(builder: (ctx, colorP,child){
                                                return Text(resProvider.selectedPublishingHouse![index]!,
                                                  style: robotoRegular.copyWith(color: ColorResources.titleColor(context)),);
                                              }),
                                              const SizedBox(width: Dimensions.paddingSizeSmall),
                                              InkWell(
                                                splashColor: Colors.transparent,
                                                onTap: (){resProvider.removePublishingHouse(index);},
                                                child: Icon(Icons.close, size: 15, color: ColorResources.titleColor(context)),
                                              ),
                                            ]),
                                          ),
                                        );
                                      },
                                    ):const SizedBox(),
                                  ),
                                ),
                                //End Author Publishing

                                const SizedBox(height: 15),

                               //  SizedBox(height: keyboardHeight > 0 ? (keyboardHeight - 150) : 0),
                              ],
                            ),

                          ]),
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      height: (keyboardHeight > 0 &&  (_publishingFocus.hasFocus || _authorFocus.hasFocus)) ? (keyboardHeight) :  80,
                      decoration: BoxDecoration(
                        color: (keyboardHeight > 0 &&  (_publishingFocus.hasFocus || _authorFocus.hasFocus)) ? Colors.transparent  : Theme.of(context).cardColor,
                        boxShadow:  (keyboardHeight > 0 &&  (_publishingFocus.hasFocus || _authorFocus.hasFocus)) ? null : [BoxShadow(color: Colors.grey[Provider.of<ThemeController>(context).darkTheme ? 800 : 200]!,
                            spreadRadius: 0.5, blurRadius: 0.3)],
                      ),
                      child: (keyboardHeight > 0 &&  (_publishingFocus.hasFocus || _authorFocus.hasFocus)) ? const SizedBox() : Consumer<AddProductController>(
                          builder: (context,resProvider, _) {
                            return!resProvider.isLoading? SizedBox(height: 50,
                              child: InkWell(
                                onTap: resProvider.categoryList == null ? null : (){
                                  bool haveBlankTitle = false;
                                  bool haveBlankDes = false;
                                  for(TextEditingController title in resProvider.titleControllerList){
                                    if(title.text.isEmpty){
                                      haveBlankTitle = true;
                                      break;
                                    }
                                  }
                                  for(TextEditingController des in resProvider.descriptionControllerList){
                                    if(des.text.isEmpty){
                                      haveBlankDes = true;
                                      break;}}

                                  if(haveBlankTitle){
                                    showCustomSnackBarWidget(getTranslated('please_input_all_title',context),context, sanckBarType: SnackBarType.warning);
                                  }else if(haveBlankDes){
                                    showCustomSnackBarWidget(getTranslated('please_input_all_des',context),context,  sanckBarType: SnackBarType.warning);
                                  }
                                  // else if ((resProvider.productTypeIndex == 1 &&resProvider.digitalProductTypeIndex == 1 &&
                                  //     resProvider.selectedFileForImport == null) && widget.product == null ) {
                                  //   showCustomSnackBarWidget(getTranslated('please_choose_digital_product',context),context,  sanckBarType: SnackBarType.warning);
                                  // }
                                  else if (resProvider.categoryIndex == 0 || resProvider.categoryIndex == -1) {
                                    showCustomSnackBarWidget(getTranslated('select_a_category',context),context,  sanckBarType: SnackBarType.warning);
                                  }
                                  else if (resProvider.brandIndex == 0 && Provider.of<SplashController>(context, listen: false).configModel!.brandSetting == "1" && resProvider.productTypeIndex != 1) {
                                    showCustomSnackBarWidget(getTranslated('select_a_brand',context),context,  sanckBarType: SnackBarType.warning);
                                  }
                                  else if (resProvider.unitValue == '' || resProvider.unitValue == null &&  resProvider.productTypeIndex == 0) {
                                    showCustomSnackBarWidget(getTranslated('select_a_unit',context),context,  sanckBarType: SnackBarType.warning);
                                  }
                                  else if (resProvider.productCode.text == '' || resProvider.productCode.text.isEmpty) {
                                    showCustomSnackBarWidget(getTranslated('product_code_is_required',context),context,  sanckBarType: SnackBarType.warning);
                                  }
                                  else if (resProvider.productCode.text.length < 6 || resProvider.productCode.text == '000000') {
                                    showCustomSnackBarWidget(getTranslated('product_code_minimum_6_digit',context),context,  sanckBarType: SnackBarType.warning);
                                  }
                                  else{
                                    for(TextEditingController textEditingController in resProvider.titleControllerList) {
                                      titleList.add(textEditingController.text.trim());
                                    }
                                    // if(resProvider.productTypeIndex == 1 &&resProvider.digitalProductTypeIndex == 1 &&
                                    //     resProvider.selectedFileForImport != null ) {
                                    //   resProvider.uploadDigitalProduct(Provider.of<AuthController>(context,listen: false).getUserToken());
                                    // }
                                    resProvider.setSelectedPageIndex(1, isUpdate: true);
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => AddProductNextScreen(
                                        categoryId: resProvider.categoryList![resProvider.categoryIndex!-1].id.toString(),
                                        subCategoryId: resProvider.subCategoryIndex != 0? resProvider.subCategoryList![resProvider.subCategoryIndex!-1].id.toString(): "-1",
                                        subSubCategoryId:(resProvider.subSubCategoryIndex != 0 && resProvider.subSubCategoryIndex! != -1) ? resProvider.subSubCategoryList![resProvider.subSubCategoryIndex!-1].id.toString():"-1",
                                        brandId: brandIds[resProvider.brandIndex!].toString(),
                                        unit: unitValue,
                                        product: widget.product, addProduct: widget.addProduct)));
                                  }},


                                child: Container(width: MediaQuery.of(context).size.width, height: 40,
                                  decoration: BoxDecoration(
                                    color: resProvider.categoryList == null ? Theme.of(context).hintColor : Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                                  ),
                                  child: Center(child: Text(getTranslated('next',context)!, style: const TextStyle(
                                      color: Colors.white,fontWeight: FontWeight.w600,
                                      fontSize: Dimensions.fontSizeLarge),)),
                                ),
                              ),):
                            const SizedBox();
                          }
                      ),
                    )
                  ],
                );
              }
            ):const SizedBox();
          },
        ),
       ),
     );
  }

  List<Widget> _generateTabChildren() {
    List<Widget> tabs = [];
    for(int index=0; index < Provider.of<SplashController>(context, listen: false).configModel!.languageList!.length; index++) {
      tabs.add(Text(Provider.of<SplashController>(context, listen: false).configModel!.languageList![index].name!.capitalize(),
          style: robotoBold.copyWith()));
    }
    return tabs;
  }

  List<Widget> _generateTabPage(AddProductController resProvider) {
    List<Widget> tabView = [];
    for(int index=0; index < Provider.of<SplashController>(context, listen: false).configModel!.languageList!.length; index++) {
      tabView.add(TitleAndDescriptionWidget(resProvider: resProvider, index: index));
    }
    return tabView;
  }
}


extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}