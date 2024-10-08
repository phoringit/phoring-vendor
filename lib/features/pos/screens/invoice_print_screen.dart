// import 'dart:async';
// import 'dart:developer';
// import 'dart:io';
// import 'package:esc_pos_utils/esc_pos_utils.dart';
// import 'package:flutter/material.dart';
// // import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
// import 'package:sixvalley_vendor_app/features/pos/domain/models/invoice_model.dart';
// import 'package:sixvalley_vendor_app/features/shop/domain/models/shop_model.dart';
// import 'package:sixvalley_vendor_app/helper/date_converter.dart';
// import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
// import 'package:sixvalley_vendor_app/main.dart';
// import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
// import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
// // import 'package:flutter_pos_printer_platform_image_3_sdt/flutter_pos_printer_platform_image_3_sdt.dart';
//
//
//
// class InVoicePrintScreen extends StatefulWidget {
//   final InvoiceModel? invoice;
//   final ShopModel? shopModel;
//   final int? orderId;
//   final double? discountProduct;
//   final double? total;
//   const InVoicePrintScreen({Key? key, this.invoice, this.shopModel, this.orderId, this.discountProduct, this.total}) : super(key: key);
//
//   @override
//   State<InVoicePrintScreen> createState() => _InVoicePrintScreenState();
// }
//
// class _InVoicePrintScreenState extends State<InVoicePrintScreen> {
//   var defaultPrinterType = PrinterType.bluetooth;
//   final _isBle = false;
//   var printerManager = PrinterManager.instance;
//   var devices = <BluetoothPrinter>[];
//   StreamSubscription<PrinterDevice>? _subscription;
//   StreamSubscription<BTStatus>? _subscriptionBtStatus;
//   BTStatus _currentStatus = BTStatus.none;
//   List<int>? pendingTask;
//   String _ipAddress = '';
//   String _port = '9100';
//   final _ipController = TextEditingController();
//   final _portController = TextEditingController();
//   BluetoothPrinter? selectedPrinter;
//
//   @override
//   void initState() {
//     if (Platform.isWindows) defaultPrinterType = PrinterType.usb;
//     super.initState();
//     _portController.text = _port;
//     _scan();
//
//     // subscription to listen change status of bluetooth connection
//     _subscriptionBtStatus = PrinterManager.instance.stateBluetooth.listen((status) {
//       log(' ----------------- status bt $status ------------------ ');
//       _currentStatus = status;
//
//       if (status == BTStatus.connected && pendingTask != null) {
//         if (Platform.isAndroid) {
//           Future.delayed(const Duration(milliseconds: 1000), () {
//             PrinterManager.instance.send(type: PrinterType.bluetooth, bytes: pendingTask!);
//             pendingTask = null;
//           });
//         } else if (Platform.isIOS) {
//           PrinterManager.instance.send(type: PrinterType.bluetooth, bytes: pendingTask!);
//           pendingTask = null;
//         }
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _subscription?.cancel();
//     _subscriptionBtStatus?.cancel();
//     _portController.dispose();
//     _ipController.dispose();
//     super.dispose();
//   }
//
//   // method to scan devices according PrinterType
//   void _scan() {
//     devices.clear();
//     _subscription = printerManager.discovery(type: defaultPrinterType, isBle: _isBle).listen((device) {
//       devices.add(BluetoothPrinter(
//         deviceName: device.name,
//         address: device.address,
//         isBle: _isBle,
//         vendorId: device.vendorId,
//         productId: device.productId,
//         typePrinter: defaultPrinterType,
//       ));
//       setState(() {});
//     });
//   }
//
//   void setPort(String value) {
//     if (value.isEmpty) value = '9100';
//     _port = value;
//     var device = BluetoothPrinter(
//       deviceName: value,
//       address: _ipAddress,
//       port: _port,
//       typePrinter: PrinterType.network,
//       state: false,
//     );
//     selectDevice(device);
//   }
//
//   void setIpAddress(String value) {
//     _ipAddress = value;
//     var device = BluetoothPrinter(
//       deviceName: value,
//       address: _ipAddress,
//       port: _port,
//       typePrinter: PrinterType.network,
//       state: false,
//     );
//     selectDevice(device);
//   }
//
//   void selectDevice(BluetoothPrinter device) async {
//     if (selectedPrinter != null) {
//       if ((device.address != selectedPrinter!.address) || (device.typePrinter == PrinterType.usb && selectedPrinter!.vendorId != device.vendorId)) {
//         await PrinterManager.instance.disconnect(type: selectedPrinter!.typePrinter);
//       }
//     }
//
//     selectedPrinter = device;
//     setState(() {});
//   }
//
//
//
//   Future _printReceiveTest() async {
//     final profile = await CapabilityProfile.load();
//     final generator = Generator(PaperSize.mm80, profile);
//     List<int> bytes = [];
//
//     bytes += generator.text('${widget.shopModel!.name}',
//         styles: const PosStyles(align: PosAlign.center,bold: true));
//     bytes += generator.text('${widget.shopModel!.contact}',
//         styles: const PosStyles(align: PosAlign.center));
//
//     bytes += generator.text('...............................................................', styles: const PosStyles(align: PosAlign.center));
//     bytes += generator.text(' ', styles: const PosStyles(align: PosAlign.center));
//
//     bytes += generator.row([
//       PosColumn(
//         text: '${getTranslated('invoice',  Get.context!)!.toUpperCase()}#${widget.orderId}',
//         width: 6,
//         styles: const PosStyles(align: PosAlign.left, underline: true),
//       ),
//
//       PosColumn(
//         text: getTranslated('payment_method',  Get.context!)!,
//         width: 6,
//         styles: const PosStyles(align: PosAlign.right, underline: true),
//       ),
//     ]);
//     bytes += generator.row([
//       PosColumn(
//         text: DateConverter.dateTimeStringToMonthAndTime(widget.invoice!.createdAt!),
//         width: 6,
//         styles: const PosStyles(align: PosAlign.left),
//       ),
//
//       PosColumn(
//         text: 'Cash',
//         width: 6,
//         styles: const PosStyles(align: PosAlign.right),
//       ),
//     ]);
//
//     bytes += generator.row([
//       PosColumn(
//         text: getTranslated('sl',  Get.context!)!.toUpperCase(),
//         width: 2,
//         styles: const PosStyles(align: PosAlign.left),
//       ),
//
//       PosColumn(
//         text: getTranslated('product_info',  Get.context!)!,
//         width: 6,
//         styles: const PosStyles(align: PosAlign.left),
//       ),
//       PosColumn(
//         text: getTranslated('qty',  Get.context!)!,
//         width: 1,
//         styles: const PosStyles(align: PosAlign.right),
//       ),
//       PosColumn(
//         text: getTranslated('price',  Get.context!)!,
//         width: 3,
//         styles: const PosStyles(align: PosAlign.right),
//       ),
//     ]);
//
//     bytes += generator.text('...............................................................', styles: const PosStyles(align: PosAlign.center));
//
//     for(int i =0; i< widget.invoice!.details!.length; i++){
//       bytes += generator.row([
//         PosColumn(
//           text: '${i+1}',
//           width: 1,
//           styles: const PosStyles(align: PosAlign.left),
//         ),
//
//         PosColumn(
//           text: '${widget.invoice!.details![i].productDetails!.name}',
//           width: 7,
//           styles: const PosStyles(align: PosAlign.left),
//         ),
//         PosColumn(
//           text: widget.invoice!.details![i].qty.toString(),
//           width: 1,
//           styles: const PosStyles(align: PosAlign.right),
//         ),
//         PosColumn(
//           text: '${widget.invoice!.details![i].price}',
//           width: 3,
//           styles: const PosStyles(align: PosAlign.right),
//         ),
//       ]);
//     }
//
//
//
//     bytes += generator.text('...............................................................', styles: const PosStyles(align: PosAlign.center));
//
//     bytes += generator.row([
//       PosColumn(
//         text: getTranslated('subtotal',  Get.context!)!,
//         width: 6,
//         styles: const PosStyles(align: PosAlign.left,),
//       ),
//
//       PosColumn(
//         text: '${widget.invoice!.orderAmount}',
//         width: 6,
//         styles: const PosStyles(align: PosAlign.right,),
//       ),
//     ]);
//     bytes += generator.row([
//       PosColumn(
//         text: getTranslated('product_discount',  Get.context!)!,
//         width: 6,
//         styles: const PosStyles(align: PosAlign.left),
//       ),
//
//       PosColumn(
//         text: '${widget.discountProduct}',
//         width: 6,
//         styles: const PosStyles(align: PosAlign.right),
//       ),
//     ]);
//
//     bytes += generator.row([
//       PosColumn(
//         text: getTranslated('coupon_discount',  Get.context!)!,
//         width: 12,
//         styles: const PosStyles(align: PosAlign.left),
//       ),
//     ]);
//     bytes += generator.row([
//       PosColumn(
//         text: getTranslated('extra_discount',  Get.context!)!,
//         width: 6,
//         styles: const PosStyles(align: PosAlign.left),
//       ),
//
//       PosColumn(
//         text: '${widget.invoice!.extraDiscount}',
//         width: 6,
//         styles: const PosStyles(align: PosAlign.right),
//       ),
//     ]);
//     bytes += generator.row([
//       PosColumn(
//         text: getTranslated('tax',  Get.context!)!,
//         width: 12,
//         styles: const PosStyles(align: PosAlign.left),
//       ),
//
//     ]);
//
//     bytes += generator.text('...............................................................', styles: const PosStyles(align: PosAlign.center));
//
//     bytes += generator.row([
//       PosColumn(
//         text: getTranslated('total',  Get.context!)!,
//         width: 6,
//         styles: const PosStyles(align: PosAlign.left),
//       ),
//
//       PosColumn(
//         text: '${widget.total! - widget.discountProduct!}',
//         width: 6,
//         styles: const PosStyles(align: PosAlign.right),
//       ),
//     ]);
//
//     bytes += generator.row([
//       PosColumn(
//         text: getTranslated('change',  Get.context!)!,
//         width: 6,
//         styles: const PosStyles(align: PosAlign.left),
//       ),
//
//       PosColumn(
//         text: '${widget.invoice!.orderAmount! - widget.total! - widget.discountProduct!}',
//         width: 6,
//         styles: const PosStyles(align: PosAlign.right),
//       ),
//     ]);
//
//
//
//
//     bytes += generator.text(' ', styles: const PosStyles(align: PosAlign.center));
//     bytes += generator.text('...............................................................', styles: const PosStyles(align: PosAlign.center));
//     bytes += generator.text(getTranslated('thank_you', Get.context!)!, styles: const PosStyles(align: PosAlign.center));
//     bytes += generator.text(' ',);
//
//
//     _printEscPos(bytes, generator);
//   }
//
//   /// print ticket
//   void _printEscPos(List<int> bytes, Generator generator) async {
//     if (selectedPrinter == null) return;
//     var bluetoothPrinter = selectedPrinter!;
//
//     switch (bluetoothPrinter.typePrinter) {
//       case PrinterType.usb:
//         bytes += generator.feed(2);
//         bytes += generator.cut();
//         await printerManager.connect(
//             type: bluetoothPrinter.typePrinter,
//             model: UsbPrinterInput(name: bluetoothPrinter.deviceName, productId: bluetoothPrinter.productId, vendorId: bluetoothPrinter.vendorId));
//         break;
//       case PrinterType.bluetooth:
//         bytes += generator.cut();
//         await printerManager.connect(
//             type: bluetoothPrinter.typePrinter,
//             model:
//             BluetoothPrinterInput(name: bluetoothPrinter.deviceName, address: bluetoothPrinter.address!, isBle: bluetoothPrinter.isBle));
//         pendingTask = null;
//         if (Platform.isIOS || Platform.isAndroid) pendingTask = bytes;
//         break;
//       case PrinterType.network:
//         bytes += generator.feed(2);
//         bytes += generator.cut();
//         await printerManager.connect(type: bluetoothPrinter.typePrinter, model: TcpPrinterInput(ipAddress: bluetoothPrinter.address!));
//         break;
//       default:
//     }
//     if (bluetoothPrinter.typePrinter == PrinterType.bluetooth) {
//       if (_currentStatus == BTStatus.connected) {
//         printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
//         pendingTask = null;
//       }
//     } else {
//       printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBarWidget(title: getTranslated('print', context),),
//       body: Center(
//         child: Container(
//           height: double.infinity,
//           constraints: const BoxConstraints(maxWidth: 400),
//           child: SingleChildScrollView(
//             padding: EdgeInsets.zero,
//             child: Column(
//               children: [
//                 Column(
//                     children: devices.map((device) => ListTile(
//                       title: Text('${device.deviceName}'),
//                       subtitle: Platform.isAndroid && defaultPrinterType == PrinterType.usb
//                           ? null
//                           : Visibility(visible: !Platform.isWindows, child: Text("${device.address}")),
//                       onTap: () {selectDevice(device);},
//                       leading: selectedPrinter != null &&
//                           ((device.typePrinter == PrinterType.usb && Platform.isWindows
//                               ? device.deviceName == selectedPrinter!.deviceName
//                               : device.vendorId != null && selectedPrinter!.vendorId == device.vendorId) ||
//                               (device.address != null && selectedPrinter!.address == device.address))
//                           ? const Icon(
//                         Icons.check,
//                         color: Colors.green,
//                       ) : null,
//                       trailing: OutlinedButton(
//                         onPressed: selectedPrinter == null || device.deviceName != selectedPrinter?.deviceName
//                             ? null : () async {
//                           _printReceiveTest();
//                         },
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
//                           child: Text(getTranslated('print_invoice', context)!, textAlign: TextAlign.center),
//                         ),
//                       ),
//                     ),
//                     )
//                         .toList()),
//                 Visibility(
//                   visible: defaultPrinterType == PrinterType.network && Platform.isWindows,
//                   child: Padding(
//                     padding: const EdgeInsets.only(top: 10.0),
//                     child: TextFormField(
//                       controller: _ipController,
//                       keyboardType: const TextInputType.numberWithOptions(signed: true),
//                       decoration: const InputDecoration(
//                         label: Text("Ip Address"),
//                         prefixIcon: Icon(Icons.wifi, size: 24),
//                       ),
//                       onChanged: setIpAddress,
//                     ),
//                   ),
//                 ),
//                 Visibility(
//                   visible: defaultPrinterType == PrinterType.network && Platform.isWindows,
//                   child: Padding(
//                     padding: const EdgeInsets.only(top: 10.0),
//                     child: TextFormField(
//                       controller: _portController,
//                       keyboardType: const TextInputType.numberWithOptions(signed: true),
//                       decoration: const InputDecoration(
//                         label: Text("Port"),
//                         prefixIcon: Icon(Icons.numbers_outlined, size: 24),
//                       ),
//                       onChanged: setPort,
//                     ),
//                   ),
//                 ),
//                 Visibility(
//                   visible: defaultPrinterType == PrinterType.network && Platform.isWindows,
//                   child: Padding(
//                     padding: const EdgeInsets.only(top: 10.0),
//                     child: OutlinedButton(
//                       onPressed: () async {
//                         if (_ipController.text.isNotEmpty) setIpAddress(_ipController.text);
//                         _printReceiveTest();
//                       },
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 50),
//                         child: Text(getTranslated('print_invoice', context)!, textAlign: TextAlign.center),
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class BluetoothPrinter {
//   int? id;
//   String? deviceName;
//   String? address;
//   String? port;
//   String? vendorId;
//   String? productId;
//   bool isBle;
//
//   PrinterType typePrinter;
//   bool? state;
//
//   BluetoothPrinter(
//       {this.deviceName,
//         this.address,
//         this.port,
//         this.state,
//         this.vendorId,
//         this.productId,
//         this.typePrinter = PrinterType.bluetooth,
//         this.isBle = false});
// }
//
//
//
//
// // import 'package:flutter/material.dart';
// // import 'package:esc_pos_utils/esc_pos_utils.dart';
// // import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
// //
// // class PrintReceipt extends StatefulWidget {
// //   final ShopModel? shopModel;
// //   final String orderId;
// //   final Invoice? invoice;
// //   final double discountProduct;
// //   final double total;
// //
// //   PrintReceipt({
// //     required this.shopModel,
// //     required this.orderId,
// //     required this.invoice,
// //     required this.discountProduct,
// //     required this.total,
// //   });
// //
// //   @override
// //   _PrintReceiptState createState() => _PrintReceiptState();
// // }
// //
// // class _PrintReceiptState extends State<PrintReceipt> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text('Print Receipt')),
// //       body: Padding(
// //         padding: const EdgeInsets.all(8.0),
// //         child: SingleChildScrollView(
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Center(
// //                 child: Text(
// //                   '${widget.shopModel!.name}',
// //                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
// //                 ),
// //               ),
// //               Center(
// //                 child: Text(
// //                   '${widget.shopModel!.contact}',
// //                   style: TextStyle(fontSize: 16),
// //                 ),
// //               ),
// //               Center(
// //                 child: Text('...............................................................'),
// //               ),
// //               SizedBox(height: 10),
// //               Row(
// //                 children: [
// //                   Expanded(
// //                     flex: 6,
// //                     child: Text(
// //                       '${getTranslated('invoice', context)!.toUpperCase()}#${widget.orderId}',
// //                       style: TextStyle(decoration: TextDecoration.underline),
// //                     ),
// //                   ),
// //                   Expanded(
// //                     flex: 6,
// //                     child: Text(
// //                       getTranslated('payment_method', context)!,
// //                       textAlign: TextAlign.right,
// //                       style: TextStyle(decoration: TextDecoration.underline),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               Row(
// //                 children: [
// //                   Expanded(
// //                     flex: 6,
// //                     child: Text(
// //                       DateConverter.dateTimeStringToMonthAndTime(widget.invoice!.createdAt!),
// //                     ),
// //                   ),
// //                   Expanded(
// //                     flex: 6,
// //                     child: Text(
// //                       'Cash',
// //                       textAlign: TextAlign.right,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               SizedBox(height: 10),
// //               Row(
// //                 children: [
// //                   Expanded(
// //                     flex: 2,
// //                     child: Text(
// //                       getTranslated('sl', context)!.toUpperCase(),
// //                     ),
// //                   ),
// //                   Expanded(
// //                     flex: 6,
// //                     child: Text(
// //                       getTranslated('product_info', context)!,
// //                     ),
// //                   ),
// //                   Expanded(
// //                     flex: 1,
// //                     child: Text(
// //                       getTranslated('qty', context)!,
// //                       textAlign: TextAlign.right,
// //                     ),
// //                   ),
// //                   Expanded(
// //                     flex: 3,
// //                     child: Text(
// //                       getTranslated('price', context)!,
// //                       textAlign: TextAlign.right,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               Center(
// //                 child: Text('...............................................................'),
// //               ),
// //               Column(
// //                 children: widget.invoice!.details!.map((detail) {
// //                   return Row(
// //                     children: [
// //                       Expanded(
// //                         flex: 1,
// //                         child: Text(
// //                           '${widget.invoice!.details!.indexOf(detail) + 1}',
// //                         ),
// //                       ),
// //                       Expanded(
// //                         flex: 7,
// //                         child: Text(
// //                           '${detail.productDetails!.name}',
// //                         ),
// //                       ),
// //                       Expanded(
// //                         flex: 1,
// //                         child: Text(
// //                           detail.qty.toString(),
// //                           textAlign: TextAlign.right,
// //                         ),
// //                       ),
// //                       Expanded(
// //                         flex: 3,
// //                         child: Text(
// //                           '${detail.price}',
// //                           textAlign: TextAlign.right,
// //                         ),
// //                       ),
// //                     ],
// //                   );
// //                 }).toList(),
// //               ),
// //               Center(
// //                 child: Text('...............................................................'),
// //               ),
// //               Row(
// //                 children: [
// //                   Expanded(
// //                     flex: 6,
// //                     child: Text(
// //                       getTranslated('subtotal', context)!,
// //                     ),
// //                   ),
// //                   Expanded(
// //                     flex: 6,
// //                     child: Text(
// //                       '${widget.invoice!.orderAmount}',
// //                       textAlign: TextAlign.right,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               Row(
// //                 children: [
// //                   Expanded(
// //                     flex: 6,
// //                     child: Text(
// //                       getTranslated('product_discount', context)!,
// //                     ),
// //                   ),
// //                   Expanded(
// //                     flex: 6,
// //                     child: Text(
// //                       '${widget.discountProduct}',
// //                       textAlign: TextAlign.right,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               Row(
// //                 children: [
// //                   Expanded(
// //                     flex: 12,
// //                     child: Text(
// //                       getTranslated('coupon_discount', context)!,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               Row(
// //                 children: [
// //                   Expanded(
// //                     flex: 6,
// //                     child: Text(
// //                       getTranslated('extra_discount', context)!,
// //                     ),
// //                   ),
// //                   Expanded(
// //                     flex: 6,
// //                     child: Text(
// //                       '${widget.invoice!.extraDiscount}',
// //                       textAlign: TextAlign.right,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               Row(
// //                 children: [
// //                   Expanded(
// //                     flex: 12,
// //                     child: Text(
// //                       getTranslated('tax', context)!,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               Center(
// //                 child: Text('...............................................................'),
// //               ),
// //               Row(
// //                 children: [
// //                   Expanded(
// //                     flex: 6,
// //                     child: Text(
// //                       getTranslated('total', context)!,
// //                     ),
// //                   ),
// //                   Expanded(
// //                     flex: 6,
// //                     child: Text(
// //                       '${widget.total - widget.discountProduct}',
// //                       textAlign: TextAlign.right,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               Row(
// //                 children: [
// //                   Expanded(
// //                     flex: 6,
// //                     child: Text(
// //                       getTranslated('change', context)!,
// //                     ),
// //                   ),
// //                   Expanded(
// //                     flex: 6,
// //                     child: Text(
// //                       '${widget.invoice!.orderAmount! - widget.total! - widget.discountProduct!}',
// //                       textAlign: TextAlign.right,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               SizedBox(height: 10),
// //               Center(
// //                 child: Text('...............................................................'),
// //               ),
// //               Center(
// //                 child: Text(
// //                   getTranslated('thank_you', context)!,
// //                   textAlign: TextAlign.center,
// //                 ),
// //               ),
// //               SizedBox(height: 20),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
