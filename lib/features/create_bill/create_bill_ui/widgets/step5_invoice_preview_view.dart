import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../controllers/create_bill_controller.dart';
import 'gst_invoice_document_view.dart';

class Step5InvoicePreviewView extends StatelessWidget {
  final CreateBillController controller;

  const Step5InvoicePreviewView({
    super.key,
    required this.controller,
  });

  void _openFullInvoice(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => _FullScreenInvoiceViewer(controller: controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subtitle Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n?.stepInvoicePreview ?? 'Preview Invoice / Bill',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textBody,
                letterSpacing: -0.2,
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openFullInvoice(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.fullscreen_rounded,
                        size: 16,
                        color: Color(0xFF0284C7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n?.invoicePreview ?? 'Full Invoice View',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Live Dynamic GST Invoice Document
        GstInvoiceDocumentView(controller: controller),
      ],
    );
  }
}

class _FullScreenInvoiceViewer extends StatefulWidget {
  final CreateBillController controller;

  const _FullScreenInvoiceViewer({required this.controller});

  @override
  State<_FullScreenInvoiceViewer> createState() =>
      _FullScreenInvoiceViewerState();
}

class _FullScreenInvoiceViewerState extends State<_FullScreenInvoiceViewer> {
  final TransformationController _transformController =
      TransformationController();
  double _scale = 1.0;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    setState(() {
      _scale = (_scale + 0.3).clamp(0.5, 4.0);
      _transformController.value =
          Matrix4.diagonal3Values(_scale, _scale, 1.0);
    });
  }

  void _zoomOut() {
    setState(() {
      _scale = (_scale - 0.3).clamp(0.5, 4.0);
      _transformController.value =
          Matrix4.diagonal3Values(_scale, _scale, 1.0);
    });
  }

  void _resetZoom() {
    setState(() {
      _scale = 1.0;
      _transformController.value = Matrix4.identity();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final customerName = widget.controller.walkInNameController.text.trim().isNotEmpty
        ? widget.controller.walkInNameController.text.trim()
        : (widget.controller.selectedCustomer ??
            widget.controller.customerNameController.text.trim());

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: l10n?.close ?? 'Close',
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.invoicePreview ?? 'Full Invoice Preview',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            if (customerName.isNotEmpty)
              Text(
                customerName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF94A3B8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out_rounded, color: Colors.white70, size: 22),
            onPressed: _zoomOut,
            tooltip: 'Zoom Out',
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in_rounded, color: Colors.white70, size: 22),
            onPressed: _zoomIn,
            tooltip: 'Zoom In',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 20),
            onPressed: _resetZoom,
            tooltip: 'Reset (100%)',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: InteractiveViewer(
          transformationController: _transformController,
          minScale: 0.5,
          maxScale: 4.0,
          boundaryMargin: const EdgeInsets.all(40),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: GstInvoiceDocumentView(controller: widget.controller),
            ),
          ),
        ),
      ),
    );
  }
}
