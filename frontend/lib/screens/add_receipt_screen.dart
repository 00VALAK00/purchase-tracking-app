import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/constants.dart';

class AddReceiptScreen extends StatefulWidget {
  const AddReceiptScreen({super.key});

  @override
  State<AddReceiptScreen> createState() => _AddReceiptScreenState();
}

class _AddReceiptScreenState extends State<AddReceiptScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final _fidelityCardController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _fidelityCardController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        
        // Save image to app's documents directory
        try {
          await _saveImageToDocuments(image.path);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(
               content: Text('Image saved to gallery'),
               backgroundColor: Colors.blue,
               duration: Duration(seconds: 2),
             ),
            );
          }
        } catch (e) {
          // Silent fail - image is still selected for processing
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _processReceipt() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final transactionProvider = context.read<TransactionProvider>();

      if (authProvider.token != null) {
        final success = await transactionProvider.processReceipt(
          token: authProvider.token!,
          imagePath: _selectedImage!.path,
          fidelityCardNumber: _fidelityCardController.text.trim().isEmpty
              ? null
              : _fidelityCardController.text.trim(),
        );

        if (success && mounted) {
          // Save image to app's documents directory
          try {
            await _saveImageToDocuments(_selectedImage!.path);
            ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(
               content: Text('Receipt processed and saved to gallery!'),
               backgroundColor: Colors.green,
             ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Receipt processed but failed to save: $e'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          Navigator.pop(context);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                transactionProvider.error ?? 'Failed to process receipt',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: const Text('Choose how you want to add a receipt image'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                             Icon(Icons.camera_alt),
                  SizedBox(width: 8),
                  Text('Camera'),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_library),
                  SizedBox(width: 8),
                  Text('Gallery'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveImageToDocuments(String imagePath) async {
    try {
      if (Platform.isAndroid) {
        // Try multiple locations to ensure the image is saved somewhere accessible
        List<String> savedPaths = [];
        
        // Location 1: DCIM folder (most accessible)
        try {
          final dcimDir = Directory('/storage/emulated/0/DCIM');
          if (await dcimDir.exists()) {
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final fileName = 'receipt_$timestamp.jpg';
            final savedPath = '${dcimDir.path}/$fileName';
            
            await File(imagePath).copy(savedPath);
            savedPaths.add(savedPath);
            print('✅ Saved to DCIM: $savedPath');
          }
        } catch (e) {
          print('❌ DCIM save failed: $e');
        }
        
        // Location 2: Pictures folder
        try {
          final picturesDir = Directory('/storage/emulated/0/Pictures');
          if (await picturesDir.exists()) {
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final fileName = 'receipt_$timestamp.jpg';
            final savedPath = '${picturesDir.path}/$fileName';
            
            await File(imagePath).copy(savedPath);
            savedPaths.add(savedPath);
            print('✅ Saved to Pictures: $savedPath');
          }
        } catch (e) {
          print('❌ Pictures save failed: $e');
        }
        
        // Location 3: Downloads folder
        try {
          final downloadsDir = Directory('/storage/emulated/0/Download');
          if (await downloadsDir.exists()) {
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final fileName = 'receipt_$timestamp.jpg';
            final savedPath = '${downloadsDir.path}/$fileName';
            
            await File(imagePath).copy(savedPath);
            savedPaths.add(savedPath);
            print('✅ Saved to Downloads: $savedPath');
          }
        } catch (e) {
          print('❌ Downloads save failed: $e');
        }
        
        if (savedPaths.isEmpty) {
          throw Exception('Failed to save image to any accessible location');
        }
        
        // Force media scan for all saved locations
        for (String path in savedPaths) {
          try {
            await _forceMediaScan(path);
          } catch (e) {
            print('Media scan failed for $path: $e');
          }
        }
        
        print('🎉 Image saved to ${savedPaths.length} locations: $savedPaths');
      } else {
        // For iOS, save to app documents directory
        final documentsDir = await getApplicationDocumentsDirectory();
        final receiptsDir = Directory('${documentsDir.path}/receipts');
        
        if (!await receiptsDir.exists()) {
          await receiptsDir.create(recursive: true);
        }
        
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'receipt_$timestamp.jpg';
        final savedPath = '${receiptsDir.path}/$fileName';
        
        await File(imagePath).copy(savedPath);
      }
    } catch (e) {
      throw Exception('Failed to save image: $e');
    }
  }

  Future<void> _forceMediaScan(String filePath) async {
    try {
      const platform = MethodChannel('com.example.purchase_tracking_app/media_scan');
      await platform.invokeMethod('forceScan', {'path': filePath});
    } catch (e) {
      // If platform channel fails, the image is still saved to DCIM
      // and should appear in gallery after a few seconds
      print('Media scan failed: $e');
    }
  }

  // Backup method: Save to Pictures folder which is also scanned by gallery
  Future<void> _saveToPicturesFolder(String imagePath) async {
    try {
      final picturesDir = Directory('/storage/emulated/0/Pictures');
      if (!await picturesDir.exists()) {
        await picturesDir.create(recursive: true);
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'receipt_$timestamp.jpg';
      final savedPath = '${picturesDir.path}/$fileName';
      
      await File(imagePath).copy(savedPath);
      print('Backup save to Pictures: $savedPath');
    } catch (e) {
      print('Backup save failed: $e');
    }
  }

  // Test method to check gallery access
  Future<void> _testGalleryAccess() async {
    try {
      List<String> results = [];
      
      // Test DCIM directory
      try {
        final dcimDir = Directory('/storage/emulated/0/DCIM');
        final dcimExists = await dcimDir.exists();
        if (dcimExists) {
          final files = await dcimDir.list().toList();
          results.add('DCIM: ✅ (${files.length} files)');
          print('DCIM accessible with ${files.length} files');
        } else {
          results.add('DCIM: ❌ Not accessible');
        }
      } catch (e) {
        results.add('DCIM: ❌ Error: $e');
      }
      
      // Test Pictures directory
      try {
        final picturesDir = Directory('/storage/emulated/0/Pictures');
        final picturesExists = await picturesDir.exists();
        if (picturesExists) {
          final files = await picturesDir.list().toList();
          results.add('Pictures: ✅ (${files.length} files)');
          print('Pictures accessible with ${files.length} files');
        } else {
          results.add('Pictures: ❌ Not accessible');
        }
      } catch (e) {
        results.add('Pictures: ❌ Error: $e');
      }
      
      // Test Downloads directory
      try {
        final downloadsDir = Directory('/storage/emulated/0/Download');
        final downloadsExists = await downloadsDir.exists();
        if (downloadsExists) {
          final files = await downloadsDir.list().toList();
          results.add('Downloads: ✅ (${files.length} files)');
          print('Downloads accessible with ${files.length} files');
        } else {
          results.add('Downloads: ❌ Not accessible');
        }
      } catch (e) {
        results.add('Downloads: ❌ Error: $e');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(results.join('\n')),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 8),
          ),
        );
      }
      
      print('Gallery access test completed');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gallery test failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Check if images were actually saved
  Future<void> _checkSavedImages() async {
    try {
      List<String> results = [];
      
      // Check DCIM for receipt images
      try {
        final dcimDir = Directory('/storage/emulated/0/DCIM');
        if (await dcimDir.exists()) {
          final files = await dcimDir.list().toList();
          final receiptFiles = files.where((f) => f.path.contains('receipt_')).toList();
          results.add('DCIM receipts: ${receiptFiles.length}');
          for (var file in receiptFiles) {
            print('Found receipt: ${file.path}');
          }
        }
      } catch (e) {
        results.add('DCIM check failed: $e');
      }
      
      // Check Pictures for receipt images
      try {
        final picturesDir = Directory('/storage/emulated/0/Pictures');
        if (await picturesDir.exists()) {
          final files = await picturesDir.list().toList();
          final receiptFiles = files.where((f) => f.path.contains('receipt_')).toList();
          results.add('Pictures receipts: ${receiptFiles.length}');
          for (var file in receiptFiles) {
            print('Found receipt: ${file.path}');
          }
        }
      } catch (e) {
        results.add('Pictures check failed: $e');
      }
      
      // Check Downloads for receipt images
      try {
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (await downloadsDir.exists()) {
          final files = await downloadsDir.list().toList();
          final receiptFiles = files.where((f) => f.path.contains('receipt_')).toList();
          results.add('Downloads receipts: ${receiptFiles.length}');
          for (var file in receiptFiles) {
            print('Found receipt: ${file.path}');
          }
        }
      } catch (e) {
        results.add('Downloads check failed: $e');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(results.join('\n')),
            backgroundColor: Colors.teal,
            duration: const Duration(seconds: 8),
          ),
        );
      }
      
      print('Saved images check completed');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Check failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveToGallery() async {
    if (_selectedImage == null) return;
    
    try {
      await _saveImageToDocuments(_selectedImage!.path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(
               content: Text('Image saved to gallery successfully!'),
               backgroundColor: Colors.green,
             ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundColor),
      appBar: AppBar(
        title: const Text('Add Receipt'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            const Text(
              'Upload Receipt',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Take a photo or select from gallery to process your receipt',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Image Selection Area
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      child: Stack(
                        children: [
                          Image.file(
                            _selectedImage!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectedImage = null;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No image selected',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap the button below to add a receipt image',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            // Select Image Button
            ElevatedButton.icon(
              onPressed: _showImageSourceDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.buttonHeight / 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
              icon: const Icon(Icons.add_a_photo),
              label: const Text(
                'Select Image',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 24),

                        // Save to Gallery Button (only show when image is selected)
            if (_selectedImage != null) ...[
              ElevatedButton.icon(
                onPressed: () => _saveToGallery(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.buttonHeight / 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                ),
                icon: const Icon(Icons.save_alt),
                                 label: const Text(
                   'Save to Gallery',
                   style: TextStyle(
                     fontSize: 18,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
               ),
               const SizedBox(height: 16),
               
                               // Test Gallery Access Button
                ElevatedButton.icon(
                  onPressed: () => _testGalleryAccess(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.buttonHeight / 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                  ),
                  icon: const Icon(Icons.photo_library),
                  label: const Text(
                    'Test Gallery Access',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Check Saved Images Button
                ElevatedButton.icon(
                  onPressed: () => _checkSavedImages(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.buttonHeight / 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                  ),
                  icon: const Icon(Icons.search),
                  label: const Text(
                    'Check Saved Images',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
               const SizedBox(height: 24),
             ],

            // Fidelity Card Number (Optional)
            TextField(
              controller: _fidelityCardController,
              decoration: const InputDecoration(
                labelText: 'Fidelity Card Number (Optional)',
                prefixIcon: Icon(Icons.card_giftcard),
                border: OutlineInputBorder(),
                hintText: 'Enter your loyalty card number',
              ),
            ),

            const SizedBox(height: 32),

            // Process Button
            Consumer<TransactionProvider>(
              builder: (context, transactionProvider, child) {
                return ElevatedButton(
                  onPressed: (_selectedImage != null && !_isProcessing)
                      ? _processReceipt
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.buttonHeight / 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                  ),
                  child: _isProcessing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Processing...'),
                          ],
                        )
                      : const Text(
                          'Process Receipt',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Info Text
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your receipt will be processed using OCR technology to extract purchase details automatically.',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
