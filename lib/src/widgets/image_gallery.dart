import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../conditional/conditional.dart';
import '../models/preview_image.dart';

class ImageGallery extends StatelessWidget {
  const ImageGallery({
    super.key,
    this.imageHeaders,
    this.imageProviderBuilder,
    required this.images,
    required this.onClosePressed,
    this.options = const ImageGalleryOptions(),
    required this.pageController,
  });

  /// See [Chat.imageHeaders].
  final Map<String, String>? imageHeaders;

  /// See [Chat.imageProviderBuilder].
  final ImageProvider Function({
    required String uri,
    required Map<String, String>? imageHeaders,
    required Conditional conditional,
  })? imageProviderBuilder;

  /// Images to show in the gallery.
  final List<PreviewImage> images;

  /// Triggered when the gallery is swiped down or closed via the icon.
  final VoidCallback onClosePressed;

  /// Customisation options for the gallery.
  final ImageGalleryOptions options;

  /// Page controller for the image pages.
  final PageController pageController;

  Widget _imageGalleryLoadingBuilder(ImageChunkEvent? event) => Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            value: event == null || event.expectedTotalBytes == null
                ? 0
                : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => PopScope(
        onPopInvoked: (didPop) {
          if (didPop) {
            onClosePressed();
          }
        },
        child: Dismissible(
          key: const Key('photo_view_gallery'),
          direction: DismissDirection.down,
          onDismissed: (direction) => onClosePressed(),
          child: GestureDetector(
            onTap: onClosePressed,
            child: Stack(
              children: [
                PhotoViewGallery.builder(
                  builder: (BuildContext context, int index) =>
                      PhotoViewGalleryPageOptions(
                    imageProvider: imageProviderBuilder != null
                        ? imageProviderBuilder!(
                            uri: images[index].uri,
                            imageHeaders: imageHeaders,
                            conditional: Conditional(),
                          )
                        : Conditional().getProvider(
                            images[index].uri,
                            headers: imageHeaders,
                          ),
                    minScale: options.minScale,
                    maxScale: options.maxScale,
                  ),
                  Positioned.directional(
                    end: 16,
                    textDirection: Directionality.of(context),
                    top: 56,
                    child: CloseButton(
                      color: Colors.white,
                      onPressed: onClosePressed,
                    ),
                  ),
                  ...options.imageOptions(context,images,pageController),
                ),
              ],
            ),
          ),
        )
      ),
}

class ImageGalleryOptions {
  const ImageGalleryOptions({
    this.maxScale,
    this.minScale,
    this.imageOptions,
  });

  final dynamic imageOptions;

  /// See [PhotoViewGalleryPageOptions.maxScale].
  final dynamic maxScale;

  /// See [PhotoViewGalleryPageOptions.minScale].
  final dynamic minScale;
}
