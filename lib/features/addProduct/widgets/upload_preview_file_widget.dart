import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/add_product_controller.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';


class UploadPreviewFileWidget extends StatefulWidget {
  final Product? product;
  const UploadPreviewFileWidget({super.key, this.product});

  @override
  State<UploadPreviewFileWidget> createState() => _UploadPreviewFileWidgetState();
}

class _UploadPreviewFileWidgetState extends State<UploadPreviewFileWidget> {
  final tooltipController = JustTheController();

  @override
  void initState() {
    if(widget.product!= null && widget.product?.previewFileFullUrl != null && widget.product?.previewFileFullUrl?.path != null && widget.product?.previewFileFullUrl?.path != '') {
      Provider.of<AddProductController>(context,listen: false).setPreviewData(false);
    } else {
      Provider.of<AddProductController>(context,listen: false).setPreviewData(true);
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<AddProductController>(
        builder: (context, resProvider, child) {
        return Column(children: [
          Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text( getTranslated('upload_preview_file', context)!, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  JustTheTooltip(
                    backgroundColor: Colors.black87,
                    controller: tooltipController,
                    preferredDirection: AxisDirection.up,
                    tailLength: 10,
                    tailBaseWidth: 20,
                    content: Container(width: 250,
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        child: Text(getTranslated('upload_a_suitable_file', context)!,
                            style: robotoRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault))),
                    child: InkWell(onTap: ()=>  tooltipController.showTooltip(),
                      child: Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                        child: SizedBox(width: 20, child: Image.asset(Images.infoIcon)),
                      ),
                    ),
                  )
                ],
              )
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D1B7FED), // 0x0D is the hex value for 5% opacity
                      offset: Offset(0, 6),
                      blurRadius: 12,
                      spreadRadius: -3,
                    ),
                    BoxShadow(
                      color: Color(0x0D1B7FED), // 0x0D is the hex value for 5% opacity
                      offset: Offset(0, -6),
                      blurRadius: 12,
                      spreadRadius: -3,
                    ),
                  ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [


                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                    ),
                    child: DottedBorder(
                        dashPattern: const [4,5],
                        borderType: BorderType.RRect,
                        color: Theme.of(context).hintColor,
                        radius: const Radius.circular(15),
                        child: Container(
                          height: 110,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          ),
                          child: Stack(
                            children: [

                              if(!resProvider.isPreviewNull || resProvider.digitalProductPreview != null )
                              Positioned(
                                top: 10,
                                right: 10,
                                child: InkWell(
                                  onTap: () {
                                    if(!resProvider.isPreviewNull) {
                                      resProvider.deleteDigitalPreviewFile(widget.product?.id);
                                    } else {
                                      resProvider.deleteDigitalPreviewFile(null);
                                    }
                                  } ,
                                  child: resProvider.isPreviewLoading ? const Center(child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator())) : Image.asset(width:25, Images.digitalPreviewDeleteIcon))
                              ),

                              Positioned.fill(
                                child: Center(
                                  child:Column(
                                    mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [

                                      if(resProvider.digitalProductPreview == null && resProvider.isPreviewNull)
                                      ...[
                                        InkWell(
                                          onTap: () => resProvider.pickFileDigitalProductPreview(),
                                          child: Column(
                                            children: [
                                              SizedBox(width: 30, child: Image.asset(Images.uploadIcon)),
                                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                              Text(getTranslated('upload_file', context)!,
                                                  style: robotoRegular.copyWith(fontWeight: FontWeight.w600, fontSize: Dimensions.fontSizeDefault))
                                            ],
                                          ),
                                        )
                                      ],


                                      if(resProvider.digitalProductPreview != null)
                                        ...[
                                          Column(
                                            children: [
                                              SizedBox(width: 30, child: Image.asset(Images.digitalPreviewFileIcon) ),
                                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                              Text(resProvider.digitalProductPreview?.name ?? '',
                                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault))
                                            ],
                                          )
                                        ],


                                        if(resProvider.digitalProductPreview == null && !resProvider.isPreviewNull)
                                          ...[
                                            Column(
                                              children: [
                                                SizedBox(width: 30, child: Image.asset(Images.digitalPreviewFileIcon)),
                                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                                Text(widget.product?.previewFileFullUrl?.key ?? '',
                                                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault))
                                              ],
                                            )
                                          ],

                                    ],
                                  ),
                                ),
                              ),



                            ],
                          )
                        )
                    ),
                  ),


                ],
              ),
            ),
          ),
        ],
        );
      }
    );
  }
}
